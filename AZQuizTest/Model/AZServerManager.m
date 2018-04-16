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
#import "AZAnswer+CoreDataClass.h"
#import "AZQuestion+CoreDataClass.h"

@interface AZServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager* operationManager;
@property (strong, nonatomic) NSArray* itemsArray;
@property (strong, nonatomic) NSString* GETQuizzesURLString;
@property (strong, nonatomic) NSString* GETQuizURLString;

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
        self.itemsArray = [NSArray array];
        self.GETQuizzesURLString = @"http://quiz.o2.pl/api/v1/quizzes/0/100";
        self.GETQuizURLString = @"http://quiz.o2.pl/api/v1/quiz/";
        
    }
    return self;
}

- (void) getQuizzsOnSuccess:(void (^)(NSArray *))success
                  onFailure:(void (^)(NSError *, NSInteger))failure {
    
    [self.operationManager GET:self.GETQuizzesURLString
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                  
                           self.itemsArray = [responseObject objectForKey:@"items"];

                           if (success) {
                               success(self.itemsArray);
                           }
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           
                           if (failure) {
                               NSHTTPURLResponse* htttpResponse = (NSHTTPURLResponse *)task;
                               failure(error,htttpResponse.statusCode);
                           }
                       }];  
}

- (void) getQuizQuestionsWithQuizID:(NSUInteger) idNumber
                          OnSuccess:(void (^)(NSMutableSet *))success
                          onFailure:(void (^)(NSError *, NSInteger))failure {
    
    [self.operationManager GET:[self.GETQuizURLString stringByAppendingString:[NSString stringWithFormat:@"%ld/0",idNumber]]
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           
                           NSArray* questionObjectsArray = [responseObject objectForKey:@"questions"];
                           
                           NSMutableSet* questionsSet = [NSMutableSet set];
                           
                           for (NSDictionary* dict in questionObjectsArray) {
                               
                               AZQuestion* question = [[AZQuestion alloc]initWithContext:[[AZDataManager sharedManager]managedContex]];
                               
                               question.text = [dict objectForKey:@"text"];
                               question.order = [[dict objectForKey:@"order"]integerValue];
                               
                               [questionsSet addObject:question];
                           }
                           [[AZDataManager sharedManager]saveContext];

                           if (success) {
                               success(questionsSet);
                           }
                           
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           
                           if (failure) {
                               NSHTTPURLResponse* htttpResponse = (NSHTTPURLResponse *)task;
                               failure(error,htttpResponse.statusCode);
                           }
                       }];
}

- (void) getAnswersFromQuizID:(NSUInteger) idNumber toQuestionNumber:(NSUInteger) questionNumber
             OnSuccess:(void (^)(NSSet *))success
             onFailure:(void (^)(NSError *, NSInteger))failure {
    
    [self.operationManager GET:[self.GETQuizURLString stringByAppendingString:[NSString stringWithFormat:@"%ld/0",idNumber]]
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                           NSArray* answersArray = [[[responseObject objectForKey:@"questions"]objectAtIndex:questionNumber]objectForKey:@"answers"];
                           NSMutableSet* answersSet = [NSMutableSet set];
                           
                           for (NSDictionary* dict in answersArray) {
                               
                               AZAnswer* answer = [[AZAnswer alloc]initWithContext:[[AZDataManager sharedManager]managedContex]];
                               
                               answer.text = [dict objectForKey:@"text"];
                               answer.isCorrect = [dict objectForKey:@"isCorrect"];
                               
                               [answersSet addObject:answer];   
                           }

                           if (success) {
                               success(answersSet);
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
