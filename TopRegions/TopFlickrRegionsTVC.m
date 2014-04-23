//
//  TopFlickrPlacesTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/10/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "TopFlickrRegionsTVC.h"
#import "FlickrFetcher.h"
#import "RegionsUpdated.h"

@interface TopFlickrRegionsTVC ()

@end

@implementation TopFlickrRegionsTVC

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:RegionsUpdatedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self performFetch];
                                                  }] ;
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    request.fetchLimit = 7;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numberOfPhotographers"
                                                              ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil cacheName:nil];
}

@end
