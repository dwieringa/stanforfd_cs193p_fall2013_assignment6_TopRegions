//
//  RecentlyViewedFlickrPhotosTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/14/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "RecentlyViewedFlickrPhotosTVC.h"
#import "PhotoDatabaseAvailability.h"

@interface RecentlyViewedFlickrPhotosTVC ()
@end


@implementation RecentlyViewedFlickrPhotosTVC

- (void)awakeFromNib
{
    // Obtain database context
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }] ;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self performFetch];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"lastView != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastView"
                                                              ascending:NO]];
    request.fetchLimit = 5;
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

@end
