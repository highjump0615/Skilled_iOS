//
//  PostViewController.m
//  Skilld
//
//  Created by TianHang on 3/10/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "PostViewController.h"
#import "CommonUtils.h"
#import "MBProgressHUD.h"
#import "UIImage+ResizeAdditions.h"
#import "ProfileViewController.h"

#import <AWSRuntime/AWSRuntime.h>


@interface PostViewController ()

@end

@implementation PostViewController

static MBProgressHUD *s_hud;
static int s_nMaxLength = 140;
static int s_nTitleMaxLength = 30;

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
    
    [self.mScrollView setContentSize:CGSizeMake(self.mScrollView.frame.size.width, 517)];
	
    [self.mTitleTxt setValue:[UIColor colorWithRed:0.33 green:0.33 blue:0.34 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIFont *proximaNova = [UIFont fontWithName:@"ProximaNova-Light" size:17];
    [self.mTitleTxt setFont:proximaNova];
    [self.mCategoryLbl setFont:proximaNova];
    
    proximaNova = [UIFont fontWithName:@"ProximaNova-Light" size:11];
    [self.mContentTxt setFont:proximaNova];
    self.mContentTxt.placeholder = @"Write your text here...";
    self.mContentTxt.placeholderColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.34 alpha:1];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    CommonUtils *utils = [CommonUtils sharedObject];
    utils.mBlogToPost = [[BlogData alloc] init];
    
    if (self.mImageToPost) {
        
        if (self.mUrlVideoToPost) {
            utils.mBlogToPost.type = BlogVideo;
        }
        else {
            utils.mBlogToPost.type = BlogImage;
        }
        
        self.mPhotoImg.image = self.mImageToPost;
        
        [self.mViewTitle setHidden:YES];
        [self.mViewPost setFrame:CGRectMake(self.mViewTitle.frame.origin.x,
                                           self.mViewTitle.frame.origin.y,
                                           self.mViewPost.frame.size.width,
                                           self.mViewPost.frame.size.height)];
    }
    else {
        utils.mBlogToPost.type = BlogText;
        PFUser *currentUser = [PFUser currentUser];
        
        if (currentUser) {
            PFFile *photoFile = currentUser[@"photo"];
            self.mPhotoImg.file = photoFile;
            [self.mPhotoImg loadInBackground];
        }
    }
    
    [self.mContentLeftLbl setText:[NSString stringWithFormat:@"%d", s_nMaxLength]];
    [self.mTitleLeftLbl setText:[NSString stringWithFormat:@"%d", s_nTitleMaxLength]];
}

- (void)viewWillAppear:(BOOL)animated {
    CommonUtils *utils = [CommonUtils sharedObject];
    if (utils.mBlogToPost.category) {
        self.mCategoryLbl.text = utils.mBlogToPost.category.strName;
    }
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

const int PART_SIZE = (5 * 1024 * 1024); // 5MB is the smallest part size allowed for a multipart upload. (Only the last part can be smaller.)

- (IBAction)onShare:(id)sender {
    CommonUtils *utils = [CommonUtils sharedObject];
    
    // input check
    if (utils.mBlogToPost.type == BlogText) {
        if (!self.mTitleTxt.text.length) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Input the title" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    if (!self.mContentTxt.text.length) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Input the contents to post" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
    }
    
    if (!utils.mBlogToPost.category) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Select the category" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
    }
    
    utils.mBlogToPost.strTitle = self.mTitleTxt.text;
    utils.mBlogToPost.strContent = self.mContentTxt.text;
    
    mBlog = [PFObject objectWithClassName:@"Blogs"];
    mBlog[@"type"] = @(utils.mBlogToPost.type);
    mBlog[@"user"] = [PFUser currentUser];
    
    if (utils.mBlogToPost.type == BlogText) {
        mBlog[@"title"] = utils.mBlogToPost.strTitle;
    }
    else {
        UIImage *resizedImage = [self.mImageToPost resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(320, 185) interpolationQuality:kCGInterpolationHigh];
        UIImage *thumbnailImage = [self.mImageToPost thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:0.0f interpolationQuality:kCGInterpolationDefault];
        
        // JPEG to decrease file size and enable faster uploads & downloads
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
        NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
        
        if (!imageData || !thumbnailImageData) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Invalid Image to Post" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        imageData = UIImageJPEGRepresentation(self.mImageToPost, 1.0);
        
        mBlog[@"image"] = [PFFile fileWithData:imageData];
        mBlog[@"thumbnail"] = [PFFile fileWithData:thumbnailImageData];
        
        if (utils.mBlogToPost.type == BlogVideo) {
            NSData *videoData = [NSData dataWithContentsOfURL:self.mUrlVideoToPost];
            
            PFUser *user = [PFUser currentUser];
            NSInteger nTimeStamp = [[NSDate date] timeIntervalSince1970];

            NSString *strFileName = [NSString stringWithFormat:@"%@%ld.mov", user.objectId, (long)nTimeStamp];
            
                // Clean up any unfinished task business by marking where you
                // stopped or ending the task outright.
//                [application endBackgroundTask:bgTask];
//                bgTask = UIBackgroundTaskInvalid;
            
            // Upload image data.  Remember to set the content type.
            S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:strFileName inBucket:VIDEO_BUCKET];
//            S3UploadInputStream *stream = [S3UploadInputStream inputStreamWithData:videoData];
            por.contentType = @"movie/mov";
            por.data = videoData;
//            por.contentLength = videoData.length;
//            por.stream = stream;
            por.delegate = self;
            
//            utils.tm.delegate = self;
            [utils.tm upload:por];
//            [utils.tm uploadData:videoData bucket:VIDEO_BUCKET key:strFileName];
            
            // Put the image data into the specified s3 bucket and object.
//            [utils.s3 putObject:por];
            
//            @try {
//                S3InitiateMultipartUploadRequest *initReq = [[S3InitiateMultipartUploadRequest alloc] initWithKey:strFileName inBucket:VIDEO_BUCKET];
//                S3MultipartUpload *upload = [utils.s3 initiateMultipartUpload:initReq].multipartUpload;
//                S3CompleteMultipartUploadRequest *compReq = [[S3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:upload];
//                
//                int numberOfParts = [self countParts:videoData];
//                for ( int part = 0; part < numberOfParts; part++ ) {
//                    NSData *dataForPart = [self getPart:part fromData:videoData];
//                    
//                    // The S3UploadInputStream was deprecated after the release of iOS6.
//                    S3UploadInputStream *stream = [S3UploadInputStream inputStreamWithData:dataForPart];
////                    if ( using3G ) {
////                        // If connected via 3G "throttle" the stream.
////                        stream.delay = 0.2; // In seconds
////                        stream.packetSize = 16; // Number of 1K blocks
////                    }
//                    
//                    S3UploadPartRequest *upReq = [[S3UploadPartRequest alloc] initWithMultipartUpload:upload];
//                    upReq.partNumber = ( part + 1 );
//                    upReq.contentLength = [dataForPart length];
//                    upReq.stream = stream;
//                    
//                    S3UploadPartResponse *response = [utils.s3 uploadPart:upReq];
//                    [compReq addPartWithPartNumber:( part + 1 ) withETag:response.etag];
//                }
//                
//                [utils.s3 completeMultipartUpload:compReq];
//            }
//            @catch ( AmazonServiceException *exception ) {
//                NSLog( @"Multipart Upload Failed, Reason: %@", exception  );
//            }
            
            mBlog[@"video"] = strFileName;
                
        }
    }
    
    mBlog[@"text"] = utils.mBlogToPost.strContent;
    mBlog[@"category"] = utils.mBlogToPost.category.strId;
    
    if (utils.mBlogToPost.type == BlogText || utils.mBlogToPost.type == BlogImage) {
        [self saveBlogData];
    }
    
//    PFUser *currentUser = [PFUser currentUser];
//    int nPost = [currentUser[@"postcount"] intValue];
//    currentUser[@"postcount"] = [NSNumber numberWithInt:nPost + 1];
//    
//    [currentUser saveInBackground];
    
    s_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    s_hud.labelText = @"Uploading...";
}

//-(NSData*)getPart:(int)part fromData:(NSData*)fullData
//{
//    NSRange range;
//    range.length = PART_SIZE;
//    range.location = part * PART_SIZE;
//    
//    int maxByte = (part + 1) * PART_SIZE;
//    if ( [fullData length] < maxByte ) {
//        range.length = [fullData length] - range.location;
//    }
//    
//    return [fullData subdataWithRange:range];
//}
//
//-(int)countParts:(NSData*)fullData
//{
//    int q = (int)([fullData length] / PART_SIZE);
//    int r = (int)([fullData length] % PART_SIZE);
//    
//    return ( r == 0 ) ? q : q + 1;
//}

# pragma mark - TextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    if (newLength <= s_nMaxLength) {
        [self.mContentLeftLbl setText:[NSString stringWithFormat:@"%d", s_nMaxLength - newLength]];
        return YES;
    }
    else {
        return NO;
    }
}

- (void) saveBlogData {
    [mBlog saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // add object
            ProfileViewController *profileView = (ProfileViewController *)self.mParentViewController;
            BlogData *blog = [[BlogData alloc] init];
            blog.strId = mBlog.objectId;
            blog.type = [mBlog[@"type"] intValue];
            blog.strTitle = mBlog[@"title"];
            blog.strContent = mBlog[@"text"];
            blog.strVideoName = mBlog[@"video"];
            blog.image = (PFFile *)mBlog[@"image"];
            blog.date = mBlog.createdAt;
            blog.user = [PFUser currentUser];
            blog.object = mBlog;
            blog.bLiked = 0;
            blog.nLikeCount = 0;
            [profileView.mBlogs insertObject:blog atIndex:0];
            
            if (blog.type > BlogText) {
                [profileView.mImageBlogs insertObject:mBlog atIndex:0];
            }
            
            [s_hud setHidden:YES];
            [self onBack:nil];

        }
        else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark - AmazonServiceRequestDelegate

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [self saveBlogData];
    s_hud.labelText = @"Saving...";
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    if (utils.bgTask != UIBackgroundTaskInvalid) {
        UIApplication* app = [UIApplication sharedApplication];
        [app endBackgroundTask:utils.bgTask];
        utils.bgTask = UIBackgroundTaskInvalid;
    }
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite {
    NSLog(@"didSendData:%lld, totalBytesWritten:%lld, totalBytesExpectedToWrite:%lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    int nPercent = (int)(totalBytesWritten / (float)totalBytesExpectedToWrite * 100.0);
    s_hud.labelText = [NSString stringWithFormat:@"Uploading... %d%%", nPercent];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    [CommonUtils showAlertMessage:error.description withTitle:@"Upload Error"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [s_hud setHidden:YES];
}



#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mTitleTxt) {
//		[self.mContentTxt becomeFirstResponder];
        [self.mContentTxt performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
	}
    
	return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    if (newLength <= s_nTitleMaxLength) {
        [self.mTitleLeftLbl setText:[NSString stringWithFormat:@"%d", s_nTitleMaxLength - newLength]];
        return YES;
    }
    else {
        return NO;
    }
}


@end
