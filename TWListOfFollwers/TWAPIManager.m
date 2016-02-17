//
//  TWAPIManager.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWAPIManager.h"
#import "TWTwitterAccount.h"
#import "TWTweet.h"
#import "FavoriteAccount.h"

#define BASE_API @"https://api.twitter.com/1.1/"

#define FRIENDS_API @"friends/list.json"
#define GET_TWEETS_API @"statuses/user_timeline.json"

#define kFavoritesSinceMaxIDUpdated @"FavoritesSinceMaxIDUpdated"

@implementation TWAPIManager

- (void)fetchListOfFollowingForTwitterAccount:(ACAccount *)account withNextCursor:(NSString *)nextCursor withCompletionBlock:(TwitterWebServiceCompletionBlock)completionBlock
{
    self.authenticatedAccount = account;
    NSString *nextCursorId = nextCursor;
    if (!nextCursorId) {
        nextCursorId = @"-1";
    }
    
    if (!completionBlock)
    {
        completionBlock = ^(id response, NSString *nextMaxTagID, NSError *error)
        {
            
        };
    }

    if([nextCursorId integerValue] == 0)
    {
        //End of Fetch
        dispatch_async(dispatch_get_main_queue(), ^{completionBlock(nil,nil,nil);});
        return;
    }

    NSMutableString *requestURLString = [[BASE_API stringByAppendingString:FRIENDS_API] mutableCopy];
    [requestURLString appendFormat:@"?cursor=%@&screen_name=%@&skip_status=true&include_user_entities=false&count=200",nextCursorId,[account username]];
    NSURL *followingURL = [NSURL URLWithString:requestURLString];
    SLRequest* request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:followingURL parameters:nil];
    
    request.account = account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error)
        {
            NSError *returnError = [self errorFromNetworkError:error];
            dispatch_async(dispatch_get_main_queue(), ^{completionBlock(nil,nil,returnError);});
            return;
        }

        NSError *jsonError = nil;
        id responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
        if (jsonError)
        {
            NSError *returnError = [self errorFromNetworkError:error];
            dispatch_async(dispatch_get_main_queue(), ^{completionBlock(nil,nil,returnError);});
            return;
        }
        
        id processedResponse = [self parseResponseFromWebService:responseJSON];
        NSString *nextMaxTagID = [self getMaxTagIDFromResponse:responseJSON];
        dispatch_async(dispatch_get_main_queue(), ^{completionBlock(processedResponse,nextMaxTagID,nil);});

    }];
    
}

- (void)fetchRecentTweetsOfFavoriteAccount:(FavoriteAccount *)favorite withCompletionBlock:(TwitterWebServiceCompletionBlock)completionBlock
{
    if (!completionBlock)
    {
        completionBlock = ^(id response, NSString *nextMaxTagID, NSError *error)
        {
            
        };
    }

    NSString *screenName = [favorite screenName];
    NSMutableString *requestURLString = [[BASE_API stringByAppendingString:GET_TWEETS_API] mutableCopy];
    [requestURLString appendFormat:@"?screen_name=%@&exclude_replies=1&count=25",screenName];
    
//    if ([[favorite sinceID] integerValue] > 0) {
//        [requestURLString appendFormat:@"&since_id=%@",[favorite sinceID]];
//    }
    
    if ([[favorite maxID] integerValue] > 0) {
        [requestURLString appendFormat:@"&max_id=%@",[favorite maxID]];
    }


    NSURL *getTweetsURL = [NSURL URLWithString:requestURLString];
    SLRequest* request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:getTweetsURL parameters:nil];
    request.account = self.authenticatedAccount;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

        if (error)
        {
            NSError *returnError = [self errorFromNetworkError:error];
            dispatch_async(dispatch_get_main_queue(), ^{completionBlock(nil,nil,returnError);});
            return;
        }
        NSError *jsonError = nil;
        id responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
        if (jsonError)
        {
            NSError *returnError = [self errorFromNetworkError:error];
            dispatch_async(dispatch_get_main_queue(), ^{completionBlock(nil,nil,returnError);});
            return;
        }
        
//        NSLog(@"URL RESPONSE : %@",responseJSON);
        
        id processedResponse = [self getTweetsFromWebResponse:responseJSON];
        [self getMaxAndSinceIDForResponse:processedResponse favoriteAccount:favorite];
        dispatch_async(dispatch_get_main_queue(), ^{completionBlock(processedResponse,nil,nil);});
    }];
}

#pragma mark - Networking

-(NSError *)errorFromNetworkError:(NSError *)error
{
    NSString *description = NSLocalizedString(@"Could not connect to service. Please check your network settings.", @"");
    return [NSError errorWithDomain:BASE_API code:error.code userInfo:@{NSLocalizedDescriptionKey:description}];
}

- (NSString *)getMaxTagIDFromResponse:(id)serviceResponse
{
    return [(NSDictionary *)serviceResponse objectForKey:@"next_cursor"];
}

- (void)getMaxAndSinceIDForResponse:(id)processedResponse favoriteAccount:(FavoriteAccount *)favorite
{
    if ([processedResponse isKindOfClass:[NSArray class]]) {
        NSArray *tweetsArray = (NSArray *)processedResponse;
        
        if ([tweetsArray count] > 0) {
            //For since_id
//            TWTweet *recentTweet = (TWTweet *)[tweetsArray objectAtIndex:0];
//            [favorite setSinceID:[recentTweet tweetID]];
//            NSLog(@"************ SINCE_ID %@ *************** ",[favorite sinceID]);
//            
            //for max_id
            TWTweet * oldestTweet = (TWTweet *)[tweetsArray lastObject];
            NSInteger numberID = [[oldestTweet tweetID] integerValue];
            numberID--;
            [favorite setMaxID:[NSString stringWithFormat:@"%ld",numberID]];
            NSLog(@"************ MAX_ID %@ *************** ",[favorite maxID]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFavoritesSinceMaxIDUpdated object:nil];
        }
    }
}



- (NSMutableArray *)parseResponseFromWebService:(NSDictionary *)serviceResponse
{
    //Creates TWUserAccount Object from the huge Dictionary got through parsing JSON response
    NSMutableArray *returnArray = [NSMutableArray array];
    NSArray *listOfUsers = serviceResponse[@"users"];
    
    [listOfUsers enumerateObjectsUsingBlock:^(NSDictionary *userDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        TWTwitterAccount *user = [TWTwitterAccount new];
        user.userID = userDictionary[@"id"];
        user.username = userDictionary[@"name"];
        user.handlerName = [NSString stringWithFormat:@"@%@",userDictionary[@"screen_name"]];
        user.profileImageURL = [NSURL URLWithString:userDictionary[@"profile_image_url"]];
        [returnArray addObject:user];
    }];
    
    return returnArray;
}


- (id)getTweetsFromWebResponse:(id)responseJSON
{
    NSMutableArray *returnArray = [NSMutableArray new];
    
    NSMutableArray *tweetsArray = [NSMutableArray array];
    if ([responseJSON isKindOfClass:[NSArray class]]) {
        tweetsArray = [(NSArray *)responseJSON mutableCopy];
    }
    
    [tweetsArray enumerateObjectsUsingBlock:^(NSDictionary *tweetDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        TWTweet *newTweet = [TWTweet new];
        newTweet.tweetID = tweetDictionary[@"id_str"];
        NSDictionary *user = tweetDictionary[@"user"];
        newTweet.tweetAuthorScreenName = [NSString stringWithFormat:@"%@",user[@"name"]];
        newTweet.tweetAuthorHandler = [NSString stringWithFormat:@"@%@",user[@"screen_name"]];
        newTweet.tweetCreatedAt = [self getTweetCreatedAt:tweetDictionary[@"created_at"]];
        newTweet.tweetText = tweetDictionary[@"text"];
        newTweet.tweetRetweetCount = tweetDictionary[@"retweet_count"];
        newTweet.tweetFavoriteCount = tweetDictionary[@"favorite_count"];
        newTweet.tweetFavorited = [[tweetDictionary objectForKey:@"favorited"] boolValue];
        newTweet.tweetRetweeted = [[tweetDictionary objectForKey:@"retweeted"] boolValue];
        newTweet.profileImageURL = [NSURL URLWithString:user[@"profile_image_url"]];
        [newTweet setTweetAuthorID:user[@"id"]];

        [returnArray addObject:newTweet];
    }];
    
    return returnArray;
}

- (NSDate *)getTweetCreatedAt:(NSString *)createdAt
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *tweetDate = [dateFormatter dateFromString:createdAt];
    return tweetDate;
}

@end
