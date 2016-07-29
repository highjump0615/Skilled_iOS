//
//  HomeViewController.h
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface HomeViewController : UIViewController {
    int m_nCurBlogNum;
    
    int m_nMoreShowYPos;
    int m_nMoreHideYPos;
    
    int m_nCurrnetCount;
    int m_nCountOnce;
    
    BOOL m_bTrendMode;
    BOOL m_bSearchOn;
    
    NSString *mStrSearchKey;
}

@property (weak, nonatomic) IBOutlet UITableView *mFeedTable;
@property (weak, nonatomic) IBOutlet UIView *mViewMore;
@property (weak, nonatomic) IBOutlet UIView *mViewSearch;
@property (weak, nonatomic) IBOutlet UITextField *mTxtSearch;
@property (weak, nonatomic) IBOutlet UIButton *mBtnTrend;

//@property(strong) NSMutableArray *mPlayerArray;


- (IBAction)onMoreClose:(id)sender;
- (IBAction)onMoreFacebook:(id)sender;
- (IBAction)onMoreTwitter:(id)sender;
- (IBAction)onMoreEmail:(id)sender;
- (IBAction)onMoreReport:(id)sender;

- (IBAction)onSearch:(id)sender;
- (IBAction)onTrend:(id)sender;

@end
