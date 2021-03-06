//
//  TWFollowingTableViewCell.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWFollowingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *handlerName;
@property (weak, nonatomic) IBOutlet UIButton *addToFavorites;

@end
