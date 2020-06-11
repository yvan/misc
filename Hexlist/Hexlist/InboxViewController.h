//
//  InboxViewController.h
//  Hexlist
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HexManager.h"
#import "AlertManager.h"
#import "MBProgressHUD.h"
#import "sendViewController.h"
#import "HexCell.h"

@interface InboxViewController : UIViewController <UITableViewDelegate
                                                   ,UITableViewDataSource
                                                   ,UIGestureRecognizerDelegate
                                                   ,CreateViewControllerDelegate
                                                   ,HexCellDelegate>

@property (nonatomic, strong) RLMResults *hexes;
@property (nonatomic, strong) RLMNotificationToken *rlmNotificationToken;
@property (nonatomic, strong) NSMutableArray *staticHexes;
@property (strong, nonatomic) NSMutableSet<Hex*> *selectedHexes;
@property (nonatomic, assign) BOOL currentlyPerformingFineGrainedUpdate;

@property (nonatomic, assign) NSInteger numLinksForMaxHexCellSize;

@property (weak, nonatomic) IBOutlet UIScrollView *emptyMessageScrollView;
@property (weak, nonatomic) IBOutlet UITableView *inboxTableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;

//Send View Segue
@property (nonatomic, assign) SendType sendViewSendType;
@property Hex *hexToSend;

//Create View Segue
@property (nonatomic, assign) CreateViewAction createViewAction;
@property (strong, nonatomic) Link *linkToView;

@end
