//
//  SettingsViewController.m
//  Skilld
//
//  Created by TianHang on 3/18/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "SettingsViewController.h"
#import "Appirater.h"
#import "MBProgressHUD.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableViewDeleage

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 2;
        case 2:
			return 1;
		case 3:
			return 3;
		default:
			break;
	}
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kSourceCellID = @"SettingsCell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kSourceCellID];
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCellID];
        
        UIFont *proximaNova = [UIFont fontWithName:@"ProximaNova-Light" size:17];
        
        cell.backgroundColor = [UIColor colorWithRed:35/255.0 green:35/255.0 blue:46/255.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:104/255.0 alpha:1.0];
        [cell.textLabel setFont:proximaNova];
        
		switch (indexPath.section) {
			case 0: {
				cell.textLabel.text = @"Push Notifications";
                
                UISwitch* btnSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(255, 7, 80, 30)];
                [btnSwitch setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
				[btnSwitch addTarget:self action:@selector(onSwitchPushNotification:) forControlEvents:UIControlEventValueChanged];
				[cell addSubview:btnSwitch];
				btnSwitch.on = YES;
                
				cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				break;
            }
                
			case 1:
				if(indexPath.row == 0) {
                    cell.textLabel.text = @"Send feedback";
                }
				else if(indexPath.row == 1) {
                    cell.textLabel.text = @"Rate us on App Store";
                }
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
                
            case 2:
                cell.textLabel.text = @"Clear Cache";
                break;
                
			case 3:
				if(indexPath.row == 0)
					cell.textLabel.text = @"Privacy Policy";
				else if(indexPath.row == 1)
					cell.textLabel.text = @"Terms of Use";
				else if(indexPath.row == 2)
					cell.textLabel.text = @"FAQs";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
                
			default:
				break;
		}
	}
	return cell;
}

- (void)onSwitchPushNotification:(id)sender {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	switch (indexPath.section) {
		case 0:
			break;
            
		case 1: {
			if(indexPath.row == 0) {
                [self sendFeedback];
			}
			else if(indexPath.row == 1) {
                [self rateusOnAppstore];
			}
		}
			break;
            
        case 2: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Confirmation"
                                                           message:@"Do you really want to clear all cache data?"
                                                          delegate:self
                                                 cancelButtonTitle:@"No"
                                                 otherButtonTitles:@"Yes",nil];
            [alert show];
            break;
        }
            
		case 3:
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"Settings2PrivacyPolicy" sender:nil];
            }
            else if(indexPath.row == 1) {
                [self performSegueWithIdentifier:@"Settings2Terms" sender:nil];
            }
            else if(indexPath.row == 2) {
//                cell.textLabel.text = @"FAQs";
            }
			break;

		default:
			break;
	}
}
    
- (void)sendFeedback {
	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:@"Send Feedback"];
	
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
	if (result == MFMailComposeResultSent) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Feedback has been sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		alert.tag = 1000;
	}
    
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rateusOnAppstore {
	[Appirater showPrompt];
}


- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onLogout:(id)sender {
    [PFUser logOut];
    
    if ([FBSession activeSession]) {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cacheFolderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSError *error = nil;
        
        NSString *dir = [cacheFolderPath stringByAppendingPathComponent:@"Parse/PFFileCache"];
        NSArray *files = [fileManager contentsOfDirectoryAtPath:dir error:&error];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Clearing...";
        
        int nCount = [files count];
        int nCur = 0;
        
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:dir error:&error]) {
            BOOL success = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", dir, file] error:&error];
            if (!success || error) {
                // it failed.
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
            
            nCur++;
            
            int nPercent = (int)(nCur / (float)nCount * 100.0);
            hud.labelText = [NSString stringWithFormat:@"Clearing... %d%%", nPercent];
        }
        
        [hud hide:YES];
    }
}


@end
