//
//  CommonUtils.h
//  Skilld
//
//  Created by TianHang on 3/14/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlogCategory.h"
#import <AWSS3/AWSS3.h>

#import "AVFoundation/AVFoundation.h"

#define TEXT_FACTOR 190

// Constants used to represent your AWS Credentials.
#define ACCESS_KEY_ID          @"AKIAIXO5Z5NGL5ORVPIA"
#define SECRET_KEY             @"4UsKPi/rEILPvxEhU/+U5YQY0+clTw98mF17XOxW"

// Constants for the Bucket and Object name.
#define VIDEO_BUCKET         @"skilld-blog-video"


typedef enum {
    BlogText,
    BlogImage,
    BlogVideo
} BlogType;

typedef enum {
    NotificationFollow,
    NotificationComment,
    NotificationLikeText,
    NotificationLikePhoto,
    NotificationLikeVideo
} NotificationType;

@interface CommentData : NSObject

@property (strong) NSString *strUsername;
@property (strong) NSString *strContent;
@property (strong) NSDate *date;
@property (strong) PFUser *user;
@property (strong) PFObject *object;

@end

@interface LikeData : NSObject

@property (strong) PFObject *object;

@end


@interface BlogData : NSObject

@property (strong) NSString *strId;
@property (assign) BlogType type;
@property (strong) NSString *strTitle;
@property (strong) NSString *strContent;
@property (strong) NSURL *videoUrl;
@property (strong) PFFile *image;
@property (strong) NSString *strVideoName;
@property (strong) BlogCategory *category;
@property (strong) NSDate *date;
@property (strong) PFUser *user;

@property (strong) PFObject *object;

@property (nonatomic) int bLiked; // 1: like, 0: unliked, -1: not determinded
@property (nonatomic) int nLikeCount;

@property (strong) NSMutableArray *mCommentList;
@property (strong) NSMutableArray *mLikeList;

@end

@interface FollowingLikeData : NSObject

@property (strong) NSString *strUsername;
@property (strong) PFUser *user;

@end


@interface CommonUtils : NSObject {
    NSMutableArray *mCategoryList;
    BlogData *mBlogToPost;
    NSMutableArray *mBlogList;
}

@property (strong) BlogData *mBlogToPost;
@property (strong) NSMutableArray *mCategoryList;
@property (strong) NSMutableArray *mBlogList;
@property (nonatomic) BOOL bProfilePhotoUpdated;

@property (nonatomic, strong) AVPlayer *mMoviePlayer;

@property (strong) AmazonS3Client *s3;
@property (strong) S3TransferManager *tm;

@property (nonatomic) UIBackgroundTaskIdentifier bgTask;


+ (id)sharedObject;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width height:(float)i_height;

+ (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title;
+ (NSString *)getTimeString:(NSDate *)date;

+ (int)getHeight:(NSString *)text width:(int)nWidth height:(int)nHeight;
+ (int)getHeightMax:(NSString *)text width:(int)nWidth minheight:(int)nHeight;

+ (NSString *)getUsernameToShow:(PFUser *)user;

- (int)getSelectedCategory;
- (void)setCategory:(BlogCategory *)category;
- (void)setCategories:(NSArray *)objects;
- (void)saveCategorySelection;
- (void)gotoMain:(UIViewController *)displayView segue:(NSString *)segueString;

- (void)stopPlaying;

@end
