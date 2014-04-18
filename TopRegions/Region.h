//
//  Region.h
//  TopRegions
//
//  Created by David Wieringa on 4/18/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSNumber * numberOfPhotographers;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Photo *photos;

@end
