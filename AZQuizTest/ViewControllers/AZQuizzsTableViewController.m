//
//  AZQuizzsTableViewController.m
//  AZQuizTest
//
//  Created by andrei zeniukevich on 12/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import "AZQuizzsTableViewController.h"
#import "AZQuizViewController.h"
#import "AZServerManager.h"
#import "AZQuizCell.h"
#import "UIImageView+AFNetworking.h"

#import "AZQuiz+CoreDataClass.h"
#import "AZQuestion+CoreDataClass.h"
#import "AZAnswer+CoreDataClass.h"

@interface AZQuizzsTableViewController ()

@property (strong, nonatomic) NSArray* quizzsArray;
@property (assign, nonatomic) NSInteger selectedQuizIDNumber;
@property (strong, nonatomic) AZQuiz* selectedQuiz;
@property (strong, nonatomic) NSString* docsDirectory;

@end

@implementation AZQuizzsTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
}

//- (void)viewWillAppear:(BOOL)animated {
//
//    [super viewWillAppear:animated];
//
//    [[AZServerManager sharedManager]getQuizzsOnSuccess:^(NSArray *objectsArray) {
//    
//            [self createQuizEntitiesFromArray:objectsArray];
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
        
        AZQuiz* quiz = [[AZQuiz alloc]initWithContext:self.managedObjectContext];
        
        quiz.idNumber = [[dictionary objectForKey:@"id"]integerValue];
        quiz.title = [dictionary objectForKey:@"title"];
        quiz.createdAt = [dictionary objectForKey:@"createdAt"];
        quiz.mainPhotoURL = [[dictionary objectForKey:@"mainPhoto"]objectForKey:@"url"];
        
    }
    [[AZDataManager sharedManager]saveContext];
}

- (NSArray *) allQuizzes {
    
    NSFetchRequest* fetchRequest = AZQuiz.fetchRequest;
    
    NSSortDescriptor* sortDescription =
    [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescription]];

    NSArray* allQuizzes = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return allQuizzes;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController<AZQuiz *> *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest<AZQuiz *> *fetchRequest = AZQuiz.fetchRequest;
    
    [fetchRequest setFetchBatchSize:5];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController<AZQuiz *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                          managedObjectContext:self.managedObjectContext
                                                                                                            sectionNameKeyPath:nil
                                                                                                                     cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withQuiz:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withQuiz:anObject];
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"quizCell";
    
    AZQuizCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    AZQuiz* quiz = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self configureCell:cell withQuiz:quiz];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)configureCell: (AZQuizCell*) cell withQuiz:(AZQuiz*) quiz {
    
    cell.quizTitleLabel.text = quiz.title;
    
    if (quiz.mainPhotoURL) {
        
        __weak AZQuizCell* weakCell = cell;
        
        
        NSURL* backgroundImageURL = [[NSURL alloc]initWithString:quiz.mainPhotoURL];
        NSURLRequest* imageRequest = [NSURLRequest requestWithURL:backgroundImageURL];
        UIImage* withoutPhoto = [UIImage imageNamed:@"Nophoto.png"];
        
        [cell.mainImage setImageWithURLRequest:imageRequest
                              placeholderImage:withoutPhoto
                                       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                           
                                           weakCell.mainImage.image = image;
                                           [weakCell layoutSubviews];
                                           
                                       } failure:nil];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.view.frame.size.width / 1.5f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AZQuiz* selectedQuiz = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    self.selectedQuizIDNumber = selectedQuiz.idNumber;
    self.selectedQuiz = selectedQuiz;
    
    [self performSegueWithIdentifier:@"gotoAZQuizViewController"
                              sender:[self.fetchedResultsController
                   objectAtIndexPath:indexPath]];
}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[AZQuizViewController class]]) {
        
        AZQuizViewController* vc = segue.destinationViewController;
        
        vc.quiz = self.selectedQuiz;
    }
}

@end
