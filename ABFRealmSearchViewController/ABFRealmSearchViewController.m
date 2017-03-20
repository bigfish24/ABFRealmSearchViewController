//
//  ABFRealmSearchViewController.m
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 6/1/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "ABFRealmSearchViewController.h"

#import <Realm/Realm.h>
#import <Realm/RLMRealm_Dynamic.h>

typedef void(^ABFBlock)();

@interface ABFRealmSearchViewController () <UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) RLMNotificationToken *token;

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) RLMRealmConfiguration *realmConfiguration;

@property (assign, nonatomic) BOOL viewIsLoaded;

@end

@implementation ABFRealmSearchViewController
@synthesize sortPropertyKey = _sortPropertyKey,
results = _results;

#pragma mark - UIKit

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.searchBarInTableView) {
        
        self.tableView.tableHeaderView = self.searchBar;
        
        [self.searchBar sizeToFit];
    }
    
    self.definesPresentationContext = YES;
    
    self.viewIsLoaded = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshSearchResults];
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
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self refreshSearchResults];
}

#pragma mark - <UITableViewDelegate>

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.resultsDelegate respondsToSelector:@selector(searchViewController:willSelectObject:atIndexPath:)]) {
        
        id object = [self.results objectAtIndex:indexPath.row];
        
        [self.resultsDelegate searchViewController:self willSelectObject:object atIndexPath:indexPath];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.resultsDelegate respondsToSelector:@selector(searchViewController:didSelectObject:atIndexPath:)]) {
        
        id object = [self.results objectAtIndex:indexPath.row];
        
        [self.resultsDelegate searchViewController:self didSelectObject:object atIndexPath:indexPath];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.results objectAtIndex:indexPath.row];
    
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
    NSLog(@"You need to implement searchViewController:cellForObject:atIndexPath:");
    return nil;
}

#pragma mark - Getters

- (RLMRealm *)realm
{
    return [RLMRealm realmWithConfiguration:self.realmConfiguration error:nil];
}

- (NSString *)sortPropertyKey
{
    if (!_sortPropertyKey &&
        ![self.searchPropertyKeyPath containsString:@"."]) {
        
        return self.searchPropertyKeyPath;
    }
    
    return _sortPropertyKey;
}

#pragma mark - Setters

- (void)setEntityName:(NSString *)entityName
{
    _entityName = entityName;
    
    [self refreshSearchResults];
}


- (void)setSearchPropertyKeyPath:(NSString *)searchPropertyKeyPath
{
    _searchPropertyKeyPath = searchPropertyKeyPath;
    
    [self refreshSearchResults];
}

- (void)setBasePredicate:(NSPredicate *)basePredicate
{
    _basePredicate = basePredicate;
    
    [self refreshSearchResults];
}

- (void)setSortPropertyKey:(NSString *)sortPropertyKey
{
    _sortPropertyKey = sortPropertyKey;
    
    [self refreshSearchResults];
}

- (void)setSortAscending:(BOOL)sortAscending
{
    _sortAscending = sortAscending;
    
    [self refreshSearchResults];
}

- (void)setCaseInsensitiveSearch:(BOOL)caseInsensitiveSearch
{
    _caseInsensitiveSearch = caseInsensitiveSearch;
    
    [self refreshSearchResults];
}

- (void)setUseContainsSearch:(BOOL)useContainsSearch
{
    _useContainsSearch = useContainsSearch;
    
    [self refreshSearchResults];
}

#pragma mark - Public Instance

- (void)refreshSearchResults
{
    NSString *searchString = self.searchController.searchBar.text;
    
    NSPredicate *predicate = [self searchPredicateWithText:searchString];
    
    [self updateResultsWithPredicate:predicate];
}

#pragma mark - Private Instance

- (BOOL)isReadOnly
{
    return _realmConfiguration.readOnly;
}

- (void)updateResultsWithPredicate:(NSPredicate *)predicate
{
    RLMResults *results = [self searchResultsWithEntityName:self.entityName
                                                    inRealm:self.realm
                                                  predicate:predicate
                                            sortPropertyKey:self.sortPropertyKey
                                              sortAscending:self.sortAscending];
    
    if (results) {
        if ([self isReadOnly]) {
            _results = results;
            [self.tableView reloadData];
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        self.token = [results addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
            if (error ||
                !weakSelf.viewIsLoaded) {
                return;
            }
            
            _results = results;
            
            UITableView *tableView = weakSelf.tableView;
            // Initial run of the query will pass nil for the change information
            if (!change) {
                [tableView reloadData];
                return;
            }
            
            // Query results have changed, so apply them to the UITableView
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[change deletionsInSection:0]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[change insertionsInSection:0]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView reloadRowsAtIndexPaths:[change modificationsInSection:0]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        }];
    }
}

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

- (RLMResults *)searchResultsWithEntityName:(NSString *)entityName
                                    inRealm:(RLMRealm *)realm
                                  predicate:(NSPredicate *)predicate
                            sortPropertyKey:(NSString *)sortPropertyKey
                              sortAscending:(BOOL)sortAscending
{
    if (entityName && realm) {
        RLMResults *results = [realm objects:entityName withPredicate:predicate];
        
        if (self.sortPropertyKey) {
            
            RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:sortPropertyKey
                                                                         ascending:sortAscending];
            
            results = [results sortedResultsUsingDescriptors:@[sort]];
        }
        
        return results;
    }
    
    return nil;
}

- (void)runOnMainThread:(ABFBlock)block
{
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

@end
