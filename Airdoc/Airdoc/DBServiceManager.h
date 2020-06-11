//
//  APIServiceManager.h
//  Airdoc
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "File.h"
#import "DBQueryWrapper.h"
#import "DBOperationWrapper.h"
#import "DBQueryLimitWrapper.h"
#import "FileSystemInterface.h"
#import "FileSystemAbstraction.h"
#import "FileSystemFunctions.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ReloadCollectionViewProgressDelegate.h"
#import "reloadSelectedFilesViewAfterCloudNavigationDelegate.h"
#import "sendLinksFromServiceManagerDelegate.h"
#import "LinkJM.h"
#import "AppConstants.h"

@protocol DBServiceManagerDelegate <NSObject>

-(void) dbCreateFileLoadingObjectWithFile:(File*)file andReduceStack:(NSString*)reduceStackToPath;
-(void) uploadAfterCreatingUploadFolderDBWithOriginallySelectedFiles:(NSMutableArray*)originallySelectedFiles;
-(void) dbUnselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath;
-(void) alertUserToFileNotFound:(File*)file;

@end

@interface DBServiceManager : NSObject

@property (nonatomic) int globalActiveRequestCount;
@property (nonatomic) NSMutableArray* bgTaskArray;
@property (nonatomic) NSMutableArray* fileIdnetifiersForTaskArray;
@property (nonatomic) NSMutableArray* dbQueryWrapperHolder;
@property (nonatomic) NSMutableArray* dbOperationWrapperHolder;
@property (nonatomic) NSMutableArray* dbQueryOccurrenceLimitHolder;
@property (nonatomic) NSMutableDictionary* dictionaryWithShareableLinks;
@property (nonatomic) BOOL canLoadAndNavigateAfterAuth;

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;
@property (nonatomic) FileSystemFunctions* fsFunctions;

@property (nonatomic, weak) id <SendLinksFromServiceManagerDelegate> sendLinksFromServiceManagerDelegate;
@property (nonatomic, weak) id <ReloadCollectionViewProgressDelegate> reloadCollectionViewProgressDelegate;
@property (nonatomic, weak) id <CloudNavigationPopulateDelegate> selectedFilesViewCloudNavDelegate;
@property (nonatomic, weak) id <DBServiceManagerDelegate> dbServiceManagerDelegate;

-(void) cancelNavigationLoad;
-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify;
-(void) destroyDBOperationsWithFilePaths:(NSArray*)arrayOfPathsToCheck;
-(BOOL) cancelFileLoadWithFile:(File*)fileToStopDownloadingFrom;
-(BOOL) cancelFileUploadWithFile:(File*)fileToStopUploadingFrom;
-(void) checkForAndCreateEnvoyUploadsFolderThenUpload:(UIViewController*)passedController;
-(void) produceShareableLinkForFile:(NSString*)filePathToLinkify;

-(void) pressedDropboxFolder:(UIViewController*)passedController withFile:(File*)passedFile shouldReloadMainView:(BOOL)shouldReloadSelectedFilesView;

-(void) deleteFileFromDropbox:(File*)file onDropboxPath:(NSString*)dirToDelete;
-(void) moveFileOnDropBox:(File*)file fromPath:(NSString*)fromPath toPath:(NSString*)toPath;
-(void) prepareForExportToOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToDB:(BOOL)moveToDBPressed andMovedFromDB:(BOOL)moveFromDBPressed;
-(void) prepareToSaveFilesExportedFromOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToDB:(BOOL)moveToDBPressed andMovedFromDB:(BOOL)moveFromDBPressed;

@end
