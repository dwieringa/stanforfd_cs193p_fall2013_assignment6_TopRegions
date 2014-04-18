//
//  TopRegionsAppDelegate.m
//  TopRegions
//
//  Created by David Wieringa on 4/17/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "TopRegionsAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"

@interface TopRegionsAppDelegate() <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@end

@implementation TopRegionsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Obtain UIManagedContext (via UIManagedDocument)
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"couldn't open document at %@", url);
        }];
    } else {
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"couldn't create document at %@", url);
        }];
    }

    
    // Override point for customization after application launch.
    return YES;
}

- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.photoDatabaseContext = self.document.managedObjectContext;
        [self fetchPhotos];
    } else {
        NSLog(@"trouble in documentIsReady. Check/handle document states");
    }
}

- (void)fetchPhotos
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // start the spinner
    NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResult = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                            options:0
                                                                              error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Flickr results = %@", propertyListResults);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // stop the spinner
            [Photo loadPhotosFromFlickrArray:[propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS]
                    intoManagedObjectContext:self.photoDatabaseContext];
        });
    });
}

- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    _photoDatabaseContext = photoDatabaseContext;
    
    NSDictionary *userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext : self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

@end
