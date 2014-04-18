//
//  Region+Flickr.h
//  TopRegions
//
//  Created by David Wieringa on 4/18/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "Region.h"

@interface Region (Flickr)

+ (Region *)regionWithName:(NSString *)regionName
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
