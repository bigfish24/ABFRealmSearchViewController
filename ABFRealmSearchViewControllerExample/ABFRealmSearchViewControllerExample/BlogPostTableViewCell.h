//
//  BlogPostTableViewCell.h
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 8/11/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlogPostTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *emojiLabel;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@end
