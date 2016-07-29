//
//  LoginViewController.m
//  Skilld
//
//  Created by TianHang on 3/6/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "LoginViewController.h"
#import "CommonUtils.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
	
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onLogin:(id)sender {
    // check if they are empty
    if(self.mTxtUsername.text.length == 0 || self.mTxtPassword.text.length == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Fill user name and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
    
    [PFUser logInWithUsernameInBackground:self.mTxtUsername.text password:self.mTxtPassword.text block:^(PFUser *user, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (user) {
            CommonUtils* utils = [CommonUtils sharedObject];
            [utils gotoMain:self segue:@"Login2Main"];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)animationView:(CGFloat)yPos {
	if(yPos == self.view.frame.origin.y)
		return;
    //	self.view.userInteractionEnabled = NO;
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect rt = self.view.frame;
						 rt.origin.y = yPos/* + 64*/;
						 self.view.frame = rt;
					 }completion:^(BOOL finished) {
                         //						 self.view.userInteractionEnabled = YES;
                     }];
}

#pragma mark - KeyBoard notifications
- (void)keyboardWillShow:(NSNotification*)notify {
    [self animationView:-50];
}

- (void)keyboardWillHide:(NSNotification*)notify {
	[self animationView:0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mTxtUsername) {
		[self.mTxtPassword becomeFirstResponder];
	}
    else if (textField == self.mTxtPassword) {
        [textField resignFirstResponder];
    }
    
	return YES;
}


@end
