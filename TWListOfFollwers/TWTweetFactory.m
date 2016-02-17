//
//  TWTweetFactory.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 2/2/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWTweetFactory.h"
#import "TWAPIManager.h"
#import "FavoriteAccount.h"
#import "TWTweet.h"

@interface TWTweetFactory ()

@property (nonatomic, strong) NSMutableArray *allFavoritesTweets;

@end


@implementation TWTweetFactory

//This class is responsible for fetching favorites from core data and providing a list of all favorite's tweets

- (instancetype)init
{
    if (self == [super init]) {
        _allFavoritesTweets = [NSMutableArray new];
    }
    return self;
}

- (void)fetchTweetsOfFavorites:(NSArray *)favorites newFetch:(BOOL)newFetch withSuccessBlock:(void (^)(NSArray *tweetsList))successBlock  failureBlock:(void (^)(NSError *error))failureBlock
{
    for (FavoriteAccount *favorite in favorites)
    {
        if ([favorite lastReadTweetID] && newFetch) {
            
            //Set Max_ID to lastReadTweetID - 1
            NSInteger numberID = [[favorite lastReadTweetID] integerValue];
            numberID--;
            [favorite setMaxID:[NSString stringWithFormat:@"%ld",numberID]];
            NSLog(@"************ LAST READ MAX_ID %@ *************** ",[favorite maxID]);

        }
        [self.apiManager fetchRecentTweetsOfFavoriteAccount:favorite withCompletionBlock:^(id response, NSString *nextMaxTagID, NSError *error) {
            
            if (!error) {
                if ([response isKindOfClass:[NSArray class]]) {
                    [self.allFavoritesTweets addObjectsFromArray:response];
                    
                    if (favorite == [favorites lastObject]) {
                        [self sortTweetsForReverseChrnologicalOrderWithSuccessBlock:successBlock];
                        [self.allFavoritesTweets removeAllObjects];
                    }
                }
            }
            else {
                failureBlock(error);
            }
        }];
        
    }
}

- (void)sortTweetsForReverseChrnologicalOrderWithSuccessBlock:(void (^)(NSArray *tweetsList))successBlock
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tweetCreatedAt"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.allFavoritesTweets = [[self.allFavoritesTweets sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

    successBlock(self.allFavoritesTweets);
}
@end
