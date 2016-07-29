//
//  PostViewController.h
//  Skilld
//
//  Created by TianHang on 3/10/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"
#import "BlogCategory.h"
#import <AWSS3/AWSS3.h>

@interface PostViewController : UIViewController <AmazonServiceRequestDelegate> {
    BlogCategory *mCategory;    
    PFObject *mBlog;
}

@property (strong) UIImage *mImageToPost;
@property (strong) NSURL *mUrlVideoToPost;

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UITextField *mTitleTxt;
@property (weak, nonatomic) IBOutlet UILabel *mTitleLeftLbl;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *mContentTxt;
@property (weak, nonatomic) IBOutlet UILabel *mContentLeftLbl;

@property (weak, nonatomic) IBOutlet UILabel *mCategoryLbl;
@property (weak, nonatomic) IBOutlet PFImageView *mPhotoImg;

@property (weak, nonatomic) IBOutlet UIView *mViewTitle;
@property (weak, nonatomic) IBOutlet UIView *mViewPost;

@property (strong) UIViewController *mParentViewController;

- (IBAction)onBack:(id)sender;
- (IBAction)onShare:(id)sender;

@end
