//
//  RecentPhotos.h
//  TopPlaces
//
//  Created by David Wieringa on 4/14/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject
+ (NSArray *)allPhotos;
+ (void)addPhoto:(NSDictionary *)photo;
@end
