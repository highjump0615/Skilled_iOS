//
//  MainTabbarController.m
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "MainTabbarController.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PostViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MainTabbarController ()

@end

@implementation MainTabbarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.delegate = appdelegate;
	
    // set selected and unselected icons
    // home
    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];

    item.image = [[UIImage imageNamed:@"tab_home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_home_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [item setTitlePositionAdjustment:UIOffsetMake(0, -10)];
    
    // interest
    item = [self.tabBar.items objectAtIndex:1];
    
    item.image = [[UIImage imageNamed:@"tab_interest.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_interest_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [item setTitlePositionAdjustment:UIOffsetMake(0, -10)];
    
    // shutter
//    item = [self.tabBar.items objectAtIndex:2];
    
//    item.image = [[UIImage imageNamed:@"tab_shutter.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
//    [item setTitlePositionAdjustment:UIOffsetMake(0, -10)];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( self.tabBar.bounds.size.width / 2 - 16, 8, 32, 32);
    [cameraButton setImage:[UIImage imageNamed:@"tab_shutter.png"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"tab_shutter_select.png"] forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:cameraButton];

    // notify
    item = [self.tabBar.items objectAtIndex:3];
    
    item.image = [[UIImage imageNamed:@"tab_notify.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_notify_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [item setTitlePositionAdjustment:UIOffsetMake(0, -10)];
    
    // profile
    item = [self.tabBar.items objectAtIndex:4];
    
    item.image = [[UIImage imageNamed:@"tab_profile.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_profile_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [item setTitlePositionAdjustment:UIOffsetMake(0, -10)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)photoCaptureButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Your Camera", @"Media From Library", nil];
    [actionSheet showFromTabBar:self.tabBar];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie, nil];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie, nil];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie, nil];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    mUrlMovie = nil;
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
//        NSString *moviePath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
        // NSLog(@"%@",moviePath);
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
//        }
    
        mUrlMovie = videoUrl;
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        mImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);

    }
    else {
        mImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
    }
    
    [self performSegueWithIdentifier:@"Tabbar2Post" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Tabbar2Post"]) {
        PostViewController* postViewController = [segue destinationViewController];
        postViewController.mImageToPost = mImage;
        postViewController.mUrlVideoToPost = mUrlMovie;
    }
}



@end
