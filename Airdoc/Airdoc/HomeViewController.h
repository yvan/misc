//
// HomeViewController.h
// Airdoc
//
//
//  Created by Roman Scher on 01/04/2015.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "AppConstants.h"
#import "DBServiceManager.h"
#import "GDServiceManager.h"
#import "LocalStorageManager.h"
#import "InboxManager.h" /*TEST*/
#import "AdvertiserWrapper.h"
#import "HomeCollectionViewCell.h"
#import "SettingsViewController.h"
#import "SelectedFilesViewController.h"
#import "sendViewController.h"
#import "NameFileViewController.h"
#import "FileSystemAbstraction.h"
#import "FileSystemInit.h"
#import "FileSystemFunctions.h"
#import "FileSystemInterface.h"
#import "SSZipArchive.h" /*TEST*/
#import "FileLoadingObject.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "leftToRightSegue.h"
#import "MBProgressHUD.h"
#import "KxMenu.h"
#import "HighlightButton.h"
#import "CircleButton.h"
#import "InternetManager.h"

@interface HomeViewController : UIViewController <UICollectionViewDataSource
                                                  ,UICollectionViewDelegate
                                                  ,UICollectionViewDelegateFlowLayout
                                                  ,UIGestureRecognizerDelegate
                                                  ,UIDocumentInteractionControllerDelegate
                                                  /*,CBCentralManagerDelegate*/
                                                  ,SelectedFilesViewControllerDelegate
                                                  ,ReloadCollectionViewProgressDelegate
                                                  ,ELCImagePickerControllerDelegate
                                                  ,DBServiceManagerDelegate
                                                  ,GDServiceManagerDelegate>

@property (nonatomic) UILongPressGestureRecognizer *gesture;

@property (nonatomic, strong) dispatch_queue_t fileLoadingObjectsQueue;
@property (nonatomic, strong) dispatch_queue_t splitFoldersQueue;


@property (nonatomic) DBServiceManager* dbServiceManager;
@property (nonatomic) GDServiceManager* gdServiceManager;

@property (nonatomic, strong) InboxManager *inboxManager; /*TEST*/
@property (nonatomic, strong) LocalStorageManager *localStorageManager;

@property (nonatomic, strong) FileSystemInterface* fsInterface;
@property (nonatomic, strong) FileSystemAbstraction* fsAbstraction;
@property (nonatomic, strong) FileSystemFunctions* fsFunctions;
@property (nonatomic, strong) FileSystemInit* fsInit;

//@property (nonatomic) CBCentralManager* bluetoothManager;

@property (nonatomic) BOOL currentlyLoadingCollectionViewAndHidden;

@property (nonatomic) NSMutableArray* arrayForFoldersToDisplay;
@property (nonatomic) NSMutableArray* arrayForNonFoldersToDisplay;

@property IBOutlet UICollectionView* homeFileCollectionView;
@property (nonatomic, strong) HighlightButton* collectionViewBackButton;
@property (nonatomic, strong) UIBarButtonItem *collectionViewBackBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* selectedFilesBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* unselectBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* separatorBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *emptyMessageScrollView;
@property (weak, nonatomic) IBOutlet UILabel *emptyCollectionMessage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *collectionViewActivityIndicator;
@property (strong, nonatomic) UIGestureRecognizer *leftSwipeGestureRecognizer;
@property (strong, nonatomic) UIGestureRecognizer *rightSwipeGestureRecognizer;
@property (strong, nonatomic) NSTimer *loadingTimer;


@property (weak, nonatomic) IBOutlet UIToolbar *fileOptionsToolbar;
@property BOOL fileOptionsToolbarIsActive;

@property (weak, nonatomic) IBOutlet CircleButton *addButton;
@property BOOL addButtonIsCurrentlySendButton;
@property (nonatomic, assign) BOOL transitioningToSendLinkButton;

@property (strong, nonatomic) NSString *nameFileViewControllerActionIdentifier;

//Send View Segue
@property (strong, nonatomic) NSString *sendViewSendType;

@end
