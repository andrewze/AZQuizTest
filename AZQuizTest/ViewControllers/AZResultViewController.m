//
//  AZResultViewController.m
//  AZQuizTest
//
//  Created by andrei zeniukevich on 16/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import "AZResultViewController.h"

@interface AZResultViewController ()

@end

@implementation AZResultViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.resultLabel.text = [NSString stringWithFormat:@"%ld %%",self.result];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)actionResetQuiz:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionGoToQuizList:(UIButton *)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
