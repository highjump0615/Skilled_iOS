//
//  CommentViewController.h
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "SWTableViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface CommentViewController : UIViewController <SWTableViewCellDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mLblNoComment;
@property (weak, nonatomic) IBOutlet PFImageView *mImgPhoto;
@property (weak, nonatomic) IBOutlet UITableView *mCommentTable;
@property (weak, nonatomic) IBOutlet UITextField *mTxtContent;
@property (strong) BlogData *mBlogData;

- (IBAction)onBack:(id)sender;
- (IBAction)onSend:(id)sender;

@end
