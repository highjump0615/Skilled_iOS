//
//  NotifyViewController.h
//  Skilld
//
//  Created by TianHang on 3/10/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationData : NSObject

@property (strong) PFUser *user;
@property (strong) NSString *strUsername;
@property (strong) NSString *strComment;
@property (strong) PFFile *image;
@property (nonatomic) int type;
@property (strong) NSDate *date;

@end

@interface NotifyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end
