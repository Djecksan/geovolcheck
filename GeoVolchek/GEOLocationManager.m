//
//  GEOLocationManager.m
//  GeoVolchek
//
//  Created by e.Tulenev on 20.04.15.
//  Copyright (c) 2015 MaximumSoft. All rights reserved.
//

#import "GEOLocationManager.h"
@import UIKit;

@interface GEOLocationManager()
@property (nonatomic, getter=isInBackground) BOOL inBackground;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@end

static NSInteger kMinUpdateTime = 1;
static CGFloat kMinUpdateDistance = 0.5;

@implementation GEOLocationManager

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        self.locationManager = [[CLLocationManager alloc] init];
        
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        self.locationManager.activityType = CLActivityTypeOtherNavigation;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.activityType = CLActivityTypeFitness;
        
        [self.locationManager setDelegate:self];
    }
    return self;
}

-(BOOL)isInBackground {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    return (state == UIApplicationStateBackground || state == UIApplicationStateInactive);
}

- (void)startUpdatingLocation {    
    
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self isInBackground] ? [self.locationManager requestAlwaysAuthorization] : [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self isInBackground] ? [self.locationManager startMonitoringSignificantLocationChanges] : [self.locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation {
    [self isInBackground] ? [self.locationManager stopMonitoringSignificantLocationChanges] : [self.locationManager stopUpdatingLocation];
}

-(void)applicationDidBecomeActive {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self startUpdatingLocation];
}

-(void)applicationDidEnterBackground {
    [self.locationManager stopUpdatingLocation];
    [self startUpdatingLocation];
}

- (void)endBackgroundTask {
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //фильтруем апдейты на основании минимального времени обновления и минимально дистанции
    if (oldLocation && ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < kMinUpdateTime ||
                        [newLocation distanceFromLocation:oldLocation] < kMinUpdateDistance)) {
        return;
    }
    
    if ([self isInBackground]) {
        if (self.locationUpdatedInBackground) {
            
            self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
                [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
            }];
            
            self.locationUpdatedInBackground(newLocation);
            [self endBackgroundTask];
        }
    } else {
        //если приложение активно - выполняем этот блок
        if (self.locationUpdatedInForeground) {
            self.locationUpdatedInForeground(newLocation);
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            // do some error handling
        }
            break;
        default:{
            [self isInBackground] ? [self.locationManager startMonitoringSignificantLocationChanges] : [self.locationManager startUpdatingLocation];
        }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

@end