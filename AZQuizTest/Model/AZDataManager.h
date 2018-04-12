//
//  AZDataManager.h
//  AZQuizTest
//
//  Created by andrei zeniukevich on 10/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AZDataManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (readonly, strong) NSManagedObjectContext* managedContex;

+ (AZDataManager*) sharedManager;
- (void)saveContext;

@end
