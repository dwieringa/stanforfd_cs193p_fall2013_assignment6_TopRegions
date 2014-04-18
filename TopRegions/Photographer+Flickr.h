//
//  Photographer+Flickr.h
//  TopRegions
//
//  Created by David Wieringa on 4/18/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Flickr)

+ (Photographer *)photographerWithName:(NSString *)name
                 inManagedObjectContext:(NSManagedObjectContext *)context;

@end
