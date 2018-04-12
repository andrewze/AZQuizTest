//
//  AZQuizCell.h
//  AZQuizTest
//
//  Created by andrei zeniukevich on 10/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZQuizCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *quizTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *quizStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

@end
