//
//  EditProfileViewController.h
//  Skilld
//
//  Created by TianHang on 3/19/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"

@interface EditProfileViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    BOOL mbSetPhoto;
}

@property (weak, nonatomic) IBOutlet PlaceholderTextView *mAboutTxt;
@property (weak, nonatomic) IBOutlet UILabel *mAboutLeftLbl;

@property (weak, nonatomic) IBOutlet UITextField *mFullNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *mLocationTxt;
@property (weak, nonatomic) IBOutlet UILabel *mUsernameLbl;
@property (weak, nonatomic) IBOutlet UILabel *mChgPswdLbl;
@property (weak, nonatomic) IBOutlet UIButton *mPhotoBtn;

@property (weak, nonatomic) UIViewController *mParent;

- (IBAction)onBack:(id)sender;
- (IBAction)onUpdate:(id)sender;
- (IBAction)onEditPhoto:(id)sender;



@end
