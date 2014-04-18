//
//  Photo.h
//  TopRegions
//
//  Created by David Wieringa on 4/18/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Region;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * placeID;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) Photographer *whoTook;

@end
