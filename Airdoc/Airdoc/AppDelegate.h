//
//  AppDelegate.h
//  Airdoc
//
//  Created by Yvan Scher on 1/2/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"    
#import "LocalStorageManager.h"
#import "InboxManager.h"
#import "IntroViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) LocalStorageManager *localStorageManager;
@property (nonatomic, readonly) InboxManager *inboxManager;

@end

