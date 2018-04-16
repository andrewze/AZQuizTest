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

#import "AZQuestion+CoreDataClass.h"
#import "AZQuiz+CoreDataClass.h"
#import "AZAnswer+CoreDataClass.h"

@interface AZQuizViewController ()

@property (strong, nonatomic) AZQuestion* currentQuestion;
@property (strong, nonatomic) NSPredicate* currentPredicate;

@end

@implementation AZQuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"last = %hd",self.quiz.lastCompletedQuestionNumber);
    
    NSString *predicateString = [NSString stringWithFormat:@"order == %d", self.quiz.lastCompletedQuestionNumber + 1];
    self.currentPredicate = [NSPredicate predicateWithFormat:predicateString];
    
    if (!self.quiz.questions || self.currentQuestion.order == 0) {
        [self addQuestions];
    } else {
        self.currentQuestion = [[self.quiz.questions filteredSetUsingPredicate:self.currentPredicate]anyObject];
        [self showQuestionInfo];
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext* ) managedObjectContext {
    return [[AZDataManager sharedManager]managedContex];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void) addQuestions {
    
    __weak typeof(self) weakSelf = self;
    
    [[AZServerManager sharedManager]getQuizQuestionsWithQuizID:self.quiz.idNumber
                                                     OnSuccess:^(NSMutableSet *responceSet) {
                                                         
                                                         if (![self.quiz.questions isEqual:responceSet]) {

                                                             weakSelf.quiz.questions = responceSet;
                                                             weakSelf.currentQuestion = [[weakSelf.quiz.questions filteredSetUsingPredicate:self.currentPredicate]anyObject];
                                                             
                                                             [self showQuestionInfo];
                                                         }
                                                     }
                                                     onFailure:nil];
    
}

- (void) addAnswers {
    
    __weak typeof(self) weakSelf = self;
    
    [[AZServerManager sharedManager]getAnswersFromQuizID:self.quiz.idNumber
                                        toQuestionNumber:self.currentQuestion.order
                                               OnSuccess:^(NSSet *responceSet) {
                                                   
                                                   weakSelf.currentQuestion.answers = responceSet;
                                                   NSLog(@"count = %lu",self.currentQuestion.answers.count);
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
        
        NSLog(@"%@",answer.text);
        
        button.titleLabel.text = answer.text;
        
        NSLog(@"%@",button.titleLabel.text);
        
        if (answer.isCorrect) {
            button.tag = 1;
        } else {
            button.tag = 0;
        }
    }
    [self.view setNeedsDisplay];
}

#pragma mark - Actions

- (IBAction)actionChoiseAnswer:(UIButton *)sender {
    
    self.quiz.lastCompletedQuestionNumber++;
    
    NSLog(@"tag = %ld", sender.tag);
    
    if (self.quiz.lastCompletedQuestionNumber < self.quiz.questions.count) {
        [self viewWillAppear:YES];
    } else if (self.quiz.lastCompletedQuestionNumber == self.quiz.questions.count) {
        
        self.quiz.lastCompletedQuestionNumber = 0;
        NSLog(@"seccess!");
    }
}
@end
