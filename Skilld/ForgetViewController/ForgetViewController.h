//
//  ForgetViewController.h
//  Skilld
//
//  Created by TianHang on 3/6/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *mTxtEmail;


- (IBAction)onBack:(id)sender;
- (IBAction)onLogin:(id)sender;
- (IBAction)onRequest:(id)sender;

@end
