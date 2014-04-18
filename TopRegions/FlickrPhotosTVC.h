//
//  FlickrPhotosTVC.h
//  TopPlaces
//
//  Created by David Wieringa on 4/14/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface FlickrPhotosTVC : CoreDataTableViewController

// Model of this MVC (it can be publicly set)
@property (nonatomic, strong) NSArray *photos; // of Flickr photo NSDictionary

@end
