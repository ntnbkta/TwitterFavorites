//
//  TWTweetCardViewController.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/22/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWTweetView.h"

@interface TWTweetCardViewController : UIViewController <MDCSwipeToChooseDelegate>

@property (nonatomic, strong) TWTweetView *frontCardView;
@property (nonatomic, strong) TWTweetView *backCardView;

@end
