//
//  Photographer+Flickr.m
//  TopRegions
//
//  Created by David Wieringa on 4/18/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "Photographer+Flickr.h"

@implementation Photographer (Flickr)

+ (Photographer *)photographerWithName:(NSString *)name
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (error || !matches || ([matches count] > 1)) {
            NSLog(@"error checking if photographer exists. name=%@", name);
        } else if ([matches count]) {
            photographer = [matches firstObject];
        } else {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer"
                                                         inManagedObjectContext:context];
            
            photographer.name = name;
        }
    }
    
    return photographer;
}

@end
