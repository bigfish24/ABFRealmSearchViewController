//
//  RestaurantSearchViewController.m
//  ABFRealmSearchControllerExample
//
//  Created by Adam Fish on 6/2/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "RestaurantSearchViewController.h"
#import "RestaurantTableViewController.h"

#import <Realm/Realm.h>
#import <RealmSFRestaurantData/SFRestaurantScores.h>

@implementation RestaurantSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Restaurants";
}

#pragma mark - <ABFRealmSearchControllerDataSource>

- (UITableViewCell *)searchViewController:(ABFRealmSearchViewController *)searchViewController
                            cellForObject:(id)anObject
                              atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"restaurantCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"restaurantCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ABFRestaurantObject *restaurant = anObject;
    
    cell.textLabel.text = [restaurant.name capitalizedString];
    
    return cell;
}

#pragma mark - <ABFRealmSearchControllerDelegate>

- (void)searchViewController:(ABFRealmSearchViewController *)searchViewController
             didSelectObject:(id)selectedObject
                 atIndexPath:(NSIndexPath *)indexPath
{
    RestaurantTableViewController *restaurantViewController = [[RestaurantTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    restaurantViewController.restaurant = selectedObject;
    
    [self.navigationController pushViewController:restaurantViewController animated:YES];
}

@end
