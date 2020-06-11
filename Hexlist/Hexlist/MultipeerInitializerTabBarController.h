//
//  MultipeerInitializerTabBarController.h
//  Hexlist
//
//  Created by Roman Scher on 1/21/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "SessionWrapper.h"
#import "AdvertiserWrapper.h"
#import "BrowserWrapper.h"
#import "SettingsManager.h"
#import "HexManager.h"
#import "ConnectedPeopleManager.h"
#import "ConnectViewController.h"
#import "HomeViewController.h"
#import "MyHexlistViewController.h"
#import "InboxViewController.h"
#import "MBProgressHUD.h"
#import "FileSystemInterface.h"
#import <AudioToolbox/AudioServices.h>
#import "LinkJM.h"
#import "HexJM.h"
#import "DataSendWrapper.h"

@interface MultipeerInitializerTabBarController : UITabBarController <SettingsViewControllerDelegate
                                                                      ,SessionWrapperDelegate
                                                                      ,AdvertiserWrapperDelegate
                                                                      ,BrowserWrapperDelegate
                                                                      ,SendViewControllerDelegate>

@property (nonatomic, strong) SessionWrapper *sessionWrapper;
@property (nonatomic, strong) AdvertiserWrapper *advertiserWrapper;
@property (nonatomic, strong) BrowserWrapper *browserWrapper;

@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;

@property (nonatomic) FileSystemInterface* fsInterface;

@end
