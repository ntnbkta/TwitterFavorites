//
//  TWAPIManager.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWAPIManager.h"
#import "TWAccountManager.h"
#import "TWUserAccount.h"

#define BASE_API @"https://api.twitter.com/1.1/"

#define FRIENDS_API @"friends/list.json"

@implementation TWAPIManager

+ (TWAPIManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static TWAPIManager *sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[TWAPIManager alloc] init];
    });
    return sharedManager;
}

- (void)fetchListOfFollowingForTwitterAccount:(ACAccount *)account withNextCursor:(NSString *)nextCursor withCompletionBlock:(TwitterWebServiceCompletionBlock)completionBlock
{
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

    NSLog(@"****** NEXT CURSOR : %@",nextCursorId);
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

- (NSMutableArray *)parseResponseFromWebService:(NSDictionary *)serviceResponse
{
    //Creates TWUserAccount Object from the huge Dictionary got through parsing JSON response
    NSMutableArray *returnArray = [NSMutableArray array];
    NSArray *listOfUsers = serviceResponse[@"users"];
    
    [listOfUsers enumerateObjectsUsingBlock:^(NSDictionary *userDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        TWUserAccount *user = [TWUserAccount new];
        user.userID = userDictionary[@"id"];
        user.username = userDictionary[@"name"];
        user.handlerName = [NSString stringWithFormat:@"@%@",userDictionary[@"screen_name"]];
        user.profileImageURL = [NSURL URLWithString:userDictionary[@"profile_image_url"]];
        
        [returnArray addObject:user];
    }];
    
    return returnArray;
}


@end
