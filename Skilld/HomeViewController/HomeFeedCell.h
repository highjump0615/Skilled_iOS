//
//  HomeFeedCell.h
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "ALMoviePlayerController.h"



@class HomeViewController;

@interface HomeFeedCell : UITableViewCell <ALMoviePlayerControllerDelegate> {
    BOOL mbPlaying;
    NSString *mBlogId;
}

@property (weak, nonatomic) IBOutlet PFImageView *mImgPhoto;
@property (weak, nonatomic) IBOutlet UIButton *mBtnUsername;
@property (weak, nonatomic) IBOutlet UIImageView *mImgLocation;
@property (weak, nonatomic) IBOutlet UILabel *mLblLocation;
@property (weak, nonatomic) IBOutlet UILabel *mLblTime;
@property (weak, nonatomic) IBOutlet UIButton *mBtnLikeList;
@property (weak, nonatomic) IBOutlet UILabel *mLblLike;

@property (weak, nonatomic) IBOutlet UIButton *mBtnCategory;

@property (weak, nonatomic) IBOutlet UIImageView *mImgComment;
@property (weak, nonatomic) IBOutlet UIButton *mBtnPlay;
//@property (nonatomic, strong) ALMoviePlayerController *mMoviePlayer;
@property (nonatomic, strong) AVPlayer *mMoviePlayer;
@property (nonatomic, strong) AVPlayerLayer *mPlayerLayer;

@property (weak, nonatomic) IBOutlet UITextView *mTxtComment;
@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;
@property (weak, nonatomic) IBOutlet PFImageView *mImgImage;
@property (weak, nonatomic) IBOutlet UIButton *mBtnLike;
@property (weak, nonatomic) IBOutlet UIButton *mBtnComment;
@property (weak, nonatomic) IBOutlet UIButton *mBtnMore;

@property (strong) BlogData *mBlogData;
@property (strong) HomeViewController *mParentView;

- (IBAction)onLike:(id)sender;
- (IBAction)onMore:(id)sender;
- (IBAction)onPlay:(id)sender;

- (void) onStop;

- (void) fillContent:(BlogData *)data;

@end
