//
//  GEOLocationManager.h
//  GeoVolchek
//
//  Created by e.Tulenev on 20.04.15.
//  Copyright (c) 2015 MaximumSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

typedef void(^locationHandler)(CLLocation *location);

@interface GEOLocationManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) locationHandler locationUpdatedInForeground;
@property (nonatomic, copy) locationHandler locationUpdatedInBackground;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)endBackgroundTask;

@end
