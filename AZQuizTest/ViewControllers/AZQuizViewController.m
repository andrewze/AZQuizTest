//
//  AZQuizViewController.m
//  AZQuizTest
//
//  Created by andrei zeniukevich on 13/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import "AZQuizViewController.h"
#import "AZServerManager.h"
#import "AZDataManager.h"
#import "AZResultViewController.h"

#import "AZQuestion+CoreDataClass.h"
#import "AZQuiz+CoreDataClass.h"
#import "AZAnswer+CoreDataClass.h"

@interface AZQuizViewController ()

@property (strong, nonatomic) AZQuestion* currentQuestion;
@property (strong, nonatomic) NSPredicate* currentPredicate;
@property (assign, nonatomic) float procentSuccessForOneQuestion;

@end

@implementation AZQuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"self.quiz.lastCompletedQuestionNumber = %i",self.quiz.lastCompletedQuestionNumber);
    NSLog(@"self.quiz.questions.count = %ld",self.quiz.questions.count);
    
    NSString *predicateString = [NSString stringWithFormat:@"order == %d", self.quiz.lastCompletedQuestionNumber + 1];
    self.currentPredicate = [NSPredicate predicateWithFormat:predicateString];
    
    if (!self.quiz.questions || self.currentQuestion.order == 0) {
        [self addQuestions];
    } else {
        self.currentQuestion = [[self.quiz.questions filteredSetUsingPredicate:self.currentPredicate]anyObject];
        [self showQuestionInfo];
        
        if (self.procentSuccessForOneQuestion == 0) {
            self.procentSuccessForOneQuestion = 100 / self.quiz.questions.count;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext* ) managedObjectContext {
    return [[AZDataManager sharedManager]managedContex];
}

#pragma mark - Set data

- (void) addQuestions {
    
    __weak typeof(self) weakSelf = self;
    
    [[AZServerManager sharedManager]getQuizQuestionsWithQuizID:self.quiz.idNumber
                                                     OnSuccess:^(NSMutableSet *responceSet) {
                                                         
                                                         if (![self.quiz.questions isEqual:responceSet]) {

                                                             weakSelf.quiz.questions = responceSet;
                                                             weakSelf.currentQuestion = [[weakSelf.quiz.questions filteredSetUsingPredicate:self.currentPredicate]anyObject];
                                                             
                                                             if (self.procentSuccessForOneQuestion == 0) {
                                                                 self.procentSuccessForOneQuestion = 100 / self.quiz.questions.count;
                                                             }
                                                             
                                                             [self showQuestionInfo];
                                                         }
                                                     }
                                                     onFailure:nil];
    
}

- (void) addAnswers {
    
    __weak typeof(self) weakSelf = self;
    
    [[AZServerManager sharedManager]getAnswersFromQuizID:self.quiz.idNumber
                                        toQuestionNumber:self.quiz.lastCompletedQuestionNumber
                                               OnSuccess:^(NSSet *responceSet) {
                                                   
                                                   weakSelf.currentQuestion.answers = responceSet;
                                                   [self setAnswerLabels];
                                               }
                                               onFailure:nil];
    
    [[AZDataManager sharedManager]saveContext];
}

- (void) showQuestionInfo {
    
    if (!self.quizMainPhotoImageView.image) {
        
        NSURL* mainImageURL = [NSURL URLWithString:self.quiz.mainPhotoURL];
        NSData* mainImageData = [NSData dataWithContentsOfURL:mainImageURL];
        UIImage* mainImage = [UIImage imageWithData:mainImageData];
        
        self.quizMainPhotoImageView.image = mainImage;
    }
    
    self.quiestionLabel.text = self.currentQuestion.text;
    self.quizTitleLabel.text = self.quiz.title;
    self.quizProgressView.progress = (float)self.currentQuestion.order / self.quiz.questions.count;
    
    if (self.currentQuestion.answers.count == 0) {
        [self addAnswers];
    } else {
        [self setAnswerLabels];
    }
}

- (void) setAnswerLabels {
    
    NSArray* array = [self.currentQuestion.answers allObjects];
    
    for (int i = 0; i < self.answerButtons.count; i++) {
        
        UIButton* button = [self.answerButtons objectAtIndex:i];
        
        AZAnswer* answer = [array objectAtIndex:i];
        
        [button setTitle:answer.text forState:UIControlStateNormal];
        
        if (answer.isCorrect) {
            
            button.tag = 1;
            [button setBackgroundImage:[self imageWithColor:[UIColor greenColor]] forState:UIControlStateHighlighted];
            
        } else {
            
            button.tag = 0;
            [button setBackgroundImage:[self imageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
        }
    }
    [self.view setNeedsDisplay];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Actions

- (IBAction)actionChoiseAnswer:(UIButton *)sender {

    if (sender.tag == 1) {
        self.quiz.result = self.quiz.result + self.procentSuccessForOneQuestion;
    }

    if (self.quiz.lastCompletedQuestionNumber < self.quiz.questions.count - 1) {
        
        self.quiz.lastCompletedQuestionNumber++;
        [self viewWillAppear:YES];
        
    } else if (self.quiz.lastCompletedQuestionNumber == self.quiz.questions.count - 1) {
        
        self.quiz.lastCompletedQuestionNumber = 0;
        self.quiz.isCompleted = YES;
        
        [self performSegueWithIdentifier:@"gotoAZResultViewController"
                                  sender:self];
    }
}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[AZResultViewController class]]) {
        
        AZResultViewController* vc = segue.destinationViewController;
        
        vc.result = self.quiz.result;
        
        self.quiz.result = 0;
    }
}



@end
