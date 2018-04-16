//
//  AZQuizzesTableViewController.m
//  AZQuizTest
//
//  Created by andrei zeniukevich on 12/04/2018.
//  Copyright © 2018 andrei zeniukevich. All rights reserved.
//

#import "AZQuizzesTableViewController.h"
#import "AZQuizViewController.h"
#import "AZServerManager.h"
#import "AZQuizCell.h"
#import "UIImageView+AFNetworking.h"

#import "AZQuiz+CoreDataClass.h"
#import "AZQuestion+CoreDataClass.h"
#import "AZAnswer+CoreDataClass.h"

@interface AZQuizzesTableViewController ()

@property (strong, nonatomic) NSArray* quizzsArray;
@property (assign, nonatomic) NSInteger selectedQuizIDNumber;
@property (strong, nonatomic) AZQuiz* selectedQuiz;

@end

@implementation AZQuizzesTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[AZServerManager sharedManager]getQuizzsOnSuccess:^(NSArray *objectsArray) {
        
        NSArray* quizzesInStore = [self allQuizzes];
        
        if (quizzesInStore.count != objectsArray.count) {
            [self createQuizEntitiesFromArray:objectsArray];
        }
        
    } onFailure:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

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
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController<AZQuiz *> *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest<AZQuiz *> *fetchRequest = AZQuiz.fetchRequest;
    
    [fetchRequest setFetchBatchSize:5];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    
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

- (NSArray*)allQuizzes {
    
    NSEntityDescription *entityDescription = AZQuiz.entity;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSError* requestError = nil;
    
    [request setEntity:entityDescription];
    
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    return items;;
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
    
    __weak AZQuizCell* weakCell = cell;
    
    NSURL* backgroundImageURL = [[NSURL alloc]initWithString:quiz.mainPhotoURL];
    NSURLRequest* imageRequest = [NSURLRequest requestWithURL:backgroundImageURL];
    
    cell.imageView.image = nil;
    
    [cell.mainImage setImageWithURLRequest:imageRequest
                          placeholderImage:nil
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                       
                                       weakCell.quizTitleLabel.text = quiz.title;
                                       weakCell.mainImage.image = image;

                                       if (quiz.questions.count == 0) {
                                           cell.quizStatusLabel.text = @"";
                                       } else if (quiz.isCompleted == YES) {
                                           cell.quizStatusLabel.text = [NSString stringWithFormat:@"Ostatni wynik: %hd %%", quiz.result];
                                       } else if (quiz.isCompleted == NO & quiz.questions > 0) {
                                           cell.quizStatusLabel.text = [NSString stringWithFormat:@"Quiz rozwiazany w %lu %%", quiz.lastCompletedQuestionNumber / quiz.questions.count * 100];
                                       }
                                       
                                       [weakCell layoutSubviews];
                                           
                                    } failure:nil];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.view.frame.size.width / 1.44f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AZQuiz* selectedQuiz = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    self.selectedQuizIDNumber = selectedQuiz.idNumber;
    self.selectedQuiz = selectedQuiz;
    
    [self performSegueWithIdentifier:@"gotoAZQuizViewController"
                              sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[AZQuizViewController class]]) {
        
        AZQuizViewController* vc = segue.destinationViewController;
        
        vc.quiz = self.selectedQuiz;
        
        vc.quiz.result = 0;
    }
}

@end
