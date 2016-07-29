//
//  ChgPswdViewController.h
//  Skilld
//
//  Created by TianHang on 3/19/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChgPswdViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *mOldPswdTxt;
@property (weak, nonatomic) IBOutlet UITextField *mNewPswdTxt;
@property (weak, nonatomic) IBOutlet UITextField *mConfirmPswdTxt;

- (IBAction)onBack:(id)sender;
- (IBAction)onUpdate:(id)sender;

@end
