//
//  ProfileViewController.m
//  Skilld
//
//  Created by TianHang on 3/10/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "ProfileViewController.h"
#import "CommonUtils.h"
#import "MBProgressHUD.h"
#import "BlogViewController.h"
#import "FollowViewController.h"
#import "EditProfileViewController.h"
#import "ProfileInfoCell.h"
#import "HomeFeedCell.h"
#import "CommentViewController.h"
#import "PostViewController.h"

#import "EGORefreshTableFooterView.h"

@interface ProfileViewController () <EGORefreshTableDelegate, MFMailComposeViewControllerDelegate> {
    
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    
    int m_nIndex;
    int m_nFollowerCnt;
    int m_nFollowingCnt;
    int m_bFollowing;
    
    
    int m_nCurrnetCount;
    int m_nMediaCurrnetCount;
    
    int m_nBlogCount;
    int m_nMediaBlogCount;
    
    int m_bList;
    
    int m_nMoreShowYPos;
    int m_nMoreHideYPos;
    
    int m_nCurBlogNum;
    
    BOOL _reloading;
    
    int m_nCountOnce;
    int m_nMediaCountOnce;
    
    UITapGestureRecognizer *mTap;
}

@property (weak, nonatomic) IBOutlet UITableView *mProfileTable;
@property (weak, nonatomic) IBOutlet UIView *mViewMore;

@end

@implementation ProfileViewController

@synthesize mBlogs = mBlogs;
@synthesize mImageBlogs = mImageBlogs;

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
    
    mBlogs = [[NSMutableArray alloc] init];
    mImageBlogs = [[NSMutableArray alloc] init];
    m_nFollowerCnt = 0;
    m_nFollowingCnt = 0;
    m_bList = YES;
    
    m_nCountOnce = 3;
    m_nMediaCountOnce = 9;
    
    m_nMoreHideYPos = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    m_nMoreShowYPos = m_nMoreHideYPos - self.mViewMore.frame.size.height;
    
    PFUser *currentUser = [PFUser currentUser];
    self.mBackImage.file = currentUser[@"background"];
    [self.mBackImage loadInBackground];
    
    mTap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(onMoreClose:)];
    
    [self.view addGestureRecognizer:mTap];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.mViewMore setFrame:CGRectMake(self.mViewMore.frame.origin.x, m_nMoreHideYPos, self.mViewMore.frame.size.width, self.mViewMore.frame.size.height)];
//   [self.mProfileTable reloadData];
    
    m_nCurrnetCount = 0;
    m_nMediaCurrnetCount = 0;
    [self getBlog];
    [self getMediaBlog];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Following"];
    [query whereKey:@"followinguser" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            m_nFollowerCnt = (int)objects.count;
            [self.mProfileTable reloadData];
        }
    }];
    
    query = [PFQuery queryWithClassName:@"Following"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            m_nFollowingCnt = (int)objects.count;
            [self.mProfileTable reloadData];
        }
    }];

    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Profile2Blog"]) {
        
        PFObject *objBlog = [mImageBlogs objectAtIndex:m_nIndex];
        
        BlogViewController* blogViewController = [segue destinationViewController];
        
        BlogData *blog = [[BlogData alloc] init];
        
        blog.strId = objBlog.objectId;
        blog.type = [objBlog[@"type"] intValue];
        blog.strTitle = objBlog[@"title"];
        blog.strContent = objBlog[@"text"];
        blog.strVideoName = objBlog[@"video"];
        blog.image = (PFFile *)objBlog[@"image"];
        blog.date = objBlog.createdAt;
        blog.user = [PFUser currentUser];
        blog.object = objBlog;
        
        CommonUtils *utils = [CommonUtils sharedObject];
        
        // set category
        for (BlogCategory *cate in utils.mCategoryList) {
            if ([cate.strId isEqualToString:objBlog[@"category"]]) {
                blog.category = cate;
                break;
            }
        }
        
        blog.bLiked = -1;
        blog.nLikeCount = [objBlog[@"likes"] intValue];

        blogViewController.mBlog = blog;
    }
    else if ([[segue identifier] isEqualToString:@"Profile2Following"]) {
        FollowViewController* followViewController = [segue destinationViewController];
        followViewController.mbFollowing = m_bFollowing;
        followViewController.mUser = [PFUser currentUser];
        
        if (m_nCurBlogNum >= 0) {
            BlogData *blog = [mBlogs objectAtIndex:m_nCurBlogNum];
            followViewController.mBlogObject = blog.object;
        }
        else {
            followViewController.mBlogObject = nil;
        }
    }
    else if ([[segue identifier] isEqualToString:@"Profile2EditProfile"]) {
        EditProfileViewController* editViewController = [segue destinationViewController];
        editViewController.mParent = self;
    }
    else if ([[segue identifier] isEqualToString:@"Profile2Comments"]) {
        CommentViewController* commentViewController = [segue destinationViewController];
        commentViewController.mBlogData = [mBlogs objectAtIndex:m_nCurBlogNum];
    }
    else if ([[segue identifier] isEqualToString:@"Profile2Post"]) {
        PostViewController* postViewController = [segue destinationViewController];
        postViewController.mParentViewController = self;
    }
}

- (void)onButFollower:(id)sender {
    m_bFollowing = NO;
    m_nCurBlogNum = -1;
    [self performSegueWithIdentifier:@"Profile2Following" sender:nil];
}

- (void)onButFollowing:(id)sender {
    m_bFollowing = YES;
    m_nCurBlogNum = -1;
    [self performSegueWithIdentifier:@"Profile2Following" sender:nil];
}

- (void)setBlogFooterView {
    if (m_bList) {  // list view
        if (mBlogs.count > 0) {
            [self setFooterView];
        }
        else {
            [self removeFooterView];
        }
    }
    else {  // collection view
        if (mImageBlogs.count >= m_nMediaCountOnce) {
            [self setFooterView];
        }
        else {
            [self removeFooterView];
        }
    }
}

- (void)onBtnBlogList:(id)sender {
    if (!m_bList) {
        m_bList = YES;
        [self.mProfileTable reloadData];
        [self.view addGestureRecognizer:mTap];
        
        m_nCurrnetCount = 0;
        [self getBlog];

        [self setBlogFooterView];
    }
}

- (void)onBtnGrid:(id)sender {
    if (m_bList) {
        [[CommonUtils sharedObject] stopPlaying];
        
        m_bList = NO;
        [self.mProfileTable reloadData];
        [self.view removeGestureRecognizer:mTap];
        
        [self onMoreClose:nil];
        
        m_nMediaCurrnetCount = 0;
        [self getMediaBlog];
        
        [self setBlogFooterView];
    }
}

- (void)onBtnLikeList:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;
    [self performSegueWithIdentifier:@"Profile2Following" sender:nil];
}

- (void)onBtnCategory:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;
    CommonUtils *utils = [CommonUtils sharedObject];
    BlogData *blog = [mBlogs objectAtIndex:m_nCurBlogNum];
    
    [utils setCategory:blog.category];
    self.tabBarController.selectedIndex = 0;
}

- (void)onBtnComment:(id)sender {
    m_nCurBlogNum = (int)((UIButton*)sender).tag;
    [self performSegueWithIdentifier:@"Profile2Comments" sender:nil];
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

- (void)onMoreClose:(id)sender {
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rt = self.mViewMore.frame;
                         rt.origin.y = m_nMoreHideYPos;
                         self.mViewMore.frame = rt;
                     }completion:^(BOOL finished) {
                         //						 self.view.userInteractionEnabled = YES;
                     }];
}

- (IBAction)onMoreEmail:(id)sender {
    BlogData *blogData = [mBlogs objectAtIndex:m_nCurBlogNum];
    
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

- (IBAction)onMoreDelete:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete"
                                                   message:@"Do you really want to delete this post?"
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
	[alert show];
    
    [self onMoreClose:nil];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{

        BlogData *blogData = [mBlogs objectAtIndex:m_nCurBlogNum];
        
        // delete comment data
        for (CommentData *comment in blogData.mCommentList) {
            [comment.object deleteInBackground];
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
        [query whereKey:@"blog" equalTo:blogData.object];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *likeobjects, NSError *error) {
            
            if (!error) {
                for (PFObject *likeobject in likeobjects) {
                    [likeobject deleteInBackground];
                }
                
                if (blogData.type == BlogVideo) {
                    CommonUtils *utils = [CommonUtils sharedObject];
                    [utils.s3 deleteObjectWithKey:blogData.strVideoName withBucket:VIDEO_BUCKET];
                }
                
                [blogData.object deleteInBackground];
            }
            else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

        [mBlogs removeObjectAtIndex:m_nCurBlogNum];
        for (PFObject *object in mImageBlogs) {
            if (object == blogData.object) {
                [mImageBlogs removeObject:object];
                break;
            }
        }
        m_nBlogCount--;
        
        [self.mProfileTable reloadData];
        [self setBlogFooterView];
    }
}

#pragma mark - Collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return mImageBlogs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ImageCollectionCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    PFObject *objBlog = [mImageBlogs objectAtIndex:indexPath.row];
    
    PFImageView *backImageView = (PFImageView *)[cell viewWithTag:100];
    [backImageView setBackgroundColor:[UIColor clearColor]];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"profile_img_default.png"];
    
    if (objBlog) {
        backImageView.file = objBlog[@"image"];
        [backImageView loadInBackground:^(UIImage *image, NSError *error) {
            [backImageView setBackgroundColor:[UIColor blackColor]];
        }];
        
        UIImageView *videoIconView = (UIImageView *)[cell viewWithTag:101];
        
        if ([objBlog[@"type"] intValue] == BlogVideo) {
            [videoIconView setHidden:NO];
        }
        else {
            [videoIconView setHidden:YES];
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    m_nIndex = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"Profile2Blog" sender:nil];
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int nNum = 1;
    
    if (m_bList) {
        nNum = (int)mBlogs.count + 1;
    }
    else {
        if (mImageBlogs.count > 0) {
            nNum = 2;
        }
    }
    
    return nNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableCell;
    
    if (indexPath.row == 0) {
        ProfileInfoCell *profileCell = (ProfileInfoCell *)[self.mProfileTable dequeueReusableCellWithIdentifier:@"ProfileCell"];

        PFUser *currentUser = [PFUser currentUser];
        //    CommonUtils *utils = [CommonUtils sharedObject];
        
        if (currentUser) {
            profileCell.mFullNameLbl.text = currentUser[@"fullname"];
            profileCell.mLocationLbl.text = currentUser[@"location"];
            profileCell.mAboutLbl.text = currentUser[@"about"];
            
            PFFile *photoFile = currentUser[@"photo"];
            
            profileCell.mPhotoImg.image = [UIImage imageNamed:@"profile_photo_default.png"];
            profileCell.mPhotoImg.file = photoFile;
            [profileCell.mPhotoImg loadInBackground];
            
//            profileCell.mPostNumLbl.text = [NSString stringWithFormat:@"%lu", (unsigned long)mBlogs.count];
            profileCell.mPostNumLbl.text = [NSString stringWithFormat:@"%lu", (unsigned long)m_nBlogCount];
            //        self.mFollowerNumLbl.text = [NSString stringWithFormat:@"%d", [currentUser[@"followercount"] intValue]];
//            profileCell.mFollowingNumLbl.text = [NSString stringWithFormat:@"%d", [currentUser[@"followingcount"] intValue]];
        }
        
        profileCell.mFollowerNumLbl.text = [NSString stringWithFormat:@"%d", m_nFollowerCnt];
        profileCell.mFollowingNumLbl.text = [NSString stringWithFormat:@"%d", m_nFollowingCnt];
        
        if (m_bList) {
            [profileCell.mButBlog setImage:[UIImage imageNamed:@"profile_blog.png"] forState:UIControlStateNormal];
            [profileCell.mButGrid setImage:[UIImage imageNamed:@"profile_picture_norm.png"] forState:UIControlStateNormal];
        }
        else {
            [profileCell.mButBlog setImage:[UIImage imageNamed:@"profile_blog_norm.png"] forState:UIControlStateNormal];
            [profileCell.mButGrid setImage:[UIImage imageNamed:@"profile_picture.png"] forState:UIControlStateNormal];
        }
        
        [profileCell.mButBlog addTarget:self action:@selector(onBtnBlogList:) forControlEvents:UIControlEventTouchUpInside];
        [profileCell.mButGrid addTarget:self action:@selector(onBtnGrid:) forControlEvents:UIControlEventTouchUpInside];
        
        [profileCell.mButFollower addTarget:self action:@selector(onButFollower:) forControlEvents:UIControlEventTouchUpInside];
        [profileCell.mButFollowing addTarget:self action:@selector(onButFollowing:) forControlEvents:UIControlEventTouchUpInside];
        
        tableCell = profileCell;
    }
    else {
        if (m_bList) {
            HomeFeedCell *listCell = (HomeFeedCell *)[self.mProfileTable dequeueReusableCellWithIdentifier:@"ProfileListCell"];
            
            BlogData *blog = [mBlogs objectAtIndex:indexPath.row - 1];
            [listCell fillContent:blog];
            
            // likelist button
            [listCell.mBtnLikeList addTarget:self action:@selector(onBtnLikeList:) forControlEvents:UIControlEventTouchUpInside];
            listCell.mBtnLikeList.tag = indexPath.row - 1;
            
            // category button
            [listCell.mBtnCategory addTarget:self action:@selector(onBtnCategory:) forControlEvents:UIControlEventTouchUpInside];
            listCell.mBtnCategory.tag = indexPath.row - 1;
            
            // comment button
            [listCell.mBtnComment addTarget:self action:@selector(onBtnComment:) forControlEvents:UIControlEventTouchUpInside];
            listCell.mBtnComment.tag = indexPath.row - 1;
            
            // more button
            [listCell.mBtnMore addTarget:self action:@selector(onBtnMore:) forControlEvents:UIControlEventTouchUpInside];
            listCell.mBtnMore.tag = indexPath.row - 1;
            
            tableCell = listCell;
        }
        else {
            if (indexPath.row == 1) {
                UITableViewCell *gridCell = (UITableViewCell *)[self.mProfileTable dequeueReusableCellWithIdentifier:@"ProfileGridCell"];
                
                UICollectionView *gridView = (UICollectionView *)[gridCell viewWithTag:101];
                [gridView setFrame:CGRectMake(gridView.frame.origin.x, gridView.frame.origin.x, gridView.frame.size.width, ceil(mImageBlogs.count / 3.0) * 105)];
                [gridView setContentSize:CGSizeMake(self.mProfileTable.frame.size.width, ceil(mImageBlogs.count / 3.0) * 105)];
                [gridView reloadData];

                tableCell = gridCell;
            }
        }
    }
    
    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int nHeight = 0;
    
    if (indexPath.row == 0) {
        nHeight = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
        
        if (m_bList) {
            if (mBlogs.count > 0) {
                nHeight = 288;
            }
        }
        else {
            if (mImageBlogs.count > 0) {
                nHeight = 288;
            }
        }
    }
    else {
        if (m_bList) {
            nHeight = 473;
            
            BlogData *blog = [mBlogs objectAtIndex:indexPath.row - 1];
            
            if (blog.type == BlogText) {
//                nHeight = [CommonUtils getHeight:blog.strContent width:273 height:156] + TEXT_FACTOR;
                nHeight = [CommonUtils getHeight:blog.strContent width:273 height:0] + TEXT_FACTOR;
            }
            else {
//                nHeight = [CommonUtils getHeight:blog.strContent width:273 height:15];
                nHeight = [CommonUtils getHeight:blog.strContent width:273 height:0];
                nHeight += 320 - 25 + TEXT_FACTOR;
            }
        }
        else {
            if (indexPath.row == 1) {
                nHeight = ceil(mImageBlogs.count / 3.0) * 105;
            }
        }
    }

    return nHeight;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (m_bList && indexPath.row > 0) {
        if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound) {
            HomeFeedCell *feedCell = (HomeFeedCell *)cell;
            [feedCell onStop];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self onMoreClose:nil];
}


-(void)setFooterView{
    //    UIEdgeInsets test = self.m_chartView.m_scrollView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(self.mProfileTable.contentSize.height, self.mProfileTable.frame.size.height);
    
    if (_refreshFooterView && [_refreshFooterView superview]) {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              self.mProfileTable.frame.size.width,
                                              self.view.bounds.size.height);
    }else {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         self.mProfileTable.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [self.mProfileTable addSubview:_refreshFooterView];
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

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	//	NSLog(@"scrollViewDidScroll");
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    //	NSLog(@"scrollViewDidEndDragging");
	
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
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mProfileTable];
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
    
//    [self getBlog:NO];
    
    //    [self testFinishedLoadData];
	
}
//加载调用的方法
-(void)getNextPageView{
    
    if (m_bList) {
        [self getBlog];
    }
    else {
        [self getMediaBlog];
    }
	
    //    [self testFinishedLoadData];
	
}

-(void)testFinishedLoadData{
    [self finishReloadingData];
    [self setFooterView];
}

- (void)getBlog {
    
    if (![PFUser currentUser]) {
        return;
    }

    PFQuery *queryCount = [PFQuery queryWithClassName:@"Blogs"];
    [queryCount whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [queryCount findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            m_nBlogCount = (int)objects.count;
            [self.mProfileTable reloadData];
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blogs"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    query.limit = m_nCountOnce;
    query.skip = m_nCurrnetCount;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            //            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //
            //            self.mPostNumLbl.text = [NSString stringWithFormat:@"%lu", (unsigned long)objects.count];
            
            if (m_nCurrnetCount == 0) {
                [mBlogs removeAllObjects];
            }
            
            if (objects.count > 0) {
                //                [self.mNoMediaLbl setHidden:YES];
                
                CommonUtils *utils = [CommonUtils sharedObject];
                
                for (PFObject *obj in objects) {
                    BlogData *blog = [[BlogData alloc] init];
                    blog.strId = obj.objectId;
                    blog.type = [obj[@"type"] intValue];
                    blog.strTitle = obj[@"title"];
                    blog.strContent = obj[@"text"];
                    blog.strVideoName = obj[@"video"];
                    blog.image = (PFFile *)obj[@"image"];
                    blog.date = obj.createdAt;
                    blog.user = [PFUser currentUser];
                    blog.object = obj;
                    blog.bLiked = -1;
                    blog.nLikeCount = [obj[@"likes"] intValue];
                    
                    // set category
                    for (BlogCategory *cate in utils.mCategoryList) {
                        if ([cate.strId isEqualToString:obj[@"category"]]) {
                            blog.category = cate;
                            break;
                        }
                    }
                    
                    [mBlogs addObject:blog];
                }
            }
            
            [self.mProfileTable reloadData];
            [self testFinishedLoadData];
            [self setBlogFooterView];
            
            int i = 0;
            
            for (BlogData *blog in mBlogs) {
                
                // get like info
                if ([PFUser currentUser]) {
                    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
                    [query whereKey:@"blog" equalTo:blog.object];
                    [query whereKey:@"user" equalTo:[PFUser currentUser]];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *likeobjects, NSError *error) {
                        
                        if (!error) {
                            
                            if (likeobjects.count > 0) {
                                blog.bLiked = 1;
                            }
                            else {
                                blog.bLiked = 0;
                            }
                            
                            [self.mProfileTable reloadData];
                        }
                        else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                    
                    // get comment info
                    query = [PFQuery queryWithClassName:@"Comments"];
                    [query whereKey:@"blog" equalTo:blog.object];
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
                            
                            [self.mProfileTable reloadData];
                        }
                        else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                }
                
                i++;
            }
            
            m_nCurrnetCount += objects.count;
            
        }
        else {
            
            NSString *errorString = [error userInfo][@"error"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
}

- (void)getMediaBlog {
    
    if (![PFUser currentUser]) {
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blogs"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    // query media blogs only
    [query whereKey:@"type" greaterThan:[NSNumber numberWithInt:BlogText]];
    
    query.limit = m_nMediaCountOnce;
    query.skip = m_nMediaCurrnetCount;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            //            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //
            //            self.mPostNumLbl.text = [NSString stringWithFormat:@"%lu", (unsigned long)objects.count];
            
            if (m_nMediaCurrnetCount == 0) {
                [mImageBlogs removeAllObjects];
            }
            
            if (objects.count > 0) {
                //                [self.mNoMediaLbl setHidden:YES];
                
                CommonUtils *utils = [CommonUtils sharedObject];
                
                for (PFObject *obj in objects) {
                    BlogData *blog = [[BlogData alloc] init];
                    
                    blog.strId = obj.objectId;
                    blog.type = [obj[@"type"] intValue];
                    blog.strTitle = obj[@"title"];
                    blog.strContent = obj[@"text"];
                    blog.strVideoName = obj[@"video"];
                    blog.image = (PFFile *)obj[@"image"];
                    blog.date = obj.createdAt;
                    blog.user = [PFUser currentUser];
                    blog.object = obj;
                    blog.bLiked = -1;
                    blog.nLikeCount = [obj[@"likes"] intValue];
                    
                    // set category
                    for (BlogCategory *cate in utils.mCategoryList) {
                        if ([cate.strId isEqualToString:obj[@"category"]]) {
                            blog.category = cate;
                            break;
                        }
                    }
                    
                    [mImageBlogs addObject:obj];
                }
            }
            
            [self.mProfileTable reloadData];
            [self testFinishedLoadData];
            [self setBlogFooterView];
            
            m_nMediaCurrnetCount += objects.count;
            
        }
        else {
            
            NSString *errorString = [error userInfo][@"error"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
    
}


@end
