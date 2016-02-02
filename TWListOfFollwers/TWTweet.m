//
//  TWTweet.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/28/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWTweet.h"

@implementation TWTweet

- (NSString *)description
{
    return  [NSString stringWithFormat:@"ID: %@,\n Author : %@\n Text: %@,\n Favorite Count : %@,\n Retweet Count : %@,\n Favorited : %d,\n Retweeted : %d\n, CreatedAt : %@", self.tweetID,self.tweetAuthorHandler, self.tweetText,self.tweetFavoriteCount,self.tweetRetweetCount,self.tweetFavorited,self.tweetRetweeted, self.tweetCreatedAt];
}
@end
