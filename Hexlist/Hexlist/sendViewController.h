//
//  sendViewController.h
//  Hexlist
//
//  Created by Roman Scher on 7/17/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "FileSystemAbstraction.h"
#import "ConnectedPeopleManager.h"
#import "SendCell.h"
#import "MBProgressHUD.h"
#import "HighlightButton.h"
#import "RetrieveLinksFromServiceManagerDelegate.h"
#import "LinkJM.h"
#import "Hex.h"
#import "HexManager.h"
#import "CreateViewController.h"

@protocol SendViewControllerDelegate <NSObject>

@required

-(void)sendHexJMs:(NSArray<HexJM*>*)hexJMsToSend ToPeers:(NSMutableArray *)peersToSendTo;
-(void)sendHexes:(NSArray<Hex*>*)hexesToSend ToPeers:(NSMutableArray *)peersToSendTo;

@end

@interface sendViewController : UIViewController <UITableViewDelegate
                                                  ,UITableViewDataSource
                                                  ,UINavigationBarDelegate
                                                  ,RetrieveLinksFromServiceManagerDelegate
                                                  ,CreateViewControllerDelegate>

@property (weak, nonatomic) id <SendViewControllerDelegate> sendViewControllerDelegate;

@property (nonatomic, strong) FileSystemAbstraction* fsAbstraction;

@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;

@property (nonatomic, strong) NSMutableArray *staticConnectedStrangers;
@property (nonatomic) NSMutableArray* directoryPathStackCopy;

@property (nonatomic, strong) NSMutableArray *selectedLocalPeople;

@property (weak, nonatomic) IBOutlet UITableView *peopleTableView;
@property (strong, nonatomic) IBOutlet HighlightButton *cancelButton;
@property (strong, nonatomic) IBOutlet HighlightButton *reloadButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage2;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property BOOL sendButtonIsActive;

//Sending parameters
@property (nonatomic, assign) SendType sendType;
@property (strong, nonatomic) NSString *linkGenerationUUID;
@property (strong, nonatomic) UIView *contentCover;
@property (strong, nonatomic) MBProgressHUD *generatingLinksAlert;
@property (nonatomic, assign) BOOL retrieveLinksDelegateMethodAlreadyCalled;

//Cloud Hex Send
@property (nonatomic, assign) CreateViewAction createViewAction;
@property (strong, nonatomic) NSArray<LinkJM*> *linksToSendWithHex;
@property (strong, nonatomic) HexJM *hexJMToSend;

//Hex Send
@property Hex *hexToSend;

//Reload Button Animations
@property BOOL currentlyReloading;
@property (strong, nonatomic) NSTimer *rotationTimer;
@property (strong, nonatomic) NSTimer *searchingTimer;
@property int rotationCount;

@end
