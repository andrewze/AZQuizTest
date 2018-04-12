//
//  AZQuizzsTableViewController.m
//  AZQuizTest
//
//  Created by andrei zeniukevich on 12/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import "AZQuizzsTableViewController.h"
#import "AZServerManager.h"
#import "AZQuizCell.h"
#import "UIImageView+AFNetworking.h"

#import "AZQuiz+CoreDataClass.h"

@interface AZQuizzsTableViewController ()

@property (strong, nonatomic) NSArray* quizzsArray;

@end

@implementation AZQuizzsTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self allObjects];
}

//- (void)viewWillAppear:(BOOL)animated {
//
//    [[AZServerManager sharedManager]getQuizzsOnSuccess:^(NSArray *objectsArray) {
//
//        [self createQuizEntitiesFromArray:objectsArray];
//
//        [self.tableView reloadData];
//
//    } onFailure:nil];
//}

- (NSManagedObjectContext* ) managedObjectContext {
    return [[AZDataManager sharedManager]managedContex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) createQuizEntitiesFromArray:(NSArray*) itemsArray {
    
    for (NSDictionary* dictionary in itemsArray) {
        
        AZQuiz* quiz = [NSEntityDescription insertNewObjectForEntityForName:@"AZQuiz" inManagedObjectContext:self.managedObjectContext];
        
        quiz.title = [dictionary objectForKey:@"title"];
        quiz.createdAt = [dictionary objectForKey:@"createdAt"];
        quiz.mainPhotoURL = [[dictionary objectForKey:@"mainPhoto"]objectForKey:@"url"];
        
    }
    [[AZDataManager sharedManager]saveContext];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController<AZQuiz *> *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
 
    NSFetchRequest<AZQuiz *> *fetchRequest = AZQuiz.fetchRequest;
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController<AZQuiz *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

- (void) allObjects {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"AZQuiz"
                inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    NSLog(@"count %ld", resultArray.count);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"quizCell";
    
    AZQuizCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    AZQuiz* quiz = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.quizTitleLabel.text = quiz.title;
    
//    if (quiz.mainPhotoURL) {
//
//        __weak AZQuizCell* weakCell = cell;
//
//        NSURL* backgroundImageURL = [[NSURL alloc]initWithString:quiz.mainPhotoURL];
//        NSURLRequest* imageRequest = [NSURLRequest requestWithURL:backgroundImageURL];
//
//        [cell.mainImage setImageWithURLRequest:imageRequest
//                                  placeholderImage:nil
//                                           success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//
//                                               weakCell.mainImage.image = image;
//                                               [weakCell layoutSubviews];
//
//                                           } failure:nil];
//        }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.view.frame.size.width / 1.5f);
}

@end
