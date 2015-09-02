//
//  ABFRealmSearchViewController.m
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 6/1/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "ABFRealmSearchViewController.h"

#import <Realm/Realm.h>
#import <RBQFetchedResultsController/RBQFetchedResultsController.h>
#import <RBQFetchedResultsController/RBQFetchRequest.h>

@interface ABFRealmSearchViewController () <UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) RBQFetchedResultsController *fetchResultsController;

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSOperationQueue *searchQueue;

@property (strong, nonatomic) RLMRealmConfiguration *realmConfiguration;

@end

@implementation ABFRealmSearchViewController

#pragma mark - UIKit

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef DEBUG
    NSAssert(self.resultsDataSource, @"No data source set!");
    NSAssert(self.entityName, @"EntityName not set!");
    NSAssert(self.searchPropertyKeyPath, @"SearchPropertyKeyPath not set!");
#endif
    
    if (self.searchBarInTableView) {
        
        self.tableView.tableHeaderView = self.searchBar;
        
        [self.searchBar sizeToFit];
    }
    
    self.definesPresentationContext = YES;
    
    // Create the base fetch request (nil predicate will return all restaurants)
    RBQFetchRequest *baseFetch = [self searchFetchRequestWithEntityName:self.entityName
                                                                inRealm:self.realm
                                                              predicate:self.basePredicate];
    
    // Create the fetch results controller
    self.fetchResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:baseFetch
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
    
    // Trigger the fetch
    [self.fetchResultsController performFetch];
}

#pragma mark - ABFRealmSearchViewController Initializiation

- (instancetype)initWithEntityName:(NSString *)entityName
             searchPropertyKeyPath:(NSString *)keyPath
{
    return [self initWithEntityName:entityName
                            inRealm:[RLMRealm defaultRealm]
              searchPropertyKeyPath:keyPath
                      basePredicate:nil
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
{
    return [self initWithEntityName:entityName
                            inRealm:realm
              searchPropertyKeyPath:keyPath
                      basePredicate:nil
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate
{
    return [self initWithEntityName:entityName
                            inRealm:[RLMRealm defaultRealm]
              searchPropertyKeyPath:keyPath
                      basePredicate:basePredicate
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate
{
    return [self initWithEntityName:entityName
                            inRealm:realm
              searchPropertyKeyPath:keyPath
                      basePredicate:basePredicate
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate
                    tableViewStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        [self defaultInitWithEntityName:entityName
                                inRealm:realm
                  searchPropertyKeyPath:keyPath
                          basePredicate:basePredicate];
    }
    
    return self;
}

#pragma mark UITableViewController Initialization

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)defaultInitWithEntityName:(NSString *)entityName
                          inRealm:(RLMRealm *)realm
            searchPropertyKeyPath:(NSString *)keyPath
                    basePredicate:(NSPredicate *)basePredicate
{
    [self baseInit];
    
    _entityName = entityName;
    _realmConfiguration = realm.configuration;
    _searchPropertyKeyPath = keyPath;
    
    // Only use keyPath for sort if it is just a key
    if (![keyPath containsString:@"."]) {
        _sortPropertyKey = keyPath;
    }
    
    _basePredicate = basePredicate;
}

- (void)baseInit
{
    // Defaults
    _resultsDataSource = self;
    _resultsDelegate = self;
    
    _searchBarInTableView = YES;
    _useContainsSearch = NO;
    _caseInsensitiveSearch = YES;
    _sortAscending = YES;
    
    _realmConfiguration = [RLMRealmConfiguration defaultConfiguration];
    
    // Create the search controller
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    
    _searchBar = _searchController.searchBar;
    
    // Search queue
    _searchQueue = [[NSOperationQueue alloc] init];
    _searchQueue.maxConcurrentOperationCount = 1;
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    
    NSPredicate *predicate = [self searchPredicateWithText:searchString];
    
    typeof(self) __weak weakSelf = self;
    
    NSBlockOperation *searchOperation = [NSBlockOperation blockOperationWithBlock:^() {
        
        RLMRealm *realm = [RLMRealm realmWithConfiguration:weakSelf.realmConfiguration error:nil];
        
        // Create new fetch request with predicate
        RBQFetchRequest *searchFetchRequest = [weakSelf searchFetchRequestWithEntityName:weakSelf.entityName
                                                                                 inRealm:realm
                                                                               predicate:predicate];
        
        [weakSelf.fetchResultsController updateFetchRequest:searchFetchRequest
                                         sectionNameKeyPath:nil
                                             andPeformFetch:YES];
        
        // Reload table view on main threa
        dispatch_async(dispatch_get_main_queue(), ^() {
            [weakSelf.tableView reloadData];
        });
    }];
    
    // Remove any pending searches
    [self.searchQueue cancelAllOperations];
    
    // Perform the most recent search
    [self.searchQueue addOperation:searchOperation];
}

#pragma mark - <UITableViewDelegate>

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.resultsDelegate respondsToSelector:@selector(searchViewController:willSelectObject:atIndexPath:)]) {
        
        id object = [self.fetchResultsController objectAtIndexPath:indexPath];
        
        [self.resultsDelegate searchViewController:self willSelectObject:object atIndexPath:indexPath];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.resultsDelegate respondsToSelector:@selector(searchViewController:didSelectObject:atIndexPath:)]) {
        
        id object = [self.fetchResultsController objectAtIndexPath:indexPath];
        
        [self.resultsDelegate searchViewController:self didSelectObject:object atIndexPath:indexPath];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.fetchResultsController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [self.fetchResultsController numberOfRowsForSectionIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.fetchResultsController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [self.resultsDataSource searchViewController:self
                                                           cellForObject:object
                                                             atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - <ABFRealmSearchControllerDataSource>

- (UITableViewCell *)searchViewController:(ABFRealmSearchViewController *)searchViewController
                            cellForObject:(id)anObject
                              atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Getters

- (RLMRealm *)realm
{
    return [RLMRealm realmWithConfiguration:self.realmConfiguration error:nil];
}

#pragma mark - Private

- (NSPredicate *)searchPredicateWithText:(NSString *)text
{
    if (![text isEqualToString:@""]) {
        
        NSExpression *leftExpression = [NSExpression expressionForKeyPath:self.searchPropertyKeyPath];
        
        NSExpression *rightExpression = [NSExpression expressionForConstantValue:text];
        
        NSPredicateOperatorType operatorType = self.useContainsSearch ? NSContainsPredicateOperatorType : NSBeginsWithPredicateOperatorType;
        
        NSComparisonPredicateOptions options = self.caseInsensitiveSearch ? NSCaseInsensitivePredicateOption : 0;
        
        NSComparisonPredicate *filterPredicate = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                                    rightExpression:rightExpression
                                                                                           modifier:NSDirectPredicateModifier
                                                                                               type:operatorType options:options];
        
        if (self.basePredicate) {
            NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[self.basePredicate,filterPredicate]];
            
            return compoundPredicate;
        }
        
        return filterPredicate;
    }
    
    return self.basePredicate;
}

- (RBQFetchRequest *)searchFetchRequestWithEntityName:(NSString *)entityName
                                              inRealm:(RLMRealm *)realm
                                            predicate:(NSPredicate *)predicate
{
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:entityName
                                                                        inRealm:realm
                                                                      predicate:predicate];
    
    if (self.sortPropertyKey) {
        
        RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithProperty:self.sortPropertyKey
                                                                      ascending:self.sortAscending];
        
        fetchRequest.sortDescriptors = @[sort];
    }
    
    return fetchRequest;
}

@end
