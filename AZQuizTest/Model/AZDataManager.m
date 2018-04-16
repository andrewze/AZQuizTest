//
//  AZDataManager.m
//  AZQuizTest
//
//  Created by andrei zeniukevich on 10/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import "AZDataManager.h"

@implementation AZDataManager

@synthesize persistentContainer = _persistentContainer;

+ (AZDataManager*) sharedManager {
    
    static AZDataManager* dataManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[AZDataManager alloc]init];
    });
    
    return dataManager;
}

- (NSManagedObjectContext *)managedContex {
    
    return self.persistentContainer.viewContext;
}

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"AZQuizTest"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}



@end


