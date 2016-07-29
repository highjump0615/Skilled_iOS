//
//  MainViewController.m
//  Skilld
//
//  Created by TianHang on 3/4/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "CommonUtils.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    
    UIFont *proximaNova = [UIFont fontWithName:@"ProximaNova-Bold" size:30];
    [self.mLblWelcome setFont:proximaNova];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        CommonUtils* utils = [CommonUtils sharedObject];
        [utils gotoMain:self segue:@"Startup2Main"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFacebook:(id)sender {

    [self.mBtnFacebook setEnabled:NO];
    
    NSArray *permissionsArray = @[ @"user_about_me", @"email", @"publish_actions", @"publish_stream", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        CommonUtils* utils = [CommonUtils sharedObject];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.mBtnFacebook setEnabled:YES];
        
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        }
        else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            
            // Create request for user's Facebook data
            FBRequest *request = [FBRequest requestForMe];
            
            // Send request to Facebook
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (!error) {
                    
                    PFUser *currentUser = [PFUser currentUser];
                    
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    // check and see if a user already exists for this email
                    PFQuery *query = [PFUser query];
                    [query whereKey:@"email" equalTo:userData[@"email"]];
                    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        if(number > 0) {
                            
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                            message:[NSString stringWithFormat:@"%@ is already existing", userData[@"email"]]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                            
                            // delete the user that was created as part of Parse's Facebook login
                            [currentUser deleteInBackground];
//                            [PFUser logOut];
                            
                            // put the user logged out notification on the wire
                            [[FBSession activeSession] closeAndClearTokenInformation];

                        }
                        else {
                            if (userData[@"username"]) {
                                currentUser.username = userData[@"username"];
                            }
                            
                            if (userData[@"name"]) {
                                currentUser[@"fullname"] = userData[@"name"];
                            }
                            
                            if (userData[@"location"]) {
                                currentUser[@"location"] = userData[@"location"][@"name"];
                            }
                            currentUser.email = userData[@"email"];
                            
                            NSString *facebookID = userData[@"id"];
                            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                            
                            NSData *data = [NSData dataWithContentsOfURL:pictureURL];
                            PFFile *photoFile = [PFFile fileWithData:data];
                            currentUser[@"photo"] = photoFile;
                            
                            [currentUser saveInBackground];
                            
                            [utils gotoMain:self segue:@"Startup2Main"];
                        }
                    }];
                    
                    
                }
                
            }];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        } else {
            NSLog(@"User logged in through Facebook!");
            
            if (user) {
                
                [utils gotoMain:self segue:@"Startup2Main"];
            }
        }
        
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)onTwitter:(id)sender {
    
    [self.mBtnTwitter setEnabled:NO];
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        
        CommonUtils* utils = [CommonUtils sharedObject];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.mBtnTwitter setEnabled:YES];
        
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            
            PFUser *currentUser = [PFUser currentUser];
            currentUser.username = [[PFTwitterUtils twitter] screenName];
            
            // check and see if a user already exists for this email
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" equalTo:currentUser.username];
            [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if(number > 0) {
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:[NSString stringWithFormat:@"%@ is already existing", currentUser.username]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                    // delete the user that was created as part of Parse's Facebook login
                    [currentUser deleteInBackground];
//                    [PFUser logOut];
                }
                else {
                    NSURL *urlShow = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", currentUser.username]];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlShow];
                    [[PFTwitterUtils twitter] signRequest:request];
                    NSURLResponse *response = nil;
                    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                         returningResponse:&response
                                                                     error:&error];
                    
                    if ( error == nil){
                        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                        NSURL *pictureURL = [NSURL URLWithString:[result objectForKey:@"profile_image_url_https"]];
                        
                        NSData *data = [NSData dataWithContentsOfURL:pictureURL];
                        PFFile *photoFile = [PFFile fileWithData:data];
                        currentUser[@"photo"] = photoFile;
                        
                        NSString * names = [result objectForKey:@"name"];
                        [currentUser setObject:names forKey:@"fullname"];
                        
                        [currentUser saveInBackground];
                        [utils gotoMain:self segue:@"Startup2Main"];
                    }
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        else {
            NSLog(@"User logged in with Twitter!");
            
            if (user) {
                [utils gotoMain:self segue:@"Startup2Main"];
            }

        }
        
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

@end
