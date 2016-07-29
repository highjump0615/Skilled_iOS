//
//  NotifyViewController.m
//  Skilld
//
//  Created by TianHang on 3/10/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "NotifyViewController.h"
#import "MBProgressHUD.h"
#import "NotifyTableCell.h"
#import "CommonUtils.h"
#import "OtherProfileViewController.h"

#import "EGORefreshTableFooterView.h"

@implementation NotificationData

@end

@interface NotifyViewController () <EGORefreshTableDelegate> {
    
    NSMutableArray *mFollowingList;
    NSMutableArray *mLikeList;
    NSMutableArray *mCommentList;
    
    NotificationData *mNotifyData;
    int mnNotifyType;
    
    int m_nCountOnce;
    int m_nFollowCurrnetCount;
    int m_nLikeCurrnetCount;
    int m_nCommentCurrnetCount;
    
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *mSegment;

@end

@implementation NotifyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getNotificationData {
    if (mnNotifyType == 0) { // following
        // get following info
        PFQuery *query = [PFQuery queryWithClassName:@"Following"];
        [query whereKey:@"followinguser" equalTo:[PFUser currentUser]];
        [query orderByDescending:@"updatedAt"];
        
        query.limit = m_nCountOnce;
        query.skip = m_nFollowCurrnetCount;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (mnNotifyType != 0) {
               return;
            }
            
            if (!error) {
                
                if (m_nFollowCurrnetCount == 0) {
                    [mFollowingList removeAllObjects];
                }
                
                for (PFObject *obj in objects) {
                    
                    NotificationData *notifyData = [[NotificationData alloc] init];
                    
                    notifyData.user = obj[@"user"];
                    notifyData.strUsername = obj[@"username"];
                    notifyData.type = NotificationFollow;
                    notifyData.date = obj.updatedAt;
                    
                    [mFollowingList addObject:notifyData];
                }
                
                m_nFollowCurrnetCount += objects.count;
                
                [self.mTableView reloadData];
                
                if (m_nFollowCurrnetCount > m_nCountOnce) {
                    [self testFinishedLoadData];
                }
            }
            else {
                
                NSString *errorString = [error userInfo][@"error"];
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else if (mnNotifyType == 1) { // like
        // get like info
        PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
        [query whereKey:@"targetuser" equalTo:[PFUser currentUser]];
        [query orderByDescending:@"updatedAt"];
        
        query.limit = m_nCountOnce;
        query.skip = m_nLikeCurrnetCount;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (mnNotifyType != 1) {
                return;
            }
            
            if (!error) {
                
                if (m_nLikeCurrnetCount == 0) {
                    [mLikeList removeAllObjects];
                }
                
                for (PFObject *obj in objects) {
                    
                    int nType = [obj[@"type"] intValue];
                    
                    NotificationData *notifyData = [[NotificationData alloc] init];
                    
                    notifyData.user = obj[@"user"];
                    notifyData.strUsername = obj[@"username"];

                    if (nType == BlogText) {
                        notifyData.type = NotificationLikeText;
                    }
                    else if (nType == BlogImage) {
                        notifyData.type = NotificationLikePhoto;
                    }
                    else if (nType == BlogVideo) {
                        notifyData.type = NotificationLikeVideo;
                    }
                    
                    notifyData.image = obj[@"thumbnail"];
                    notifyData.date = obj.updatedAt;
                    
                    [mLikeList addObject:notifyData];
                }
                
                m_nLikeCurrnetCount += objects.count;
                
                [self.mTableView reloadData];
                
                if (m_nLikeCurrnetCount > m_nCountOnce) {
                    [self testFinishedLoadData];
                }
            }
            else {
                
                NSString *errorString = [error userInfo][@"error"];
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else if (mnNotifyType == 2) { // comment
        // get like info
        PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
        [query whereKey:@"targetuser" equalTo:[PFUser currentUser]];
        [query orderByDescending:@"updatedAt"];
        
        query.limit = m_nCountOnce;
        query.skip = m_nCommentCurrnetCount;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (mnNotifyType != 2) {
                return;
            }
            
            if (!error) {
                
                if (m_nCommentCurrnetCount == 0) {
                    [mCommentList removeAllObjects];
                }
                
                for (PFObject *obj in objects) {
                    
                    NotificationData *notifyData = [[NotificationData alloc] init];
                    
                    notifyData.user = obj[@"user"];
                    notifyData.strUsername = obj[@"username"];
                    notifyData.strComment = obj[@"content"];
                    notifyData.image = obj[@"thumbnail"];
                    notifyData.date = obj.updatedAt;
                    notifyData.type = NotificationComment;
                    
                    [mCommentList addObject:notifyData];
                }
                
                m_nCommentCurrnetCount += objects.count;
                
                [self.mTableView reloadData];

                if (m_nCommentCurrnetCount > m_nCountOnce) {
                    [self testFinishedLoadData];
                }
            }
            else {
                
                NSString *errorString = [error userInfo][@"error"];
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    mFollowingList = [[NSMutableArray alloc] init];
    mLikeList = [[NSMutableArray alloc] init];
    mCommentList = [[NSMutableArray alloc] init];
    
    [self.mSegment addTarget:self
                      action:@selector(onChangeSegment:forEvent:)
            forControlEvents:UIControlEventValueChanged];

    mnNotifyType = 0;
    m_nFollowCurrnetCount = m_nLikeCurrnetCount =  m_nCommentCurrnetCount = 0;
    m_nCountOnce = 10;
    [self getNotificationData];
}

- (void)onChangeSegment:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"changed %ld", (long)self.mSegment.selectedSegmentIndex);
    
    mnNotifyType = (int)self.mSegment.selectedSegmentIndex;
    m_nFollowCurrnetCount = m_nLikeCurrnetCount =  m_nCommentCurrnetCount = 0;
    [self getNotificationData];
    
    [self.mTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (mnNotifyType == 0) {
        return [mFollowingList count];
    }
    else if (mnNotifyType == 1) {
        return [mLikeList count];
    }
    else {
        return [mCommentList count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"";
    NotifyTableCell *notifyCell;
    int nIndex = 0;
    
    switch (mnNotifyType) {
        case 0: { // following
            cellIdentifier = @"NotifyFollowCellID";
            notifyCell = (NotifyTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            [notifyCell.mImgUser.layer setMasksToBounds:YES];
            [notifyCell.mImgUser.layer setCornerRadius:22.0];
            notifyCell.mImgUser.image = [UIImage imageNamed:@"profile_photo_default.png"];
            notifyCell.mImgPhoto.image = [UIImage imageNamed:@"profile_img_default.png"];
            
            for (NotificationData *data in mFollowingList) {
                
                if (data.type == NotificationFollow) {
                    if (nIndex == indexPath.row) {
                        [data.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            PFUser *followUser = (PFUser *)object;
                            
                            notifyCell.mImgUser.file = followUser[@"photo"];
                            [notifyCell.mImgUser loadInBackground];
                        }];
                        
                        [notifyCell.mLblText setText:[NSString stringWithFormat:@"%@ followed you", data.strUsername]];
                        [notifyCell.mLblTime setText:[CommonUtils getTimeString:data.date]];
                        
                        break;
                    }
                    
                    nIndex++;
                }
            }
            
            break;
        }
            
        case 1: { // like
            cellIdentifier = @"NotifyLikeCellID";
            notifyCell = (NotifyTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            [notifyCell.mImgUser.layer setMasksToBounds:YES];
            [notifyCell.mImgUser.layer setCornerRadius:22.0];
            notifyCell.mImgUser.image = [UIImage imageNamed:@"profile_photo_default.png"];
            notifyCell.mImgPhoto.image = [UIImage imageNamed:@"profile_img_default.png"];
            
            notifyCell.mImgPhoto.image = [UIImage imageNamed:@"profile_img_default.png"];
            
            for (NotificationData *data in mLikeList) {
                
                    if (nIndex == indexPath.row) {
                        [data.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            PFUser *followUser = (PFUser *)object;
                            
                            notifyCell.mImgUser.file = followUser[@"photo"];
                            [notifyCell.mImgUser loadInBackground];
                        }];
                        
                        NSString *strFormat;
                        if (data.type == NotificationLikeText) {
                            strFormat = [NSString stringWithFormat:@"%@ liked your text", data.strUsername];
                            
                            [notifyCell.mImgPhoto setHidden:YES];
                        }
                        else {
                            if (data.type == NotificationLikePhoto) {
                                strFormat = [NSString stringWithFormat:@"%@ liked your photo", data.strUsername];
                            }
                            else {
                                strFormat = [NSString stringWithFormat:@"%@ liked your video", data.strUsername];
                            }
                            
                            [notifyCell.mImgPhoto setHidden:NO];
                            notifyCell.mImgPhoto.file = data.image;
                            [notifyCell.mImgPhoto loadInBackground];
                        }
                        
                        [notifyCell.mLblText setText:strFormat];
                        [notifyCell.mLblTime setText:[CommonUtils getTimeString:data.date]];
                        
                        break;
                    }
                    
                    nIndex++;
            }
            
            break;
        }
            
        case 2: { // comment
            cellIdentifier = @"NotifyLikeCellID";
            notifyCell = (NotifyTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            [notifyCell.mImgUser.layer setMasksToBounds:YES];
            [notifyCell.mImgUser.layer setCornerRadius:22.0];
            notifyCell.mImgUser.image = [UIImage imageNamed:@"profile_photo_default.png"];
            notifyCell.mImgPhoto.image = [UIImage imageNamed:@"profile_img_default.png"];
            
            for (NotificationData *data in mCommentList) {
                
                if (data.type == NotificationComment) {
                    if (nIndex == indexPath.row) {
                        [data.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            PFUser *followUser = (PFUser *)object;
                            
                            notifyCell.mImgUser.file = followUser[@"photo"];
                            [notifyCell.mImgUser loadInBackground];
                        }];
                        
                        [notifyCell.mLblText setText:[NSString stringWithFormat:@"%@ commented your post", data.strUsername]];
                        [notifyCell.mLblTime setText:[CommonUtils getTimeString:data.date]];
                        
                        if (data.image) {
                            [notifyCell.mImgPhoto setHidden:NO];
                            notifyCell.mImgPhoto.file = data.image;
                            [notifyCell.mImgPhoto loadInBackground];
                        }
                        else {
                            [notifyCell.mImgPhoto setHidden:YES];
                        }
                        
                        break;
                    }
                    
                    nIndex++;
                }
            }
            
            break;
        }
    }
    
    
    
    return notifyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    int nIndex = 0;
    
    if (mnNotifyType == 0) {
        mNotifyData = [mFollowingList objectAtIndex:indexPath.row];
    }
    else if (mnNotifyType == 1) {
        mNotifyData = [mLikeList objectAtIndex:indexPath.row];
    }
    else {
        mNotifyData = [mCommentList objectAtIndex:indexPath.row];
    }
    
    
//    switch (indexPath.section) {
//        case 0: {
//            
//            for (NotificationData *data in mNotificationList) {
//                
//                if (data.type == NotificationFollow) {
//                    if (nIndex == indexPath.row) {
//                        mNotifyData = data;
//                        break;
//                    }
//                    
//                    nIndex++;
//                }
//            }
//            
//            break;
//        }
//            
//        case 1: {
//            
//            for (NotificationData *data in mNotificationList) {
//                
//                if (data.type == NotificationLikePhoto || data.type == NotificationLikeVideo) {
//                    if (nIndex == indexPath.row) {
//                        mNotifyData = data;
//                        break;
//                    }
//                    
//                    nIndex++;
//                }
//            }
//            
//            break;
//        }
//            
//        case 2: {
//
//            for (NotificationData *data in mNotificationList) {
//                
//                if (data.type == NotificationComment) {
//                    if (nIndex == indexPath.row) {
//                        mNotifyData = data;
//                        break;
//                    }
//
//                    nIndex++;
//                }
//            }
//            
//            break;
//        }
//    }
    
    if (mNotifyData) {
        [mNotifyData.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self performSegueWithIdentifier:@"Notification2OtherProfile" sender:nil];
        }];
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 25;
//}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Notification2OtherProfile"]) {
        OtherProfileViewController* otherViewController = [segue destinationViewController];
        otherViewController.mUser = mNotifyData.user;
    }
}


-(void)setFooterView{
    //    UIEdgeInsets test = self.m_chartView.m_scrollView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(self.mTableView.contentSize.height, self.mTableView.frame.size.height);
    
    if (_refreshFooterView && [_refreshFooterView superview]) {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              self.mTableView.frame.size.width,
                                              self.view.bounds.size.height);
    }else {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         self.mTableView.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [self.mTableView addSubview:_refreshFooterView];
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
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mTableView];
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
    
//    m_nCurrnetCount = 0;
    
    //    [self getBlog:NO];
    
    //    [self testFinishedLoadData];
	
}
//加载调用的方法
-(void)getNextPageView{
    
    [self getNotificationData];
    //    [self testFinishedLoadData];
	
}

-(void)testFinishedLoadData{
    [self finishReloadingData];
    [self setFooterView];
}



@end
