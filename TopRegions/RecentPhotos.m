//
//  RecentPhotos.m
//  TopPlaces
//
//  Created by David Wieringa on 4/14/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "RecentPhotos.h"
#import "FlickrFetcher.h"

@implementation RecentPhotos

#define RECENT_PHOTOS_KEY @"Recent_Photos_Key"
#define RECENT_PHOTOS_MAX_NUMBER 20

+ (NSArray *)allPhotos
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTOS_KEY];
}

+ (void)addPhoto:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    
    if (!photos) photos = [NSMutableArray array];
    NSUInteger key = [photos indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[photo valueForKeyPath:FLICKR_PHOTO_ID] isEqualToString:[obj valueForKeyPath:FLICKR_PHOTO_ID]];
    }];
    if (key != NSNotFound) [photos removeObjectAtIndex:key];
    
    [photos insertObject:photo atIndex:0];
    while ([photos count] > RECENT_PHOTOS_MAX_NUMBER) {
        [photos removeLastObject];
    }
    
    [defaults setObject:photos forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}
@end
