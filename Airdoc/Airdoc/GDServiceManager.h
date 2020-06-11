//
//  GDServiceManager.h
//  Airdoc
//
//  Created by Yvan Scher on 1/18/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//
#import "LocalStorageManager.h"
#import "File.h"
#import "GDQueryWrapper.h"
#import "GDOperationWrapper.h"
#import "GDQueryLimitWrapper.h"
#import "FileSystemInterface.h"
#import "FileSystemAbstraction.h"
#import "FileSystemFunctions.h"
#import <Foundation/Foundation.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "ReloadCollectionViewProgressDelegate.h"
#import "reloadSelectedFilesViewAfterCloudNavigationDelegate.h"
#import "sendLinksFromServiceManagerDelegate.h"
#import "LinkJM.h"

@protocol GDServiceManagerDelegate <NSObject>

-(void) gdCreateFileLoadingObjectWithFile:(File*)file andReduceStack:(NSString*)reduceStackToPath;
-(void) uploadAfterCreatingUploadFolderGDWithOriginallySelectedFiles:(NSMutableArray*)originallySelectedFiles;
-(void) gdUnselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface GDServiceManager : NSObject <UINavigationControllerDelegate>

@property (nonatomic) GTMOAuth2Authentication *auth;
@property (nonatomic, retain) GTLServiceDrive *driveService;
@property (nonatomic, strong) GTLServiceTicket *serviceTicketForNavigationLoad;
@property (nonatomic) UIViewController* passedInController; //still need the global for cancelling the auth sequence
@property (nonatomic) NSMutableArray* gdQueryWrapperHolder;
@property (nonatomic) NSMutableArray* gdOperationWrapperHolder;
@property (nonatomic) NSMutableArray* gdQueryOccurrenceLimitHolder;
@property (nonatomic) NSMutableDictionary* dictionaryWithShareableLinks;
@property (nonatomic) int globalActiveRequestCount;
@property (nonatomic) BOOL canLoadAndNavigateAfterAuth;

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;
@property (nonatomic) FileSystemFunctions* fsFunctions;

@property (nonatomic, weak) id <SendLinksFromServiceManagerDelegate> sendLinksFromServiceManagerDelegate;
@property (nonatomic, weak) id <ReloadCollectionViewProgressDelegate> reloadCollectionViewProgressDelegate;
@property (nonatomic, weak) id <CloudNavigationPopulateDelegate> selectedFilesViewCloudNavDelegate;
@property (nonatomic, weak) id <GDServiceManagerDelegate> gdServiceManagerDelegate;

@property (nonatomic, strong) dispatch_queue_t gdQueryWrapperQueue;

// - no explicit move file, just combined upload and delete - //

-(void) deleteFileFromGoogleDrive:(File*)file;

-(BOOL) isAuthorized;
-(void) cancelNavigationLoad;
-(void) destroyGDOperationsWithFilePaths:(NSArray*)arrayOfPathsToCheck;
-(NSString*) getShareableLinksWithFiles:(NSArray*)filesToLinkify;
-(BOOL)cancelFileLoadWithFile:(File*)fileToStopDownloadingFrom;
-(BOOL)cancelFileUploadWithFile:(File*)fileToStopUploadingFrom;
-(void) checkForAndCreateEnvoyUploadsFolderThenUpload:(UIViewController*)passedController;
-(void) pressedGoogleDriveFolder:(UIViewController*)passedController withFile:(File*)file shouldReloadMainView:(BOOL)shouldReloadSelectedFilesView andMoveToGD:(BOOL)moveToGDPressed;
-(void) prepareForExportToOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToGD:(BOOL)moveToGDPressed andMovedFromGD:(BOOL)moveFromGDPressed;
-(void) prepareToSaveFilesExportedFromOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToGD:(BOOL)moveToGDPressed andMovedFromGD:(BOOL)moveFromGDPressed;

@end
