//
//  RealmSearchViewController.swift
//  RealmSearchViewControllerExample
//
//  Created by Adam Fish on 10/2/15.
//  Copyright © 2015 Adam Fish. All rights reserved.
//

import UIKit
import Realm
import Realm.Dynamic
import RealmSwift

// MARK: Protocols

/// Method(s) to retrieve data from a data source
public protocol RealmSearchResultsDataSource {
    /**
    Called by the search view controller to retrieve the cell for display of a given object
    
    :param: searchViewController the search view controller instance
    :param: anObject             the object to be displayed by the cell
    :param: indexPath            the indexPath that the object resides at
    
    :return: instance of UITableViewCell that displays the object information
    */
    func searchViewController(controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: NSIndexPath) -> UITableViewCell
}

/**
Method(s) to notify a delegate of ABFRealmSearchViewController events
*/
public protocol RealmSearchResultsDelegate {
    /**
    Called just before an object is selected from the search results table view
    
    :param: searchViewController the search view controller instance
    :param: anObject             the object to be selected
    :param: indexPath            the indexPath that the object resides at
    */
    func searchViewController(controller: RealmSearchViewController, willSelectObject anObject: Object, atIndexPath indexPath: NSIndexPath)
    
    /**
    Called just when an object is selected from the search results table view
    
    :param: searchViewController the search view controller instance
    :param: selectedObject       the selected object
    :param: indexPath            the indexPath that the object resides at
    */
    func searchViewController(controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: NSIndexPath)
}

// MARK: RealmSearchViewController

/// The ABFRealmSearchViewController class creates a controller object that inherits UITableViewController and manages the table view within it to support and display text searching against a Realm object.
public class RealmSearchViewController: UITableViewController, RealmSearchResultsDataSource, RealmSearchResultsDelegate {
    
    // MARK: Properties
    /// The data source object for the search view controller
    public var resultsDataSource: RealmSearchResultsDataSource!
    
    /// The delegate for the search view controller
    public var resultsDelegate: RealmSearchResultsDelegate!
    
    /// The entity (Realm object) name
    @IBInspectable public var entityName: String? {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// The keyPath on the entity that will be searched against.
    @IBInspectable public var searchPropertyKeyPath: String? {
        didSet {
            
            if self.searchPropertyKeyPath?.containsString(".") == false && self.sortPropertyKey == nil {
                
                self.sortPropertyKey = self.searchPropertyKeyPath
            }
            
            self.refreshSearchResults()
        }
    }
    
    /// The base predicate, used when the search bar text is blank. Can be nil.
    public var basePredicate: NSPredicate? {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// The key to sort the results on.
    ///
    /// By default this uses searchPropertyKeyPath if it is just a key.
    /// Realm currently doesn't support sorting by key path.
    @IBInspectable public var sortPropertyKey: String? {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// Defines whether the search results are sorted ascending
    ///
    /// Default is YES
    @IBInspectable public var sortAscending: Bool = true {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// Defines whether the search bar is inserted into the table view header
    ///
    /// Default is YES
    @IBInspectable public var searchBarInTableView: Bool = true
    
    /// Defines whether the text search is case insensitive
    ///
    /// Default is YES
    @IBInspectable public var caseInsensitiveSearch: Bool = true {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// Defines whether the text input uses a CONTAINS filter or just BEGINSWITH.
    ///
    /// Default is NO
    @IBInspectable public var useContainsSearch: Bool = false {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// The configuration for the Realm in which the entity resides
    ///
    /// Default is [RLMRealmConfiguration defaultConfiguration]
    public var realmConfiguration: Realm.Configuration {
        set {
            self.internalConfiguration = newValue
        }
        get {
            if let configuration = self.internalConfiguration {
                return configuration
            }
            
            return Realm.Configuration.defaultConfiguration
        }
    }
    
    /// The Realm in which the given entity resides in
    public var realm: Realm {
        return try! Realm(configuration: self.realmConfiguration)
    }
    
    /// The underlying search results
    public var results: RLMResults?
    
    /// The search bar for the controller
    public var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    // MARK: Public Methods
    
    /// Performs the search again with the current text input and base predicate
    public func refreshSearchResults() {
        let searchString = self.searchController.searchBar.text
        
        let predicate = self.searchPredicate(searchString)
        
        self.updateResults(predicate)
    }
    
    // MARK: Initialization
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        resultsDataSource = self
        resultsDelegate = self
    }
    
    override public init(style: UITableViewStyle) {
        super.init(style: style)

        resultsDataSource = self
        resultsDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        resultsDataSource = self
        resultsDelegate = self
    }
    
    // MARK: UIViewController
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewLoaded = true
        
        if self.searchBarInTableView {
            self.tableView.tableHeaderView = self.searchBar
            
            self.searchBar.sizeToFit()
        }
        else {
            self.searchController.hidesNavigationBarDuringPresentation = false
        }
        
        self.definesPresentationContext = true
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshSearchResults()
    }
    
    // MARK: RealmSearchResultsDataSource
    public func searchViewController(controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("You need to implement searchViewController(controller:,cellForObject object:,atIndexPath indexPath:)")
        
        return UITableViewCell()
    }
    
    // MARK: RealmSearchResultsDelegate
    public func searchViewController(controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: NSIndexPath) {
        // Subclasses to redeclare
    }
    
    public func searchViewController(controller: RealmSearchViewController, willSelectObject anObject: Object, atIndexPath indexPath: NSIndexPath) {
        // Subclasses to redeclare
    }
    
    // MARK: Private
    private var viewLoaded: Bool = false
    
    private var internalConfiguration: Realm.Configuration?
    
    private var token: RLMNotificationToken?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        
        return controller
    }()
    
    private var rlmRealm: RLMRealm {
        let configuration = self.toRLMConfiguration(self.realmConfiguration)
        
        return try! RLMRealm(configuration: configuration)
    }
    
    private var isReadOnly: Bool {
        return self.realmConfiguration.readOnly
    }
    
    private func updateResults(predicate: NSPredicate?) {
        if let results = self.searchResults(self.entityName, inRealm: self.rlmRealm, predicate: predicate, sortPropertyKey: self.sortPropertyKey, sortAscending: self.sortAscending) {
            
            guard !isReadOnly else {
                self.results = results
                self.tableView.reloadData()
                return
            }
            
            self.token = results.addNotificationBlock({ [weak self] (results, change, error) in
                if let weakSelf = self {
                    if (error != nil || !weakSelf.viewLoaded) {
                        return
                    }
                    
                    weakSelf.results = results
                    
                    let tableView = weakSelf.tableView
                    
                    // Initial run of the query will pass nil for the change information
                    if change == nil {
                        tableView.reloadData()
                        return
                    }
                    
                    // Query results have changed, so apply them to the UITableView
                    else if let aChange = change {
                        tableView.beginUpdates()
                        tableView.deleteRowsAtIndexPaths(aChange.deletionsInSection(0), withRowAnimation: .Automatic)
                        tableView.insertRowsAtIndexPaths(aChange.insertionsInSection(0), withRowAnimation: .Automatic)
                        tableView.reloadRowsAtIndexPaths(aChange.modificationsInSection(0), withRowAnimation: .Automatic)
                        tableView.endUpdates()
                    }
                }
            })
        }
    }
    
    private func searchPredicate(text: String?) -> NSPredicate? {
        if (text != "" &&  text != nil) {
            
            let leftExpression = NSExpression(forKeyPath: self.searchPropertyKeyPath!)
            
            let rightExpression = NSExpression(forConstantValue: text)
            
            let operatorType = self.useContainsSearch ? NSPredicateOperatorType.ContainsPredicateOperatorType : NSPredicateOperatorType.BeginsWithPredicateOperatorType
            
            let options = self.caseInsensitiveSearch ? NSComparisonPredicateOptions.CaseInsensitivePredicateOption : NSComparisonPredicateOptions(rawValue: 0)
            
            let filterPredicate = NSComparisonPredicate(leftExpression: leftExpression, rightExpression: rightExpression, modifier: NSComparisonPredicateModifier.DirectPredicateModifier, type: operatorType, options: options)
            
            if (self.basePredicate != nil) {
                
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.basePredicate!, filterPredicate])
                
                return compoundPredicate
            }
            
            return filterPredicate
        }
        
        return self.basePredicate
    }
    
    private func searchResults(entityName: String?, inRealm realm: RLMRealm?, predicate: NSPredicate?, sortPropertyKey: String?, sortAscending: Bool) -> RLMResults? {
        
        if entityName != nil && realm != nil {
            
            var results = realm?.objects(entityName, withPredicate: predicate)
            
            if (sortPropertyKey != nil) {
                
                let sort = RLMSortDescriptor(property: sortPropertyKey!, ascending: sortAscending)
                
                results = results?.sortedResultsUsingDescriptors([sort])
            }
            
            return results
        }
        
        return nil
    }
    
    private func toRLMConfiguration(configuration: Realm.Configuration) -> RLMRealmConfiguration {
        let rlmConfiguration = RLMRealmConfiguration()
        
        if (configuration.fileURL != nil) {
            rlmConfiguration.fileURL = configuration.fileURL
        }
        
        if (configuration.inMemoryIdentifier != nil) {
            rlmConfiguration.inMemoryIdentifier = configuration.inMemoryIdentifier
        }
        
        rlmConfiguration.encryptionKey = configuration.encryptionKey
        rlmConfiguration.readOnly = configuration.readOnly
        rlmConfiguration.schemaVersion = configuration.schemaVersion
        return rlmConfiguration
    }
    
    private func runOnMainThread(block: () -> Void) {
        if NSThread.isMainThread() {
            block()
        }
        else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block()
            })
        }
    }
}

// MARK: UITableViewDelegate
extension RealmSearchViewController {
    public override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let results = self.results {
            let baseObject = results.objectAtIndex(UInt(indexPath.row)) as RLMObjectBase
            let object = baseObject as! Object
            
            self.resultsDelegate.searchViewController(self, willSelectObject: object, atIndexPath: indexPath)
            
            return indexPath
        }
        
        return nil
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let results = self.results {
            let baseObject = results.objectAtIndex(UInt(indexPath.row)) as RLMObjectBase
            let object = baseObject as! Object
            
            self.resultsDelegate.searchViewController(self, didSelectObject: object, atIndexPath: indexPath)
        }
    }
}

// MARK: UITableViewControllerDataSource
extension RealmSearchViewController {
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = self.results {
            return Int(results.count)
        }
        
        return 0
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let results = self.results {
            let baseObject = results.objectAtIndex(UInt(indexPath.row)) as RLMObjectBase
            let object = baseObject as! Object
            
            let cell = self.resultsDataSource.searchViewController(self, cellForObject: object, atIndexPath: indexPath)
            
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: UISearchResultsUpdating
extension RealmSearchViewController: UISearchResultsUpdating {
    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.refreshSearchResults()
    }
}
