//
//  BlogObject.m
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 8/11/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "BlogObject.h"

@implementation BlogObject

#pragma mark - RLMObject

+ (NSString *)primaryKey
{
    return @"blogId";
}

// Specify default values for properties
+ (NSDictionary *)defaultPropertyValues
{
    return @{@"title" : @"",
             @"urlString" : @"",
             @"date" : [NSDate distantPast],
             @"content" : @"",
             @"imageURLString" : @"",
             };
}

// Specify properties to ignore (Realm won't persist these)
+ (NSArray *)ignoredProperties
{
    return @[@"url",
             @"imageURL"];
}

#pragma mark - Getters

- (NSURL *)url
{
    return [NSURL URLWithString:self.urlString];
}

- (NSURL *)imageURL
{
    return [NSURL URLWithString:self.imageURLString];
}

#pragma mark - Public Class

+ (void)loadBlogData
{
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:@"blog" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath];
    
    NSError *error;
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    
    if (error) {
        NSLog(@"JSON Serialization Error: %@",error.localizedDescription);
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    
    NSUInteger index = 0;
    
    for (NSDictionary *blogData in jsonArray) {
        
        BlogObject *blog = [[BlogObject alloc] init];
        
        blog.title = blogData[@"title"];
        
        // Create the correct Realm URL
        NSString *url = [NSString stringWithFormat:@"http://www.realm.io%@",blogData[@"url"]];
        blog.urlString = url;
        
        blog.date = [dateFormatter dateFromString:blogData[@"date"]];
        blog.content = blogData[@"content"];
        blog.imageURLString = blogData[@"image"];
        blog.emoji = [self randomEmoji];
        
        blog.blogId = index;
        
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [[RLMRealm defaultRealm] addOrUpdateObject:blog];
        }];
        
        index ++;
    }
}

static NSArray *emojiArray;

+ (NSString *)randomEmoji
{
    if (!emojiArray) {
        
        NSString *emojiFilePath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"];
        
        NSData *emojiData = [NSData dataWithContentsOfFile:emojiFilePath];
        
        NSError *error;
        
        emojiArray = [NSJSONSerialization JSONObjectWithData:emojiData
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    }
    
    NSInteger randomIndex = arc4random_uniform((u_int32_t)emojiArray.count);
    
    return emojiArray[randomIndex];
}

@end
