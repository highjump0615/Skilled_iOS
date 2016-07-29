//
//  HomeViewController.m
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeFeedCell.h"
#import "MBProgressHUD.h"
#import "CommentViewController.h"
#import "OtherProfileViewController.h"
#import "FollowViewController.h"
#import <Twitter/Twitter.h>

#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"




@interface HomeViewController () <EGORefreshTableDelegate, MFMailComposeViewControllerDelegate> {

    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _reloading;
    
    MFMailComposeViewController *mailerShare;
    MFMailComposeViewController *mailerReport;
    
    NSTimer* mLoadVideoTimer;
    int mnCategorySelected;
}

@end

@implementation HomeViewController

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
	
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(onMoreClose:)];
    
    [self.view addGestureRecognizer:tap];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    if (!utils.mBlogList) {
        [self.mFeedTable setHidden:YES];
    }
    
    m_nMoreHideYPos = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    m_nMoreShowYPos = m_nMoreHideYPos - self.mViewMore.frame.size.height;
    
    m_nCountOnce = 5;
    
    m_bTrendMode = NO;
    m_bSearchOn = NO;
    mStrSearchKey = @"";
//    self.mPlayerArray = [[NSMutableArray alloc] init];
    
    PFACL *myacl = [PFACL ACL];
    [myacl setPublicReadAccess:YES];
    [[PFUser currentUser] setACL:myacl];
    [[PFUser currentUser] saveInBackground];
    
    m_nCurrnetCount = 0;
    
    mnCategorySelected = -1; // none selected
    
    [self getBlog:YES];
}

- (void)getCategoryBlog {
    CommonUtils *utils = [CommonUtils sharedObject];
    int nCategorySelected = [utils getSelectedCategory];
    
    if (nCategorySelected != mnCategorySelected) {
        mnCategorySelected = nCategorySelected;
        [self getBlog:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self getCategoryBlog];
}

- (void)getBlog:(BOOL)bShowLoading {
    CommonUtils *utils = [CommonUtils sharedObject];
    PFQuery *query = [PFQuery queryWithClassName:@"Blogs"];

    // filter category
    NSMutableArray *cateArray = [[NSMutableArray alloc] init];
    BlogCategory *cate;
    
    if (mnCategorySelected > 0) {
        cate = [utils.mCategoryList objectAtIndex:mnCategorySelected];
        [cateArray addObject:cate.strId];
    }
    else {
        for (cate in utils.mCategoryList) {
            [cateArray addObject:cate.strId];
        }
    }
    
    if (mStrSearchKey.length > 0) {
        PFQuery *textQuery = [PFQuery queryWithClassName:@"Blogs"];
        [textQuery whereKey:@"text" matchesRegex:mStrSearchKey modifiers:@"i"];
        
        PFQuery *nameQuery = [PFUser query];
        [nameQuery whereKey:@"username" matchesRegex:mStrSearchKey modifiers:@"i"];
        
        PFQuery *fullnameQuery = [PFUser query];
        [fullnameQuery whereKey:@"fullname" matchesRegex:mStrSearchKey modifiers:@"i"];
        
        PFQuery *locationQuery = [PFUser query];
        [locationQuery whereKey:@"location" matchesRegex:mStrSearchKey modifiers:@"i"];
        
        PFQuery *userQuery = [PFQuery orQueryWithSubqueries:@[nameQuery, fullnameQuery, locationQuery]];
        
        PFQuery *userBlogQuery = [PFQuery queryWithClassName:@"Blogs"];
        [userBlogQuery whereKey:@"user" matchesQuery:userQuery];
        
        query = [PFQuery orQueryWithSubqueries:@[textQuery, userBlogQuery]];
    }

    if (m_bTrendMode) {
        [query orderByDescending:@"likes"];
    }
    else {
        [query orderByDescending:@"createdAt"];
    }
    [query whereKey:@"category" containedIn:cateArray];

    query.limit = m_nCountOnce;
    query.skip = m_nCurrnetCount;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            if (bShowLoading) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            
            while (1) {
            
                if (m_nCurrnetCount == 0) {
                    utils.mBlogList = [[NSMutableArray alloc] init];
                    
                    if (objects.count > 0) {
                        [self.mFeedTable setHidden:NO];
                    }
                }
                
                // set parent objects
                BlogData *blog;
                for (PFObject *obj in objects) {
                    blog = [[BlogData alloc] init];
                    blog.strId = obj.objectId;
                    blog.type = [obj[@"type"] intValue];
                    blog.strTitle = obj[@"title"];
                    blog.strContent = obj[@"text"];
                    blog.strVideoName = obj[@"video"];
                    blog.image = (PFFile *)obj[@"image"];
                    blog.date = obj.createdAt;
                    blog.user = obj[@"user"];
                    blog.object = obj;
                    [blog.user fetchIfNeeded];
                    blog.bLiked = -1;
                    blog.nLikeCount = [obj[@"likes"] intValue];
                    
                    // set category
                    for (BlogCategory *cate in utils.mCategoryList) {
                        if ([cate.strId isEqualToString:obj[@"category"]]) {
                            blog.category = cate;
                            break;
                        }
                    }
                    
                    [utils.mBlogList addObject:blog];
                }
                
                [self.mFeedTable reloadData];
                
                [self testFinishedLoadData];
                
                int i = 0;
                
                for (PFObject *obj in objects) {
                    
                    blog = [utils.mBlogList objectAtIndex:m_nCurrnetCount + i];
                    
                    // get like info
                    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
                    [query whereKey:@"blog" equalTo:obj];
                    [query whereKey:@"user" equalTo:[PFUser currentUser]];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *likeobjects, NSError *error) {
                        
                        if (!error) {
                            if (likeobjects.count > 0) {
                                blog.bLiked = 1;
                            }
                            else {
                                blog.bLiked = 0;
                            }
                            
                            [self.mFeedTable reloadData];
                        }
                        else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                    
                    // get comment info
                    query = [PFQuery queryWithClassName:@"Comments"];
                    [query whereKey:@"blog" equalTo:obj];
                    [query orderByDescending:@"updatedAt"];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *commentobjects, NSError *error) {
                        
                        if (!error) {
                            blog.mCommentList = [[NSMutableArray alloc] init];
                            
                            for (PFObject *object in commentobjects) {
                                CommentData *comment = [[CommentData alloc] init];
                                comment.user = object[@"user"];
                                comment.strContent = object[@"content"];
                                comment.strUsername = object[@"username"];
                                comment.date = object.updatedAt;
                                comment.object = object;
                                
                                [blog.mCommentList addObject:comment];
                            }
                            
                            [self.mFeedTable reloadData];
                        }
                        else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                    
                    i++;
                }
                
                m_nCurrnetCount += objects.count;
                
                break;
            }
        }
        else {
            
            NSString *errorString = [error userInfo][@"error"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
    
    if (bShowLoading) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    m_nCurrnetCount = 0;
    
    [self.mFeedTable reloadData];
    [self.mViewMore setFrame:CGRectMake(self.mViewMore.frame.origin.x, m_nMoreHideYPos, self.mViewMore.frame.size.width, self.mViewMore.frame.size.height)];
}

- (void)viewWillDisappear:(BOOL)animated {
    CommonUtils *utils = [CommonUtils sharedObject];
    [utils stopPlaying];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int nCount = 0;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    if (utils.mBlogList) {
        nCount = (int)[utils.mBlogList count];
    }
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeFeedCell *feedCell = (HomeFeedCell *)[self.mFeedTable dequeueReusableCellWithIdentifier:@"HomeFeedCellID"];
    feedCell.mParentView = self;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    if (utils.mBlogList && utils.mBlogList.count > 0) {
        BlogData *blog = [utils.mBlogList objectAtIndex:indexPath.row];
        
        [feedCell fillContent:blog];
        
        [feedCell.mBtnUsername addTarget:self action:@selector(onBtnUsername:) forControlEvents:UIControlEventTouchUpInside];
        feedCell.mBtnUsername.tag = indexPath.row;
        
        // likelist button
        [feedCell.mBtnLikeList addTarget:self action:@selector(onBtnLikeList:) forControlEvents:UIControlEventTouchUpInside];
        feedCell.mBtnLikeList.tag = indexPath.row;
        
        // category button
        [feedCell.mBtnCategory addTarget:self action:@selector(onBtnCategory:) forControlEvents:UIControlEventTouchUpInside];
        feedCell.mBtnCategory.tag = indexPath.row;
        
        // comment button
        [feedCell.mBtnComment addTarget:self action:@selector(onBtnComment:) forControlEvents:UIControlEventTouchUpInside];
        feedCell.mBtnComment.tag = indexPath.row;
        
        // more button
        [feedCell.mBtnMore addTarget:self action:@selector(onBtnMore:) forControlEvents:UIControlEventTouchUpInside];
        feedCell.mBtnMore.tag = indexPath.row;
    }
    
    return feedCell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        HomeFeedCell *feedCell = (HomeFeedCell *)cell;
        [feedCell onStop];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int nHeight = 473;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    if (utils.mBlogList && utils.mBlogList.count > 0) {
        BlogData *blog = [utils.mBlogList objectAtIndex:indexPath.row];
        
        if (blog.type == BlogText) {
//            nHeight = [CommonUtils getHeight:blog.strContent width:273 height:156] + TEXT_FACTOR;
            nHeight = [CommonUtils getHeight:blog.strContent width:273 height:0] + TEXT_FACTOR;
        }
        else {
//            nHeight = [CommonUtils getHeight:blog.strContent width:273 height:15];
            nHeight = [CommonUtils getHeight:blog.strContent width:273 height:0];
            nHeight += 320 - 25 + TEXT_FACTOR;
        }
    }
    
    return nHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self onMoreClose:nil];
}



- (void)onBtnLikeList:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;
    [self performSegueWithIdentifier:@"Home2Follow" sender:nil];
}

- (void)onBtnCategory:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;
    CommonUtils *utils = [CommonUtils sharedObject];
    BlogData *blog = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
    
    [utils setCategory:blog.category];
    [self getCategoryBlog];
}

- (void)onBtnComment:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;
    [self performSegueWithIdentifier:@"Home2Comments" sender:nil];
}

- (void)onBtnUsername:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    BlogData *blog = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
    if ([blog.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Home2OtherProfile" sender:nil];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CommonUtils *utils = [CommonUtils sharedObject];
    
    if ([[segue identifier] isEqualToString:@"Home2Comments"]) {
        CommentViewController* commentViewController = [segue destinationViewController];
        commentViewController.mBlogData = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
    }
    else if ([[segue identifier] isEqualToString:@"Home2OtherProfile"]) {
        OtherProfileViewController* otherViewController = [segue destinationViewController];
        BlogData *blog = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
        otherViewController.mUser = blog.user;
    }
    else if ([[segue identifier] isEqualToString:@"Home2Follow"]) {
        FollowViewController* followViewController = [segue destinationViewController];
        BlogData *blog = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
        followViewController.mBlogObject = blog.object;
        followViewController.mUser = [PFUser currentUser];
    }
}

- (void)onBtnMore:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;

    if (self.mViewMore.frame.origin.y == m_nMoreHideYPos) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rt = self.mViewMore.frame;
                             rt.origin.y = m_nMoreShowYPos;
                             self.mViewMore.frame = rt;
                         }completion:^(BOOL finished) {
                             //						 self.view.userInteractionEnabled = YES;
                         }];
    }
}

- (IBAction)onMoreClose:(id)sender {
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rt = self.mViewMore.frame;
                         rt.origin.y = m_nMoreHideYPos;
                         self.mViewMore.frame = rt;
                     }completion:^(BOOL finished) {
                         //						 self.view.userInteractionEnabled = YES;
                     }];
}

MBProgressHUD *s_postHud;

- (void) loadVideoThread:(NSTimer*)theTimer {
    
    BlogData *blogData = (BlogData *)[theTimer userInfo];
    
    NSData *videoData = [NSData dataWithContentsOfURL:blogData.videoUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   videoData, @"video.mov",
                                   @"movie/mov", @"contentType",
                                   @"Skilled Video", @"name",
                                   blogData.strContent, @"description",
                                   nil];
    
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/videos"
                                              parameters:params
                                              HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Successfully posted to Facebook"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSString *errorString =  [error userInfo][@"com.facebook.sdk:ParsedJSONResponseKey"][@"body"][@"error"][@"message"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [s_postHud hide:YES];
    
    [mLoadVideoTimer invalidate];
}

- (IBAction)onMoreFacebook:(id)sender {
    
    CommonUtils *utils = [CommonUtils sharedObject];
    BlogData *blogData = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
    
    BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
    
    if (blogData.type == BlogVideo) {
        if (isLinkedToFacebook) {
            
            s_postHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            s_postHud.labelText = @"Getting Video Data for posting...";
            
            mLoadVideoTimer = nil;
            mLoadVideoTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(loadVideoThread:) userInfo:blogData repeats:NO];
            
            return;
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Facebook video sharing is only available for the users logged in with Facebook"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *facebookSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeFacebook];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    facebookSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                NSLog(@"SLComposeViewControllerResultCancelled");
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone: {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Successfully posted to Facebook"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                break;
            }
        }
    };
    
    //  Set the initial body of the Tweet
    [facebookSheet setInitialText:blogData.strContent];
    
    if (blogData.image) {
        //  Adds an image to the Tweet.  For demo purposes, assume we have an
        //  image named 'larry.png' that we wish to attach
        if (![facebookSheet addImage:[UIImage imageWithData:[blogData.image getData]]]) {
            NSLog(@"Unable to add the image!");
        }
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
    //    if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
    //        NSLog(@"Unable to add the URL!");
    //    }
    
    //  Presents the Tweet Sheet to the user
    [self presentViewController:facebookSheet animated:NO completion:^{
        NSLog(@"Facebook posting has done.");
    }];
    
    [self onMoreClose:nil];
}

- (IBAction)onMoreTwitter:(id)sender {
    CommonUtils *utils = [CommonUtils sharedObject];
    BlogData *blogData = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
    
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone: {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Successfully posted to Twitter"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

                break;
            }
        }
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:blogData.strContent];
    
    if (blogData.image) {
        //  Adds an image to the Tweet.  For demo purposes, assume we have an
        //  image named 'larry.png' that we wish to attach
        if (![tweetSheet addImage:[UIImage imageWithData:[blogData.image getData]]]) {
            NSLog(@"Unable to add the image!");
        }
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
//    if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
//        NSLog(@"Unable to add the URL!");
//    }
    
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
    
    [self onMoreClose:nil];
}

- (IBAction)onMoreEmail:(id)sender {
    CommonUtils *utils = [CommonUtils sharedObject];
    BlogData *blogData = [utils.mBlogList objectAtIndex:m_nCurBlogNum];
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Skilled Share"];
    
//    NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@example.com", @"secondMail@example.com", nil];
//    [controller setToRecipients:toRecipients];

    if (blogData.image) {
        [controller addAttachmentData:[blogData.image getData] mimeType:@"image/png" fileName:@"mobiletutsImage"];
    }
    
    [controller setMessageBody:blogData.strContent isHTML:NO];
    
    if (controller) {
        [self.navigationController presentViewController:controller animated: YES completion:^{
        }];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
	if (result != MFMailComposeResultSent) {
//        NSString *strMessage;
//        
//        if (controller == mailerShare) {
//            strMessage = @"Email Share has been failed.";
//        }
//        else {
//            strMessage = @"Report has been failed.";
//        }
//        
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Email Share has been failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
	}
    
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onMoreReport:(id)sender {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Report"];
    
    NSArray *usersTo = [NSArray arrayWithObject:@"info@skilledapp.co"];
    [controller setToRecipients:usersTo];
    
    NSString* strMsg = [NSString stringWithFormat:@""];
    [controller setMessageBody:strMsg isHTML:NO];
    
    if (controller) {
        [self.navigationController presentViewController: controller animated: YES completion:^{
        }];
    }
}

- (IBAction)onSearch:(id)sender {
    m_bSearchOn = !m_bSearchOn;
    
    self.mTxtSearch.text = mStrSearchKey;
    
    if (m_bSearchOn) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect rt = self.mViewSearch.frame;
                             rt.origin.x = 0;
                             self.mViewSearch.frame = rt;
                         }completion:^(BOOL finished) {
                             [self.mTxtSearch becomeFirstResponder];
                         }];
    }
    else {
        
        if (mStrSearchKey.length > 0) {
            mStrSearchKey = @"";
            m_nCurrnetCount = 0;
            [self getBlog:YES];
        }
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect rt = self.mViewSearch.frame;
                             rt.origin.x = 320;
                             self.mViewSearch.frame = rt;
                         }completion:^(BOOL finished) {
                             //						 self.view.userInteractionEnabled = YES;
                         }];
        
        [self.mTxtSearch resignFirstResponder];
    }
}

- (IBAction)onTrend:(id)sender {
    m_bTrendMode = !m_bTrendMode;
    
    if (m_bTrendMode) {
        [self.mBtnTrend setImage:[UIImage imageNamed:@"home_trend_but.png"] forState:UIControlStateNormal];
    }
    else {
        [self.mBtnTrend setImage:[UIImage imageNamed:@"home_trendhot_but.png"] forState:UIControlStateNormal];
    }
    
    m_nCurrnetCount = 0;
    [self getBlog:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mTxtSearch) {
        
        if (![mStrSearchKey isEqualToString:self.mTxtSearch.text]) {
            mStrSearchKey = self.mTxtSearch.text;
            m_nCurrnetCount = 0;
            [self getBlog:YES];
        }
        
        [textField resignFirstResponder];
	}
    
	return YES;
}


//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
//初始化刷新视图
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#pragma mark
#pragma methods for creating and removing the header view

-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
									 self.view.frame.size.width, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    
    [self.mFeedTable addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)removeHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = nil;
}

-(void)setFooterView{
    //    UIEdgeInsets test = self.m_chartView.m_scrollView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(self.mFeedTable.contentSize.height, self.mFeedTable.frame.size.height);
    
    if (_refreshFooterView && [_refreshFooterView superview]) {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              self.mFeedTable.frame.size.width,
                                              self.view.bounds.size.height);
    }else {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         self.mFeedTable.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [self.mFeedTable addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}

-(void)removeFooterView{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark-
#pragma mark force to show the refresh headerView
-(void)showRefreshHeader:(BOOL)animated{
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.mFeedTable.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        // scroll the table view to the top region
        [self.mFeedTable scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [UIView commitAnimations];
	}
	else
	{
        self.mFeedTable.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[self.mFeedTable scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
	}
    
    [_refreshHeaderView setState:EGOOPullRefreshLoading];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	//	NSLog(@"scrollViewDidScroll");
	
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
//	NSLog(@"scrollViewDidEndDragging");
	
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

//===============
//刷新delegate
#pragma mark -
#pragma mark data reloading methods that must be overide by the subclass

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
	
	//  should be calling your tableviews data source model to reload
	_reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader) {
        // pull down to refresh data
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:0.0];
    }else if(aRefreshPos == EGORefreshFooter){
        // pull up to load more data
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:0.0];
    }
	
	// overide, the actual loading data operation is done in the subclass
}

#pragma mark -
#pragma mark method that should be called when the refreshing is finished
- (void)finishReloadingData{
	
//	NSLog(@"finishReloadingData");
	
	//  model should call this when its done loading
	_reloading = NO;
    
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mFeedTable];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mFeedTable];
        [self setFooterView];
    }
    
    // overide, the actula reloading tableView operation and reseting position operation is done in the subclass
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
	
	NSLog(@"egoRefreshTableDidTriggerRefresh");
	
	[self beginToReloadData:aRefreshPos];
	
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}


// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
	
	NSLog(@"egoRefreshTableDataSourceLastUpdated");
	
	return [NSDate date]; // should return date data source was last changed
	
}

//刷新调用的方法
-(void)refreshView{
    //    DataAccess *dataAccess= [[DataAccess alloc]init];
    //    NSMutableArray *dataArray = [dataAccess getDateArray];
    //    [self.aoView refreshView:dataArray];
    
    m_nCurrnetCount = 0;
    
    [self getBlog:NO];
    
//    [self testFinishedLoadData];
	
}
//加载调用的方法
-(void)getNextPageView{
    [self getBlog:NO];
	
    //    [self testFinishedLoadData];
	
}

-(void)testFinishedLoadData{
    [self finishReloadingData];
    [self createHeaderView];
    [self setFooterView];
}


@end
