//
//  TWTweetCardViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/22/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWTweetCardViewController.h"
#import "TWFavoritesTableViewController.h"
#import "TWTwinderEngine.h"
#import "TWFavoritesManager.h"
#import "TWTweet.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "MMPulseView.h"
#import "UIView+Toast.h"

#define kTWFavoritesListUpdated @"TWFavoritesListUpdated"

@interface TWTweetCardViewController ()

@property (nonatomic, strong) TWTwinderEngine *twinderEngine;
@property (nonatomic, strong) NSMutableArray *tweetsArray;
@property (nonatomic, strong) TWTweet *currentTweet;
@property (nonatomic, strong) MMPulseView *pulseView;
@property (weak, nonatomic) IBOutlet UIView *optionsContainerView;

@property (nonatomic, assign) BOOL newSession;

@end

@implementation TWTweetCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_tweetsArray) {
        _tweetsArray = [NSMutableArray new];
    }
    self.twinderEngine = [TWTwinderEngine sharedManager];
    
    [self setUpBarButtonItem];
    [self setUpPulseLoadingView:nil];
    self.newSession = YES;
    [self fetchTweetsOfFavorites:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTweetsOfFavorites:) name:kTWFavoritesListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpPulseLoadingView:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpBarButtonItem];
    [self setUpPulseLoadingView:nil];
}

- (void)setUpBarButtonItem
{
    UIImage *buttonImage = [UIImage imageNamed:@"favorites.png"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    
    // Initialize the UIBarButtonItem
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    
    // Set the Target and Action for aButton
    [aButton addTarget:self action:@selector(showFavorites:) forControlEvents:UIControlEventTouchUpInside];
    
    // Then you can add the aBarButtonItem to the UIToolbar
    [self.navigationItem setRightBarButtonItem:aBarButtonItem];
}

- (void)setUpPulseLoadingView:(NSNotification *)notif
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    if(!_pulseView)
    {
        _pulseView = [[MMPulseView alloc] init];
        _pulseView.frame = CGRectMake(CGRectGetWidth(screenRect)/1,
                                     CGRectGetHeight(screenRect)/2*0,
                                     CGRectGetWidth(screenRect)/1,
                                     CGRectGetHeight(screenRect)/1);
        
        _pulseView.center = self.view.center;
        [self.view insertSubview:_pulseView belowSubview:_optionsContainerView];
        
        _pulseView.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        _pulseView.colors = @[(__bridge id)[UIColor colorWithRed:0.996 green:0.647 blue:0.008 alpha:1].CGColor,(__bridge id)[UIColor colorWithRed:1 green:0.31 blue:0.349 alpha:1].CGColor,(__bridge id)[UIColor colorWithRed:41.0/255.0 green:161.0/255.0 blue:236.0/255.0 alpha:1.0].CGColor];
        
        CGFloat posY = (CGRectGetHeight(screenRect)-320)/2/CGRectGetHeight(screenRect);
        _pulseView.startPoint = CGPointMake(0.5, posY);
        _pulseView.endPoint = CGPointMake(0.5, 1.0f - posY);
        
        _pulseView.minRadius = 40;
        _pulseView.maxRadius = 150;
        
        _pulseView.duration = 4;
        _pulseView.count = 6;
        _pulseView.lineWidth = 2.0f;
    }
    [self.pulseView startAnimation];
}

- (void)fetchTweetsOfFavorites:(NSNotification *)notif
{
    [self.optionsContainerView setHidden:YES];
    [self.pulseView startAnimation];
    [self.twinderEngine fetchTweetsOfFavoritesWithNewFetch:self.newSession completionBlock:^(NSArray *tweetsList)
     {
         if (!tweetsList) {
             [self.view makeToast:@"Add Favorites to Lists."];
             return ;
         }
         if (self.tweetsArray) {
             self.newSession = NO;
             [self.tweetsArray addObjectsFromArray:tweetsList];
         }
         // Display the first ChoosePersonView in front. Users can swipe to indicate
         // whether they like or dislike the person displayed.
         [self.pulseView stopAnimation];

         if (!self.frontCardView) {
             self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
             [self.view addSubview:self.frontCardView];
             
             // Display the second ChoosePersonView in back. This view controller uses
             // the MDCSwipeToChooseDelegate protocol methods to update the front and
             // back views after each user swipe.
             self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
             [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];

         }
         
         [self.optionsContainerView setHidden:NO];
     } errorBlock:^(NSError *error) {
         [self.optionsContainerView setHidden:YES];
         
         NSLog(@"********** %s ERROR : %@ **********", __PRETTY_FUNCTION__, [error localizedDescription]);
     }];
}


#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
//    NSLog(@"You couldn't decide on %@.", self.currentTweet.tweetText);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    
    TWTweetView *swipedView = (TWTweetView *)view;
    [self.twinderEngine.favoritesManager lastReadTweet:swipedView.tweet];
    
    if ([self.tweetsArray count]==0 && !self.backCardView) {
        [self.optionsContainerView setHidden:YES];
        self.newSession = NO;
        [self fetchTweetsOfFavorites:nil];
    }
    if (direction == MDCSwipeDirectionLeft) {
//        NSLog(@"You noped %@.", self.currentTweet.tweetID);
    } else {
//        NSLog(@"You liked %@.", self.currentTweet.tweetID);
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
    options.likedText = @"Favorite";
    options.nopeText = @"Retweet";
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


#pragma mark Control Events

- (IBAction)showFavorites:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *favoritesViewController = [storyboard instantiateViewControllerWithIdentifier:@"TWFavoritesNavigationController"];
    
    [self.navigationController presentViewController:favoritesViewController animated:YES completion:nil];

}

- (IBAction)tweetRead:(id)sender
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         [self.frontCardView setHidden:YES];
                         [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
                        
                     } completion:nil];
}


- (IBAction)retweetTweet:(id)sender
{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];

}

- (IBAction)favoriteTweet:(id)sender
{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];

}

@end
