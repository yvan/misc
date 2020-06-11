//
//  SettingsViewController.h
//  Airdoc
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "AppDelegate.h"
#import "IntroViewController.h"
#import "LocalStorageManager.h"
#import "ConnectedPeopleManager.h"
#import "SettingsCell.h"
#import "SettingsSwitchCell.h"
#import "SettingsCellSpecial.h"
#import "HighlightButton.h"

@protocol SettingsViewControllerDelegate <NSObject>

@required

-(void)backToIntroScreenTapped;

@end

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <SettingsViewControllerDelegate> settingsViewControllerDelegate;

@property (nonatomic, strong) LocalStorageManager *localStorageManager;
@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end
