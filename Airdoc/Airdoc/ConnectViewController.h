//
//  ConnectViewController.h
//  Airdoc
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "SessionWrapper.h"
#import "AdvertiserWrapper.h"
#import "BrowserWrapper.h"
#import "LocalStorageManager.h"
#import "ConnectedPeopleManager.h"
#import "FriendCell.h"
#import "StrangerCell.h"
#import "ConnectToolbarCell.h"
#import "BBBadgeBarButtonItem.h"
#import "MBProgressHUD.h"
#import "ProgressNavigationViewController.h"
#import "HighlightButton.h"

@interface ConnectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) LocalStorageManager *localStorageManager;
@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;

//@property (nonatomic, strong) NSMutableArray *tempConnectedFriends;
@property (nonatomic, strong) NSMutableArray *tempConnectedStrangers;
@property (atomic) NSInteger numConnectedFriends;
@property (atomic) NSInteger numConnectedStrangers;
@property (atomic) NSInteger numFriends;

@property (weak, nonatomic) IBOutlet UIView *emptyTableViewCellView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableViewCellLabel;
@property (weak, nonatomic) IBOutlet UISwitch *emptyTableViewCellSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet HighlightButton *reloadButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage2;
@property IBOutlet UITableView *peopleTableView;
@property (strong, nonatomic) UIBarButtonItem *savedLeftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView *keepDeviceAwakeView;
@property (weak, nonatomic) IBOutlet UISwitch *keepDeviceAwakeSwitch;
@property BOOL currentlyReloading;
@property (strong, nonatomic) NSTimer *rotationTimer;
@property (strong, nonatomic) NSTimer *searchingTimer;
@property int rotationCount;

@end
