//
//  ConnectViewController.h
//  Hexlist
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "SessionWrapper.h"
#import "AdvertiserWrapper.h"
#import "BrowserWrapper.h"
#import "SettingsManager.h"
#import "ConnectedPeopleManager.h"
#import "StrangerCell.h"
#import "ConnectToolbarCell.h"
#import "MBProgressHUD.h"
#import "HighlightButton.h"

@interface ConnectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;

@property (nonatomic, strong) NSMutableArray *staticConnectedStrangers;

@property (weak, nonatomic) IBOutlet UIView *emptyTableViewCellView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableViewCellLabel;
@property (weak, nonatomic) IBOutlet UISwitch *emptyTableViewCellSwitch;

@property (weak, nonatomic) IBOutlet HighlightButton *reloadButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage2;
@property IBOutlet UITableView *peopleTableView;

//@property (weak, nonatomic) IBOutlet UIView *keepDeviceAwakeView;
//@property (weak, nonatomic) IBOutlet UISwitch *keepDeviceAwakeSwitch;
@property BOOL currentlyReloading;
@property (strong, nonatomic) NSTimer *rotationTimer;
@property (strong, nonatomic) NSTimer *searchingTimer;
@property int rotationCount;

@end
