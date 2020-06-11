//
//  APIServiceManager.m
//  Airdoc
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//  This class manages our apps relationship to various APIs
//  Dropbox, Google Drive, Box are the three we're starting with
//  For example when you move from Google Drive to Box, this manager
//  will recognize that and make calls to those APIs to add a file to Box
//  and delete it from Google Drive


/*  - throughout the code  UIBackgroundTaskIdentifier is a way for us to turn the thing
    - that directly precedes it (in the code) into a background task, it allows background
    - downloading and uploading to dropbox. It's totally awesome. 
    - we end these background tasks in teh various delegate methods by looping through
    - the queries we turned into tasks and selecting the index indicated by the path
    - returned by the delegate method. That index is the bgTask we need to stop in that 
    - delegate.
 */

#import "DBServiceManager.h"
#import <DropboxSDK/DropboxSDK.h>

// we try a query 3 times, after that
// we kill it.

static int const GLOBALQUERYATTEMPTLIMIT = 3;

// type of query that we will
// use to check against the
// typeOfQuery field in the
// DBQueryWrapper class

static int const DBLOADMETADATANORMAL = 1;
static int const DBLOADMETADATASELECTED = 2;
static int const DBLOADMETADATAENVOYUPLOADS = 3;
static int const DBLOADFILE = 4;
static int const DBUPLOADFILE = 5;
static int const DBDELETEFILE = 6;
static int const DBMOVEFROM = 7;

@interface DBServiceManager () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient* restClientForNavigation; //separate rest client for navigation that can be cancelled
@property (nonatomic, strong) DBRestClient* restClientForLoadingLink; //need the rest client on a global var or else the delegate reference to self deallocates

@end

@implementation DBServiceManager

-(id) init{
    
    self = [super init];
        
    // observer for loading the dropbox root folder after a user auths the
    // first time.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(getDropboxRootForAuth)
                                          name:@"getDropboxRootForAuth"
                                          object:nil];
    
    //notification that gets triggered from the app delegate on auth
    //when the user is authing from a press to move to DB
    //should pass nil for the viewcontroller input
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(checkForAndCreateEnvoyUploadsFolderThenUpload:)
                                         name:@"authDropboxForDirectMoveToDB"
                                         object:nil];
    
    // observer for cancelling dropbox registeration
    // and triggering a view contorller dismissal
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(dropboxRegistrationCancelled)
                                          name:@"dropboxRegistrationCancelled"
                                          object:nil];
    
    //notification triggered from the home view controller on a bck button press
    //as we're loading.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelNavigationLoadFromBackPress)
                                                 name:@"dropboxLoadCancelledByBackButtonPress"
                                               object:nil];
    
    //create a timer that purges dropbox clients that have no more requests to make every minute.
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkForAndPurgeInactiveClients) userInfo:nil repeats:YES];
    });
    
    return self;
}

-(FileSystemInterface*) fsInterface{
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}

-(FileSystemAbstraction*) fsAbstraction{
    if(!_fsAbstraction){
        _fsAbstraction = [FileSystemAbstraction sharedFileSystemAbstraction];
    }
    return _fsAbstraction;
}

-(FileSystemFunctions*) fsFunctions{
    if(!_fsFunctions){
        _fsFunctions = [FileSystemFunctions sharedFileSystemFunctions];
    }
    return _fsFunctions;
}

-(NSMutableArray*) dbQueryWrapperHolder {
    if(!_dbQueryWrapperHolder){
        _dbQueryWrapperHolder = [[NSMutableArray alloc] init];
    }
    return _dbQueryWrapperHolder;
}

-(NSMutableArray*) dbOperationWrapperHolder {
    if(!_dbOperationWrapperHolder){
        _dbOperationWrapperHolder = [[NSMutableArray alloc] init];
    }
    return _dbOperationWrapperHolder;
}

-(NSMutableArray*) dbQueryOccurrenceLimitHolder {
    if(!_dbQueryOccurrenceLimitHolder){
        _dbQueryOccurrenceLimitHolder = [[NSMutableArray alloc] init];
    }
    return _dbQueryOccurrenceLimitHolder;
}

-(NSMutableDictionary*) dictionaryWithShareableLinks {
    if(!_dictionaryWithShareableLinks){
        _dictionaryWithShareableLinks = [[NSMutableDictionary alloc] init];
    }
    return _dictionaryWithShareableLinks;
}

//if we don't have this lazy evlaution for the
//restclient it won't work.
//we need a separate one for our navigation reload
//restclient

-(DBRestClient *) restClientForNavigation {
    if (!_restClientForNavigation) {
        _restClientForNavigation = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClientForNavigation.delegate = self;
    }
    return _restClientForNavigation;
}

//need the rest client on a global var.
-(DBRestClient *) restClientForLoadingLink {
    if(!_restClientForLoadingLink){
        _restClientForLoadingLink = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClientForLoadingLink.delegate = self;
    }
    return _restClientForLoadingLink;
}

// produce rest client creates a rest client
// basically we need to use multiple rest clients
// to for each download operation by the user
// because each of those download operations
// needs to store a path where the paste/download
// operation was pressed.

- (DBRestClient *) produceRestClient{
    DBRestClient* restClientToReturn = [[DBRestClient alloc] initWithSession:[DBSession sharedSession] ];
    restClientToReturn.delegate = self;
    return restClientToReturn;
}

-(DBQueryWrapper*) wrapRestClient:(DBRestClient*)restClient withStoredReduceStackToPath:(NSString*)pathToWrap andTypeOfQuery:(int)typeOfQuery andPassedFile:(File*)passedFile andshouldReloadSelectedFilesView:(BOOL)shouldReload andMoveToDB:(BOOL)moveToDBPressed cameFromAuth:(BOOL)cameFromAuth andMovedFromDB:(BOOL)moveFromDBPressed andSelectedFiles:(NSMutableArray*)selectedFiles{
    
    DBQueryWrapper* queryWrapper = [[DBQueryWrapper alloc] initWithRestClient:restClient andStoredReduceStackToPath:pathToWrap andTypeOfQuery:typeOfQuery andPassedFile:passedFile andshouldReloadMainView:shouldReload andMoveToDB:moveToDBPressed cameFromAuth:cameFromAuth andMovedFromDB:moveFromDBPressed andSelectedFiles:selectedFiles];
    return queryWrapper;
}

#pragma mark - Dropbox Authentication

/*  - takes a cocntroller as an input and links the user's account
 - from that controller? This is the second step in DB tutorial
 - for the sync API
 - */

-(void) pressedDropboxFolder:(UIViewController*)passedController withFile:(File*)passedFile shouldReloadMainView:(BOOL)shouldReloadSelectedFilesView{
    _canLoadAndNavigateAfterAuth = YES;
    //if we're not linked we trigger the openURL in the app delegate
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:passedController];
    }else{
        // this call used to be in Homeview controller but needs to be here here, because otherwise, it gets triggered
        // before the auth is done. the rest client MUST be initialized after auth is done.
        // the first time the restclietn get's initilized is in this method, so it needs to be here,
        // where it can only be accessed after auth.
        
        [self getFileInfoFromDropboxPath:[[self fsInterface] resolveFilePath:passedFile.path excludingUpToDirectory:@"Dropbox"] withPressedFile:passedFile andshouldReloadSelectedFilesView:shouldReloadSelectedFilesView andMoveToDB:NO];
    }
}

// just for loading in the view the first time we get
// authenticated, triggered by a notification

-(void) getDropboxRootForAuth{
    if(_canLoadAndNavigateAfterAuth){
        File* dummyDropBoxFileToPass = [[File alloc] initWithName:@"Dropbox" andPath:@"/Dropbox" andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
        //wrap the navigation load in a wrapper with a flag saying this client is gonna LOAD views
        DBQueryWrapper* navigationWrapper = [self wrapRestClient:[self restClientForNavigation] withStoredReduceStackToPath:nil andTypeOfQuery:DBLOADMETADATANORMAL andPassedFile:dummyDropBoxFileToPass andshouldReloadSelectedFilesView:NO andMoveToDB:NO cameFromAuth:YES andMovedFromDB:NO andSelectedFiles:[[NSMutableArray alloc] init]];
        [navigationWrapper incrementCustomRequestCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self dbQueryWrapperHolder] addObject:navigationWrapper];
            [[navigationWrapper getRestClient] loadMetadata:@"/" atRev:nil];
        });
    }
}

// the user had cancelled their registration
// a notification gats posted from the app
// delegate triggers this method when the
// user cancels their dropbox registration
// process, this posts a notification to teh
// homeview controller.
-(void) dropboxRegistrationCancelled{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterDropboxCancel" object:self];
}

#pragma mark - prepare files for move methods

// - method takes files in dropbox and puts them into a special array on the filesystem that gets them ready
// - to be sent to another folder

// basically we assume that whereever the file is sending from (as long as it is a cloud platform) is up to date with it's
// remote copy in teh cloud.
// we still need an algorithm to handle local issues.
// local files are stored in the file system and so can be recursively queries using iOS built in methods
// non local files cannot be recursively queried in this way, simply because they don't exist on our machine
// they only exist in the cloud or in our filesystem.json
// we need to make them working for both the local system and the appropriate foreign one.

-(void) prepareForExportToOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToDB:(BOOL)moveToDBPressed andMovedFromDB:(BOOL)moveFromDBPressed{
    
    DBRestClient* newClient = [self produceRestClient];
    
    DBQueryWrapper* newClientWrapper = [self wrapRestClient:newClient withStoredReduceStackToPath:storedReduceStackToPath andTypeOfQuery:DBLOADFILE andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToDB:moveToDBPressed cameFromAuth:NO andMovedFromDB:moveFromDBPressed andSelectedFiles:selectedFilesForMove];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self dbQueryWrapperHolder] addObject:newClientWrapper];
    });
    // - this might be improved if the array was ordered
    // - with parents on the left and children on the right
    // - I think this is how its structured but we can't
    // - deal with this right now. If parents
    // - were always on the. Since a file can only have
    // - on parent, eventually we can also create a sorted
    // - and unsorted set, where things that already
    // - have parents and are not directories themselves
    // - are no longer checked.
    // otuer selects a file, the inner loop selected another file
    // the outer file is checked to see if it is the parent of the
    // inner file.
    for (int i = 0; i<[selectedFilesForMove count]; i++) {
        
        File* tempFile = ((File*)selectedFilesForMove[i]);
        
        if ([[self fsInterface] filePath:tempFile.path isLocatedInsideDirectoryName:@"Dropbox"]) {
            [newClientWrapper incrementCustomRequestCount];
            NSString* pathOnDropbox = [[self fsInterface] resolveFilePath:tempFile.path excludingUpToDirectory:@"Dropbox"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[newClientWrapper getRestClient] loadMetadata:pathOnDropbox atRev:nil];
            });
            
            UIBackgroundTaskIdentifier bgTask = 0;
            bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            }];
            
            [_bgTaskArray addObject:@(bgTask)];
            [_fileIdnetifiersForTaskArray addObject:pathOnDropbox];
        }
    }
}

// - method takes folders in the prepared array and gets them ready to be put into Dropbox.
// - fundamentally should be the SAME method in every class where we need to import files INTO.
// - each one will differ slightly in the way that it UPLOADS stuff to the cloud.
// -

-(void) prepareToSaveFilesExportedFromOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToDB:(BOOL)moveToDBPressed andMovedFromDB:(BOOL)moveFromDBPressed{
    
    NSString* storedReduceStackToPathTemp;
        
    if(calledFromInbox)
    {
        storedReduceStackToPathTemp = [@"/Dropbox" stringByAppendingPathComponent:@"Envoy Uploads"];
    }else{
        storedReduceStackToPathTemp = storedReduceStackToPath;
    }
    
    DBRestClient* newClient = [self produceRestClient];
    
    DBQueryWrapper* newClientWrapper = [self wrapRestClient:newClient withStoredReduceStackToPath:storedReduceStackToPathTemp andTypeOfQuery:DBUPLOADFILE andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToDB:moveToDBPressed cameFromAuth:NO andMovedFromDB:moveFromDBPressed andSelectedFiles:selectedFilesForMove];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self dbQueryWrapperHolder]addObject:newClientWrapper];
    });
    
    NSMutableIndexSet* filesToRemove = [[NSMutableIndexSet alloc] init];
    
    //add the first directory (the one originally called upon if it is not in the array
    //prepared to be exported. This make sure the original directory will appear
    // in the new folder, if we don't do this, it will not appear.
    
    // otuer selects a file, the inner loop selected another file
    // the outer file is checked to see if it is the parent of the
    // inner file.
    for (int i = 0; i<[selectedFilesForMove count]; i++) {
        
        File* tempFile = ((File*)selectedFilesForMove[i]);
        
        if ([[self fsInterface] filePath:storedReduceStackToPathTemp isLocatedInsideDirectoryName:@"Dropbox"] && ![[self fsInterface] filePath:tempFile.path isLocatedInsideDirectoryName:@"Dropbox"] && ![filesToRemove containsIndex:i]) {
            [self pullFilesToUploadFromOther:tempFile withQueryWrapper:newClientWrapper];
        }
    }
}

#pragma mark - Metadata Retrieval Methods

/*  - gets the files we want for the particular directory we just entered
    - doesn't download files, just downloads their meta data
    - */

-(void) getFileInfoFromDropboxPath:(NSString*)pathOnDropbox withPressedFile:(File*)passedFile andshouldReloadSelectedFilesView:(BOOL)shouldReload andMoveToDB:(BOOL)moveToDBPressed{
    
    //search for a navigation client wrapper if it alrady exists
    //if it exists take the old one and edit the passed in file
    //and other things to match the new request, and use that old
    //wrapper. The alternative to this was putting break; statements
    //in the loadedetadata loop through the _dbQueryWrapperHolder
    //array and that caused problems because we couldn't be
    //sure we were getting the right query wrapper(or we could but it will break if we change our app).
    dispatch_async(dispatch_get_main_queue(), ^{
        DBQueryWrapper* oldQueryWrapper = nil;
        DBQueryWrapper* navigationWrapper;
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachQueryWrapper getRestClient] isEqual:[self restClientForNavigation]]){
                oldQueryWrapper = eachQueryWrapper;
            }
        }
        if(oldQueryWrapper != nil){
            //DO NOT FOR THE LOVE OF GOD ADD
            //THIS OBEJCT TO THE _dbQueryWrapperHolder
            //array. I KNOW the one below is.
            //This object already exists in the array.
            [oldQueryWrapper setPassedFile:passedFile];
            [oldQueryWrapper setShouldReloadMainView:shouldReload];
            [oldQueryWrapper setMoveToDBPressed:moveToDBPressed];
            [oldQueryWrapper setCameFromAuth:NO];
            if(!shouldReload){
                [oldQueryWrapper setTypeOfQuery:DBLOADMETADATASELECTED];
            }
            [oldQueryWrapper incrementCustomRequestCount];
            //calls to loadmetadata with % characters in the thing do not appear to work.
            [[oldQueryWrapper getRestClient] loadMetadata:[@"/" stringByAppendingPathComponent:pathOnDropbox] atRev:nil];
        }else{
            navigationWrapper = [self wrapRestClient:[self restClientForNavigation] withStoredReduceStackToPath:nil andTypeOfQuery:DBLOADMETADATANORMAL andPassedFile:passedFile andshouldReloadSelectedFilesView:shouldReload andMoveToDB:moveToDBPressed cameFromAuth:NO andMovedFromDB:NO andSelectedFiles:[[NSMutableArray alloc] init]];
            if(!shouldReload){
                [navigationWrapper setTypeOfQuery:DBLOADMETADATASELECTED];
            }
            [navigationWrapper incrementCustomRequestCount];
            [[self dbQueryWrapperHolder] addObject:navigationWrapper];
            //calls to loadmetadata with % characters in the thing do not appear to work.
            [[navigationWrapper getRestClient] loadMetadata:[@"/" stringByAppendingPathComponent:pathOnDropbox] atRev:nil];
        }
    });
}

-(void)cancelNavigationLoad{
    //the problem with cancelAllRequests
    //is that if we're current downloading
    //something then it will cancel that things
    //download if we click dropbox and then cancel
    //that nvagiation via the clicking on the home button.
    //we could create a secondary rest client just for navigation
    //or for loading files that that unaffected by a call to cancel all.
    [[self restClientForNavigation] cancelAllRequests];
    _canLoadAndNavigateAfterAuth = NO;
}

-(void)cancelNavigationLoadFromBackPress{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
    [[self restClientForNavigation] cancelAllRequests];
    _canLoadAndNavigateAfterAuth = NO;
}

//kind of complex but not too complex.
//basically it just checks the query wrapper
//on each query wrapper for each request to LOAD
//a file and checks to see if the path being loaded to
//is an index on the dictionary inside the query wrapper
//if it is and it contains the original path on dropbox
//we cancel loading from that path on dropbox
-(BOOL)cancelFileLoadWithFile:(File*)fileToStopDownloadingFrom {
    NSString* originalPathToStopDownloading = @"";
    
    //if we find a matching query wrapper who's dictionary has a reference to the right local path
    //we get the original path on dropbox and cancel that load.
    for (DBQueryWrapper* queryWrapper in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]) {
        
        NSString* pathToTackOn = @"";
        //if the stored reduce stack to path and the parent url of the file are NOT
        //the same then that MUST mean this file was downloaded as part of a folder.
        //so we tack on the name of the folder/path to get from teh stored reducestack
        //to the actual file we want to cancel to the stored reduce stack [queryWrapper getStoredReduceStackToPath]
        if (![[queryWrapper getStoredReduceStackToPath] isEqualToString:fileToStopDownloadingFrom.parentURLPath]) {
            pathToTackOn = [[self fsInterface] resolveFilePath:fileToStopDownloadingFrom.parentURLPath excludingUpToDirectory:[[queryWrapper getStoredReduceStackToPath] lastPathComponent]];
        }

        if([[[queryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:pathToTackOn] isEqualToString:[fileToStopDownloadingFrom.path stringByDeletingLastPathComponent]]){
            //dropbox path
            originalPathToStopDownloading = [queryWrapper.downloadPathToOriginalPathMap valueForKey:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopDownloadingFrom.path]];
            
            //localpath
            NSString* downloadPathToStopDownloading = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopDownloadingFrom.path];
            
            //decrement the custom request count
            [queryWrapper decrementCustomRequestCount];
            
            //actually cancel the download
            [[queryWrapper getRestClient] cancelFileLoad:[[self fsInterface] resolveFilePath:originalPathToStopDownloading excludingUpToDirectory:@"Dropbox"]];
            
            //destroy the query limit object if this download had one.
            //source path is path one (path on dropbox) destination path is path 2 (path locally on phone)
            [self destroyObjectFromQueryLimitQueueWithPath1:originalPathToStopDownloading andPath2:downloadPathToStopDownloading andTypeOfQuery:DBLOADFILE];
            
            //remove the reference to the file inside the query wrapper
            [queryWrapper.downloadPathToOriginalPathMap removeObjectForKey:downloadPathToStopDownloading];
            
            return YES;
        }
    }
    return NO;
}

//kind of complex but not too complex.
//basically it just checks the query wrapper
//on each query wrapper for each request to LOAD
//a file and checks to see if the path being loaded to
//is an index on the dictionary inside the query wrapper
//if it is and it contains the original path on dropbox
//we cancel uploading loading to that path on dropbox

-(BOOL)cancelFileUploadWithFile:(File*)fileToStopUploadingFrom {
    NSString* originalPathToStopUploading = @"";
    
    //if we find a matching query wrapper who's dictionary has a reference to the right local path
    //we get the original path on dropbox and cancel that load.
    for (DBQueryWrapper* queryWrapper in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]) {
        
        NSString* pathToTackOn = @"";
        //if the stored reduce stack to path and the parent url of the file are NOT
        //the same then that MUST mean this file was downloaded as part of a folder.
        //so we tack on the name of the folder/path to get from teh stored reducestack
        //to the actual file we want to cancel to the stored reduce stack [queryWrapper getStoredReduceStackToPath]
        if (![[queryWrapper getStoredReduceStackToPath] isEqualToString:fileToStopUploadingFrom.parentURLPath]) {
            pathToTackOn = [[self fsInterface] resolveFilePath:fileToStopUploadingFrom.parentURLPath excludingUpToDirectory:[[queryWrapper getStoredReduceStackToPath] lastPathComponent]];
        }
        
        if([[[queryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:pathToTackOn] isEqualToString:[fileToStopUploadingFrom.path stringByDeletingLastPathComponent]]){
            //destination path
            originalPathToStopUploading = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopUploadingFrom.path];
            
            //source path
            NSString* uploadPathToStopUploading = [queryWrapper.downloadPathToOriginalPathMap valueForKey:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopUploadingFrom.path]];
            
            //decrement the custom request count and cancel the dropbox operation
            [queryWrapper decrementCustomRequestCount];
            [[queryWrapper getRestClient] cancelFileUpload:[[self fsInterface] resolveFilePath:fileToStopUploadingFrom.path excludingUpToDirectory:@"Dropbox"]];
            
            //destroy the query limit object
            [self destroyObjectFromQueryLimitQueueWithPath1:originalPathToStopUploading andPath2:uploadPathToStopUploading andTypeOfQuery:DBUPLOADFILE];
            
            //remove a file reference in the query wrapper
            [queryWrapper.downloadPathToOriginalPathMap removeObjectForKey:uploadPathToStopUploading];
            return YES;
        }
    }
    return NO;
}

#pragma mark - DBRestClientDelegate (the ones we actually use)


/* METADATA DELEGATE METHODS */

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]){
            //if the metadata query is for a navigation load of sorts
            //we can decrement the request count
            //if the metadata is for a download or upload
            //we cannot decrement the requestcount because if we did
            //in the time between this code and the call to the method
            //our NStimer could go off and purge a query wrapper that we need
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                if([eachQueryWrapper getTypeOfQuery] == DBLOADMETADATANORMAL){
                    
                    [eachQueryWrapper decrementCustomRequestCount];
                    [self navigationLoadWithClient:eachQueryWrapper loadedMetadata:metadata];
                    
                } else if ( [eachQueryWrapper getTypeOfQuery] == DBLOADMETADATASELECTED) {
                    
                    [eachQueryWrapper decrementCustomRequestCount];
                    [self navigationLoadForSelectedFilesWithClient:eachQueryWrapper loadedMetadata:metadata];
                    
                } else if([eachQueryWrapper getTypeOfQuery] == DBLOADFILE){
                    
                    //do not decrementCustomREquestCount here, decrement it at the end of the
                    //call to this method
                    [self recursiveDownloadForExport:eachQueryWrapper loadedMetadata:metadata];
                    
                } else if([eachQueryWrapper getTypeOfQuery] == DBLOADMETADATAENVOYUPLOADS){
                    
                    [eachQueryWrapper decrementCustomRequestCount];
                    [self processMetaDataFromCheckForAndCreateEnvoyUploadsFolder:eachQueryWrapper withMetaData:metadata withError:nil];
                }
            }
        }
    });
    
    //end a background task if it exists for this metadata load
    for (int i =0; i<[_fileIdnetifiersForTaskArray count]; i++) {
        if([[_fileIdnetifiersForTaskArray objectAtIndex:i] isEqualToString:metadata.path]){
            [[UIApplication sharedApplication] endBackgroundTask:i];
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError*)error{
    
    NSLog(@"LOADED METADATA FAILED %ld", (long)error.code);
    
    //if there's a 401 code then unlink the session
    //and re-authenticate the user from the app delegate
    if(error){
        //if there's an authentication error
        if (error.code == 401) {
            [[DBSession sharedSession] unlinkAll];
            [[DBSession sharedSession] linkFromController:(UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController]];
        /*https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/constant_group/URL_Loading_System_Error_Codes
        that url has the error codes for timeouts, etc*/
        //if there's a timeout error
        } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCollectionViewMessageForTimeout" object:self];
            [self cancelNavigationLoad];
        //if there is some other unspecified error
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCollectionViewMessageForUnspecifiedError" object:self];
            [self cancelNavigationLoad];
        }
        
    }else {
        //Check if this error resulted from a query to check for the Envoy Uploads folder
        dispatch_async(dispatch_get_main_queue(), ^{
            for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
                if([[eachQueryWrapper getRestClient] isEqual:client]){
                    if([eachQueryWrapper getTypeOfQuery] == DBLOADMETADATAENVOYUPLOADS){
                        [eachQueryWrapper decrementCustomRequestCount];
                        [self processMetaDataFromCheckForAndCreateEnvoyUploadsFolder:eachQueryWrapper withMetaData:nil withError:error];
                    }
                }
            }
        });
    }
}

/* DOWNLOAD DELEGATE METHODS */

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata{
    
    NSLog(@"DropBox File downloaded successfully from path: %@ ", metadata.path);
    
    //if an upload succeeds pull the query limit object out of the holder for it
    [self destroyObjectFromQueryLimitQueueWithPath1:[metadata.path stringByRemovingPercentEncoding] andPath2:[destPath stringByRemovingPercentEncoding] andTypeOfQuery:DBLOADFILE];
    
    //decrement global request queue and get new requests off the queue
    _globalActiveRequestCount--;
    if(![self globalActiveRequestsMaxedOut]){
        [self dequeueDBOperationsUpToGlobalMax];
    }
    
    //check for query wrappers to reduce the count on.
    //we need to be careful because some of these query wrappers
    //will have a count of 1 but multiple files downloading.???
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                [eachQueryWrapper decrementCustomRequestCount];
            }
        }
    });
    
    //we don't put this in the error delegate method below because we
    //don't want errors to end the backgorund task, we want errors to re-query.
    for (int i =0; i<[_fileIdnetifiersForTaskArray count]; i++) {
        if([[_fileIdnetifiersForTaskArray objectAtIndex:i] isEqualToString:destPath]){
            [[UIApplication sharedApplication] endBackgroundTask:i];
        }
    }
}

// - need to implement logic here in case dropbox fails and the queues
// - need to be reset from a failed method.

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error{
    
    NSLog(@"DropBox File download failes from path: %@ ", [error.userInfo objectForKey:@"path"]);
    //if there was a download error (you know cuz we're inside this clalback)
    //and the error code is 404 then that file no longer exists.
    //so we need to cancel teh download and destroy its metadata
    if (error.code == 404) {
        [client cancelFileLoad:[error.userInfo objectForKey:@"path"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* storedReduceStackToPath;
            File* passedFileNowExtracted;
            for(DBQueryWrapper* eachWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
                if([[eachWrapper getRestClient] isEqual:client]){
                    storedReduceStackToPath = [eachWrapper getStoredReduceStackToPath];
                    passedFileNowExtracted = [eachWrapper getPassedFile];
                }
            }
            
            File* newFileShouldMimicOld = [[File alloc] initWithName:[[error.userInfo objectForKey:@"path"] lastPathComponent] andPath:[storedReduceStackToPath stringByAppendingPathComponent:[[error.userInfo objectForKey:@"path"] lastPathComponent]] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:NO andBoxId:@"-1"];
            
            //use that stored reduce stack.
            NSLog(@"REMOVING FILE: %@, FROM PATH %@", newFileShouldMimicOld.name, storedReduceStackToPath);
            [[self fsInterface] removeSingleFileFromFileSystemJSON:newFileShouldMimicOld inDirectoryPath:storedReduceStackToPath];
            [_dbServiceManagerDelegate alertUserToFileNotFound:newFileShouldMimicOld];
        });
    } else {
        NSString* unencodedPath = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: [[error.userInfo objectForKey:@"path"] stringByRemovingPercentEncoding]];
        NSString* unencodedDestinationPath = [[error.userInfo objectForKey:@"destinationPath"] stringByRemovingPercentEncoding];
        
        //decrement global request queue
        _globalActiveRequestCount--;
        
        //increment the # of times this particular request has failed.
        [self incrementNumberOfFailedQueriesWithPath1:unencodedPath andPath2:unencodedDestinationPath andTypeOfQuery:DBLOADFILE];
        
        if (![self overQueryOccurrenceLimitForQueryWithPath1:unencodedPath andPath2:unencodedDestinationPath andTypeOfQuery:DBLOADFILE]){
            
            //if we're maxed out
            if([self globalActiveRequestsMaxedOut]){
                
                DBOperationWrapper* operationWrapper = [[DBOperationWrapper alloc] initWithRestClient:client andPath1:unencodedPath andPath2:unencodedDestinationPath andTypeOfQuery:DBLOADFILE andFilename:[unencodedPath lastPathComponent]];
                [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                
            }else{
                
                //keep original do not swap out for unencoded. we need it this way.
                [client loadFile:[error.userInfo objectForKey:@"path"] intoPath:[error.userInfo objectForKey:@"destinationPath"]];
                _globalActiveRequestCount++;
                [self dequeueDBOperationsUpToGlobalMax];
            }
        }
    }
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath{
    
//    NSLog(@"DropBox File download progress; %f", progress);
    //get the stored reduce stack for this client
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* storedReduceStackToPath;
        for(DBQueryWrapper* eachWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachWrapper getRestClient] isEqual:client]){
                storedReduceStackToPath = [eachWrapper getStoredReduceStackToPath];
            }
        }
        //use that stored reduce stack.
        [_reloadCollectionViewProgressDelegate reloadCollectionViewFilePath:destPath withProgress:progress withReduceStack:storedReduceStackToPath];
    });
}

/* UPLOAD DELEGATE METHODS */

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"DropBox File uploaded successfully to path: %@", metadata.path);
    
    //if an upload succeeds pull the query limit object out of the holder for it
    [self destroyObjectFromQueryLimitQueueWithPath1:[[destPath stringByRemovingPercentEncoding] stringByDeletingLastPathComponent] andPath2:[srcPath stringByRemovingPercentEncoding] andTypeOfQuery:DBUPLOADFILE];
    //decrement global request queue and get new requests off the queue
    _globalActiveRequestCount--;
    if(![self globalActiveRequestsMaxedOut]){
        [self dequeueDBOperationsUpToGlobalMax];   
    }
    
    //grab the proper counter and decrement it if the file is
    //uploaded properly the request is over.
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* storedReduceStackToPath;
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                [eachQueryWrapper decrementCustomRequestCount];
                storedReduceStackToPath = [eachQueryWrapper getStoredReduceStackToPath];
            }
        }
        
        // if we don't send a progress event on finish then the animation can
        // freeze 
        CGFloat progress = 1.0;
        //use that stored reduce stack to path string
        [_reloadCollectionViewProgressDelegate reloadCollectionViewFilePath:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: @"Dropbox"] stringByAppendingPathComponent: destPath] withProgress:progress withReduceStack:storedReduceStackToPath];
    });
    
    //we don't put this in the error delegate method below because we
    //don't want errors to end the backgorund task, we want errors to re-query.
    for (int i =0; i<[_fileIdnetifiersForTaskArray count]; i++) {
        if([[_fileIdnetifiersForTaskArray objectAtIndex:i] isEqualToString:destPath]){
            [[UIApplication sharedApplication] endBackgroundTask:i];
        }
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    
    NSLog(@"DropBox File upload failed to path: %@", [error.userInfo objectForKey:@"destinationPath"]);
    
    NSString* unencodedDestination = [[[[self fsInterface]getDocumentsDirectory] stringByAppendingPathComponent:@"Dropbox"] stringByAppendingPathComponent:[[error.userInfo objectForKey:@"destinationPath"] stringByRemovingPercentEncoding]];
    NSString* unencodedSource = [[error.userInfo objectForKey:@"sourcePath"] stringByRemovingPercentEncoding];
    
    //decrement global request queue
    _globalActiveRequestCount--;
    
    //increment the number of times this request has failed.
    [self incrementNumberOfFailedQueriesWithPath1:unencodedDestination andPath2:unencodedSource andTypeOfQuery:DBUPLOADFILE];
    
    if (![self overQueryOccurrenceLimitForQueryWithPath1:unencodedDestination andPath2:unencodedSource andTypeOfQuery:DBUPLOADFILE]){
        
        if([self globalActiveRequestsMaxedOut]){
            
            DBOperationWrapper* operationWrapper = [[DBOperationWrapper alloc] initWithRestClient:client andPath1:unencodedDestination andPath2:unencodedSource andTypeOfQuery:DBUPLOADFILE andFilename:[unencodedDestination lastPathComponent]];
            [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
            
        }else{
            //don't swap these with unencoded versions, dropbox
            //needs its input paths encoded.
            //re upload the file if the upload fails a first time
            [client uploadFile:[[error.userInfo objectForKey:@"destinationPath"] lastPathComponent] toPath:[[error.userInfo objectForKey:@"destinationPath"] stringByDeletingLastPathComponent] withParentRev:nil fromPath:[error.userInfo objectForKey:@"sourcePath"]];
             _globalActiveRequestCount++;
            [self dequeueDBOperationsUpToGlobalMax];
        }
    }
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath{
//    NSLog(@"Dropbox File upload progress: %f", progress);
    // if we're potentially observing a file that is being loaded, we trigger an animation.
    
    //get the stored reduce stack for this client
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* storedReduceStackToPath;
        for(DBQueryWrapper* eachWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachWrapper getRestClient] isEqual:client]){
                storedReduceStackToPath = [eachWrapper getStoredReduceStackToPath];
            }
        }
        
        //use that stored reduce stack to path string
        [_reloadCollectionViewProgressDelegate reloadCollectionViewFilePath:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: @"Dropbox"] stringByAppendingPathComponent: destPath] withProgress:progress withReduceStack:storedReduceStackToPath];
    });
}

/* CREATE FOLDER DELEGATES */

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)metadata{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]) {
            if([[eachQueryWrapper getRestClient] isEqual:client]) {
                [eachQueryWrapper decrementCustomRequestCount];
                if([eachQueryWrapper getTypeOfQuery] == DBLOADMETADATAENVOYUPLOADS){
                    [self startUploadAfterCreatingEnvoyUploadsFolderWithMetaData:metadata andOriginallySelectedFiles:[eachQueryWrapper getOriginallySelectedFiles] withError:nil];
                }
            }
        }
    });
    
    //we don't put this in the error delegate method below because we
    //don't want errors to end the backgorund task, we want errors to re-query.
    for (int i =0; i<[_fileIdnetifiersForTaskArray count]; i++) {
        if([[_fileIdnetifiersForTaskArray objectAtIndex:i] isEqualToString:metadata.path]){
            [[UIApplication sharedApplication] endBackgroundTask:i];
        }
    }
}

#pragma mark - DBRestClientDelegate (the ones we don't use)

// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"Dropbox File folder create failed with error : %@", error);
    
    //if there's a 401 code then unlink the session
    //and re-authenticate the user from the app delegate
    if(error && error.code == 401){
        [[DBSession sharedSession] unlinkAll];
        [[DBSession sharedSession] linkFromController:(UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController]];
    }
    
    //need this here, we handle the 404 in the method below called startUpLoadAfterCreatingENvoyUploads.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                if([eachQueryWrapper getTypeOfQuery] == DBLOADMETADATAENVOYUPLOADS){
                    [self processMetaDataFromCheckForAndCreateEnvoyUploadsFolder:eachQueryWrapper withMetaData:nil withError:error];
                }
            }
        }
    });
}

// - deletion delegate mathods - //

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
    
    NSLog(@"DropBox SUCCESSFULLY DELETED PATH: %@", path);
    //if the delete was successfull decrement the count for that client.
    dispatch_async(dispatch_get_main_queue(), ^{
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                [eachQueryWrapper decrementCustomRequestCount];
            }
        }
    });
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
    
    NSLog(@"DropBox THERE WAS AN ERROR WHILE TRYING TO DELETE A PATH: %@", error);
    //retry the delete.
    dispatch_async(dispatch_get_main_queue(), ^{
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                //GET THE PATH FROM THE ERROR userInfo (as above in other delegate methods)
                //and redo the delete
            }
        }
    });
}

// - moved delegate methods - //

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path to:(DBMetadata *)result{
    
    NSLog(@"DropBox SUCESSFULLY MOVED FROM PATH %@ TO PATH %@.", from_path, result.path);
    //if the move was successful decrement the count for that client
    dispatch_async(dispatch_get_main_queue(), ^{
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                [eachQueryWrapper decrementCustomRequestCount];
            }
        }
    });
}

- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error{
    
    NSLog(@"DropBox ERROR WHILE MOVING A FILE :%@", error);
    //retry the move
//    dispatch_async(dispatch_get_main_queue(), ^{
//        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc]initWithArray:[self dbQueryWrapperHolder]]){
//            if([[eachQueryWrapper getRestClient] isEqual:client]){
//            }
//        }
//    });
}

//delegate reponse to grab a link
- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path {
    NSLog(@"link is %@ for path %@", link, path);
    
    if (link == nil) {
        [_sendLinksFromServiceManagerDelegate sendLinkDictionaryFailedToRetrieveAllLinks];
    }
    else {
        NSString* amendedPath = [[@"/" stringByAppendingPathComponent:@"Dropbox"] stringByAppendingPathComponent:path];
        
        LinkJM *linkObject = (LinkJM*)[[self dictionaryWithShareableLinks] objectForKey:amendedPath];
        
        if ([linkObject.url isEqualToString:@""]) {
            linkObject.url = link;
        }
        
        int emptyCount = 0;
        for (NSString* key in [self dictionaryWithShareableLinks]) {
            LinkJM *linkObject = (LinkJM*)[[self dictionaryWithShareableLinks] objectForKey:key];
            if ([linkObject.url isEqualToString:@""]) {
                emptyCount++;
            }
        }
        
        //if none of the things we want links for are missing
        //we have all our our links the user requested, send
        //them back. Else continue to wait for next link.
        if (emptyCount == 0) {
            //return a dictionary into the homeview
            [_sendLinksFromServiceManagerDelegate sendLinkDictionaryFromServiceManagerDelegate:[[NSDictionary alloc] initWithDictionary:[self dictionaryWithShareableLinks]]];
        }
    }
}

//delegate response to grab a link
- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error {
    NSLog(@"%@", [error localizedDescription]);
    // currently we DO NOT retry to get a link on error we just send a message
    // saying that link retrieval has failed, no point really this is virtually instant
    [_sendLinksFromServiceManagerDelegate sendLinkDictionaryFailedToRetrieveAllLinks];
}

// - END REST CLIENT DELEGATES - //

#pragma mark - Methods for Navigation Load, Download, and Upload

-(void) navigationLoadWithClient:(DBQueryWrapper *)passedQueryWrapper loadedMetadata:(DBMetadata *)metadata{
    if (metadata.isDirectory){//if our metadata query says it's a directory
        NSMutableArray* filesForBatchWrite = [[NSMutableArray alloc] init];
        NSString* newFileParentPath = @"";
        for (DBMetadata *file in metadata.contents) {
            
            File* newFile = [[File alloc] initWithName:file.filename andPath:[@"/Dropbox" stringByAppendingPathComponent:file.path]  andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:file.isDirectory andBoxId:@"-1"];
            newFileParentPath = newFile.parentURLPath;
            
            if (file.isDirectory) {
                [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
            }
            [filesForBatchWrite addObject:newFile];
        }
        [[self fsInterface] saveBatchOfFilesToFileSystemJSON:filesForBatchWrite inDirectoryPath:newFileParentPath];
    }else{
        File* newFile = [[File alloc] initWithName:metadata.filename  andPath:[@"/Dropbox" stringByAppendingPathComponent:metadata.path] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:metadata.isDirectory andBoxId:@"-1"];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
    }
    
    // push the file we're navigating into
    // popualte the current directory and resolve any selected files.
    // only do this if the boolean is set to true
    // we added this boolean because sometimes we load this data into
    // selectedfiles view and we don't want to reload anything on the main
    // collection view while we're in the selected files view.
    
    if([passedQueryWrapper getShouldReloadMainView]){//ONLY FOR LOADING DATA IN THE MAIN VIEW
        [[self fsAbstraction] pushOntoPathStack:[passedQueryWrapper getPassedFile]];
        [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getPassedFile].path];
        
        // - if a folder that is passed in (entered) is in the _selectedFiles array, then
        // = all it's children should also be added to the selected file array.
        
        // we need to make sure a file doesn't already exist in the array before we add it

        // send a notification to update the toolbar once we've pushed.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
    }
    
    //current dire proxy is just an array that we can pass back to the
    //selecte fiels view delegate so it can figure out what's in
    //the next directory even when we're not repopulating the
    //actual currentdirectory array (basically when we click)
    //on a folder in the selected files view and need to load
    //metadata in the selected files view but not in the original view.
    //the real current directory array has already been populated if it's supposed to be
    //in the if(_shouldReloadCurrentDirectory) statement code block
    NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
    [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy inDirectoryPath:[passedQueryWrapper getPassedFile].path];
    //use a delegate and not a notification because we need to pass data back to it.
    [_selectedFilesViewCloudNavDelegate populateWithFilesToDisplay:currentDirProxy withPassed:[passedQueryWrapper getPassedFile]];
    [passedQueryWrapper setShouldReloadMainView:YES];
    
    // we need this here otherwise the stack path gets fucked (extra dropboxes added)
    // the problem is that on load after the auth this causes dropbox
    // to crash because we're iterating through it somewhere else.
    if([passedQueryWrapper getCameFromAuth]){

        [[self fsAbstraction] pushOntoPathStack:[passedQueryWrapper getPassedFile]];
        // send a notification to update the toolbar oncewe've pushed.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
    }
    
    //if this is not inside this if statement it populates the current directory when trying to load
    //cloud files in the selected files view
    [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getPassedFile].path];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
}

-(void) navigationLoadForSelectedFilesWithClient:(DBQueryWrapper *)passedQueryWrapper loadedMetadata:(DBMetadata *)metadata{
    
    if (metadata.isDirectory) {
        NSMutableArray* filesForBatchWrite = [[NSMutableArray alloc] init];
        NSString* newFileParentPath = @"";
        for (DBMetadata *file in metadata.contents) {
            File* newFile = [[File alloc] initWithName:file.filename andPath:[@"/Dropbox" stringByAppendingPathComponent:file.path] andDate:[NSDate date] andRevision:file.rev andDirectoryFlag:file.isDirectory andBoxId:@"-1"];
            newFileParentPath = newFile.parentURLPath;
            if (file.isDirectory) {
                [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
            }
            [filesForBatchWrite addObject:newFile];
        }
        [[self fsInterface] saveBatchOfFilesToFileSystemJSON:filesForBatchWrite inDirectoryPath:newFileParentPath];
    }else{
        File* newFile = [[File alloc] initWithName:metadata.filename andPath:[@"/Dropbox" stringByAppendingPathComponent:metadata.path] andDate:[NSDate date] andRevision:metadata.rev andDirectoryFlag:metadata.isDirectory andBoxId:@"-1"];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
    }
    
    //current dire proxy is just an array that we can pass back to the
    //selecte fiels view delegate so it can figure out what's in
    //the next directory even when we're not repopulating the
    //actual currentdirectory array (basically when we click)
    //on a folder in the selected files view and need to load
    //metadata in the selected files view but not in the original view.
    //the real current directory array has already been populated if it's supposed to be
    //in the if(_shouldReloadCurrentDirectory) statement code block
    NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
    [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy inDirectoryPath:[passedQueryWrapper getPassedFile].path];
    //use a delegate and not a notification because we need to pass data back to it.
    [_selectedFilesViewCloudNavDelegate populateWithFilesToDisplay:currentDirProxy withPassed:[passedQueryWrapper getPassedFile]];
    [passedQueryWrapper setShouldReloadMainView:YES];
}

/* upload files recursively to dropbox */

-(void) pullFilesToUploadFromOther:(File*) oldFile withQueryWrapper:(DBQueryWrapper*)passedQueryWrapper{
    
    NSMutableArray* prepareToSaveFilesOthArray = [[NSMutableArray alloc]init];
    [[self fsInterface] isValidPath:oldFile.path];
    
    if (oldFile.isDirectory){ // recursively call if it's a directory
        
        NSString* pathForNewDir = [[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:oldFile.path] stringByDeletingLastPathComponent];
        
        //check if the parent is presentat at new location, it it's not then save directly in place we want to move to.
        while (![[self fsInterface] isValidPath:pathForNewDir]){
            
            pathForNewDir = [self urlPathMiddleOut:pathForNewDir onQueryWrapper:passedQueryWrapper];
        }
        
        //save the new directory.
        File* newDir = [[File alloc] initWithName:oldFile.name andPath:[pathForNewDir  stringByAppendingPathComponent:oldFile.name] andDate:[NSDate date] andRevision:oldFile.revision andDirectoryFlag:YES andBoxId:@"-1"];
        
        [[self fsInterface] createDirectoryAtPath:newDir.path withIntermediateDirectories:NO attributes:nil];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:newDir.parentURLPath];
        [passedQueryWrapper incrementCustomRequestCount];
        
        //create the folder on dropbox
        [[passedQueryWrapper  getRestClient] createFolder:[[self fsInterface] resolveFilePath:newDir.path excludingUpToDirectory:@"Dropbox"]];
        
        UIBackgroundTaskIdentifier bgTask = 0;
        bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        }];
        
        [_bgTaskArray addObject:@(bgTask)];
        [_fileIdnetifiersForTaskArray addObject:[[self fsInterface] resolveFilePath:newDir.path excludingUpToDirectory:@"Dropbox"]];
        
        [[self fsInterface] populateArrayWithFileSystemJSON:prepareToSaveFilesOthArray inDirectoryPath:oldFile.path];
        
        for(File* child in prepareToSaveFilesOthArray){
            
            [self pullFilesToUploadFromOther:child withQueryWrapper:passedQueryWrapper];
        }
        
    }else{
        
        NSString* pathforNewFile = [[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:[oldFile.path stringByDeletingLastPathComponent]];
        // while the path leading up to the file is not valid delete the path component at
        // the start of the path right after /Documents
        // /Documents/Local/Manual/somefile/blah becomes /Documents/Local/somefile/blah becomes /Documents/Local/blah
        while (![[self fsInterface] isValidPath:pathforNewFile]){
            
            pathforNewFile = [self urlPathMiddleOut:pathforNewFile onQueryWrapper:passedQueryWrapper];
        }
        
        File* newFile = [[File alloc] initWithName:oldFile.name andPath:[pathforNewFile  stringByAppendingPathComponent:oldFile.name] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:NO andBoxId:@"-1"];
        
        //set the object in the download path to original dictionary, was causing a crash on cancel uplaod before.
        [passedQueryWrapper setObject:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:oldFile.path] stringByRemovingPercentEncoding] forKeyInDownloadPathToOriginalPathMap:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: newFile.path]];
        
        // we don't want to move the filesystem.json file...
        if(![newFile.name isEqualToString:@".filesystem.json"]){
            
            [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
            
            [[self fsInterface] isValidPath:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:oldFile.path]];
            
            [passedQueryWrapper incrementCustomRequestCount];
            
            //create the file loading object
            [_dbServiceManagerDelegate dbCreateFileLoadingObjectWithFile:newFile andReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
            
            if(![self overQueryOccurrenceLimitForQueryWithPath1:[[[self fsInterface] resolveFilePath:newFile.path excludingUpToDirectory:@"Dropbox"] stringByDeletingLastPathComponent] andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:oldFile.path] stringByRemovingPercentEncoding] andTypeOfQuery:DBUPLOADFILE]){
                
                //if we're already making the max # of queries (4).
                if([self globalActiveRequestsMaxedOut]){
                    
                    //if we're already full on downloads/uploads
                    DBOperationWrapper* operationWrapper = [[DBOperationWrapper alloc] initWithRestClient:[passedQueryWrapper getRestClient] andPath1:[[[self fsInterface] resolveFilePath:newFile.path excludingUpToDirectory:@"Dropbox"] stringByDeletingLastPathComponent] andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:oldFile.path] stringByRemovingPercentEncoding] andTypeOfQuery:DBUPLOADFILE andFilename:newFile.name];
                    
                    [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                    //if we're not shoot off the query.
                } else {
                    
                    //upload the file to dropbox
                    [[passedQueryWrapper getRestClient] uploadFile:newFile.name toPath:[[[self fsInterface] resolveFilePath:newFile.path excludingUpToDirectory:@"Dropbox"] stringByDeletingLastPathComponent] withParentRev:nil fromPath:[[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:oldFile.path] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    //create a query limit object and add it to the array for query limits
                    DBQueryLimitWrapper* queryLimitWrapper = [[DBQueryLimitWrapper alloc] initWithPath1:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:newFile.path] andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:oldFile.path] stringByRemovingPercentEncoding] andTypeOfQuery:DBUPLOADFILE];
                    
                    [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                    
                    _globalActiveRequestCount++;
                    [self dequeueDBOperationsUpToGlobalMax];
                }
            }
            
            UIBackgroundTaskIdentifier bgTask = 0;
            bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            }];
            
            [_bgTaskArray addObject:@(bgTask)];
            [_fileIdnetifiersForTaskArray addObject:[[self fsInterface] resolveFilePath:newFile.path excludingUpToDirectory:@"Dropbox"]];
        }
    }
    
    if([[passedQueryWrapper getStoredReduceStackToPath] isEqualToString:[[self fsAbstraction] reduceStackToPath]]){
        
        [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getStoredReduceStackToPath]];
        //must be a reload to add a new cell?
        //or is there another way to add a cell.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
    }
    
    // if this method call was the result of pressing "move to DB"
    // and the user has moved files directly to dropbox but not
    // renaviagted we need to send a signal to change images in
    // the collectionview
//    if([passedQueryWrapper getMoveToDBPressed]){
//        //all we're doing here is deselecting two files, there should be a way to do this w/o reloading.
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
//    }
}

/*  - this method will recursively iterate through each level of the selected file/directory
    - and is will directly beam it into its desitnation path where it should be.
    - this is going to replace the convoluted, screwed up asynchornous system 
    - I made this weekend. This doesn't download files into the dropbox directory
    - it downloads files directly into the new directory where it needs to go.
 
    - */

-(void) recursiveDownloadForExport:(DBQueryWrapper*)passedQueryWrapper loadedMetadata:(DBMetadata*)metadata{
    
    // - if we've triggered 3 or more (probably 4) api calls
    // - then we pause the queue that contans the recursive calls.
        
    if (metadata.isDirectory) {
        
        NSString* pathForNewDir = [[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:metadata.path] stringByDeletingLastPathComponent];
        
        //&& ![[urlForNewDir path] isEqualToString:[self urlPathMiddleOut:[urlForNewDir path]]]
        //check if the parent is presentat at new location, it it's not then save directly in place we want to move to.
        while (![[self fsInterface] isValidPath:pathForNewDir]){
            pathForNewDir = [self urlPathMiddleOut:pathForNewDir onQueryWrapper:passedQueryWrapper];
        }
        
        //save the new directory.
        File* newDir = [[File alloc] initWithName:metadata.filename andPath:[pathForNewDir stringByAppendingPathComponent:metadata.filename] andDate:[NSDate date] andRevision:metadata.rev andDirectoryFlag:metadata.isDirectory andBoxId:@"-1"];

        //if the encoded file name is too long truncate that thing and its path
        if([newDir.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
            NSString* extension = [newDir.name pathExtension];
            newDir.name = [[newDir.name substringToIndex:newDir.name.length/2] stringByAppendingPathExtension:extension];
            newDir.path = [[newDir.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newDir.name];
        }
        
        [passedQueryWrapper decrementCustomRequestCount];
        [[self fsInterface] createDirectoryAtPath:newDir.path withIntermediateDirectories:NO attributes:nil];
        
        [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:newDir.parentURLPath];
        
        //for each file inside our directory create the file
        for (DBMetadata *file in metadata.contents) {

            //if you're in this if then you're underneath a file and your file.path exists at the new location.
            NSString* pathForNewFile = [[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:file.path] stringByDeletingLastPathComponent];
            // while the path leading up to the file is not valid delete the path component at
            // the start of the path right after /Documents
            // /Documents/Local/Manual/somefile/blah becomes /Documents/Local/somefile/blah becomes /Documents/Local/blah
            while (![[self fsInterface] isValidPath:pathForNewFile]){
                pathForNewFile = [self urlPathMiddleOut:pathForNewFile onQueryWrapper:passedQueryWrapper];
            }
            
            File* newFile = [[File alloc] initWithName:file.filename andPath:[pathForNewFile  stringByAppendingPathComponent:file.filename] andDate:[NSDate date] andRevision:file.rev andDirectoryFlag:file.isDirectory andBoxId:@"-1"];
            
            //don't bring in files with the name .filesystem.json
            if(![newFile.name isEqualToString:@".filesystem.json"]){
            
                //if the encoded file name is too long truncate that thing and its path
                if([newFile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
                    NSString* extension = [newFile.name pathExtension];
                    newFile.name = [[newFile.name substringToIndex:newFile.name.length/2] stringByAppendingPathExtension:extension];
                    newFile.path = [[newFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name];
                }
                
                [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
                
                //if the file is a directory then recursive call that bitch.
                if(file.isDirectory){
                    
                    //DO NOT ADD FOLDER TO THE PASSED QUERY WRAPPER DICTIONARY MAPPING PATHS LOCALLY TO PATHS ON DROPBOX
                    //FOLDERS CANT BE CANCELLED
                    [passedQueryWrapper incrementCustomRequestCount];
                    [[passedQueryWrapper getRestClient] loadMetadata:file.path  atRev:nil];
                    [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];

                    UIBackgroundTaskIdentifier bgTask = 0;
                    bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                    }];
                    [_bgTaskArray addObject:@(bgTask)];
                    
                    [_fileIdnetifiersForTaskArray addObject:file.path];
                }else{//if the file is a non-directory file load it straight into the new location.
                    
                    [passedQueryWrapper setObject:[  [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:@"/Dropbox"] stringByAppendingPathComponent:file.path] forKeyInDownloadPathToOriginalPathMap:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: newFile.path]];
                    [passedQueryWrapper incrementCustomRequestCount];
                    
                    //create the file loading object
                    [_dbServiceManagerDelegate dbCreateFileLoadingObjectWithFile:newFile andReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
                    
                    //if the encoded file name is too long truncate that thing and its path
                    if([newFile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
                        NSString* extension = [newFile.name pathExtension];
                        newFile.name = [[newFile.name substringToIndex:newFile.name.length/2] stringByAppendingPathExtension:extension];
                        newFile.path = [[newFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name];
                    }
                    
                    //if we're not over the global limit for this unique type of query (path1, path2, download or upload)
                    //then queue it up or send it out.
                    if (![self overQueryOccurrenceLimitForQueryWithPath1:file.path andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: newFile.path] stringByRemovingPercentEncoding] andTypeOfQuery:DBLOADFILE]){
                        
                        //if we're at the global max, queue up this
                        //operation
                        if([self globalActiveRequestsMaxedOut]){
                            
                            DBOperationWrapper* operationWrapper = [[DBOperationWrapper alloc] initWithRestClient:[passedQueryWrapper getRestClient] andPath1:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:file.path] andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: newFile.path] stringByRemovingPercentEncoding] andTypeOfQuery:DBLOADFILE andFilename:file.filename];
                            [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                            
                            //if we're not at the global max then do the operation and
                            //get other operations up to the global max.DONT create
                            //a file loading object conditionally, create it no matter
                            //what, we want that file loading object to appear in the view
                        }else{
                            
                            //download the file from dropbox
                            [[passedQueryWrapper getRestClient] loadFile:file.path intoPath: [[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: newFile.path] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                            //create a query limit for this unique query.
                            DBQueryLimitWrapper* queryLimitWrapper = [[DBQueryLimitWrapper alloc] initWithPath1:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:file.path] andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: newFile.path] stringByRemovingPercentEncoding] andTypeOfQuery:DBLOADFILE];
                            //add it if it doesn't exist
                            [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                            //increment the global active requests/queries
                            _globalActiveRequestCount++;
                            //get as many things from the queue as possible and
                            //execute them
                            [self dequeueDBOperationsUpToGlobalMax];
                        }
                    }
                
                    UIBackgroundTaskIdentifier bgTask = 0;
                    bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                    }];
                    [_bgTaskArray addObject:@(bgTask)];
                    
                    [_fileIdnetifiersForTaskArray addObject:pathForNewFile];
                }
            }
        }
        
    }else{//only gets triggered for selected non directory files. this makes the recursion a little weird.
        
        //if you're in this if then your not underneath a file that exists at the new location and your name needs to be used
        //to build your path direclty in the new folder you're being transplanted to.
        
        //contents are nil because we just use Dropbox DBREstClient to load in the file data.
        File* newFile = [[File alloc] initWithName:metadata.filename andPath:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:metadata.filename] andDate:[NSDate date] andRevision:metadata.rev andDirectoryFlag:metadata.isDirectory andBoxId:@"-1"];
        
        //don't bring in files with the name .filesystem.json
        if(![newFile.name isEqualToString:@".filesystem.json"]){
            
            //if the encoded file name is too long truncate that thing and its path
            if([newFile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
                NSString* extension = [newFile.name pathExtension];
                newFile.name = [[newFile.name substringToIndex:newFile.name.length/2] stringByAppendingPathExtension:extension];
                newFile.path = [[newFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name];
            }
            
            //create a map inside a dictionary on teh queryWrapper to map the path on our device
            //to the path downloaded from dropbox.
            [passedQueryWrapper setObject:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:@"Dropbox"] stringByAppendingPathComponent:metadata.path ] forKeyInDownloadPathToOriginalPathMap:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:newFile.name]]];
            
            //I thin kwe would NOT need to endcode the japanese characters, but the filenames could have spaces which MUST be encoded
            //so the solution is to ONLY enocde the spaces via a premade method or our own methdo? no...that's not it because
            //then otehr speicla chars will cause crashes.
            [passedQueryWrapper incrementCustomRequestCount];
            //create the file loading object
            [_dbServiceManagerDelegate dbCreateFileLoadingObjectWithFile:newFile andReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
            
            if(![self overQueryOccurrenceLimitForQueryWithPath1:metadata.path andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:newFile.name]] stringByRemovingPercentEncoding]andTypeOfQuery:DBLOADFILE]){
                
                //if we're at the global max, queue up this
                //operation
                if([self globalActiveRequestsMaxedOut]){
                    
                    DBOperationWrapper* operationWrapper = [[DBOperationWrapper alloc] initWithRestClient:[passedQueryWrapper getRestClient] andPath1:metadata.path andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:newFile.name]] stringByRemovingPercentEncoding] andTypeOfQuery:DBLOADFILE andFilename:metadata.filename];
                    [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                    
                    //if we're not at the global max then do the operation and
                    //get other operations up to the global max. DONT create
                    //a file loading object conditionally, create it no matter
                    //what, we want that file loading object to appear in the view
                }else{
                                    
                    //ACTUALLY LOAD THE DROPBOX FILE.
                    //download the file from dropbox
                    //download the file from dropbox onto the phone
                    [[passedQueryWrapper getRestClient] loadFile:metadata.path intoPath:[[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:newFile.name]] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    //setup a query limit
                    DBQueryLimitWrapper* queryLimitWrapper = [[DBQueryLimitWrapper alloc] initWithPath1:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:metadata.path] andPath2:[[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:newFile.name]] stringByRemovingPercentEncoding] andTypeOfQuery:DBLOADFILE];
                    //add if it doesn't exist
                    [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                    
                    _globalActiveRequestCount++;
                    [self dequeueDBOperationsUpToGlobalMax];
                }
            }
            
            
            [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
            
            UIBackgroundTaskIdentifier bgTask = 0;
            bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            }];
            [_bgTaskArray addObject:@(bgTask)];
            [_fileIdnetifiersForTaskArray addObject:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:metadata.filename]];
        }
    }
    
    //clear the selectedfiles array.
    //[[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    
    if([[passedQueryWrapper getStoredReduceStackToPath] isEqualToString:[[self fsAbstraction] reduceStackToPath]]){
        
        [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getStoredReduceStackToPath]];
        //loading animation for load progress on files
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endLoadingAnimationNotification" object:self];
        //reload the collection view when there's new files to show.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
        //re-show a previously hidden collection view as soon as there's new files to show.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
    }
    
    if([passedQueryWrapper getMoveFromDBPressed]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
    }
    //decrement the customREquestCount from the metadata call
    [passedQueryWrapper decrementCustomRequestCount];
}

-(void) deleteFileFromDropbox:(File*)fileOrFolder onDropboxPath:(NSString*)pathToDelete{
    
    DBRestClient* newClient = [self produceRestClient];
    DBQueryWrapper* wrappedNewClient = [self wrapRestClient:newClient withStoredReduceStackToPath:nil andTypeOfQuery:DBDELETEFILE andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToDB:NO cameFromAuth:NO andMovedFromDB:NO andSelectedFiles:[[NSMutableArray alloc] initWithObjects:fileOrFolder, nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self dbQueryWrapperHolder] addObject:wrappedNewClient];
        [wrappedNewClient incrementCustomRequestCount];
        [[wrappedNewClient getRestClient] deletePath:pathToDelete];
    });
}

// - move is only good for reorganizing files WITHIN dropbox - //

-(void) moveFileOnDropBox:(File*)file fromPath:(NSString*)fromPath toPath:(NSString*)toPath{
    
    DBRestClient* newClient = [self produceRestClient];
    DBQueryWrapper* wrappedNewClient = [self wrapRestClient:newClient withStoredReduceStackToPath:nil andTypeOfQuery:DBMOVEFROM andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToDB:NO cameFromAuth:NO andMovedFromDB:NO andSelectedFiles:[[NSMutableArray alloc] initWithObjects:file, nil]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self dbQueryWrapperHolder] addObject:wrappedNewClient];
        [wrappedNewClient incrementCustomRequestCount];
        [[wrappedNewClient getRestClient] moveFrom:fromPath toPath:toPath];
    });
}

//send a request to check for the envoy uploads folder

-(void) checkForAndCreateEnvoyUploadsFolderThenUpload:(UIViewController*)passedController {
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:passedController];
    } else {
        //we only allow the user to do a direct move to the Envoy Uploads folder if they are NOT inside dropbox
        //if we don't have this here, the user can 1. selected a file 2. auth dropbox by clicking on the dropbox icon
        //and then the file wil lupload because this method get striggered from an auth and we can't help that
        //because we need to send a notification to this method incase they want to auth somehwere else.
        if(!_canLoadAndNavigateAfterAuth){
            
            DBRestClient* newClient = [self produceRestClient];
            
            DBQueryWrapper* newQueryWrapper = [self wrapRestClient:newClient withStoredReduceStackToPath:nil andTypeOfQuery:DBLOADMETADATAENVOYUPLOADS andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToDB:YES cameFromAuth:NO andMovedFromDB:NO andSelectedFiles:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]]];
            
            //the goal of all the code up to the point of sending a delegate message to
            //the homeview controller on the dbservicemanagerdelegate is to avoid having to
            //reload the collectionview on the original screen/screens from which the files are uploaded.
            
            //could actually do w/o this array but want to keep for clarity
            //we could just keep the unique paths as dictionary keys.
            NSMutableArray* uniqueParentPaths = [[NSMutableArray alloc] init];
            NSMutableDictionary* dictionaryForFilesIndexedByParentPaths = [[NSMutableDictionary alloc] init];
            
            //sets the unique parent paths in an array and creates a dictionary
            for(File* selectedFile in [[NSMutableArray alloc]initWithArray:[[self fsAbstraction] selectedFiles]]){
                if(![uniqueParentPaths containsObject:selectedFile.parentURLPath]){
                    
                    [uniqueParentPaths addObject:selectedFile.parentURLPath];
                    
                    NSMutableArray* fileArrayForDictionary;
                    
                    //if there are no files currently indexed to this parent then make the array and set i
                    if(![dictionaryForFilesIndexedByParentPaths objectForKey:selectedFile.parentURLPath]){
                        fileArrayForDictionary = [[NSMutableArray alloc] init];
                        [fileArrayForDictionary addObject:selectedFile];
                        [dictionaryForFilesIndexedByParentPaths setObject:fileArrayForDictionary forKey:selectedFile.parentURLPath];
                    //if there are files currently indexed to this parent then add the file to the array alrady there
                    //andput it back into the dictionary.
                    } else {
                        fileArrayForDictionary = [dictionaryForFilesIndexedByParentPaths objectForKey:selectedFile.parentURLPath];
                        [fileArrayForDictionary addObject:selectedFile];
                    }
                }
            }
            
            //loop through the parent file paths and populate
            for(NSString* uniqueParentPath in uniqueParentPaths){
                
                // basically build a dummy model of where the files are to preoperly grab the index path for that file loading object.
                NSMutableArray* foldersArray = [[NSMutableArray alloc] init];
                NSMutableArray* nonFoldersArray = [[NSMutableArray alloc] init];
                
                //populate dummy current directory
                NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
                [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy  inDirectoryPath:uniqueParentPath];
                
                for(File* file in currentDirProxy){
                    if(file.isDirectory){
                        [foldersArray addObject:file];
                    }else{
                        [nonFoldersArray addObject:file];
                    }
                }
                
                //sort the arrays
                foldersArray = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:foldersArray] copyItems:YES];
                nonFoldersArray = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:nonFoldersArray] copyItems:YES];
                
                //get the selected children array for each unique thing.
                NSArray* arrayOfSelectedChildren = [dictionaryForFilesIndexedByParentPaths objectForKey:uniqueParentPath];
                
                //get the index path for each child and change the image inside it
                for(File* selectedChild in arrayOfSelectedChildren){
                    NSIndexPath* indexPathForFile = [NSIndexPath indexPathForRow:([nonFoldersArray indexOfObject:selectedChild]+[foldersArray count]) inSection:0];
                    //needs to be delegate based because this class (DBServiceManager) doesn't know that homecollectionview exists.
                    //if we're looking at the parent directory right now then reset the index paths inside it.
                    if([[[self fsAbstraction] reduceStackToPath] isEqualToString:selectedChild.parentURLPath]){
                        [_dbServiceManagerDelegate dbUnselectHomeCollectionViewCellAtIndexPath:indexPathForFile];
                    }
                }
            }
            
            //clear global selected files array
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        
            //DO NOT FORGET TO ADD TO THE GLOBAL ARRAY
            //OR ELSE NON OF THE QUERIES WILL WORK
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self dbQueryWrapperHolder] addObject:newQueryWrapper];
            });
            [newQueryWrapper incrementCustomRequestCount];
            [[newQueryWrapper getRestClient] loadMetadata:@"/Envoy Uploads" atRev:nil];
        }
    }
}

//process the metadata from

-(void) processMetaDataFromCheckForAndCreateEnvoyUploadsFolder:(DBQueryWrapper*)eachQueryWrapper withMetaData:(DBMetadata*)metadata withError:(NSError*)error {
    
    //create the folder if it doesn't exist. Do nothing if it does exist (should be an error message in metadata?)
    //send a notification back to the home collection view to initiate the upload.
    if((error != nil) && (error.code == 404)){//folder does NOT exist and must be created
        [eachQueryWrapper incrementCustomRequestCount];
        [[eachQueryWrapper getRestClient] createFolder:@"/Envoy Uploads"];
    }else if ((metadata != nil) &&  metadata.isDeleted){//folder exists but is in a deleted state
        [eachQueryWrapper incrementCustomRequestCount];
        [[eachQueryWrapper getRestClient] createFolder:@"/Envoy Uploads"];
    }else {//folder exists in a normal state and we can start the upload
        [self startUploadAfterCreatingEnvoyUploadsFolderWithMetaData:metadata andOriginallySelectedFiles:[eachQueryWrapper getOriginallySelectedFiles] withError:error];
    }
}

//triggred after the EnvoyUploads folder is created.

-(void) startUploadAfterCreatingEnvoyUploadsFolderWithMetaData:(DBMetadata*)metadata andOriginallySelectedFiles:(NSMutableArray*)originallySelectedFiles withError:(NSError*)error {
    if(!error){
        //need to check for path vaildity because this method gets
        //called when the directory probably doesn't exist yet locally(on app launch)
        //and after it does exist locally (after navigation to dropbox)
        if(![[self fsInterface] isValidPath:[@"/Dropbox" stringByAppendingPathComponent:@"Envoy Uploads"]]){
            File* newFile = [[File alloc] initWithName:@"Envoy Uploads" andPath:[@"/Dropbox" stringByAppendingPathComponent:@"Envoy Uploads"] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
            [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
            [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
        }
        [_dbServiceManagerDelegate uploadAfterCreatingUploadFolderDBWithOriginallySelectedFiles:originallySelectedFiles];
    }else{
        NSLog(@"FAILED TO MAKE ENVOYUPLOADS FOLDER!");
//        Put an alert here for a failed operation!
    }
}

// add an empty entry for each path that we want a shareable
// link for
-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify {
    
    [[self dictionaryWithShareableLinks] removeAllObjects];
    
    //first set the dictionary keys
    for (File* fileToGetLinkFor in filesToLinkify) {
        
        LinkJM *linkObject = [[LinkJM alloc] init];
        linkObject.url = @"";
        linkObject.fileName = fileToGetLinkFor.name;
        linkObject.type = [LinkJM LINK_TYPE_DROPBOX];
        
        //if a key doesn't already exist we add it, don't want to replace keys
        //if the user selects another file much later.
//        if ([[self dictionaryWithShareableLinks] objectForKey:fileToGetLinkFor.path] == nil) {
            [[self dictionaryWithShareableLinks] setObject:linkObject forKey:fileToGetLinkFor.path];
//        }
    }
    //next get the shareable links for all the files.
    //these need to be in separate loops to ensure all keys
    //will eb in the dictionary when the link production finishes
    //it's an async process
    for (File* fileToGetLinkFor in filesToLinkify) {
        [self produceShareableLinkForFile:fileToGetLinkFor.path];
    }
}

//call to the class to produce a link
-(void) produceShareableLinkForFile:(NSString*)filePathToLinkify {
    //need the rest client on a global var or else the delegate reference to self deallocates
    [[self restClientForLoadingLink] loadSharableLinkForFile:[[self fsInterface] resolveFilePath:filePathToLinkify excludingUpToDirectory:@"Dropbox"]];
}

// method that removes all rest clients that have 0
// outstanding requests from the array. removes
// inactive rest clients and their wrappers from memory

-(void) checkForAndPurgeInactiveClients {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableIndexSet* wrappedClientsToRemove = [[NSMutableIndexSet alloc] init];
        for(DBQueryWrapper* wrappedClient in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]){
            //if the cutsom request count (affected by both active servicetickets and fetchers
            //for each service ticket or fetcher fetching is doign stuff
            //then do nothing. If it's 0 (all fetchers/servicetickets inactive)
            //then add that wrappedClient to be removed.
            if ([wrappedClient getCustomRequestCount] == 0) {
                [wrappedClientsToRemove addIndex:[[self dbQueryWrapperHolder] indexOfObject:wrappedClient]];
            }
        }
        [[self dbQueryWrapperHolder] removeObjectsAtIndexes:wrappedClientsToRemove];
    });
}

#pragma mark - Functionality methods

/*  - This method basically reduces a url path from the front (excluding the path to the current directory
    - where we are currently located (as returned by pushDirectoryOnToStack). Basically it takes the full
    - potential path to a folder from dropbox and subsequently checks whether a cut off path exists
    - the idea is to always be able to move subdirectories into the new folder.
    - takes /Blah/blah/blah/Documents/Anaphora/Subfile/ - >checks the validity of this path.
    - turns it into /Blah/blah/blah/Documents/Subfile/ - >checks the validity
    - turns the path to save into /Blah/blah/blah/Documents/ + filename if non of the parents of the
    - child directory are present.
    -*/

// should this just be in teh Filesystem Interface?

-(NSString*) urlPathMiddleOut:(NSString*)pathToMiddleOut onQueryWrapper:(DBQueryWrapper*)passedQueryWrapper{
    
    NSString *finalPath = @"";
    NSInteger firstSlash = -1;
    NSInteger finalSlash = -1;
    
    //get the first slash.
    NSRange firstRange = [[passedQueryWrapper getStoredReduceStackToPath] rangeOfString:@"/"];
    NSString* firstString = [[passedQueryWrapper getStoredReduceStackToPath] substringFromIndex:firstRange.location];
    
    if([pathToMiddleOut rangeOfString:firstString].length > 0){
        NSRange range = [pathToMiddleOut rangeOfString:firstString];
        firstSlash = range.location+firstString.length;
    }
    
    for (NSInteger index=firstSlash+1; index<pathToMiddleOut.length;index++){
        if(([pathToMiddleOut characterAtIndex:index] == '/')){
            finalSlash = index;
            break;
        }
    }
    
    if (finalSlash != -1){//final slash doesn't exist because we only have one file component path left (and the end slash is missing)
        finalPath = [[finalPath stringByAppendingString:[pathToMiddleOut substringToIndex:firstSlash]] stringByAppendingString:[pathToMiddleOut substringFromIndex:finalSlash]];
    }else{
        finalPath = [pathToMiddleOut stringByDeletingLastPathComponent];
    }
    return finalPath;
}

#pragma mark DBOperationQueue for queueing API requests.

// this is effectively an ENQUEUE operation
//quques up an operation on a global queue
//waiting to be executed.

-(void) queueDBOperationOnGlobalRequestQueue:(DBOperationWrapper*) queryOperationToEnqueue {
    [[self dbOperationWrapperHolder] addObject:queryOperationToEnqueue];
}

//this oepration dequeues until we meet our global max or have dequeued everything

-(void) dequeueDBOperationsUpToGlobalMax {
    
    NSMutableIndexSet* dbOperationWrappersToRemove = [[NSMutableIndexSet alloc] init];
    for (int opWrapperIndex=0; opWrapperIndex < [[self dbOperationWrapperHolder] count]; opWrapperIndex++) {
        if(![self globalActiveRequestsMaxedOut]) {
            DBOperationWrapper* operationWrapper = [[self dbOperationWrapperHolder] objectAtIndex:opWrapperIndex];
            [dbOperationWrappersToRemove addIndex:opWrapperIndex];
            [self executeQueryFromDBOperationWrapper:operationWrapper];
        }
    }
    [[self dbOperationWrapperHolder] removeObjectsAtIndexes:dbOperationWrappersToRemove];
}

// this is effectively a DEQUEUE operation.

-(DBOperationWrapper*) dequeueDBOperationOnGlobalRequestQueue {
    DBOperationWrapper* operationWrapper = [[self dbOperationWrapperHolder] firstObject];
    [[self dbOperationWrapperHolder] removeObjectAtIndex:0];
    return operationWrapper;
}

-(void) executeQueryFromDBOperationWrapper:(DBOperationWrapper*) queryOperationToDequeue  {
    
    switch ([queryOperationToDequeue getTypeOfQuery]) {
        
        //empty cases are there but don't do anything.
        //still testing whether or not we want
        //small queries that are not download/upload
        //oprations to be on this thing.
        case DBLOADFILE:
            _globalActiveRequestCount++;
            //DO NOT ENCODE THE "loadFile" path input here. dropbox won't find encoded names on dropbox
            [[queryOperationToDequeue getRestClient] loadFile:[[self fsInterface] resolveFilePath:[queryOperationToDequeue getPath1] excludingUpToDirectory:@"Documents"] intoPath:[[[queryOperationToDequeue getPath2] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            break;
        case DBUPLOADFILE:
            _globalActiveRequestCount++;
            //DO NOT encode teh "toPath" path input here, dropbox will not find the right path to upload to on dropbox
            [[queryOperationToDequeue getRestClient] uploadFile:[queryOperationToDequeue getFilename] toPath:[[self fsInterface] resolveFilePath:[queryOperationToDequeue getPath1] excludingUpToDirectory:@"Documents"] withParentRev:nil fromPath:[[[queryOperationToDequeue getPath2] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            break;
        default:
            break;
    }
}

//the logic here is that if the path passed to this thing matches
//either path1 or path2 of a Operation Wrapper, this is actually a
//cool strategy. 1. create a copy of the array. 2. iterate through
//and store index paths, 3. remove index paths.
//you can't get an error of iterating while editing somewhere else
//and you can't remove something that's not there becuase removing
//via index set only removes indicies that are there.

-(void) destroyDBOperationsWithFilePaths:(NSArray*)arrayOfFileLoadingObjects{
    
    NSMutableIndexSet* indiciesToRemove = [[NSMutableIndexSet alloc] init];
    NSArray* arrayCopy = [[NSMutableArray alloc] initWithArray:[self dbOperationWrapperHolder]];
    
    for (int opWrapperIndex=0; opWrapperIndex < [arrayCopy count]; opWrapperIndex++){
        for (FileLoadingObject* fileLoadingObject in arrayOfFileLoadingObjects){
            NSString* filePath = fileLoadingObject.file.path;
            if ([filePath isEqualToString:[arrayCopy[opWrapperIndex] getPath1]] || [filePath isEqualToString:[arrayCopy[opWrapperIndex] getPath2]]){
                [indiciesToRemove addIndex:opWrapperIndex];
                
            }
        }
    }
    
    //do not decrement the _globalActiveRequestCount because these are things
    //removed from a queue. they are not active requests.
    [[self dbOperationWrapperHolder] removeObjectsAtIndexes:indiciesToRemove];
}

//checks our global queue to see how many things
//are in it, if there's, picked 4 because
//after some basic tests, that seemd like
//as much as we could get going at once.
//statistical analysis needed to determine
//the actual number.

-(BOOL) globalActiveRequestsMaxedOut {
    
    return _globalActiveRequestCount > 4;
}

// finds a query limit wrapper object and increases teh number of tries for that
// particular query

-(void) incrementNumberOfFailedQueriesWithPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery{
    for (DBQueryLimitWrapper* queryWrapper in [self dbQueryOccurrenceLimitHolder]) {
        if ([queryWrapper.path1 isEqualToString:path1] && [queryWrapper.path2 isEqualToString:path2] && (queryWrapper.typeOfQuery == typeOfQuery)){
            queryWrapper.numberOfTimesQueried++;
        }
    }
}

// these checks are done GLOBALLY and not on individual querywrappers
// because we want to limit a particular query and not oen instance of
// it these return YES if we are over or at the limit and NO if we have
// room to try the query again.

-(BOOL) overQueryOccurrenceLimitForQueryWithPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery{

    for (DBQueryLimitWrapper* queryWrapper in [self dbQueryOccurrenceLimitHolder]){

        if ([queryWrapper.path1 isEqualToString:path1] && [queryWrapper.path2 isEqualToString:path2] && (queryWrapper.typeOfQuery == typeOfQuery)){
            if (queryWrapper.numberOfTimesQueried >= GLOBALQUERYATTEMPTLIMIT) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;
}

-(void) addObjectToQueryLimitQueueIfNotExists:(DBQueryLimitWrapper*)queryLimitToAdd {
    BOOL limitObjectAlreadyExists = NO;
    for (DBQueryLimitWrapper* queryWrapper in [self dbQueryOccurrenceLimitHolder]){
        if ([queryWrapper.path1 isEqualToString:queryLimitToAdd.path1] && [queryWrapper.path2 isEqualToString:queryLimitToAdd.path2] && (queryWrapper.typeOfQuery == queryLimitToAdd.typeOfQuery)){
            limitObjectAlreadyExists = YES;
        }
    }
    if (!limitObjectAlreadyExists) {
        [[self dbQueryOccurrenceLimitHolder] addObject:queryLimitToAdd];
    }
}

-(void) destroyObjectFromQueryLimitQueueWithPath1:(NSString*) path1 andPath2:(NSString*) path2 andTypeOfQuery:(int)typeOfQuery {
    NSMutableIndexSet* indiciesToRemove = [[NSMutableIndexSet alloc] init];
    for (DBQueryLimitWrapper* queryWrapper in [self dbQueryOccurrenceLimitHolder]) {
        
        if ([queryWrapper.path1 isEqualToString:path1] && [queryWrapper.path2 isEqualToString:path2] && (queryWrapper.typeOfQuery == typeOfQuery)){
            [indiciesToRemove addIndex:[[self dbQueryOccurrenceLimitHolder] indexOfObject:queryWrapper ]];
        }
    }
    [[self dbQueryOccurrenceLimitHolder] removeObjectsAtIndexes:indiciesToRemove];
}

@end
