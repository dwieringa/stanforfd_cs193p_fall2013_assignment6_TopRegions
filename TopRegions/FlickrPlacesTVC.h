//
//  FlickrPlacesTVC.h
//  TopPlaces
//
//  Created by David Wieringa on 4/10/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPlacesTVC : UITableViewController
@property (nonatomic, strong) NSArray *places;
@property (readonly, nonatomic, strong) NSArray *countries; // of Flickr countries
@property (readonly, nonatomic, strong) NSDictionary *placesByCountry; // of Flickr places NSDictionary

- (NSDictionary *)placeForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
