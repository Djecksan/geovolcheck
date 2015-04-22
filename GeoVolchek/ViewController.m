//
//  ViewController.m
//  GeoVolchek
//
//  Created by e.Tulenev on 20.04.15.
//  Copyright (c) 2015 MaximumSoft. All rights reserved.
//

#import "ViewController.h"
#import "GEOLocationManager.h"
#import "GEOLocationCell.h"
#import "ETCoreDataManager.h"

@interface ViewController ()
@property (nonatomic, strong) GEOLocationManager *locationTracker;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableArray *displayItems;
@end

static NSString *cellIdentifier = @"geoIdentifier";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[ETCoreDataManager sharedManager] backgroundContext];
    self.locationTracker = [[GEOLocationManager alloc] init];
    self.displayItems = [NSMutableArray array];
    
    __weak GEOLocationManager *lc = self.locationTracker;
    __weak typeof(self) weakerSelf = self;
    
//    [self.locationTracker setLocationUpdatedInForeground:^ (CLLocation *location) {
//        [weakerSelf insertLocation:location];
//    }];
    
    [self.locationTracker setLocationUpdatedInBackground:^ (CLLocation *location) {
        //предположим, что у нас есть метод с completion и fail хендлерами для отправки местоположения
        NSLog(@"sendLocationToServer");
        
        [weakerSelf sendLocationToServer:location completion:^{
            [lc endBackgroundTask];
        } fail:^(NSError *fail) {
            [lc endBackgroundTask];
        }];
    }];
    
    [self.locationTracker startUpdatingLocation];
}

-(void)insertLocation:(CLLocation *)location {
    NSManagedObject *loc = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:_context];
    [loc setValuesForKeysWithDictionary:@{@"timeStamp":[NSDate date], @"latitude":[NSNumber numberWithDouble:location.coordinate.latitude], @"longitude":[NSNumber numberWithDouble:location.coordinate.longitude]}];
//  [[ETCoreDataManager sharedManager] saveInContext:weakerSelf.context];
    [self loadLocations];
}

-(void)loadLocations {
    NSEntityDescription *Location = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:Location];
    NSError *error;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    [self.displayItems setArray:results];
    [self.tableView reloadData];
}

-(void)sendLocationToServer:(CLLocation *)location
                 completion:(void (^)(void))cpmpletion
                       fail:(void (^)(NSError *fail))fail {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.alertBody = [NSString stringWithFormat:@"New location: %@", location];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    
    [self insertLocation:location];
    cpmpletion();
}

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GEOLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setLocation:_displayItems[indexPath.item]];
    return cell;
}

@end
