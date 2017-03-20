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
    func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell
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
    func searchViewController(_ controller: RealmSearchViewController, willSelectObject anObject: Object, atIndexPath indexPath: IndexPath)
    
    /**
    Called just when an object is selected from the search results table view
    
    :param: searchViewController the search view controller instance
    :param: selectedObject       the selected object
    :param: indexPath            the indexPath that the object resides at
    */
    func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath)
}

// MARK: RealmSearchViewController

/// The ABFRealmSearchViewController class creates a controller object that inherits UITableViewController and manages the table view within it to support and display text searching against a Realm object.
open class RealmSearchViewController: UITableViewController, RealmSearchResultsDataSource, RealmSearchResultsDelegate {
    
    // MARK: Properties
    /// The data source object for the search view controller
    open var resultsDataSource: RealmSearchResultsDataSource!
    
    /// The delegate for the search view controller
    open var resultsDelegate: RealmSearchResultsDelegate!
    
    /// The entity (Realm object) name
    @IBInspectable open var entityName: String? {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// The keyPath on the entity that will be searched against.
    @IBInspectable open var searchPropertyKeyPath: String? {
        didSet {
            
            if self.searchPropertyKeyPath?.contains(".") == false && self.sortPropertyKey == nil {
                
                self.sortPropertyKey = self.searchPropertyKeyPath
            }
            
            self.refreshSearchResults()
        }
    }
    
    /// The base predicate, used when the search bar text is blank. Can be nil.
    open var basePredicate: NSPredicate? {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// The key to sort the results on.
    ///
    /// By default this uses searchPropertyKeyPath if it is just a key.
    /// Realm currently doesn't support sorting by key path.
    @IBInspectable open var sortPropertyKey: String? {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// Defines whether the search results are sorted ascending
    ///
    /// Default is YES
    @IBInspectable open var sortAscending: Bool = true {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// Defines whether the search bar is inserted into the table view header
    ///
    /// Default is YES
    @IBInspectable open var searchBarInTableView: Bool = true
    
    /// Defines whether the text search is case insensitive
    ///
    /// Default is YES
    @IBInspectable open var caseInsensitiveSearch: Bool = true {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// Defines whether the text input uses a CONTAINS filter or just BEGINSWITH.
    ///
    /// Default is NO
    @IBInspectable open var useContainsSearch: Bool = false {
        didSet {
            self.refreshSearchResults()
        }
    }
    
    /// The configuration for the Realm in which the entity resides
    ///
    /// Default is [RLMRealmConfiguration defaultConfiguration]
    open var realmConfiguration: Realm.Configuration {
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
    open var realm: Realm {
        return try! Realm(configuration: self.realmConfiguration)
    }
    
    /// The underlying search results
    open var results: RLMResults<RLMObject>?
    
    /// The search bar for the controller
    open var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    // MARK: Public Methods
    
    /// Performs the search again with the current text input and base predicate
    open func refreshSearchResults() {
        let searchString = self.searchController.searchBar.text
        
        let predicate = self.searchPredicate(searchString)
        
        self.updateResults(predicate)
    }
    
    // MARK: Initialization
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewIsLoaded = true
        
        if self.searchBarInTableView {
            self.tableView.tableHeaderView = self.searchBar
            
            self.searchBar.sizeToFit()
        }
        else {
            self.searchController.hidesNavigationBarDuringPresentation = false
        }
        
        self.definesPresentationContext = true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshSearchResults()
    }
    
    // MARK: RealmSearchResultsDataSource
    open func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        print("You need to implement searchViewController(controller:,cellForObject object:,atIndexPath indexPath:)")
        
        return UITableViewCell()
    }
    
    // MARK: RealmSearchResultsDelegate
    open func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
        // Subclasses to redeclare
    }
    
    open func searchViewController(_ controller: RealmSearchViewController, willSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
        // Subclasses to redeclare
    }
    
    // MARK: Private
    fileprivate var viewIsLoaded: Bool = false
    
    fileprivate var internalConfiguration: Realm.Configuration?
    
    fileprivate var token: RLMNotificationToken?
    
    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        
        return controller
    }()
    
    fileprivate var rlmRealm: RLMRealm {
        let configuration = self.toRLMConfiguration(self.realmConfiguration)
        
        return try! RLMRealm(configuration: configuration)
    }
    
    fileprivate var isReadOnly: Bool {
        return self.realmConfiguration.readOnly
    }
    
    fileprivate func updateResults(_ predicate: NSPredicate?) {
        if let results = self.searchResults(self.entityName, inRealm: self.rlmRealm, predicate: predicate, sortPropertyKey: self.sortPropertyKey, sortAscending: self.sortAscending) {
            
            guard !isReadOnly else {
                self.results = results
                self.tableView.reloadData()
                return
            }
            
            self.token = results.addNotificationBlock({ [weak self] (results, change, error) in
                if let weakSelf = self {
                    if (error != nil || !weakSelf.viewIsLoaded) {
                        return
                    }
                    
                    weakSelf.results = results
                    
                    let tableView = weakSelf.tableView
                    
                    // Initial run of the query will pass nil for the change information
                    if change == nil {
                        tableView?.reloadData()
                        return
                    }
                    
                    // Query results have changed, so apply them to the UITableView
                    else if let aChange = change {
                        tableView?.beginUpdates()
                        tableView?.deleteRows(at: aChange.deletions(inSection: 0), with: .automatic)
                        tableView?.insertRows(at: aChange.insertions(inSection: 0), with: .automatic)
                        tableView?.reloadRows(at: aChange.modifications(inSection: 0), with: .automatic)
                        tableView?.endUpdates()
                    }
                }
            })
        }
    }
    
    fileprivate func searchPredicate(_ text: String?) -> NSPredicate? {
        if (text != "" &&  text != nil) {
            
            let leftExpression = NSExpression(forKeyPath: self.searchPropertyKeyPath!)
            
            let rightExpression = NSExpression(forConstantValue: text)
            
            let operatorType = self.useContainsSearch ? NSComparisonPredicate.Operator.contains : NSComparisonPredicate.Operator.beginsWith
            
            let options = self.caseInsensitiveSearch ? NSComparisonPredicate.Options.caseInsensitive : NSComparisonPredicate.Options(rawValue: 0)
            
            let filterPredicate = NSComparisonPredicate(leftExpression: leftExpression, rightExpression: rightExpression, modifier: NSComparisonPredicate.Modifier.direct, type: operatorType, options: options)
            
            if (self.basePredicate != nil) {
                
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.basePredicate!, filterPredicate])
                
                return compoundPredicate
            }
            
            return filterPredicate
        }
        
        return self.basePredicate
    }
    
    fileprivate func searchResults(_ entityName: String?, inRealm realm: RLMRealm?, predicate: NSPredicate?, sortPropertyKey: String?, sortAscending: Bool) -> RLMResults<RLMObject>? {
        
        if entityName != nil && realm != nil {
            
            var results = realm?.allObjects(entityName!)
            
            if (predicate != nil ) {
                results = realm?.objects(entityName!, with: predicate!)
            }
            
            if (sortPropertyKey != nil) {
                
                let sort = RLMSortDescriptor(keyPath: sortPropertyKey!, ascending: sortAscending)
                
                results = results?.sortedResults(using: [sort])
            }
            
            return results
        }
        
        return nil
    }
    
    fileprivate func toRLMConfiguration(_ configuration: Realm.Configuration) -> RLMRealmConfiguration {
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
    
    fileprivate func runOnMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async(execute: { () -> Void in
                block()
            })
        }
    }
}

// MARK: UITableViewDelegate
extension RealmSearchViewController {
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let results = self.results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            let object = baseObject as! Object
            
            self.resultsDelegate.searchViewController(self, willSelectObject: object, atIndexPath: indexPath)
            
            return indexPath
        }
        
        return nil
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let results = self.results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            let object = baseObject as! Object
            
            self.resultsDelegate.searchViewController(self, didSelectObject: object, atIndexPath: indexPath)
        }
    }
}

// MARK: UITableViewControllerDataSource
extension RealmSearchViewController {
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = self.results {
            return Int(results.count)
        }
        
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let results = self.results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            let object = baseObject as! Object
            
            let cell = self.resultsDataSource.searchViewController(self, cellForObject: object, atIndexPath: indexPath)
            
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: UISearchResultsUpdating
extension RealmSearchViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        self.refreshSearchResults()
    }
}
