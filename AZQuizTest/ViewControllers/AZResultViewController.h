//
//  AZResultViewController.h
//  AZQuizTest
//
//  Created by andrei zeniukevich on 16/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZResultViewController : UIViewController

@property (assign, nonatomic) NSInteger result;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

- (IBAction)actionResetQuiz:(UIButton *)sender;
- (IBAction)actionGoToQuizList:(UIButton *)sender;

@end
