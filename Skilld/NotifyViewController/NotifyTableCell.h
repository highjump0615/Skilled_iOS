//
//  NotifyTableCell.h
//  Skilld
//
//  Created by TianHang on 3/10/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifyTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *mImgUser;
@property (weak, nonatomic) IBOutlet UILabel *mLblText;
@property (weak, nonatomic) IBOutlet UILabel *mLblTime;
@property (weak, nonatomic) IBOutlet PFImageView *mImgPhoto;

@end
