//
//  SettingsViewController.h
//  Hexlist
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AppConstants.h"
#import "AppDelegate.h"
#import "IntroViewController.h"
#import "SettingsManager.h"
#import "ConnectedPeopleManager.h"
#import "SettingsCell.h"
#import "SettingsSwitchCell.h"
#import "SettingsCellSpecial.h"
#import "SettingsServiceCell.h"
#import "MyHexColorCell.h"
#import "HighlightButton.h"
#import "SharedServiceManager.h"
#import "IntroViewController.h"
#import "LegalContentViewController.h"
#import "MBProgressHUD.h"



@protocol SettingsViewControllerDelegate <NSObject>

@required

-(void)backToIntroScreenTapped;

@end

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource ,MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) id <SettingsViewControllerDelegate> settingsViewControllerDelegate;

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (nonatomic) SharedServiceManager* sharedManager;
@property (nonatomic) NSMutableArray* tempServicesArray;
@property (strong, nonatomic) NSMutableDictionary *servicesToUnlink;

@property (nonatomic, assign) SettingsContentType settingsContentType;
@property (nonatomic, assign) LegalType legalType;

@end
