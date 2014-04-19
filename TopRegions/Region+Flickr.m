//
//  Region+Flickr.m
//  TopRegions
//
//  Created by David Wieringa on 4/18/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "Region+Flickr.h"

@implementation Region (Flickr)

+ (Region *)regionWithName:(NSString *)name
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (error || !matches || ([matches count] > 1)) {
            NSLog(@"error checking if region exists. name=%@", name);
        } else if ([matches count]) {
            region = [matches firstObject];
        } else {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                   inManagedObjectContext:context];
            
            region.name = name;
            region.numberOfPhotographers = 0;
        }
    }
    
    return region;
 
}

@end
