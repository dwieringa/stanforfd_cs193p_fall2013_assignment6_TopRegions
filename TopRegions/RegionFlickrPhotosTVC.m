//
//  PlaceFlickrPhotosTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/14/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "RegionFlickrPhotosTVC.h"
#import "FlickrFetcher.h"

@interface RegionFlickrPhotosTVC ()

@end

@implementation RegionFlickrPhotosTVC

- (void)setRegion:(NSDictionary *)region
{
    _region = region;
    self.title = [self.region valueForKey:@"title"];
    [self fetchPhotos];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

// this method is called when the user selects a place,
//   but also when the user "pulls down" on the table view
//   (because this is the action of self.tableView.refreshControl)

- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing]; // start the spinner
    NSString *placeid = [self.region valueForKey:FLICKR_PLACE_ID];
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:placeid maxResults:50];
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        // convert it to a Property List (NSArray and NSDictionary)
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        // get the NSArray of photo NSDictionarys out of the results
        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.photos = photos;
        });
    });
}


@end
