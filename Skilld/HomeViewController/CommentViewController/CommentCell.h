//
//  CommentCell.h
//  Skilld
//
//  Created by TianHang on 3/8/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"


//@interface CommentCell : SWTableViewCell
@interface CommentCell : UITableViewCell

@property(strong) UIButton *nameButton;
@property(strong) UILabel *timeLabel;
@property(strong) UILabel *contentLabel;
@property(strong) UITextView *contentText;
@property(strong) PFImageView *imgPhoto;

@end
