//
//  InboxViewController.h
//  Airdoc
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "LocalStorageManager.h"
#import "FileSystemInterface.h"
#import "FileSystemFunctions.h"
#import "FileSystemAbstraction.h"
#import "InboxManager.h"
#import "ConnectedPeopleManager.h"
#import "InboxCell.h"
#import "IncomingSendProgressCell.h"
#import "LinkPackageCell.h"
#import "LinkButton.h"
#import "DBServiceManager.h"
#import "GDServiceManager.h"
#import "HomeViewController.h"
#import "ProgressNavigationViewController.h"
#import "LinkPackage.h"
#import "Link.h"
#import "LinkView.h"
#import "MESegmentedControl.h"

@interface InboxViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) InboxManager *inboxManager;
@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;
@property (nonatomic, strong) LocalStorageManager *localStorageManager;

@property (nonatomic) DBServiceManager* dbServiceManager;
@property (nonatomic) GDServiceManager* gdServiceManager;

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemFunctions* fsFunctions;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;

//Files View
@property (nonatomic, strong) NSMutableArray *tempFilePackagesArray;
@property (nonatomic, strong) NSArray *tempIncomingSendProgressesArray;
//Links View
@property (nonatomic, strong) RLMResults *linkPackages;
@property (nonatomic, strong) RLMNotificationToken *rlmNotificationToken;
@property (nonatomic, strong) NSMutableArray *tempLinkPackagesArray;
@property (nonatomic, strong) NSMutableIndexSet *selectedLinkPackageIndexes;

@property (weak, nonatomic) IBOutlet UIScrollView *emptyMessageScrollView;
@property (weak, nonatomic) IBOutlet UITableView *inboxTableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;
@property (weak, nonatomic) IBOutlet MESegmentedControl *inboxSegmentedControl;

//@property (nonatomic, strong) NSNumber *filesTableOffset;
//@property (nonatomic, strong) NSNumber *linksTableOffset;
@property (nonatomic) float filesTableOffset;
@property (nonatomic) float linksTableOffset;

@end
