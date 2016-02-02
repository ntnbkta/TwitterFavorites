//
//  TWTweetView.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/29/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWTweetView.h"
#import "TWImageLabelView.h"
#import "TWTweet.h"


@interface TWTweetView ()

@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *handlerName;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;

@end

@implementation TWTweetView

+(instancetype)newTweetView
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TWTweetView" owner:self options:nil];
    return [views objectAtIndex:0];
}


- (void)setFrame:(CGRect)frame tweet:(TWTweet *)tweet options:(MDCSwipeToChooseViewOptions *)options
{
    [self setFrame:frame];
    [self setTweet:tweet];
    [self setOptions:options];
}

- (void)setTweet:(TWTweet *)tweet
{
    _tweet = tweet;
    [self.screenName setText:_tweet.tweetAuthorHandler];
    [self.handlerName setText:_tweet.tweetAuthorHandler];
    [self.createdAtLabel setText:[self getTweetCreatedAtStringFromDate:_tweet.tweetCreatedAt]];
    [self.tweetTextView setText:_tweet.tweetText];
}

- (NSString *)getTweetCreatedAtStringFromDate:(NSDate *)tweetDate
{    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    [dateFormatter setDateFormat:@"M/d/yy h:mm a"];
    NSString *createdAtString = [dateFormatter stringFromDate:tweetDate];
    
    return createdAtString;
}

@end
