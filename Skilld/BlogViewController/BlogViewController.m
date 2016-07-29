//
//  BlogViewController.m
//  Skilled
//
//  Created by TianHang on 4/5/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "BlogViewController.h"
#import "HomeFeedCell.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/Twitter.h>
#import "CommentViewController.h"
#import "MainTabbarController.h"

#import "FollowViewController.h"
#import "CommonUtils.h"

@interface BlogViewController () <MFMailComposeViewControllerDelegate> {
    int m_nMoreShowYPos;
    int m_nMoreHideYPos;
}

@property (weak, nonatomic) IBOutlet UITableView *mFeedTable;
@property (weak, nonatomic) IBOutlet UIView *mViewMore;

- (IBAction)onBack:(id)sender;

@end

@implementation BlogViewController

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
    
    // get like info
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"blog" equalTo:self.mBlog.object];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *likeobjects, NSError *error) {
        
        if (!error) {
            if (likeobjects.count > 0) {
                self.mBlog.bLiked = 1;
            }
            else {
                self.mBlog.bLiked = 0;
            }
            
            [self.mFeedTable reloadData];

        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // get comment info
    self.mBlog.mCommentList = [[NSMutableArray alloc] init];
    query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"blog" equalTo:self.mBlog.object];
    [query orderByDescending:@"updatedAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *commentobjects, NSError *error) {
        
        if (!error) {
            for (PFObject *object in commentobjects) {
                CommentData *comment = [[CommentData alloc] init];
                comment.user = object[@"user"];
                comment.strContent = object[@"content"];
                comment.strUsername = object[@"username"];
                comment.date = object.updatedAt;
                comment.object = object;
                
                [self.mBlog.mCommentList addObject:comment];
            }
            
            [self.mFeedTable reloadData];
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    m_nMoreHideYPos = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    m_nMoreShowYPos = m_nMoreHideYPos - self.mViewMore.frame.size.height;
}

- (void) viewDidAppear:(BOOL)animated {
    [self.mFeedTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeFeedCell *feedCell = (HomeFeedCell *)[self.mFeedTable dequeueReusableCellWithIdentifier:@"BlogCellID"];
    
    [feedCell fillContent:self.mBlog];
    
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
    
    return feedCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int nHeight = 473;
    
    BlogData *blog = self.mBlog;
    
    if (blog.type == BlogText) {
//        nHeight = [CommonUtils getHeight:blog.strContent width:273 height:156] + TEXT_FACTOR;
        nHeight = [CommonUtils getHeight:blog.strContent width:273 height:0] + TEXT_FACTOR;
    }
    else {
//        nHeight = [CommonUtils getHeight:blog.strContent width:273 height:15];
        nHeight = [CommonUtils getHeight:blog.strContent width:273 height:0];
        nHeight += 320 - 25 + TEXT_FACTOR;
    }
    
    return nHeight;
}

- (void)onBtnLikeList:(id)sender {
    [self performSegueWithIdentifier:@"Blog2Follow" sender:nil];
}

- (void)onBtnCategory:(id)sender {
    CommonUtils *utils = [CommonUtils sharedObject];
    [utils setCategory:self.mBlog.category];
    
    NSArray *array = [self.navigationController viewControllers];
    UIViewController *popView;
    for (popView in array) {
        if ([popView isKindOfClass:[MainTabbarController class]]) {
            break;
        }
    }
    
    MainTabbarController *tabbarController = (MainTabbarController *)popView;
    tabbarController.selectedIndex = 0;
    [[self navigationController] popToViewController:popView animated:YES];
}

- (void)onBtnComment:(id)sender {
    [self performSegueWithIdentifier:@"Blog2Comments" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Blog2Comments"]) {
        CommentViewController* commentViewController = [segue destinationViewController];
        commentViewController.mBlogData = self.mBlog;
    }
    else if ([[segue identifier] isEqualToString:@"Blog2Follow"]) {
        FollowViewController* followViewController = [segue destinationViewController];
        
        followViewController.mBlogObject = self.mBlog.object;
        followViewController.mUser = [PFUser currentUser];
    }
}


- (void)onBtnMore:(id)sender {
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self onMoreClose:nil];
}


- (IBAction)onMoreFacebook:(id)sender {
    
    NSString *strTitle = (self.mBlog.strTitle) ? self.mBlog.strTitle : @"";
    
    // Put together the dialog parameters
    NSMutableDictionary *shareparams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        strTitle, @"name",
                                        @"Skilled", @"caption",
                                        self.mBlog.strContent, @"description",
                                        @"https://skilld.com", @"link",
                                        self.mBlog.image.url, @"picture",
                                        nil];
    
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:@"http://www.skilledapp.co"];
    params.name = strTitle;
    params.caption = @"Skilld";
    params.picture = [NSURL URLWithString:self.mBlog.image.url];
    params.description = self.mBlog.strContent;
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:params.caption
                                  description:params.description
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          
                                          [self onMoreClose:nil];
                                          
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"%@", [NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    }
    else {
        // Present the feed dialog
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:shareparams
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      
                                                      [self onMoreClose:nil];
                                                      
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"%@", [NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (IBAction)onMoreTwitter:(id)sender {
    
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
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:self.mBlog.strContent];
    
    if (self.mBlog.image) {
        //  Adds an image to the Tweet.  For demo purposes, assume we have an
        //  image named 'larry.png' that we wish to attach
        if (![tweetSheet addImage:[UIImage imageWithData:[self.mBlog.image getData]]]) {
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
}

- (IBAction)onMoreEmail:(id)sender {
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Skilled Share"];
    
    //    NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@example.com", @"secondMail@example.com", nil];
    //    [controller setToRecipients:toRecipients];
    
    if (self.mBlog.image) {
        [controller addAttachmentData:[self.mBlog.image getData] mimeType:@"image/png" fileName:@"mobiletutsImage"];
    }
    
    [controller setMessageBody:self.mBlog.strContent isHTML:NO];
    
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



@end
