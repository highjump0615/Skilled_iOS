//
//  FollowViewController.h
//  Skilled
//
//  Created by TianHang on 4/8/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface FollowViewController : UIViewController

@property (strong) PFUser *mUser;
@property (nonatomic) BOOL mbFollowing;
@property (strong) PFObject *mBlogObject;

@end
