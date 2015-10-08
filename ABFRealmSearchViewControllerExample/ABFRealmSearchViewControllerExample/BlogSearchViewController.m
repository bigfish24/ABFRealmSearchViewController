//
//  BlogSearchViewController.m
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 8/11/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "BlogSearchViewController.h"
#import "BlogObject.h"
#import "BlogPostTableViewCell.h"

#import <TOWebViewController/TOWebViewController.h>

@interface BlogSearchViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation BlogSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    self.title = @"Blogs";
    self.tableView.estimatedRowHeight = 88.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BlogPostTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"blogCell"];
}

#pragma mark - <ABFRealmSearchControllerDataSource>

- (UITableViewCell *)searchViewController:(ABFRealmSearchViewController *)searchViewController
                            cellForObject:(id)anObject
                              atIndexPath:(NSIndexPath *)indexPath
{
    BlogPostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"blogCell"];
    
    BlogObject *blog = anObject;
    
    cell.emojiLabel.text = blog.emoji;
    
    cell.titleLabel.text = [blog.title capitalizedString];
    
    cell.contentLabel.text = blog.content;
    
    cell.dateLabel.text = [self.dateFormatter stringFromDate:blog.date];
    
    return cell;
}

#pragma mark - <ABFRealmSearchControllerDelegate>

- (void)searchViewController:(ABFRealmSearchViewController *)searchViewController
             didSelectObject:(id)selectedObject
                 atIndexPath:(NSIndexPath *)indexPath
{
    [searchViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BlogObject *blog = selectedObject;
    
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURLString:blog.urlString];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
