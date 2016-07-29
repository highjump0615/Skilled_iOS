//
//  MainTabbarController.h
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabbarController : UITabBarController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImage *mImage;
    NSURL *mUrlMovie;
}

@end
