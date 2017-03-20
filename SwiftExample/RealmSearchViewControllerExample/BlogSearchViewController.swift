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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 88
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.register(UINib(nibName: "BlogPostTableViewCell", bundle: nil), forCellReuseIdentifier: BlogCellIdentifier)
    }
    
    override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: BlogCellIdentifier) as! BlogPostTableViewCell
        
        if let blog = object as? BlogObject {
            cell.emojiLabel.text = blog.emoji
            
            cell.titleLabel.text = blog.title
            
            cell.contentLabel.text = blog.content
            
            cell.dateLabel.text = self.dateFormatter.string(from: blog.date)
        }
        
        return cell
    }
    
    override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
        controller.tableView.deselectRow(at: indexPath, animated: true)
        
        if let blog = anObject as? BlogObject {
            let webViewController = TOWebViewController(urlString: blog.urlString)
            
            let navigationController = UINavigationController(rootViewController: webViewController!)
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
