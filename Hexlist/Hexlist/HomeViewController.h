//
// HomeViewController.h
// Hexlist
//
//
//  Created by Roman Scher on 01/04/2015.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "AppConstants.h"
#import "SettingsManager.h"
#import "AdvertiserWrapper.h"
#import "HomeCollectionViewCell.h"
#import "SettingsViewController.h"
#import "sendViewController.h"
#import "CreateViewController.h"
#import "FileSystemAbstraction.h"
#import "FileSystemInit.h"
#import "FileSystemInterface.h"
#import "FadeSegue.h"
#import "MBProgressHUD.h"
#import "KxMenu.h"
#import "HighlightButton.h"
#import "CircleButton.h"
#import "InternetManager.h"
#import "AlertManager.h"
#import "UnselectedFilesAlertView.h"
#import "GeneratingLinksAlertView.h"
#import "SharedServiceManager.h"
#import "MyHexlistViewController.h"

@interface HomeViewController : UIViewController <UICollectionViewDataSource
                                                  ,UICollectionViewDelegate
                                                  ,UICollectionViewDelegateFlowLayout
                                                  ,UIGestureRecognizerDelegate
                                                  ,UIDocumentInteractionControllerDelegate
                                                  /*,CBCentralManagerDelegate*/
                                                  ,RetrieveLinksFromServiceManagerDelegate
                                                  ,DBServiceManagerDelegate
                                                  ,GDServiceManagerDelegate
                                                  ,BXServiceManagerDelegate
                                                  ,MyHexlistViewControllerDelegate
                                                  ,CreateViewControllerDelegate>

@property (nonatomic) UILongPressGestureRecognizer *gesture;

@property (nonatomic, strong) dispatch_queue_t fileLoadingObjectsQueue;
@property (nonatomic, strong) dispatch_queue_t splitFoldersQueue;

@property (nonatomic) SharedServiceManager* sharedManager;

@property (nonatomic, strong) FileSystemInterface* fsInterface;
@property (nonatomic, strong) FileSystemAbstraction* fsAbstraction;
@property (nonatomic, strong) FileSystemInit* fsInit;

//@property (nonatomic) CBCentralManager* bluetoothManager;

@property (nonatomic) BOOL currentlyLoadingCollectionViewAndHidden;

@property IBOutlet UICollectionView* homeFileCollectionView;
@property (nonatomic, strong) HighlightButton* collectionViewBackButton;
@property (nonatomic, strong) UIBarButtonItem *collectionViewBackBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* selectedFilesBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* unselectBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* separatorBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *emptyMessageScrollView;
@property (weak, nonatomic) IBOutlet UILabel *emptyCollectionMessage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *collectionViewActivityIndicator;
@property (strong, nonatomic) UIGestureRecognizer *rightSwipeGestureRecognizer;
@property (strong, nonatomic) NSTimer *loadingTimer;

@property (weak, nonatomic) IBOutlet UIToolbar *fileOptionsToolbar;
@property BOOL fileOptionsToolbarIsActive;

@property (weak, nonatomic) IBOutlet CircleButton *sendButton;
@property (nonatomic, assign) BOOL switchingServices;

//link generation
@property (nonatomic, assign) LinkAction linkAction;
@property (strong, nonatomic) NSString *linkGenerationUUID;
@property (nonatomic, assign) BOOL currentlyGeneratingLinks;
@property (nonatomic, assign) BOOL canceledLinksGeneration;
@property (nonatomic, assign) BOOL retrieveLinksDelegateMethodAlreadyCalled;
@property (strong, nonatomic) MBProgressHUD *generatingLinksAlert;

//Send View Segue
@property (nonatomic, assign) SendType sendViewSendType;

//Hex Creation Segue
@property (nonatomic, assign) CreateViewAction createViewAction;
@property (strong, nonatomic) NSArray<Link*>* generatedLinks;

//Add to Hex Segue
@property (nonatomic, assign) MyHexlistAction myHexlistAction;
@property (strong, nonatomic) NSArray<Link*> *linksToAddToHex;

@end
