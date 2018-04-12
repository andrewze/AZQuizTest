//
//  AZServerManager.m
//  AZQuizTest
//
//  Created by andrei zeniukevich on 11/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import "AZServerManager.h"
#import "AZDataManager.h"
#import "AFNetworking.h"
#import "AZQuiz+CoreDataClass.h"

@interface AZServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager* operationManager;
@property (strong, nonatomic) NSArray* quizzsArray;
@property (strong, nonatomic) NSString* URLString;

@end

@implementation AZServerManager

+ (AZServerManager*) sharedManager {
    
    static AZServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AZServerManager alloc]init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.operationManager = [[AFHTTPSessionManager alloc] init];
        self.quizzsArray = [NSArray array];
        self.URLString = @"http://quiz.o2.pl/api/v1/quizzes/0/100";
    }
    return self;
}

- (void) getQuizzsOnSuccess:(void (^)(NSArray *))success
                  onFailure:(void (^)(NSError *, NSInteger))failure {
    
    [self.operationManager GET:self.URLString
                    parameters:nil progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           
                           NSString* JSONString = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:responseObject
                                                                                                                options:1
                                                                                                                  error:nil] encoding:4];
                           NSLog(@"json: %@", JSONString);
                           
                           self.quizzsArray = [responseObject objectForKey:@"items"];

                           if (success) {
                               success(self.quizzsArray);
                           }
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           
                           if (failure) {
                               
                               NSHTTPURLResponse* htttpResponse = (NSHTTPURLResponse *)task;
                               failure(error,htttpResponse.statusCode);
                           }
                       }];  
}

@end
