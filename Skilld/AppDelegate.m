//
//  AppDelegate.m
//  Skilld
//
//  Created by TianHang on 3/4/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "FavouriteViewController.h"
#import "NotifyViewController.h"
#import "ProfileViewController.h"
#import "CommonUtils.h"
#import "Appirater.h"

#import <AWSRuntime/AWSRuntime.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    UIImage *image = [UIImage imageNamed:@"logo.png"];
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:35/255.0 green:35/255.0 blue:46/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [Parse setApplicationId:@"f8qAhmS35GfGPxwfj6ZDJ9Ja1lWb5WIsCI5DknaG"
                  clientKey:@"uHnEmW0sl39WTmEQyeC7ZYRQB0cd3QT452Jl7Buw"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Facebook
    [PFFacebookUtils initializeFacebook];
    
    // Twitter
    [PFTwitterUtils initializeWithConsumerKey:@"TR2ciit4QSlUQuPIKOXjvJ3Np"
                               consumerSecret:@"TBMcSaMYTooUtnd5mYGBRrWZujctCpmCB6tBSsCQF8PsNFoitC"];
    
    // Logging Control - Do NOT use logging for non-development builds.
#ifdef DEBUG
    [AmazonLogger verboseLogging];
#else
    [AmazonLogger turnLoggingOff];
#endif
    
    [AmazonErrorHandler shouldNotThrowExceptions];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [Appirater setAppId:@"870190894"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"background");
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    utils.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        
        NSLog(@"System end");
        
        [application endBackgroundTask:utils.bgTask];
        utils.bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // Do the work associated with the task, preferably in chunks.
//        
//        NSLog(@"Thread end");
//        
//        [application endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    NSArray *imagesFiles = [fileManager contentsOfDirectoryAtPath:saveDirectory error:error];
//    for (NSString *file in imagesFiles) {
//        error = nil;
//        [fileManager removeItemAtPath:[saveDirectory stringByAppendingPathComponent:file] error:error];
//        /* do error handling here */
//    }
    
    
    
    // Path to the Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Print out the path to verify we are in the right place
        NSString *directory = [paths objectAtIndex:0];
        NSLog(@"Directory: %@", directory);
        
        // For each file in the directory, create full path and delete the file
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error])
        {
            NSString *filePath = [directory stringByAppendingPathComponent:file];
            NSLog(@"File : %@", filePath);
            
            BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
            
            if (fileDeleted != YES || error != nil)
            {
                // Deal with the error...
            }
        }
        
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    BOOL bRet = NO;
    
    if ([viewController isKindOfClass:[HomeViewController class]] ||
        [viewController isKindOfClass:[FavouriteViewController class]] ||
        [viewController isKindOfClass:[NotifyViewController class]] ||
        [viewController isKindOfClass:[ProfileViewController class]]) {
        bRet = YES;
    }
    
    return bRet;
}


@end
