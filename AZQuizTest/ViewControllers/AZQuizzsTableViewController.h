//
//  AZQuizzsTableViewController.h
//  AZQuizTest
//
//  Created by andrei zeniukevich on 12/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZDataManager.h"


@interface AZQuizzsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@end
