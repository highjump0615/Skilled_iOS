//
//  SignupViewController.h
//  Skilld
//
//  Created by TianHang on 3/6/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *mTxtEmail;
@property (weak, nonatomic) IBOutlet UITextField *mTxtUsername;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPassword;

- (IBAction)onBackMain:(id)sender;
- (IBAction)onSignup:(id)sender;

@end
