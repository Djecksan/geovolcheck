//
//  ETCoreDataManager.m
//  FriendsCoreDataCoding
//
//  Created by Evgenyi Tyulenev on 11.04.15.
//  Copyright (c) 2015 iOS. All rights reserved.
//

#import "ETCoreDataManager.h"
@interface ETCoreDataManager()
@property (strong, nonatomic) NSManagedObjectContext *defaultManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation ETCoreDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self managedObjectContext];
    }
    return self;
}

+(instancetype)sharedManager {
    static ETCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ETCoreDataManager alloc] init];
    });
    return manager;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "iOS.coreData.FriendsCoreDataCoding" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FriendsCoreDataCoding" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FriendsCoreDataCoding.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _defaultManagedObjectContext = [[NSManagedObjectContext alloc]  initWithConcurrencyType:NSMainQueueConcurrencyType];
        // Добавляем наш приватный контекст отцом, чтобы дочка смогла пушить все изменения
        [_defaultManagedObjectContext setParentContext:_managedObjectContext];
    });
    
    return _managedObjectContext;
}

#pragma mark - create context

-(NSManagedObjectContext *)contextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    [context setParentContext:_defaultManagedObjectContext];
    return context;
}

- (NSManagedObjectContext *)backgroundContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:_defaultManagedObjectContext];
    return context;
}

#pragma mark - Core Data Saving support

- (void)saveInContext:(NSManagedObjectContext *)context {
    if(context.hasChanges) {
        [context performBlockAndWait:^{
            NSError *error = nil;
            [context save:&error];
            
            if(error) {
                NSLog(@"Сохранение завершилось неудачей");
            }
        }];
    }
    [self saveDefaultContext];
    
}

-(void)saveDefaultContext {
    if(_defaultManagedObjectContext.hasChanges) {
        [_defaultManagedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            [_defaultManagedObjectContext save:&error];
            
            if(error) {
                NSLog(@"Сохранение завершилось неудачей");
            }
        }];
    }
    
    // А после сохранения _defaultManagedObjectContext необходимо сохранить его родителя, то есть _daddyManagedObjectContext
    void (^saveDaddyContext) (void) = ^{
        NSError *error = nil;
        [_managedObjectContext save:&error];
        
        if(error) {
            NSLog(@"Сохранение завершилось неудачей");
        }
    };
    
    if ([_managedObjectContext hasChanges]) {
        if (wait) {
            [_managedObjectContext performBlockAndWait:saveDaddyContext];
        } else {
            [_managedObjectContext performBlock:saveDaddyContext];
        }
    }
}

@end