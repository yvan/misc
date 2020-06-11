//
//  sendViewController.h
//  Envoy
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
#import "sendLinksFromServiceManagerDelegate.h"
#import "LinkJM.h"

@protocol SendViewControllerDelegate <NSObject>

@required

-(void)sendFiles:(NSMutableArray*)filesToBeSent ToPeers: (NSMutableArray*)peersToSendTo;
-(void)sendLinks:(NSMutableArray*)linksToBeSent ToPeers: (NSMutableArray*)peersToSendTo;

@end

@interface sendViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, SendLinksFromServiceManagerDelegate>

@property (weak, nonatomic) id <SendViewControllerDelegate> sendViewControllerDelegate;

@property (nonatomic, strong) FileSystemAbstraction* fsAbstraction;

@property (nonatomic, strong) ConnectedPeopleManager *connectedPeopleManager;

//@property (nonatomic, strong) NSMutableArray *tempConnectedFriends;
@property (nonatomic, strong) NSMutableArray *tempConnectedStrangers;
@property (nonatomic) NSMutableArray* directoryPathStackCopy;
@property (atomic) NSInteger numConnectedFriends;
@property (atomic) NSInteger numConnectedStrangers;
@property (atomic) NSInteger numAcquaitances;

@property (nonatomic, strong) NSMutableArray *selectedLocalPeople;

@property (weak, nonatomic) IBOutlet UITableView *peopleTableView;
@property (strong, nonatomic) IBOutlet HighlightButton *cancelButton;
@property (strong, nonatomic) IBOutlet HighlightButton *reloadButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage2;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property BOOL sendButtonIsActive;

//Send Type
@property (strong, nonatomic) NSString *sendType;
@property (strong, nonatomic) MBProgressHUD *generatingLinksAlert;
@property (strong, nonatomic) UIView *contentCover;

//Link Send
@property (strong, nonatomic) NSMutableArray *linksToSend;
@property (nonatomic, assign) BOOL failedToReceiveLinksCalled;

//Reload Button Animations
@property BOOL currentlyReloading;
@property (strong, nonatomic) NSTimer *rotationTimer;
@property (strong, nonatomic) NSTimer *searchingTimer;
@property int rotationCount;

@end
