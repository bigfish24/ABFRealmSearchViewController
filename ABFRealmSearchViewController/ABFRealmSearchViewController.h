//
//  ABFRealmSearchViewController.h
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 6/1/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

@import UIKit;

@class ABFRealmSearchViewController, RLMRealm;

/**
 *  Method(s) to retrieve data from a data source
 */
@protocol ABFRealmSearchResultsDataSource <NSObject>

/**
 *  Called by the search view controller to retrieve the cell for display of a given object
 *
 *  @param searchViewController the search view controller instance
 *  @param anObject             the object to be displayed by the cell
 *  @param indexPath            the indexPath that the object resides at
 *
 *  @return instance of UITableViewCell that displays the object information
 */
- (UITableViewCell *)searchViewController:(ABFRealmSearchViewController *)searchViewController
                        cellForObject:(id)anObject
                          atIndexPath:(NSIndexPath *)indexPath;
@end

/**
 *  Method(s) to notify a delegate of ABFRealmSearchViewController events
 */
@protocol ABFRealmSearchResultsDelegate <NSObject>

@optional

/**
 *  Called just before an object is selected from the search results table view
 *
 *  @param searchViewController the search view controller instance
 *  @param anObject             the object to be selected
 *  @param indexPath            the indexPath that the object resides at
 */
- (void)searchViewController:(ABFRealmSearchViewController *)searchViewController
            willSelectObject:(id)anObject
                 atIndexPath:(NSIndexPath *)indexPath;

/**
 *  Called just when an object is selected from the search results table view
 *
 *  @param searchViewController the search view controller instance
 *  @param selectedObject       the selected object
 *  @param indexPath            the indexPath that the object resides at
 */
- (void)searchViewController:(ABFRealmSearchViewController *)searchViewController
             didSelectObject:(id)selectedObject
                 atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 *  The ABFRealmSearchViewController class creates a controller object that inherits UITableViewController and manages the table view within it to support and display text searching against a Realm object.
 */
@interface ABFRealmSearchViewController : UITableViewController <ABFRealmSearchResultsDataSource,ABFRealmSearchResultsDelegate>

/**
 *  The data source object for the search view controller
 */
@property (nonatomic, weak) id<ABFRealmSearchResultsDataSource> resultsDataSource;

/**
 *  The delegate for the search view controller
 */
@property (nonatomic, weak) id<ABFRealmSearchResultsDelegate> resultsDelegate;

/**
 *  The entity (Realm object) name
 */
@property (nonatomic, strong) IBInspectable NSString *entityName;

/**
 *  The Realm in which the given entity is being searched against in
 */
@property (nonatomic, readonly) RLMRealm *realm;

/**
 *  The search bar for the controller
 */
@property (nonatomic, readonly) UISearchBar *searchBar;

/**
 *  The keyPath on the entity that will be searched against.
 */
@property (nonatomic, strong) IBInspectable NSString *searchPropertyKeyPath;

/**
 *  The base predicate, used when the search bar text is blank. Can be nil.
 */
@property (nonatomic, readonly) NSPredicate *basePredicate;

/**
 *  The key to sort the results on.
 *
 *  By default this uses searchPropertyKeyPath if it is just a key.
 *  Realm currently doesn't support sorting by key path.
 */
@property (nonatomic, strong) NSString *sortPropertyKey;

/**
 *  Defines whether the search results are sorted ascending
 *
 *  Default is YES
 */
@property (nonatomic, assign) IBInspectable BOOL sortAscending;

/**
 *  Defines whether the search bar is inserted into the table view header
 *
 *  Default is YES
 */
@property (nonatomic, assign) IBInspectable BOOL searchBarInTableView;

/**
 *  Defines whether the text search is case insensitive
 *
 *  Default is YES
 */
@property (nonatomic, assign) IBInspectable BOOL caseInsensitiveSearch;

/**
 *  Defines whether the text input uses a CONTAINS filter or just BEGINSWITH.
 *
 *  Default is NO
 */
@property (nonatomic, assign) IBInspectable BOOL useContainsSearch;

/**
 *  Initializes an instance of ABFRealmSearchViewController with a given entity name defined in the default Realm
 *
 *  Defaults to UITableViewStylePlain
 *  To alter use: initWithEntityName:inRealm:searchPropertyKeyPath:initialPredicate:tableViewStyle:)
 *
 *  @param entityName   RLMObject subclass name defined in default Realm
 *  @param keyPath      keyPath on the RLMObject entity that will be searched against
 *
 *  @return instance of ABFRealmSearchViewController
 */
- (instancetype)initWithEntityName:(NSString *)entityName
             searchPropertyKeyPath:(NSString *)keyPath;

/**
 *  Initializes an instance of ABFRealmSearchViewController with a given entity name defined in a specific Realm
 *
 *  Defaults to UITableViewStylePlain
 *  To alter use: initWithEntityName:inRealm:searchPropertyKeyPath:initialPredicate:tableViewStyle:)
 *
 *  @param entityName RLMObject subclass name defined in default Realm
 *  @param realm      the Realm in which the entity will be searched against (in-memory Realms are not supported)
 *  @param keyPath    keyPath on the RLMObject entity that will be searched against
 *
 *  @return instance of ABFRealmSearchViewController
 */
- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath;

/**
 *  Initializes an instance of ABFRealmSearchViewController with a given entity name defined in the default Realm
 *
 *  Defaults to UITableViewStylePlain
 *  To alter use: initWithEntityName:inRealm:searchPropertyKeyPath:initialPredicate:tableViewStyle:)
 *
 *  @param entityName       RLMObject subclass name defined in defaultRealm
 *  @param keyPath          keyPath on the RLMObject entity that will be searched against
 *  @param basePredicate    NSPredicate for the RLMObject for use when search bar is blank
 *
 *  @return instance of ABFRealmSearchViewController
 */
- (instancetype)initWithEntityName:(NSString *)entityName
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate;

/**
 *  Initializes an instance of ABFRealmSearchViewController with a given entity name defined in a specific Realm
 *
 *  Defaults to UITableViewStylePlain
 *  To alter use: initWithEntityName:inRealm:searchPropertyKeyPath:initialPredicate:tableViewStyle:)
 *
 *  @param entityName       RLMObject subclass name
 *  @param realm            the Realm in which the entity will be searched against (in-memory Realms are not supported)
 *  @param keyPath          keyPath on the RLMObject entity that will be searched against
 *  @param basePredicate    NSPredicate for the RLMObject for use when search bar is blank
 *
 *  @return instance of ABFRealmSearchViewController
 */
- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate;

/**
 *  Initializes an instance of ABFRealmSearchViewController with a given entity name defined in a specific Realm
 *
 *  @param entityName       RLMObject subclass name
 *  @param realm            the Realm in which the entity will be searched against (in-memory Realms are not supported)
 *  @param keyPath          keyPath on the RLMObject entity that will be searched against
 *  @param basePredicate    NSPredicate for the RLMObject for use when search bar is blank
 *  @param style            the UITableView style for the search results
 *
 *  @return instance of ABFRealmSearchViewController
 */
- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate
                    tableViewStyle:(UITableViewStyle)style;

/**---------------------------------------------------------------------------------------
 *  @name Unavailable Methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  ABFRealmSearchViewController cannot be created without at least specifying the entity name
 *
 *  @return not available
 */
- (instancetype)init __attribute__((unavailable("Use initWithEntityName:searchPropertyKeyPath: or initWithEntityName:searchPropertyKeyPath:basePredicate:")));

/**
 *  ABFRealmSearchViewController cannot be created using interface builder or storyboards.
 *
 *  @param aDecoder not available
 *
 *  @return not available
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder __attribute__((unavailable("Use initWithEntityName:searchPropertyKeyPath: or initWithEntityName:searchPropertyKeyPath:basePredicate:")));

/**
 *  ABFRealmSearchViewController cannot be created using UITableViewController initializers
 *
 *  @param style not available
 *
 *  @return not available
 */
- (instancetype)initWithStyle:(UITableViewStyle)style __attribute__((unavailable("Use initWithEntityName:searchPropertyKeyPath: or initWithEntityName:searchPropertyKeyPath:basePredicate:")));

/**
 *  ABFRealmSearchViewController cannot be created using UITableViewController initializers
 *
 *  @param nibNameOrNil   not available
 *  @param nibBundleOrNil not available
 *
 *  @return not available
 */
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil __attribute__((unavailable("Use initWithEntityName:searchPropertyKeyPath: or initWithEntityName:searchPropertyKeyPath:basePredicate:")));

/**
 *  ABFRealmSearchViewController cannot be created without at least specifying the entity name
 *
 *  @return not available
 */
+ (instancetype)new __attribute__((unavailable("Use initWithEntityName:searchPropertyKeyPath: or initWithEntityName:searchPropertyKeyPath:basePredicate:")));

@end
