//
//  BlogSearchViewController.swift
//  RealmSearchViewControllerExample
//
//  Created by Adam Fish on 10/2/15.
//  Copyright © 2015 Adam Fish. All rights reserved.
//

import UIKit
import RealmSwift
import TOWebViewController

class BlogSearchViewController: RealmSearchViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 88
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.registerNib(UINib(nibName: "BlogPostTableViewCell", bundle: nil), forCellReuseIdentifier: BlogCellIdentifier)
        
        // Uncomment to insert the search bar in the nav bar
        //self.searchBarInTableView = false
        //self.navigationItem.titleView = self.searchBar
    }
    
    override func searchViewController(controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(BlogCellIdentifier) as! BlogPostTableViewCell
        
        if let blog = object as? BlogObject {
            cell.emojiLabel.text = blog.emoji
            
            cell.titleLabel.text = blog.title
            
            cell.contentLabel.text = blog.content
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
