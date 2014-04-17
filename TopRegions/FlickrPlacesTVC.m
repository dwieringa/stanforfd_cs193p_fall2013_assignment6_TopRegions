//
//  FlickrPlacesTVC.m
//  TopPlaces
//
//  Created by David Wieringa on 4/10/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "FlickrPlacesTVC.h"
#import "FlickrFetcher.h"

@interface FlickrPlacesTVC ()

@end

@implementation FlickrPlacesTVC

- (void)setPlaces:(NSArray *)places
{
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    NSMutableDictionary *placesByCountry = [[NSMutableDictionary alloc] init];
    for (NSDictionary *placeX in places) {
        NSMutableDictionary *place = [placeX mutableCopy];
        NSArray *locationParts = [[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@","];
        NSString *country = locationParts[locationParts.count-1];
        NSString *middlePart = @"";
        if (locationParts.count == 3) {
            middlePart = locationParts[1];
        }
        place[@"title"] = locationParts[0];
        place[@"subtitle"] = middlePart;
        NSMutableArray *placesInCountry = [placesByCountry objectForKey:country];
        if (placesInCountry == nil) {
            [countries addObject:country];
            placesInCountry = [[NSMutableArray alloc] init];
        }
        [placesInCountry addObject:place];
        placesByCountry[country] = placesInCountry;
    }
    _countries = [countries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    //sort places within countries
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title"  ascending:YES];
    for (NSString *country in countries) {
        //placesByCountry[country] = [ sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *places = placesByCountry[country];
        placesByCountry[country] = [places sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        //recent = [stories copy];
    }
    _placesByCountry = placesByCountry;
    [self.tableView reloadData];
}

- (NSDictionary *)placeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *country = self.countries[indexPath.section];
    NSArray *placesInCountry = self.placesByCountry[country];
    NSDictionary *place = placesInCountry[indexPath.row];
    return place;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.placesByCountry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *country = self.countries[section];
    NSArray *placesInCountry = self.placesByCountry[country];
    return placesInCountry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *place = [self placeForRowAtIndexPath:indexPath];
    cell.textLabel.text = [place valueForKeyPath:@"title"];
    cell.detailTextLabel.text = [place valueForKeyPath:@"subtitle"];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.countries[section];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
