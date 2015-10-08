//
//  MainTableViewController.m
//  ABFRealmSearchControllerExample
//
//  Created by Adam Fish on 6/1/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "MainTableViewController.h"
#import "RestaurantSearchViewController.h"
#import "BlogObject.h"
#import "BlogSearchViewController.h"

#import <Realm/Realm.h>
#import <RealmSFRestaurantData/SFRestaurantScores.h>

static NSString *kABFSectionSearchRestaurants = @"restaurantSearch";
static NSString *kABFSectionSearchBlogs = @"blogSearch";

@interface MainTableViewController ()

@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, assign) NSUInteger numberOfRestaurants;

@property (nonatomic, assign) NSUInteger numberOfBlogs;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sections = [NSMutableArray arrayWithObjects:kABFSectionSearchRestaurants,kABFSectionSearchBlogs, nil];
    
    RLMRealm *restaurantRealm = [RLMRealm realmWithPath:ABFRestaurantScoresPath()];
    
    RLMResults *restaurants = [ABFRestaurantObject allObjectsInRealm:restaurantRealm];
    
    RLMResults *blogs = [BlogObject allObjects];
    
    self.numberOfRestaurants = restaurants.count;
    
    self.numberOfBlogs = blogs.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *sectionString = self.sections[indexPath.section];
    
    if ([sectionString isEqualToString:kABFSectionSearchRestaurants]) {
        
        cell.textLabel.text = @"San Francisco Restaurants";
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.numberOfRestaurants];
    }
    else if ([sectionString isEqualToString:kABFSectionSearchBlogs]) {
        
        cell.textLabel.text = @"Realm Blogs";
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.numberOfBlogs];
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionString = self.sections[indexPath.section];
    
    if ([sectionString isEqualToString:kABFSectionSearchRestaurants]) {
        
        RLMRealm *restaurantRealm = [RLMRealm realmWithPath:ABFRestaurantScoresPath()];
        
        RestaurantSearchViewController *restaurantSearchViewController =
        [[RestaurantSearchViewController alloc] initWithEntityName:@"ABFRestaurantObject"
                                                           inRealm:restaurantRealm
                                             searchPropertyKeyPath:@"name"];
        
        [self.navigationController pushViewController:restaurantSearchViewController animated:YES];
    }
    else if ([sectionString isEqualToString:kABFSectionSearchBlogs]) {
        
        BlogSearchViewController *blogSearchViewController =
        [[BlogSearchViewController  alloc] initWithEntityName:@"BlogObject"
                                                      inRealm:[RLMRealm defaultRealm]
                                        searchPropertyKeyPath:@"title"];
        
        blogSearchViewController.useContainsSearch = YES;
        
        // Sort results
        blogSearchViewController.sortPropertyKey = @"date";
        blogSearchViewController.sortAscending = NO;
        
        [self.navigationController pushViewController:blogSearchViewController animated:YES];
    }
}

@end
