//
//  ReadOnlyBlogSearchViewController.swift
//  RealmSearchViewControllerExample
//
//  Created by Nicholas Arciero on 6/3/16.
//  Copyright © 2016 Adam Fish. All rights reserved.
//

import UIKit
import RealmSwift
import TOWebViewController

class ReadOnlyBlogSearchViewController: RealmSearchViewController {
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        return formatter
    }()
    
    // Creates a test read-only realm
    func generateReadOnlyRealm(config: Realm.Configuration) {
        let realm = try? Realm(configuration: config)
        BlogObject.loadBlogData(realm)
        fatalError("ReadOnly realm successfully created. Comment out the 'generateReadOnlyRealm()' function in viewDidLoad() and run again.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Read Only Blogs"
        
        var readOnlyConfig = Realm.Configuration.defaultConfiguration
        readOnlyConfig.fileURL = readOnlyConfig.fileURL?.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("readonly.realm")
        
        // Generate the test realm
        // **COMMENT OUT THIS LINE AFTER GENERATING THE READ-ONLY REALM**
        generateReadOnlyRealm(readOnlyConfig)
        
        readOnlyConfig.readOnly = true
        
        self.realmConfiguration = readOnlyConfig
        
        self.tableView.estimatedRowHeight = 88
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.registerNib(UINib(nibName: "BlogPostTableViewCell", bundle: nil), forCellReuseIdentifier: BlogCellIdentifier)
    }
    
    override func searchViewController(controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(BlogCellIdentifier) as! BlogPostTableViewCell
        
        if let blog = object as? BlogObject {
            cell.emojiLabel.text = blog.emoji
            
            cell.titleLabel.text = blog.title
            
            cell.contentLabel.text = blog.content
            
            cell.dateLabel.text = self.dateFormatter.stringFromDate(blog.date)
        }
        
        return cell
    }
    
    override func searchViewController(controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: NSIndexPath) {
        controller.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let blog = anObject as? BlogObject {
            let webViewController = TOWebViewController(URLString: blog.urlString)
            
            let navigationController = UINavigationController(rootViewController: webViewController)
            
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
}
