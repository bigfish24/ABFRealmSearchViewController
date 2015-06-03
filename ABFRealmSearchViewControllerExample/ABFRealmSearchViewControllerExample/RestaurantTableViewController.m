//
//  RestaurantTableViewController.m
//  ABFRealmSearchControllerExample
//
//  Created by Adam Fish on 6/1/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "RestaurantTableViewController.h"

@interface RestaurantTableViewController ()

@end

@implementation RestaurantTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [self.restaurant.name capitalizedString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.restaurant.objectSchema.properties.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLMProperty *property = self.restaurant.objectSchema.properties[indexPath.section];
    
    if (property.type == RLMPropertyTypeObject ||
        property.type == RLMPropertyTypeArray) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linkedObjectCell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"linkedObjectCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = [self textForProperty:property object:self.restaurant];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"propertyCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"propertyCell"];
    }
    
    cell.textLabel.text = [self textForProperty:property object:self.restaurant];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    RLMProperty *property = self.restaurant.objectSchema.properties[section];
    
    return property.name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLMProperty *property = self.restaurant.objectSchema.properties[indexPath.section];
    
    if (property.type == RLMPropertyTypeObject) {
        
        
    }
    else if (property.type == RLMPropertyTypeArray) {
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private

- (NSString *)textForProperty:(RLMProperty *)property
                       object:(RLMObject *)object;
{
    if (property.type == RLMPropertyTypeArray) {
        RLMArray *array = [object valueForKey:property.name];
        
        NSString *text = [NSString stringWithFormat:@"%lu",(unsigned long)array.count];
        
        return text;
    }
    else if (property.type == RLMPropertyTypeBool) {
        NSNumber *value = [object valueForKey:property.name];
        
        NSString *text = value.boolValue ? @"YES" : @"NO";
        
        return text;
    }
    else if (property.type == RLMPropertyTypeData) {
        
    }
    else if (property.type == RLMPropertyTypeDate) {
        NSDate *date = [object valueForKey:property.name];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        NSString *text = [dateFormatter stringFromDate:date];
        
        return text;
    }
    else if (property.type == RLMPropertyTypeDouble ||
             property.type == RLMPropertyTypeFloat ||
             property.type == RLMPropertyTypeInt) {
        
        NSNumber *value = [object valueForKey:property.name];
        
        NSString *text = [NSString stringWithFormat:@"%@",value];
        
        return text;
    }
    else if (property.type == RLMPropertyTypeObject) {
        RLMObject *linkedObject = [object valueForKey:property.name];
        
        if (linkedObject.objectSchema.primaryKeyProperty) {
            NSString *text = [self textForProperty:linkedObject.objectSchema.primaryKeyProperty object:linkedObject];
            
            return text;
        }
        
        return @"1";
    }
    else if (property.type == RLMPropertyTypeString) {
        NSString *text = [object valueForKey:property.name];
        
        return text;
    }
    
    return @"";
}



@end
