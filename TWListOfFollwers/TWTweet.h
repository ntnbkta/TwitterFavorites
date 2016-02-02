//
//  TWTweet.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/28/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWTweet : NSObject

@property (nonatomic, strong) NSNumber *tweetID;
@property (nonatomic, strong) NSString *tweetAuthorHandler;
@property (nonatomic, strong) NSDate *tweetCreatedAt;
@property (nonatomic, strong) NSString *tweetText;
@property (nonatomic, strong) NSNumber *tweetRetweetCount;
@property (nonatomic, strong) NSNumber *tweetFavoriteCount;
@property (nonatomic, assign) BOOL tweetRetweeted;
@property (nonatomic, assign) BOOL tweetFavorited;

@end
