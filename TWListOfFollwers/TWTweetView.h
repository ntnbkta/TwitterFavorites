//
//  TWTweetView.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/29/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@class TWTweet;

@interface TWTweetView : MDCSwipeToChooseView

@property (nonatomic, strong) TWTweet *tweet;

+(instancetype)newTweetView;
- (void)setFrame:(CGRect)frame tweet:(TWTweet *)tweet options:(MDCSwipeToChooseViewOptions *)options;

@end
