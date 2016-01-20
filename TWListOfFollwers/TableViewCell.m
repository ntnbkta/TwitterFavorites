//
//  TableViewCell.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.userProfilePic.layer setCornerRadius:3.0f];
    [self.userProfilePic.layer setMasksToBounds:YES];
    
    [self.userName setFont:[UIFont boldSystemFontOfSize:15.0]];
    [self.userName setTextAlignment:NSTextAlignmentLeft];
    [self.userName setTextColor:[UIColor blackColor]];
    [self.userName setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.userProfilePic.image = nil;
    
}

@end
