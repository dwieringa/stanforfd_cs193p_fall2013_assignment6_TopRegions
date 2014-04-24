//
//  FlickrRegionsTVC.h
//  TopPlaces
//
//  Created by David Wieringa on 4/10/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "TopRegionsAppDelegate.h"

@interface FlickrRegionsTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)setupFetchedResultsController; // abstract

- (TopRegionsAppDelegate *) app;

@end
