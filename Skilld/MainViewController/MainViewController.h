//
//  MainViewController.h
//  Skilld
//
//  Created by TianHang on 3/4/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *mLblWelcome;
@property (weak, nonatomic) IBOutlet UIButton *mBtnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *mBtnTwitter;

- (IBAction)onFacebook:(id)sender;
- (IBAction)onTwitter:(id)sender;

@end
