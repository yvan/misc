//
//  AppDelegate.m
//  Airdoc
//
//  Created by Yvan Scher on 1/2/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import <AVFoundation/AVAudioSession.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //make it so that our app sound doesn't interrupt music. 
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    _localStorageManager = [[LocalStorageManager alloc] init];
    _inboxManager = [[InboxManager alloc] init];
    
    //Create the friends.json, and inbox.json files on first run of the app
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [_localStorageManager createFriendsJsonFile];
        [_inboxManager createInboxJsonFile];
        [LocalStorageManager setSettingsDefaults];
        [InboxManager reduceNumberOfUncheckedFilePackagesToZero];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //Stops phone from going to sleep if user has enabled 'Keep device awake'
    if ([LocalStorageManager getKeepDeviceAwakeSetting]) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    
    [_localStorageManager printJsonStructureOfJsonFileWithFileIdentifier:[AppConstants friendsJSONFileIdentifier]];
    [_localStorageManager printJsonStructureOfJsonFileWithFileIdentifier:[AppConstants inboxJSONFileIdentifier]];

    // - register out app so we can share data on user's behalf - //
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"xqo6ittfta6l7ur"
                            appSecret:@"1rzrggczdt75de5"
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    // Navigation Bar & Tab Bar styling
    [[UINavigationBar appearance] setTranslucent: NO];
    [[UINavigationBar appearance] setBarTintColor: [AppConstants appSchemeColor]];
    [[UINavigationBar appearance] setTintColor:[AppConstants appSchemeColorB]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                            NSForegroundColorAttributeName: [AppConstants appSchemeColorB],
                                            NSFontAttributeName: [UIFont fontWithName:[AppConstants appFontNameB] size:20]
                                            }];
    
    //Segmented Control styling
    [[UISegmentedControl appearance] setTitleTextAttributes: @{
                                                    NSFontAttributeName: [UIFont fontWithName:[AppConstants appFontNameB] size:16]
                                                    } forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    //Set font & color of tab bar icons and text
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setTintColor:[AppConstants appSchemeColorB]];
    [[UITabBar appearance] setBarTintColor:[AppConstants appSchemeColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                            NSFontAttributeName : [UIFont fontWithName:[AppConstants appFontNameB] size:10.0f],
                                            NSForegroundColorAttributeName: [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5]
                                            } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSFontAttributeName : [UIFont fontWithName:[AppConstants appFontNameB] size:10.0f],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]
                                                        } forState:UIControlStateSelected];
    
    [[UITextField appearance] setTintColor:[AppConstants appSchemeColor]];
    
    //Removes lag from first appearance of keyboard when app is launched
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];

    // If user has entered their name before go straight to content
    if ([LocalStorageManager getUserFirstName] != nil) {
            self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *tabBarController = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"multipeerInitializerTabBarController"];
        
            [self.window setRootViewController:tabBarController];
            [self.window makeKeyAndVisible];
    }
    
    //code that runs analytics and fabric
    [Fabric with:@[[Crashlytics class]]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
            // Send notification to load an initial root dropbox path
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getDropboxRootForAuth" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"authDropboxForDirectMoveToDB" object:self];
        }else{// Add whatever other url handling code your app requires here in this else
            //if the user clicks cancel we post a notification
            //back to the DBServiceManager 
            NSArray* components =  [[url path] pathComponents];
            NSString *methodName = [components count] > 1 ? [components objectAtIndex:1] : nil;
            if ([methodName isEqual:@"cancel"]) {
                NSLog(@"Dropbox link Cancelled");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxRegistrationCancelled" object:self];
            }
        }
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
