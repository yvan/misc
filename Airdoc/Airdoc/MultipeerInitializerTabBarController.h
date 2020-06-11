//
//  MultipeerInitializerTabBarController.h
//  Airdoc
//
//  Created by Roman Scher on 1/21/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressNavigationViewController.h"
#import "AppConstants.h"
#import "SessionWrapper.h"
#import "AdvertiserWrapper.h"
#import "BrowserWrapper.h"
#import "LocalStorageManager.h"
#import "InboxManager.h"
#import "ConnectedPeopleManager.h"
#import "ConnectViewController.h"
#import "HomeViewController.h"
#import "InboxViewController.h"
#import "SSZipArchive.h"
#import "MBProgressHUD.h"
#import "FileSystemInterface.h"
#import <AudioToolbox/AudioServices.h>
#import "LinkJM.h"
#import "LinkPackageJM.h"

@interface MultipeerInitializerTabBarController : UITabBarController <SettingsViewControllerDelegate
                                                                      ,SessionWrapperDelegate
                                                                      ,AdvertiserWrapperDelegate
                                                                      ,BrowserWrapperDelegate
                                                                      ,SendViewControllerDelegate>

@property (nonatomic, readonly) SessionWrapper *sessionWrapper;
@property (nonatomic, readonly) AdvertiserWrapper *advertiserWrapper;
@property (nonatomic, readonly) BrowserWrapper *browserWrapper;

@property (nonatomic, strong) LocalStorageManager *localStorageManager;
@property (nonatomic, strong) InboxManager *inboxManager;
@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;

@property (nonatomic) FileSystemInterface* fsInterface;

@end
