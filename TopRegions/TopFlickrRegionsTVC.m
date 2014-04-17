//
//  TopFlickrPlacesTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/10/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "TopFlickrRegionsTVC.h"
#import "FlickrFetcher.h"
#import "RegionFlickrPhotosTVC.h"

@interface TopFlickrRegionsTVC ()

@end

@implementation TopFlickrRegionsTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPlaces];
}

- (IBAction)fetchPlaces
{
    [self.refreshControl beginRefreshing]; // start the spinner
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResult = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                            options:0
                                                                              error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Flickr results = %@", propertyListResults);
            [self.refreshControl endRefreshing]; // stop the spinner
            self.regions = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)preparePlaceTableViewController:(RegionFlickrPhotosTVC *)pvc toDisplayPlace:(NSDictionary *)place
{
    pvc.region = place;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Select Place"]) {
                if ([segue.destinationViewController isKindOfClass:[RegionFlickrPhotosTVC class]]) {
                    NSDictionary *place = [self regionForRowAtIndexPath:indexPath];
                    [self preparePlaceTableViewController:segue.destinationViewController toDisplayPlace:place  ];
                }
            }
        }
    }
}


@end
