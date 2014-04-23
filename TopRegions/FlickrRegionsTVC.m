//
//  FlickrRegionsTVC.m
//  TopRegions
//
//  Created by David Wieringa on 4/10/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "FlickrRegionsTVC.h"
#import "FlickrFetcher.h"
#import "RegionFlickrPhotosTVC.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosLoaded.h"
#import "Region.h"

@interface FlickrRegionsTVC ()

@end

@implementation FlickrRegionsTVC

- (void)awakeFromNib
{
    // Obtain database context
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                               object:nil
                                                queue:nil
                                           usingBlock:^(NSNotification *note) {
                                               self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                           }] ;

    [[NSNotificationCenter defaultCenter] addObserverForName:PhotosLoadedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self performFetch];
                                                  }] ;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Region Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    // Configure the cell...
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photographers", [region.numberOfPhotographers intValue]];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareRegionTableViewController:(RegionFlickrPhotosTVC *)pvc toDisplayRegion:(Region *)region
{
    pvc.region = region;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Select Region"]) {
                if ([segue.destinationViewController isKindOfClass:[RegionFlickrPhotosTVC class]]) {
                    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    [self prepareRegionTableViewController:segue.destinationViewController toDisplayRegion:region  ];
                }
            }
        }
    }
}

@end
