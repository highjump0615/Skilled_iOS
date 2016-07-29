//
//  CommonUtils.m
//  Skilld
//
//  Created by TianHang on 3/14/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "CommonUtils.h"
#import "MBProgressHUD.h"
#import <AWSRuntime/AWSRuntime.h>


@implementation CommentData

@end

@implementation LikeData

@end

@implementation BlogData

@end

@interface CommonUtils()


@end

@implementation CommonUtils

@synthesize mCategoryList;
@synthesize mBlogToPost;
@synthesize mBlogList;

+ (id)sharedObject {
	static CommonUtils* utils = nil;
	if(utils == nil) {
		utils = [[CommonUtils alloc] init];
        utils.mCategoryList = [[NSMutableArray alloc] init];
        
        utils.bProfilePhotoUpdated = YES;
        
        utils.bgTask = UIBackgroundTaskInvalid;
        
        // Initial the S3 Client.
        utils.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        utils.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
        utils.s3.timeout = 3000;
        
        utils.tm = [S3TransferManager new];
        utils.tm.s3 = utils.s3;
        
        // Create the picture bucket.
//        S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:VIDEO_BUCKET andRegion:[S3Region USWest2]];
//        S3CreateBucketResponse *createBucketResponse = [utils.s3 createBucket:createBucketRequest];
//        if(createBucketResponse.error != nil)
//        {
//            NSLog(@"Error: %@", createBucketResponse.error);
//        }
	}
	return utils;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width height:(float)i_height
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, i_height));
    [sourceImage drawInRect:CGRectMake(0, - (newHeight - i_height) / 2, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [alertView show];
}

+ (NSString *)getTimeString:(NSDate *)date {
    
    NSString *strTime = @"";
    
    NSTimeInterval time = -[date timeIntervalSinceNow];
    int min = (int)time / 60;
    int hour = min / 60;
    int day = hour / 24;
    int month = day / 30;
    int year = month / 12;
    
    if(min < 60) {
        strTime = [NSString stringWithFormat:@"%d min ago", min];
    }
    else if(min >= 60 && min < 60 * 24) {
        if(hour < 24) {
            strTime = [NSString stringWithFormat:@"%d hours ago", hour];
        }
    }
    else if (day < 31) {
        strTime = [NSString stringWithFormat:@"%d days ago", day];
    }
    else if (month < 12) {
        strTime = [NSString stringWithFormat:@"%d months ago", month];
    }
    else {
        strTime = [NSString stringWithFormat:@"%d years ago", year];
    }
    
    return strTime;
}

+ (NSString *)getUsernameToShow:(PFUser *)user {
    
    NSString *strUsername = user[@"fullname"];
    
    if (strUsername && strUsername.length > 0) {
        return strUsername;
    }
    else {
        return user.username;
    }
}

- (void)setCategory:(BlogCategory *)category {
    
    for (BlogCategory *obj in mCategoryList) {
        obj.nSelected = 0;
    }
    
    if (category)
        category.nSelected = 1;
}

- (int)getSelectedCategory {
    
    int nRes = -1;
    
    BlogCategory *cate;
    for (int i = 0; i < mCategoryList.count; i++) {
        cate = [mCategoryList objectAtIndex:i];
        if (cate.nSelected) {
            nRes = i;
            break;
        }
    }

    return nRes;
}



- (void)setCategories:(NSArray *)objects {
    
    if (mCategoryList.count > 0) {
        return;
    }

    // make blog category objects
    for (PFObject *obj in objects) {
        
        BlogCategory *newCate = [[BlogCategory alloc] initWithData:obj.objectId name:obj[@"name"]];
        
        [mCategoryList addObject:newCate];
    }
    
    // set parent objects
    for (PFObject *obj in objects) {
        BlogCategory *cateSrc;
        
        if (obj[@"parentId"]) {
            for (BlogCategory *cate in mCategoryList) {
                if ([cate.strId isEqualToString:obj.objectId]) {
                    cateSrc = cate;
                    break;
                }
            }
            
            if (cateSrc) {
                for (BlogCategory *cate in mCategoryList) {
                    if ([cate.strId isEqualToString:obj[@"parentId"]]) {
                        cateSrc.parent = cate;
                        break;
                    }
                }
            }
        }
    }
    
    // set row values
    int nIndex = 0;
    int nSubIndex = 0;
    
    for (BlogCategory *cate in mCategoryList) {
        if (cate.parent) {
            cate.nRowNum = nSubIndex;

            nSubIndex++;
        }
        else {
            cate.nRowNum = nIndex;

            nIndex++;
            nSubIndex = 0;
        }
    }
    
    // determine whether has children or not
    for (BlogCategory *cate in mCategoryList) {
        if (cate.parent && !cate.parent.bHasSubItem) {
            cate.parent.bHasSubItem = YES;
        }
    }
    
    // load the selection info from NSUserDefaults
//    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *categorySelection = (NSMutableDictionary *)[userDefaultes dictionaryForKey:@"category"];
//    
//    for (BlogCategory *cate in mCategoryList) {
//        id selObj = [categorySelection objectForKey:cate.strId];
//        
//        if (selObj) {
//            cate.nSelected = [selObj intValue];
//        }
//        else {
//            cate.nSelected = 1; // selected
//        }
//    }
}

- (void)saveCategorySelection {
    // make dictionary for select state
    NSMutableDictionary *categorySelection = [[NSMutableDictionary alloc] init];
    for (BlogCategory *cate in mCategoryList) {
        [categorySelection setObject:[NSString stringWithFormat:@"%d", cate.nSelected] forKey:cate.strId];
    }
    
    // save to NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:categorySelection forKey:@"category"];
    [userDefaults synchronize];
}

- (void)gotoMain:(UIViewController *)displayView segue:(NSString *)segueString {
    // add category data
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {

            [self setCategories:objects];
            
            // get user info if Facebook or Twitter user
//            BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
                [displayView performSegueWithIdentifier:segueString sender:nil];
                
                [MBProgressHUD hideHUDForView:displayView.view animated:YES];
        }
        else {
            
            [MBProgressHUD hideHUDForView:displayView.view animated:YES];
            
            NSString *errorString = [error userInfo][@"error"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
    
    [MBProgressHUD showHUDAddedTo:displayView.view animated:YES];
}

+ (int)getHeight:(NSString *)text width:(int)nWidth height:(int)nHeight {
    
    UIFont *avenirnextFont = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    CGSize maximumLabelSize = CGSizeMake(nWidth, nHeight);
    
    //            CGRect textRect = [blog.strContent  boundingRectWithSize:maximumLabelSize   options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:avenirnextFont} context:nil];
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = avenirnextFont;
    gettingSizeLabel.text = text;
    gettingSizeLabel.numberOfLines = 0;
    
    CGSize expectedSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    int nRes = expectedSize.height;
    
    if (nHeight > 0) {
        nRes = MIN(expectedSize.height, nHeight);
    }
    
    return nRes;
}

+ (int)getHeightMax:(NSString *)text width:(int)nWidth minheight:(int)nHeight {
    
    int nRes = nHeight;
    
    UIFont *avenirnextFont = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    CGSize maximumLabelSize = CGSizeMake(nWidth, nHeight);
    
    //            CGRect textRect = [blog.strContent  boundingRectWithSize:maximumLabelSize   options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:avenirnextFont} context:nil];
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = avenirnextFont;
    gettingSizeLabel.text = text;
    gettingSizeLabel.numberOfLines = 0;
    
    CGSize expectedSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    
    if (expectedSize.height > nHeight) {
        nRes = expectedSize.height;
    }
    
    return nRes;
}

- (void)stopPlaying {
    if (self.mMoviePlayer) {
        [self.mMoviePlayer pause];
        self.mMoviePlayer = nil;
    }
}

@end
