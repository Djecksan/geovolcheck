//
//  GEOLocationCell.m
//  GeoVolchek
//
//  Created by e.Tulenev on 21.04.15.
//  Copyright (c) 2015 MaximumSoft. All rights reserved.
//

#import "GEOLocationCell.h"
@import CoreData;

@interface GEOLocationCell()
@property (weak, nonatomic) IBOutlet UILabel* name;
@end

@implementation GEOLocationCell

-(void)setLocation:(NSManagedObject *)location {
    NSDictionary *loc = [location dictionaryWithValuesForKeys:@[@"timeStamp", @"latitude", @"longitude"]];
    [_name setText:[NSString stringWithFormat:@"latitude: %@\nlongitude: %@", loc[@"latitude"], loc[@"longitude"]]];
}

@end
