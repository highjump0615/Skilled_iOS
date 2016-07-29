//
//  ProfileInfoCell.h
//  Skilled
//
//  Created by TianHang on 4/16/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *mPhotoImg;
@property (weak, nonatomic) IBOutlet UILabel *mFullNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *mLocationLbl;
@property (weak, nonatomic) IBOutlet UILabel *mAboutLbl;

@property (weak, nonatomic) IBOutlet UILabel *mPostNumLbl;
@property (weak, nonatomic) IBOutlet UILabel *mFollowerNumLbl;
@property (weak, nonatomic) IBOutlet UILabel *mFollowingNumLbl;

@property (weak, nonatomic) IBOutlet UIButton *mButBlog;
@property (weak, nonatomic) IBOutlet UIButton *mButGrid;

@property (weak, nonatomic) IBOutlet UIButton *mButFollower;
@property (weak, nonatomic) IBOutlet UIButton *mButFollowing;

@property (weak, nonatomic) IBOutlet UIButton *mUserAddBut;

@end
