//
//  Photo+Flickr.m
//  TopRegions
//
//  Created by David Wieringa on 4/18/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Flickr.h"
#import "Region+Flickr.h"
#import "PhotosLoaded.h"
#import "RegionsUpdated.h"


@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches || error || ([matches count] > 1)) {
        NSLog(@"Error searching for photo in database to check if unique");
    } else if ([matches count]) {
        photo = [matches firstObject];
    } else {
        
        // create photo
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.uniqueID = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.placeID = [photoDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        if (![photo.title length]) {
            photo.title = @"Untitled";
        }
        
        // set/create photographer
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName
                                    inManagedObjectContext:context];
        
        // fetch region
        if ([photo.placeID length]) {
            [self fetchRegionForPhoto:photo
                  withPhotoDictionary:photoDictionary];
        }
    }
    
    return photo;
}

+ (void)fetchRegionForPhoto:(Photo *)photo
        withPhotoDictionary:(NSDictionary *)photoDictionary
{
    
    
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // start the spinner
    NSURL *url = [FlickrFetcher URLforInformationAboutPlace:photo.placeID];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResult = [NSData dataWithContentsOfURL:url];
        if (jsonResult == nil) {
            // sometimes we're getting nil as a result even though the URL is good and json data at URL is valid
            // it seems to be after XCode "sits" for a bit and then I come back and simulate a background fetch
            // below I'm repeating the fetch 2 more times.  It seems to work fine on the 1st retry so far.
            NSLog(@"jsonResult is nil");
            jsonResult = [NSData dataWithContentsOfURL:url];
            if (jsonResult == nil) {
                NSLog(@"jsonResult is nil AGAIN");
                jsonResult = [NSData dataWithContentsOfURL:url];
                if (jsonResult == nil) {
                    // after 3 failed attempts, give up
                    NSLog(@"jsonResult is nil AGAIN #3");
                    return;
                }
            }
        }
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                            options:0
                                                                              error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Place info = %@", propertyListResults);
//            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // stop the spinner
            NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResults];
            photo.region = [Region regionWithName:regionName
                            inManagedObjectContext:[photo managedObjectContext]];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
            request.predicate = [NSPredicate predicateWithFormat:@"any photos.region.name = %@", regionName];
            
            NSError *error;
            NSArray *matches = [[photo managedObjectContext] executeFetchRequest:request error:&error];
            
            if (!matches || error ) {
                NSLog(@"Error searching for photographers in database by region");
            } else {
                photo.region.numberOfPhotographers = @([matches count]);
                [[NSNotificationCenter defaultCenter] postNotificationName:RegionsUpdatedNotification
                                                                    object:self
                                                                  userInfo:nil];
            }
        });
    });
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photoDictionary in photos) {
        [self photoWithFlickrInfo:photoDictionary inManagedObjectContext:context];
    }
    
//    NSDictionary *userInfo = context ? @{ PhotoDatabaseAvailabilityContext : self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotosLoadedNotification
                                                        object:self
                                                      userInfo:nil];
}

@end
