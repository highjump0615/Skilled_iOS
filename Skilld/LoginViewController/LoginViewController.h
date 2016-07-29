//
//  LoginViewController.h
//  Skilld
//
//  Created by TianHang on 3/6/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *mTxtUsername;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPassword;

- (IBAction)onBack:(id)sender;
- (IBAction)onLogin:(id)sender;

@end
