//
//  RecentlyViewedFlickrPhotosTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/14/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "RecentlyViewedFlickrPhotosTVC.h"
#import "RecentPhotos.h"

@interface RecentlyViewedFlickrPhotosTVC ()
@end


@implementation RecentlyViewedFlickrPhotosTVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.photos = [RecentPhotos allPhotos];
}

@end
