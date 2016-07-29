//
//  ProfileViewController.h
//  Skilld
//
//  Created by TianHang on 3/10/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController {
    NSMutableArray *mBlogs;
    NSMutableArray *mImageBlogs;
}

//@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet PFImageView *mBackImage;

@property (strong) NSMutableArray *mBlogs;
@property (strong) NSMutableArray *mImageBlogs;


@end
