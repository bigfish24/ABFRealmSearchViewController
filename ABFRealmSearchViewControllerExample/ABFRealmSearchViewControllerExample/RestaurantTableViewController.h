//
//  RestaurantTableViewController.h
//  ABFRealmSearchControllerExample
//
//  Created by Adam Fish on 6/1/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ABFRestaurantObject.h>

@interface RestaurantTableViewController : UITableViewController

@property (strong, nonatomic) ABFRestaurantObject *restaurant;

@end
