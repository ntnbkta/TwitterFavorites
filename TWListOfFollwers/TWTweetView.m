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
#import <SDWebImage/UIImageView+WebCache.h>

@interface TWTweetView ()

@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *handlerName;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *retweetedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoritedCountLabel;

@end

@implementation TWTweetView

+(instancetype)newTweetView
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TWTweetView" owner:self options:nil];
    return [views objectAtIndex:0];
}


- (void)setFrame:(CGRect)frame tweet:(TWTweet *)tweet options:(MDCSwipeToChooseViewOptions *)options
{
    [super setFrame:frame];
    [self setFrame:frame];
    
    [self setBackgroundColor:[UIColor colorWithRed:41.0/255.0 green:161.0/255.0 blue:236.0/255.0 alpha:1.0]];

    [self.profileImageView.layer setCornerRadius:3.0f];
    [self.profileImageView.layer setMasksToBounds:YES];

    [self setTweet:tweet];
    [self setOptions:options];
}

- (void)setTweet:(TWTweet *)tweet
{
    _tweet = tweet;
    [self.screenName setText:_tweet.tweetAuthorScreenName];
    [self.handlerName setText:_tweet.tweetAuthorHandler];
    [self.createdAtLabel setText:[self getTweetCreatedAtStringFromDate:_tweet.tweetCreatedAt]];
    [self.tweetTextView setText:_tweet.tweetText];
    [self.retweetedCountLabel setText:[NSString stringWithFormat:@"%@",_tweet.tweetRetweetCount]];
    [self.favoritedCountLabel setText:[NSString stringWithFormat:@"%@",_tweet.tweetFavoriteCount]];

    [self.profileImageView sd_setImageWithURL:_tweet.profileImageURL placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
}

- (NSString *)getTweetCreatedAtStringFromDate:(NSDate *)tweetDate
{    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    [dateFormatter setDateFormat:@"M/d/yy h:mm a"];
    NSString *createdAtString = [dateFormatter stringFromDate:tweetDate];
    
    return createdAtString;
}

@end
