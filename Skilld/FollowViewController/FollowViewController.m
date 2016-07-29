//
//  FollowViewController.m
//  Skilled
//
//  Created by TianHang on 4/8/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "FollowViewController.h"
#import "OtherProfileViewController.h"
#import "CommonUtils.h"

@implementation FollowingLikeData

@end


@interface FollowViewController () {
    NSMutableArray *mFollowArray;
    PFUser *mTargetUser;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;

@end

@implementation FollowViewController

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
    mFollowArray = [[NSMutableArray alloc] init];
	
    NSString *strTitle;
    
    if (self.mBlogObject) {
        strTitle = @"Likes";
        
        // get like info
        PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
        [query whereKey:@"blog" equalTo:self.mBlogObject];
        [query orderByDescending:@"updatedAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *likeobjects, NSError *error) {
            
            if (!error) {
                for (PFObject *obj in likeobjects) {
                    FollowingLikeData *followData = [[FollowingLikeData alloc] init];
                    
                    followData.strUsername = obj[@"username"];
                    followData.user = obj[@"user"];
                    
                    [mFollowArray addObject:followData];
                }
                
                [self.mTableView reloadData];
            }
            else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else {
        if (self.mbFollowing) {
            strTitle = [NSString stringWithFormat:@"%@'s Following", [CommonUtils getUsernameToShow:self.mUser]];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Following"];
            [query whereKey:@"user" equalTo:self.mUser];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    for (PFObject *obj in objects) {
                        FollowingLikeData *followData = [[FollowingLikeData alloc] init];
                        
                        followData.strUsername = obj[@"followingusername"];
                        followData.user = obj[@"followinguser"];
                        
                        [mFollowArray addObject:followData];
                    }
                    
                    [self.mTableView reloadData];
                }
                else {
                    
                    NSString *errorString = [error userInfo][@"error"];
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        else {
            strTitle = [NSString stringWithFormat:@"%@'s Followers", [CommonUtils getUsernameToShow:self.mUser]];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Following"];
            [query whereKey:@"followinguser" equalTo:self.mUser];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    for (PFObject *obj in objects) {
                        FollowingLikeData *followData = [[FollowingLikeData alloc] init];
                        
                        followData.strUsername = obj[@"username"];
                        followData.user = obj[@"user"];
                        
                        [mFollowArray addObject:followData];
                    }
                    
                    [self.mTableView reloadData];
                }
                else {
                    
                    NSString *errorString = [error userInfo][@"error"];
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
            }];
        }
    }
    
    [self.mLblTitle setText:strTitle];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mFollowArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *followingCell = (UITableViewCell *)[self.mTableView dequeueReusableCellWithIdentifier:@"FollowCellID"];
    
    FollowingLikeData *followData = [mFollowArray objectAtIndex:indexPath.row];
    
    PFImageView *photoView = (PFImageView *)[followingCell viewWithTag:100];
    [photoView.layer setMasksToBounds:YES];
    [photoView.layer setCornerRadius:22.0];
    
    photoView.image = [UIImage imageNamed:@"profile_photo_default.png"];
    
    [followData.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFUser *user = (PFUser *)object;
        photoView.file = user[@"photo"];
        [photoView loadInBackground];
    }];
    
    UILabel *nameLabel = (UILabel *)[followingCell viewWithTag:101];
    [nameLabel setText:followData.strUsername];
    
    return followingCell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FollowingLikeData *followData = [mFollowArray objectAtIndex:indexPath.row];
    mTargetUser = followData.user;
    
    if ([mTargetUser.objectId isEqualToString:self.mUser.objectId]) {
        return;
    }

    [self performSegueWithIdentifier:@"Following2OtherProfile" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Following2OtherProfile"]) {
        OtherProfileViewController* otherViewController = [segue destinationViewController];
        otherViewController.mUser = mTargetUser;
    }
}


@end
