//
//  AZServerManager.h
//  AZQuizTest
//
//  Created by andrei zeniukevich on 11/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZServerManager : NSObject

+ (AZServerManager*) sharedManager;

- (void) getQuizzsOnSuccess:(void (^)(NSArray *))success
                  onFailure:(void (^)(NSError *, NSInteger))failure;

@end
