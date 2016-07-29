//
//  HomeFeedCell.m
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "HomeFeedCell.h"
#import "CommonUtils.h"
#import "HomeViewController.h"

@implementation HomeFeedCell
 
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc {
    
    [self clearMoviePlayer];
    
    [self.mPlayerLayer removeFromSuperlayer];
    self.mPlayerLayer = nil;
}

- (void) clearMoviePlayer {
    if (self.mMoviePlayer) {
        [self.mMoviePlayer removeObserver:self forKeyPath:@"status"];
        [self.mMoviePlayer removeObserver:self forKeyPath:@"rate"];
        self.mMoviePlayer = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

}

- (void) fillContent:(BlogData *)data {
    
    self.mBlogData = data;

    CommonUtils *utils = [CommonUtils sharedObject];
    
    // set the user
    PFUser *userInfo = data.user;
    
    //        [userInfo fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    
    // user photo
    [self.mImgPhoto.layer setMasksToBounds:YES];
    [self.mImgPhoto.layer setCornerRadius:16.0];
    
    PFFile *photoFile = userInfo[@"photo"];
    self.mImgPhoto.file = photoFile;
    self.mImgPhoto.image = [UIImage imageNamed:@"profile_photo_default.png"];
    [self.mImgPhoto loadInBackground];
    
    // username button
    [self.mBtnUsername setTitle:[CommonUtils getUsernameToShow:userInfo] forState:UIControlStateNormal];
    
    // location label
    self.mLblLocation.text = userInfo[@"location"];
    
    // location mark
    if (self.mLblLocation.text.length > 0) {
        [self.mImgLocation setHidden:NO];
    }
    else {
        [self.mImgLocation setHidden:YES];
    }
    
    // set time
    self.mLblTime.text = [CommonUtils getTimeString:data.date];
    
    // content, title & image
    self.mLblContent.text = data.strContent;
    
    // video player
    if (!self.mPlayerLayer) {
        self.mPlayerLayer = [[AVPlayerLayer alloc] init];
        
        [self.mPlayerLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        
        self.mMoviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        self.mPlayerLayer.frame = CGRectMake(0, 0, self.mImgImage.frame.size.width, self.mImgImage.frame.size.width);
        [self.mImgImage.layer addSublayer:self.mPlayerLayer];
    }
    
    // hide all assets for now
    [self.mImgImage setHidden:YES];
    [self.mImgImage setBackgroundColor:[UIColor clearColor]];
    [self.mLblTitle setHidden:YES];
    [self.mBtnPlay setHidden:YES];
    [self.mPlayerLayer setHidden:YES];
//    if (self.mMoviePlayer) {
//        self.mMoviePlayer = nil;
//        [self.mPlayerLayer removeFromSuperlayer];
//    }
    
    if (data.type == BlogText) {
        
        [self.mLblTitle setHidden:NO];
        
        self.mLblTitle.text = data.strTitle;
        
//        int nHeight = [CommonUtils getHeight:data.strContent width:273 height:156];
        int nHeight = [CommonUtils getHeight:data.strContent width:273 height:0];
        
        [self.mLblContent setFrame:CGRectMake(17,
                                              75,
                                              self.mLblContent.frame.size.width,
                                              nHeight)];
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  nHeight + TEXT_FACTOR)];
    }
    else {
        [self.mLblTitle setHidden:YES];
        
        [self.mImgImage setHidden:NO];
        [self.mImgImage setBackgroundColor:[UIColor clearColor]];
        
        self.mImgImage.image = [UIImage imageNamed:@"home_default_image.png"];
        self.mImgImage.file = data.image;
        self.mImgImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.mImgImage loadInBackground:^(UIImage *image, NSError *error) {
            //                UIImage *newImage = [CommonUtils imageWithImage:image scaledToWidth:320 height:185];
            //                [feedCell.mImgImage setImage:newImage];
            [self.mImgImage setBackgroundColor:[UIColor blackColor]];
        }];
        
        [self.mBtnPlay setImage:[UIImage imageNamed:@"home_play_but.png"] forState:UIControlStateNormal];
        
        
        if (data.type == BlogImage) {
        }
        else if (data.type == BlogVideo) {
            NSLog(@"blogID:%@, %@, AVplayer:%@", mBlogId, data.object.objectId, self.mMoviePlayer);
            
            if (![mBlogId isEqualToString:self.mBlogData.object.objectId]) {
                //THEN set contentURL
                // Set the content type so that the browser will treat the URL as an image.
                S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
                override.contentType = @"movie/mov";
                
                // Request a pre-signed URL to picture that has been uplaoded.
                S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
                gpsur.key                     = self.mBlogData.strVideoName;
                gpsur.bucket                  = VIDEO_BUCKET;
                gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
                gpsur.responseHeaderOverrides = override;
                
                // Get the URL
                NSError *error = nil;
                NSURL *url = [utils.s3 getPreSignedURL:gpsur error:&error];
                
                data.videoUrl = url;
                
                NSLog(@"video: %@", url);

                [self clearMoviePlayer];
                
                self.mMoviePlayer = [AVPlayer playerWithURL:url];
                [self.mMoviePlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
                [self.mMoviePlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.mMoviePlayer.currentItem];

                
                mBlogId = self.mBlogData.object.objectId;
                
                // play button
                [self.mBtnPlay setEnabled:NO];
            }
//
//            //    self.mPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.mMoviePlayer];
//            if (self.mPlayerLayer) {
//                [self.mPlayerLayer setPlayer:nil];
//            }
//            else {
//                self.mPlayerLayer = [[AVPlayerLayer alloc] init];
//            }
//            
            [self.mPlayerLayer setPlayer:self.mMoviePlayer];
//            [self.mPlayerLayer setHidden:NO];
            
            mbPlaying = NO;
            //    }
            
            [self.mBtnPlay setHidden:NO];

        }
        
        int nYPos = self.mImgImage.frame.origin.y + self.mImgImage.frame.size.height + 10;
//        int nHeight = [CommonUtils getHeight:data.strContent width:273 height:15];
        int nHeight = [CommonUtils getHeight:data.strContent width:273 height:0];
        
        [self.mLblContent setFrame:CGRectMake(self.mLblContent.frame.origin.x,
                                              nYPos,
                                              self.mLblContent.frame.size.width,
                                              nHeight)];
        //            [feedCell setFrame:CGRectMake(feedCell.frame.origin.x,
        //                                          feedCell.frame.origin.y,
        //                                          feedCell.frame.size.width,
        //                                          nHeight + 185 + TEXT_FACTOR - 25)];
    }
    
    // setlike
    self.mLblLike.text = [NSString stringWithFormat:@"%d likes", data.nLikeCount];
    
    if (data.bLiked > 0) { // liked
        [self.mBtnLikeList setImage:[UIImage imageNamed:@"home_liked_icon.png"] forState:UIControlStateNormal];
        [self.mBtnLike setEnabled:NO];
    }
    else if (data.bLiked == 0) { // unliked
        [self.mBtnLikeList setImage:[UIImage imageNamed:@"home_like.png"] forState:UIControlStateNormal];
        [self.mBtnLike setEnabled:YES];
    }
    else { // undetermined
        [self.mBtnLikeList setImage:[UIImage imageNamed:@"home_like.png"] forState:UIControlStateNormal];
        [self.mBtnLike setEnabled:NO];
    }
    
    // category button
    NSString *strCategory = [NSString stringWithFormat:@"[ %@ ]", data.category.strName];
    [self.mBtnCategory setTitle:strCategory forState:UIControlStateNormal];
    [self.mBtnCategory setTitleColor:[UIColor colorWithRed:241/255.0 green:97/255.0 blue:97/255.0 alpha:1] forState:UIControlStateNormal];
    [self.mBtnCategory setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    // set comments
    UIFont *avenirnextFont = [UIFont fontWithName:@"AvenirNext-Regular" size:11];
    if (data.mCommentList.count) {
        
        NSMutableAttributedString *commentMsgTotal = [[NSMutableAttributedString alloc] init];
        UIFont *avenirnextBoldFont = [UIFont fontWithName:@"AvenirNext-Bold" size:11];
        
        for (CommentData *commObj in data.mCommentList) {
            
            NSMutableAttributedString *commentMsg = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@\n",
                                                                                                       commObj.strUsername,
                                                                                                       commObj.strContent]];
            [commentMsg addAttribute:NSFontAttributeName
                               value:avenirnextBoldFont
                               range:NSMakeRange(0, commObj.strUsername.length)];
            [commentMsg addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                               range:NSMakeRange(0, commObj.strUsername.length)];
            
            [commentMsg addAttribute:NSFontAttributeName
                               value:avenirnextFont
                               range:NSMakeRange(commObj.strUsername.length + 2, commObj.strContent.length)];
            [commentMsg addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7]
                               range:NSMakeRange(commObj.strUsername.length + 2, commObj.strContent.length)];
            
            [commentMsgTotal appendAttributedString:commentMsg];
        }
        
        self.mTxtComment.attributedText = commentMsgTotal;
    }
    else {
        NSMutableAttributedString *noMsg = [[NSMutableAttributedString alloc] initWithString:@"No comments yet"];
        
        [noMsg addAttribute:NSFontAttributeName
                      value:avenirnextFont
                      range:NSMakeRange(0, noMsg.length)];
        [noMsg addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] range:NSMakeRange(0, noMsg.length)];
        
        self.mTxtComment.attributedText = noMsg;
    }
}

- (IBAction)onLike:(id)sender {
    
    if (!self.mBlogData.bLiked) {
        PFObject *like = [PFObject objectWithClassName:@"Likes"];
        like[@"blog"] = self.mBlogData.object;
        like[@"user"] = [PFUser currentUser];
        like[@"username"] = [CommonUtils getUsernameToShow:[PFUser currentUser]];
        like[@"targetuser"] = self.mBlogData.user;
        like[@"type"] = @(self.mBlogData.type);
        if (self.mBlogData.image)
            like[@"thumbnail"] = self.mBlogData.image;

        [like saveInBackground];

        self.mBlogData.nLikeCount++;
        
        [self.mBtnLikeList setImage:[UIImage imageNamed:@"home_liked_icon.png"] forState:UIControlStateNormal];
        [self.mLblLike setText:[NSString stringWithFormat:@"%d likes", self.mBlogData.nLikeCount]];
        
        PFObject *blogObj = self.mBlogData.object;
        blogObj[@"likes"] = [NSNumber numberWithInt:self.mBlogData.nLikeCount];
        [blogObj saveInBackground];
        
        self.mBlogData.bLiked = YES;
        
        [self.mBtnLike setEnabled:NO];
    }
}

- (IBAction)onMore:(id)sender {
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"%@: %ld", keyPath, (long)self.mMoviePlayer.status);
        
        if (self.mMoviePlayer.status == AVPlayerStatusReadyToPlay) {
            
            [self.mMoviePlayer prerollAtRate:1.0 completionHandler:^(BOOL finished) {
                NSLog(@"prerollAtRate: %d", finished);
                
//                if (finished) {
                [self.mPlayerLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
                [self.mBtnPlay setEnabled:YES];
                
                [self.mPlayerLayer setHidden:NO];
                
//                }
            }];
        }
        else if (self.mMoviePlayer.status == AVPlayerStatusFailed) {
            /* An error was encountered */
            [self.mBtnPlay setEnabled:NO];
        }
    }
    else if ([keyPath isEqualToString:@"rate"]) {
        
        CommonUtils *utils = [CommonUtils sharedObject];
        if (!utils.mMoviePlayer) {
            mbPlaying = NO;
        }
        
        if (self.mMoviePlayer.rate) {
            [self.mBtnPlay setImage:[UIImage imageNamed:@"home_pause_but.png"] forState:UIControlStateNormal];
        }
        else {
            if (mbPlaying) {
                [self.mMoviePlayer play];
            }
            else {
                [self.mBtnPlay setImage:[UIImage imageNamed:@"home_play_but.png"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void) itemDidFinishPlaying:(id)sender {
    mbPlaying = NO;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mMoviePlayer seekToTime:CMTimeMakeWithSeconds(0, 1)];
    [self.mBtnPlay setImage:[UIImage imageNamed:@"home_play_but.png"] forState:UIControlStateNormal];
    utils.mMoviePlayer = nil;
}

- (void) onStop {
    mbPlaying = NO;
    
    if (self.mMoviePlayer) {
        
        CommonUtils *utils = [CommonUtils sharedObject];
    
        [self.mMoviePlayer seekToTime:CMTimeMakeWithSeconds(0, 1)];
        [self.mMoviePlayer pause];
        utils.mMoviePlayer = nil;

        [self.mBtnPlay setImage:[UIImage imageNamed:@"home_play_but.png"] forState:UIControlStateNormal];
    }
}


- (IBAction)onPlay:(id)sender {
    
//    // stop current playing videos
//    HomeViewController *parentViewController = self.mParentView;
//    for (ALMoviePlayerController *player in parentViewController.mPlayerArray) {
//        [player stop];
//    }
//    
//    [self.mBtnPlay setEnabled:NO];
//    
    CommonUtils *utils = [CommonUtils sharedObject];
//
//    //create a player
//    self.mMoviePlayer = [[ALMoviePlayerController alloc] initWithFrame:self.mImgImage.frame];
//    self.mMoviePlayer.view.alpha = 0.f;
//    self.mMoviePlayer.delegate = self; //IMPORTANT!
//    
//    [parentViewController.mPlayerArray addObject:self.mMoviePlayer];
//    
//    NSLog(@"playing... %@", self.mMoviePlayer);
//    
//    //create the controls
//    ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.mMoviePlayer style:ALMoviePlayerControlsStyleDefault];
//    
//    //[movieControls setAdjustsFullscreenImage:NO];
//    [movieControls setBarColor:[UIColor colorWithRed:195/255.0 green:29/255.0 blue:29/255.0 alpha:0.5]];
//    [movieControls setTimeRemainingDecrements:YES];
//    //[movieControls setFadeDelay:2.0];
//    [movieControls setBarHeight:50];
//    //[movieControls setSeekRate:2.f]
//    
//    //assign controls
//    [self.mMoviePlayer setControls:movieControls];
//    self.mMoviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
//    [self addSubview:self.mMoviePlayer.view];
//    
//    //THEN set contentURL
//    // Set the content type so that the browser will treat the URL as an image.
//    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
//    override.contentType = @"movie/mov";
//    
//    // Request a pre-signed URL to picture that has been uplaoded.
//    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
//    gpsur.key                     = self.mBlogData.strVideoName;
//    gpsur.bucket                  = VIDEO_BUCKET;
//    gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
//    gpsur.responseHeaderOverrides = override;
//    
//    // Get the URL
//    NSError *error = nil;
//    NSURL *url = [utils.s3 getPreSignedURL:gpsur error:&error];
//    
//    [self.mMoviePlayer setContentURL:url];
//    
////    //delay initial load so statusBarOrientation returns correct value
////    double delayInSeconds = 0.3;
////    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
////    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
////        //        [self configureViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
////        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
//            self.mMoviePlayer.view.alpha = 1.f;
////        } completion:^(BOOL finished) {
////            NSLog(@"complete");
////        }];
////    });
    
    if (self.mMoviePlayer.rate == 0.0) {
        mbPlaying = YES;
        [self.mMoviePlayer play];
        
        utils.mMoviePlayer = self.mMoviePlayer;
    }
    else {
        mbPlaying = NO;
        [self.mMoviePlayer pause];
        utils.mMoviePlayer = nil;
    }
}


//IMPORTANT!
- (void)moviePlayerWillMoveFromWindow {

//    NSLog(@"moviePlayerWillMoveFromWindow");
//    
//    //movie player must be readded to this view upon exiting fullscreen mode.
//    if (![self.subviews containsObject:self.mMoviePlayer.view])
//        [self addSubview:self.mMoviePlayer.view];
//    
//    //you MUST use [ALMoviePlayerController setFrame:] to adjust frame, NOT [ALMoviePlayerController.view setFrame:]
//    [self.mMoviePlayer setFrame:self.mImgImage.frame];
}



@end
