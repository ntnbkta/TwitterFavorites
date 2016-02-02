//
//  TWTweetCardViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/22/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWTweetCardViewController.h"
#import "TWTwinderEngine.h"
#import "TWTweet.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

#define kTWFavoritesListUpdated @"TWFavoritesListUpdated"

static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface TWTweetCardViewController ()

@property (nonatomic, strong) TWTwinderEngine *twinderEngine;
@property (nonatomic, strong) NSMutableArray *tweetsArray;
@property (nonatomic, strong) TWTweet *currentTweet;
@end


@implementation TWTweetCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_tweetsArray) {
        _tweetsArray = [NSMutableArray new];
    }
    self.twinderEngine = [TWTwinderEngine sharedManager];
    
    [self favoritesListUpdated:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesListUpdated:) name:kTWFavoritesListUpdated object:nil];


}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)favoritesListUpdated:(NSNotification *)notif
{
    [self.twinderEngine fetchTweetsOfFavoritesWithCompletionBlock:^(NSArray *tweetsList) {
        self.tweetsArray = [tweetsList mutableCopy];
        // Display the first ChoosePersonView in front. Users can swipe to indicate
        // whether they like or dislike the person displayed.
        self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
        [self.view addSubview:self.frontCardView];
        
        // Display the second ChoosePersonView in back. This view controller uses
        // the MDCSwipeToChooseDelegate protocol methods to update the front and
        // back views after each user swipe.
        self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        
        // Add buttons to programmatically swipe the view left or right.
        // See the `nopeFrontCardView` and `likeFrontCardView` methods.
        [self constructNopeButton];
        [self constructLikedButton];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"********** %s ERROR : %@ **********", __PRETTY_FUNCTION__, [error localizedDescription]);
    }];

}


#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentTweet.tweetText);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentTweet.tweetID);
    } else {
        NSLog(@"You liked %@.", self.currentTweet.tweetID);
    }
    
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(TWTweetView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    self.currentTweet = frontCardView.tweet;
}


- (TWTweetView *)popPersonViewWithFrame:(CGRect)frame {
    if ([self.tweetsArray count] == 0) {
        return nil;
    }
    
    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    
    TWTweetView *tweetView = [TWTweetView newTweetView];
    [tweetView setFrame:frame tweet:self.tweetsArray[0] options:options];
    [tweetView setBackgroundColor:[UIColor colorWithRed:41.0/255.0 green:161.0/255.0 blue:236.0/255.0 alpha:1.0]];
    [self.tweetsArray removeObjectAtIndex:0];
    return tweetView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 100.f;
    CGFloat bottomPadding = 300.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"nope"];
    button.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.frontCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

// Create and add the "like" button.
- (void)constructLikedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"liked"];
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.frontCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:29.f/255.f
                                         green:245.f/255.f
                                          blue:106.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

@end
