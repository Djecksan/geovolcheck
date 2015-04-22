//
//  GEOLocationCell.h
//  GeoVolchek
//
//  Created by e.Tulenev on 21.04.15.
//  Copyright (c) 2015 MaximumSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObject;
@interface GEOLocationCell : UITableViewCell
-(void)setLocation:(NSManagedObject *)location;
@end
