//
//  BlogObject.h
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 8/11/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <Realm/Realm.h>

@interface BlogObject : RLMObject

@property NSInteger blogId;

@property NSString *title;
@property NSString *urlString;
@property NSDate *date;
@property NSString *content;
@property NSString *imageURLString;
@property NSString *emoji;

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURL *imageURL;

+ (void)loadBlogData;

+ (NSString *)randomEmoji;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<BlogObject>
RLM_ARRAY_TYPE(BlogObject)
