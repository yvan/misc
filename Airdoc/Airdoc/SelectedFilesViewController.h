//
//  SelectedFilesViewController.h
//  Airdoc
//
//  Created by Roman Scher on 3/17/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "DBServiceManager.h"
#import "GDServiceManager.h"
#import "LocalStorageManager.h"
#import "ConnectedPeopleManager.h"
//kind of a weird name, but it's just because that's what we called it, might go back and change in future
#import "HomeCollectionViewCell.h"
#import "FileLoadingObject.h"
#import "FileSystemAbstraction.h"
#import "FileSystemInterface.h"
#import "FileSystemFunctions.h"
#import "sendViewController.h"
#import "reloadSelectedFilesViewAfterCloudNavigationDelegate.h"
#import "CircleButton.h"

@protocol SelectedFilesViewControllerDelegate <NSObject>

-(void)selectedFileViewPoppedOff;

@end

@interface SelectedFilesViewController : UIViewController <UICollectionViewDataSource
                                                           ,UICollectionViewDelegate
                                                           ,UIGestureRecognizerDelegate
                                                           ,CloudNavigationPopulateDelegate>

@property (weak, nonatomic) id <SelectedFilesViewControllerDelegate> selectedFilesViewControllerDelegate;

@property (nonatomic, strong) dispatch_queue_t splitFoldersQueue;

//I just made a clone of the service managers
//maybe it would be better to have one instance of
//each service manager (yeah let's just abuse the singleton lol)
//anyways here goes.
@property (nonatomic) DBServiceManager* dbServiceManager;
@property (nonatomic) GDServiceManager* gdServiceManager;

//selected files to display is a way to display the selected files without
//getting rid of the originally selected array.
@property (nonatomic) NSMutableArray* filesToDisplay;
@property (nonatomic) NSMutableArray* arrayForFoldersToDisplay;
@property (nonatomic) NSMutableArray* arrayForNonFoldersToDisplay;
@property (nonatomic) NSMutableArray* selectedFilesToDisplay;
@property (nonatomic) NSMutableArray* selectedFilesArrayCopy;
@property (nonatomic) NSMutableArray* fileLoadingFilesCopy;
@property (nonatomic) NSString* fileStackCopy;
@property (nonatomic) NSMutableArray* directoryPathStackCopy;

@property (nonatomic, strong) LocalStorageManager *localStorageManager;
@property (nonatomic, strong) FileSystemAbstraction* fsAbstraction;
@property (nonatomic, strong) FileSystemInterface* fsInterface;
@property (nonatomic, strong) FileSystemFunctions* fsFunctions;

@property (nonatomic, strong) UIButton* collectionViewBackButton;
@property (nonatomic, strong) UIBarButtonItem *collectionViewBackBarButtonItem;
@property (weak, nonatomic) IBOutlet UICollectionView *selectedFilesCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *emptyMessageScrollView;
@property (nonatomic, strong) UIBarButtonItem* unselectBarButtonItem;
@property (weak, nonatomic) IBOutlet CircleButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *collectionViewActivityIndicator;

//Send View Segue
@property (strong, nonatomic) NSString *sendViewSendType;

@end