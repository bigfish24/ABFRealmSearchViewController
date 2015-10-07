//
//  BlogPostTableViewCell.swift
//  RealmSearchViewControllerExample
//
//  Created by Adam Fish on 10/2/15.
//  Copyright © 2015 Adam Fish. All rights reserved.
//

import UIKit

let BlogCellIdentifier = "BlogCell"

class BlogPostTableViewCell: UITableViewCell {
    @IBOutlet var emojiLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
