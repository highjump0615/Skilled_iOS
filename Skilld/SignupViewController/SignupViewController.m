//
//  SignupViewController.m
//  Skilld
//
//  Created by TianHang on 3/6/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "SignupViewController.h"
#import "MBProgressHUD.h"
#import "CommonUtils.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

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

- (IBAction)onBackMain:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onSignup:(id)sender {
    
    // check if they are empty
    if (self.mTxtUsername.text.length == 0 || self.mTxtPassword.text.length == 0 || self.mTxtEmail.text.length == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Fill user name, password and mail address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
    
    // Start request
    PFUser *user = [PFUser user];
    user.username = self.mTxtUsername.text;
    user.password = self.mTxtPassword.text;
    user.email = self.mTxtEmail.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            CommonUtils* utils = [CommonUtils sharedObject];
            [utils gotoMain:self segue:@"SignUp2Main"];
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
    [self animationView:-90];
}

- (void)keyboardWillHide:(NSNotification*)notify {
	[self animationView:0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mTxtEmail) {
		[self.mTxtUsername becomeFirstResponder];
	}
	else if (textField == self.mTxtUsername) {
		[self.mTxtPassword becomeFirstResponder];
	}
    else if (textField == self.mTxtPassword) {
        [textField resignFirstResponder];
    }
    
	return YES;
}



@end
