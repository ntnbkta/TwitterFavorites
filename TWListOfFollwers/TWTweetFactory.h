//
//  TWTweetFactory.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 2/2/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWAPIManager;
@interface TWTweetFactory : NSObject

@property (nonatomic, strong) TWAPIManager *apiManager;

- (void)fetchTweetsOfFavorites:(NSArray *)favorites newFetch:(BOOL)newFetch withSuccessBlock:(void (^)(NSArray *tweetsList))successBlock  failureBlock:(void (^)(NSError *error))failureBlock;

@end
