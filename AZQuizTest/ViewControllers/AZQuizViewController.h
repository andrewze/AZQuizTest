//
//  AZQuizViewController.h
//  AZQuizTest
//
//  Created by andrei zeniukevich on 13/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZDataManager.h"

@class AZQuiz;

@interface AZQuizViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *quizTitleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *quizProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *quizMainPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *quiestionLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *answerButtons;

@property (assign, nonatomic) NSUInteger executionLevel;
@property (assign, nonatomic) NSUInteger successLevel;
@property (strong, nonatomic) AZQuiz* quiz;

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

- (IBAction)actionChoiseAnswer:(UIButton *)sender;

@end
