//
//  CommentViewController.m
//  Skilld
//
//  Created by TianHang on 3/7/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentCell.h"
#import "OtherProfileViewController.h"

@interface CommentViewController () {
    PFUser *mCommentUser;
}

@end

@implementation CommentViewController

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
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
    
    PFUser *user = [PFUser currentUser];
    PFFile *photoFile = user[@"photo"];
    [self.mImgPhoto.layer setMasksToBounds:YES];
    [self.mImgPhoto.layer setCornerRadius:16.0];
    
    self.mImgPhoto.image = [UIImage imageNamed:@"profile_photo_default.png"];
    self.mImgPhoto.file = photoFile;
    [self.mImgPhoto loadInBackground];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard:)];
//    
//    [self.view addGestureRecognizer:tap];
}

//- (void)dismissKeyboard:(id)sender {
//    [self.mTxtContent resignFirstResponder];
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animationView:(CGFloat)yPos {
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
    { //phone
        
        CGSize sz = [[UIScreen mainScreen] bounds].size;
        if(yPos == sz.height - self.view.frame.size.height)
            return;
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rt = self.view.frame;
                             rt.size.height = sz.height - yPos;
                             
//                             NSLog(@"animationview: %f", rt.size.height);
                             self.view.frame = rt;
                         }completion:^(BOOL finished) {
                             self.view.userInteractionEnabled = YES;
                         }];
    }
}


#pragma mark - KeyBoard notifications
- (void)keyboardWillShow:(NSNotification*)notify {
	CGRect rtKeyBoard = [(NSValue*)[notify.userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [self animationView:rtKeyBoard.size.width];
    }
    else {
        [self animationView:rtKeyBoard.size.height];
    }
}

- (void)keyboardWillHide:(NSNotification*)notify {
	[self animationView:0];
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mBlogData.mCommentList.count > 0) {
        [self.mCommentTable setHidden:NO];
        [self.mLblNoComment setHidden:YES];
    }
    else {
        [self.mCommentTable setHidden:YES];
        [self.mLblNoComment setHidden:NO];
    }

    return self.mBlogData.mCommentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CommentCellID";
    
    CommentCell *commentCell = (CommentCell *)[self.mCommentTable dequeueReusableCellWithIdentifier:cellIdentifier];
//    UITableViewCell *commentCell = (UITableViewCell *)[self.mCommentTable dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIColor *backgroundcolor = [UIColor colorWithRed:0.12 green:0.12 blue:0.16 alpha:1.0];
    
    if (indexPath.row % 2) {
        backgroundcolor = [UIColor colorWithRed:0.16 green:0.16 blue:0.2 alpha:1.0];
    }
    
    
    if (commentCell == nil) {
        
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];

        [leftUtilityButtons addUtilityButtonWithColor:backgroundcolor icon:[UIImage imageNamed:@"comment_reply_but.png"]];
        [leftUtilityButtons addUtilityButtonWithColor:backgroundcolor icon:[UIImage imageNamed:@"comment_report_but.png"]];

//        commentCell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:cellIdentifier
//                                  containingTableView:tableView // Used for row height and selection
//                                   leftUtilityButtons:leftUtilityButtons
//                                  rightUtilityButtons:nil];
//        
//        commentCell.delegate = self;
        
        commentCell = (CommentCell *)[[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        commentCell.accessoryType = UITableViewCellAccessoryNone;
        
        UIFont *avenirnextFont = [UIFont fontWithName:@"AvenirNext-Regular" size:13];

        // username
        commentCell.nameButton = [[UIButton alloc] initWithFrame:CGRectMake(64, 1, 145, 30)];
        [commentCell.nameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        commentCell.nameButton.titleLabel.textColor = [UIColor whiteColor];
        commentCell.nameButton.titleLabel.font = avenirnextFont;
        [commentCell.contentView addSubview:commentCell.nameButton];
        
        [commentCell.nameButton addTarget:self action:@selector(onBtnUsername:) forControlEvents:UIControlEventTouchUpInside];
        
        // time label
        commentCell.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 8, 93, 15)];
        commentCell.timeLabel.textAlignment = NSTextAlignmentRight;
        commentCell.timeLabel.textColor = [UIColor whiteColor];
        commentCell.timeLabel.font = avenirnextFont;
        [commentCell.contentView addSubview:commentCell.timeLabel];
        
        commentCell.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 26, 246, 34)];
        commentCell.contentLabel.textAlignment = NSTextAlignmentLeft;
        commentCell.contentLabel.textColor = [UIColor grayColor];
        commentCell.textLabel.lineBreakMode = NSLineBreakByClipping;
        commentCell.contentLabel.numberOfLines = 0;
        commentCell.contentLabel.font = avenirnextFont;
        [commentCell.contentView addSubview:commentCell.contentLabel];
        
        commentCell.imgPhoto = [[PFImageView alloc] initWithFrame:CGRectMake(12, 9, 44, 45)];
        [commentCell.imgPhoto.layer setMasksToBounds:YES];
        [commentCell.imgPhoto.layer setCornerRadius:22.0];

        [commentCell.contentView addSubview:commentCell.imgPhoto];
        
    }
    
    commentCell.imgPhoto.image = [UIImage imageNamed:@"profile_photo_default.png"];
    
    CommentData *comment = [self.mBlogData.mCommentList objectAtIndex:indexPath.row];
    
    commentCell.nameButton.tag = indexPath.row;
    [commentCell.nameButton setTitle:comment.strUsername forState:UIControlStateNormal];;
    
    commentCell.contentLabel.text = comment.strContent;
    int nHeight = [CommonUtils getHeightMax:comment.strContent width:246 minheight:34];
    [commentCell.contentLabel setFrame:CGRectMake(commentCell.contentLabel.frame.origin.x,
                                                 commentCell.contentLabel.frame.origin.y,
                                                 commentCell.contentLabel.frame.size.width,
                                                 nHeight)];
    
    NSString *strTime = @"";
    
    NSTimeInterval time = -[comment.date timeIntervalSinceNow];
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

    commentCell.timeLabel.text = strTime;
    
    [comment.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFFile *photoFile = comment.user[@"photo"];
            commentCell.imgPhoto.file = photoFile;
            [commentCell.imgPhoto loadInBackground];
        }
    }];

    [commentCell.contentView setBackgroundColor:backgroundcolor];
    
    return commentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int nHeight = 69;
    
    CommentData *comment = [self.mBlogData.mCommentList objectAtIndex:indexPath.row];
    
    nHeight = [CommonUtils getHeightMax:comment.strContent width:246 minheight:34];
    
    nHeight = nHeight + 69 - 34;
    
    return nHeight;
}



- (void)onBtnUsername:(id)sender {
    int nCurCommentNum = (int)((UIButton*)sender).tag;
    
    CommentData *comment = [self.mBlogData.mCommentList objectAtIndex:nCurCommentNum];
    if ([comment.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        return;
    }
    
    mCommentUser = comment.user;
    [self performSegueWithIdentifier:@"Comment2OtherProfile" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Comment2OtherProfile"]) {
        OtherProfileViewController* otherViewController = [segue destinationViewController];
        otherViewController.mUser = mCommentUser;
    }
}


- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSend:(id)sender {
    if (self.mTxtContent.text.length > 0) {
        
        PFObject *commentObj = [PFObject objectWithClassName:@"Comments"];
        commentObj[@"blog"] = self.mBlogData.object;
        commentObj[@"user"] = [PFUser currentUser];
        commentObj[@"content"] = self.mTxtContent.text;
        commentObj[@"username"] = [CommonUtils getUsernameToShow:[PFUser currentUser]];
        commentObj[@"targetuser"] = self.mBlogData.user;
        if (self.mBlogData.image)
            commentObj[@"thumbnail"] = self.mBlogData.image;
        [commentObj saveInBackground];

        CommentData *comment = [[CommentData alloc] init];
        comment.strContent = [NSString stringWithString:self.mTxtContent.text];
        comment.user = [PFUser currentUser];
        comment.strUsername = [CommonUtils getUsernameToShow:[PFUser currentUser]];
        comment.date = [NSDate date];
        comment.object = commentObj;
        
        [self.mBlogData.mCommentList insertObject:comment atIndex:0];
        
        self.mTxtContent.text = @"";
        [self.mCommentTable reloadData];

    }
}

#pragma mark - SWTableViewDelegate

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            [self onSend:nil];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1: {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Report Comment"];
            
            NSArray *usersTo = [NSArray arrayWithObject:@"info@skilledapp.co"];
            [controller setToRecipients:usersTo];
            
            NSString* strMsg = [NSString stringWithFormat:@""];
            [controller setMessageBody:strMsg isHTML:NO];
            
            if (controller) {
                [self.navigationController presentViewController: controller animated: YES completion:^{
                }];
            }

            break;
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
	if (result == MFMailComposeResultSent) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Report has sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		alert.tag = 1000;
	}
    
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
