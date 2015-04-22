//
//  ETCoreDataManager.h
//  FriendsCoreDataCoding
//
//  Created by Evgenyi Tyulenev on 11.04.15.
//  Copyright (c) 2015 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ETCoreDataManager : NSObject
+ (instancetype)sharedManager;
- (void)saveDefaultContext;
- (void)saveInContext:(NSManagedObjectContext *)context;
- (NSManagedObjectContext *)backgroundContext;
@end
