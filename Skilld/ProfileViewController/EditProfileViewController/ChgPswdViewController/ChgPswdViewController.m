//
//  ChgPswdViewController.m
//  Skilld
//
//  Created by TianHang on 3/19/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "ChgPswdViewController.h"
#import "MBProgressHUD.h"

@interface ChgPswdViewController ()

@end

@implementation ChgPswdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.mOldPswdTxt setValue:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [self.mNewPswdTxt setValue:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [self.mConfirmPswdTxt setValue:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIFont *proximaNova = [UIFont fontWithName:@"ProximaNova-Light" size:17];
    [self.mOldPswdTxt setFont:proximaNova];
    [self.mNewPswdTxt setFont:proximaNova];
    [self.mConfirmPswdTxt setFont:proximaNova];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onUpdate:(id)sender {
    
    NSString* strOldPass = self.mOldPswdTxt.text;
	NSString* strNewPass = self.mNewPswdTxt.text;
	NSString* strRetypePass = self.mConfirmPswdTxt.text;
    
	if(strOldPass.length == 0 || strNewPass.length == 0 || strRetypePass.length == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Type new password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
    
	if([strNewPass isEqualToString:strRetypePass] == NO) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Retype password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFUser logInWithUsernameInBackground:[PFUser currentUser].username password:strOldPass block:^(PFUser *user, NSError *error) {
        
        if (user) {
            [PFUser currentUser].password = strNewPass;
            [[PFUser currentUser] saveInBackground];
            [self onBack:nil];
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Old password is wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mOldPswdTxt) {
		[self.mNewPswdTxt becomeFirstResponder];
	}
    else if (textField == self.mNewPswdTxt) {
		[self.mConfirmPswdTxt becomeFirstResponder];
	}
	else if (textField == self.mConfirmPswdTxt) {
        [textField resignFirstResponder];
	}
    
	return YES;
}

@end
