//
//  PlaceFlickrPhotosTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/14/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "RegionFlickrPhotosTVC.h"

@interface RegionFlickrPhotosTVC ()

@end

@implementation RegionFlickrPhotosTVC

- (void)setRegion:(Region *)region
{
    _region = region;
    self.title = region.name;
    self.managedObjectContext = [region managedObjectContext];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"region.name = %@", self.region.name];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


@end
