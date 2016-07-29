//
//  EditProfileViewController.m
//  Skilld
//
//  Created by TianHang on 3/19/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "EditProfileViewController.h"
#import "MBProgressHUD.h"
#import "CommonUtils.h"
#import "ProfileViewController.h"

@interface EditProfileViewController () {
    UIImagePickerController *mPickerPhoto;
    UIImagePickerController *mPickerBack;
    UIImage *mImageBack;
}

@property (weak, nonatomic) IBOutlet UIImageView *mImgUsername;
@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;

@property (weak, nonatomic) IBOutlet UIImageView *mImgChgPswd;
@property (weak, nonatomic) IBOutlet UIButton *mButChgPswd;

@end

@implementation EditProfileViewController

static int s_nAboutMaxLength = 45;

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
	
    [self.mFullNameTxt setValue:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [self.mLocationTxt setValue:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIFont *proximaNova = [UIFont fontWithName:@"ProximaNova-Light" size:17];
    [self.mFullNameTxt setFont:proximaNova];
    [self.mLocationTxt setFont:proximaNova];
    [self.mUsernameLbl setFont:proximaNova];
    [self.mChgPswdLbl setFont:proximaNova];
    
    proximaNova = [UIFont fontWithName:@"ProximaNova-Light" size:15];
    [self.mAboutTxt setFont:proximaNova];
    self.mAboutTxt.placeholder = @"About me...";
    self.mAboutTxt.placeholderColor = [UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        self.mUsernameLbl.text = currentUser[@"username"];
        self.mFullNameTxt.text = currentUser[@"fullname"];
        self.mLocationTxt.text = currentUser[@"location"];
        self.mAboutTxt.text = currentUser[@"about"];
        
        PFFile *photoFile = currentUser[@"photo"];
        
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                [self.mPhotoBtn setImage:image forState:UIControlStateNormal];
            }
        }];
        
        BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:currentUser];
        BOOL isLinkedToTwitter = [PFTwitterUtils isLinkedWithUser:currentUser];
        
        if (isLinkedToFacebook || isLinkedToTwitter) {
            // hide username and change password
            [self.mImgUsername setHidden:YES];
            [self.mLblUsername setHidden:YES];
            
            [self.mImgChgPswd setHidden:YES];
            [self.mButChgPswd setHidden:YES];
            [self.mChgPswdLbl setHidden:YES];
        }
    }
    
    mbSetPhoto = NO;
    mImageBack = nil;
    
    [self.mAboutLeftLbl setText:[NSString stringWithFormat:@"%d", s_nAboutMaxLength - self.mAboutTxt.text.length]];
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

    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        currentUser[@"fullname"] = self.mFullNameTxt.text;
        currentUser[@"location"] = self.mLocationTxt.text;
        currentUser[@"about"] = self.mAboutTxt.text;
        [currentUser saveInBackground];
        
        if (mbSetPhoto) {
            // saving photo image
            UIImage* image = self.mPhotoBtn.imageView.image;
            UIImage* convertImage = [CommonUtils imageWithImage:image scaledToSize:CGSizeMake(140, 140)];
            
            NSData *imageData = UIImageJPEGRepresentation(convertImage, 10);
            
            PFFile *imageFile = [PFFile fileWithName:@"photo.jpg" data:imageData];
            
            // Save PFFile
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    // Create a PFObject around a PFFile and associate it with the current user
                    currentUser[@"photo"] = imageFile;
                    
                    [self saveUserInfo];
                }
                else{
                    [hud hide:YES];
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            } progressBlock:^(int percentDone) {
                // Update your progress spinner here. percentDone will be between 0 and 100.
                hud.progress = (float)percentDone/100;
            }];
        }
        else {
            [self saveUserInfo];
        }
        
    }
}

- (void)saveUserInfo {
    PFUser *currentUser = [PFUser currentUser];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            CommonUtils *utils =  [CommonUtils sharedObject];
            utils.bProfilePhotoUpdated = mbSetPhoto;
        }
        else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    if (mImageBack) {
        ProfileViewController *profileViewController = (ProfileViewController *)self.mParent;
        [profileViewController.mBackImage setImage:mImageBack];
        
        NSData *imageData = UIImageJPEGRepresentation(mImageBack, 10);
        
        PFFile *imageBackFile = [PFFile fileWithName:@"back.jpg" data:imageData];
        // Save PFFile
        [imageBackFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                currentUser[@"background"] = imageBackFile;
                [currentUser saveInBackground];
                
                [self onBack:nil];
            }
            else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else {
        [self onBack:nil];
    }
    
}

- (IBAction)onEditPhoto:(id)sender {
    mPickerPhoto = [[UIImagePickerController alloc] init];
    mPickerPhoto.delegate = self;
    mPickerPhoto.allowsEditing = YES;
    mPickerPhoto.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
    [self presentViewController:mPickerPhoto animated:YES completion:NULL];
}

- (IBAction)onSetBackground:(id)sender {
    mPickerBack = [[UIImagePickerController alloc] init];
    mPickerBack.delegate = self;
    mPickerBack.allowsEditing = YES;
    mPickerBack.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
    [self presentViewController:mPickerBack animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    
    if (picker == mPickerPhoto) {
	
        [self.mPhotoBtn setImage:image forState:UIControlStateNormal];
        
        mbSetPhoto = YES;
    }
    else if (picker == mPickerBack) {
        mImageBack = image;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mFullNameTxt) {
		[self.mLocationTxt becomeFirstResponder];
	}
	else if (textField == self.mLocationTxt) {
        [textField resignFirstResponder];
	}
    
	return YES;
}

# pragma mark - TextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (textView == self.mAboutTxt) {
            [self.mFullNameTxt becomeFirstResponder];
        }
        else {
            [textView resignFirstResponder];
        }
        return NO;
    }
    
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    if (newLength <= s_nAboutMaxLength) {
        [self.mAboutLeftLbl setText:[NSString stringWithFormat:@"%d", s_nAboutMaxLength - newLength]];
        return YES;
    }
    else if (newLength < oldLength) {
        [self.mAboutLeftLbl setText:[NSString stringWithFormat:@"%d", s_nAboutMaxLength - newLength]];
        return YES;
    }
    else {
        return NO;
    }
}


@end
