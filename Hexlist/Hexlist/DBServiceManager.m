//
//  APIServiceManager.m
//  Hexlist
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//  This class manages our apps relationship to various APIs
//  Dropbox, Google Drive, Box are the three we're starting with
//  For example when you move from Google Drive to Box, this manager
//  will recognize that and make calls to those APIs to add a file to Box
//  and delete it from Google Drive

#import "DBServiceManager.h"
#import <DropboxSDK/DropboxSDK.h>

// type of query that we will
// use to check against the
// typeOfQuery field in the
// DBQueryWrapper class

static int const DBLOADMETADATANORMAL = 1;
static int const DBLOADSHAREABLELINK = 2;

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
    _dbQueryWrapperQueue = dispatch_queue_create("dbQueryWrapperQueue", DISPATCH_QUEUE_SERIAL);

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

-(NSMutableArray*) dbQueryWrapperHolder {
    if(!_dbQueryWrapperHolder){
        _dbQueryWrapperHolder = [[NSMutableArray alloc] init];
    }
    return _dbQueryWrapperHolder;
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
    DBRestClient* restClientToReturn = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClientToReturn.delegate = self;
    return restClientToReturn;
}

-(DBQueryWrapper*) wrapRestClient:(DBRestClient*)restClient andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile{
    DBQueryWrapper* queryWrapper = [[DBQueryWrapper alloc] initWithRestClient:restClient andTypeOfQuery:typeOfQuery andUUIDString:uuidString andPassedFile:passedFile];
    return queryWrapper;
}


#pragma mark SharedServiceManager methods

-(BOOL) isAuthorized {
    return [[DBSession sharedSession] isLinked];
}

-(void) unlinkService {
    [[DBSession sharedSession] unlinkAll];
}

#pragma mark cancel methods

-(void)cancelNavigationLoad{
    //cancel requests on just the rest client
    //for navigation.
    [[self restClientForNavigation] cancelAllRequests];
    _canLoadAndNavigateAfterAuth = NO;
}

-(void)cancelNavigationLoadFromBackPress{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
    [[self restClientForNavigation] cancelAllRequests];
    _canLoadAndNavigateAfterAuth = NO;
}

#pragma mark - Dropbox Authentication

// the user had cancelled their registration
// a notification gats posted from the app
// delegate triggers this method when the
// user cancels their dropbox registration
// process, this posts a notification to teh
// homeview controller.
-(void) dropboxRegistrationCancelled{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterDropboxCancel" object:self];
}

/*  - takes a cocntroller as an input and links the user's account
 - from that controller? This is the second step in DB tutorial
 - for the sync API
 - */

-(void) pressedDropboxFolder:(UIViewController*)passedController withFile:(File*)passedFile {
    _canLoadAndNavigateAfterAuth = YES;
    _passedFileForAuth = passedFile;
    //if we're not linked we trigger the openURL in the app delegate
    //will trigger getDropboxRootForAuth eventuallly if user auths right.
    if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:passedController];
    }else{
        // if we're authed jsut get the
        [self getFileInfoFromDropboxPath:[passedFile.displayPath substringFromIndex:8] withPressedFile:passedFile];
    }
}

// just for loading in the view the first time we get
// authenticated, triggered by a notification

-(void) getDropboxRootForAuth {
    if(_canLoadAndNavigateAfterAuth){
        //wrap the navigation load in a wrapper with a flag saying this client is gonna LOAD views
        DBQueryWrapper* navigationWrapper = [self wrapRestClient:[self restClientForNavigation] andTypeOfQuery:DBLOADMETADATANORMAL andUUIDString:[[NSUUID UUID] UUIDString] andPassedFile:_passedFileForAuth];
        //increment request count.
        [navigationWrapper incrementCustomRequestCount];
        dispatch_sync(_dbQueryWrapperQueue, ^{
            //add to array
            [[self dbQueryWrapperHolder] addObject:navigationWrapper];
            //fire off the request
            [[navigationWrapper getRestClient] loadMetadata:@"/" atRev:nil];
        });
    }
}

#pragma mark - Metadata Retrieval Methods

/*  - gets the files we want for the particular directory we just entered
    - doesn't download files, just downloads their meta data
    - */

// encode a url in swift
// http://stackoverflow.com/questions/24879659/how-to-encode-a-url-in-swift

-(void) getFileInfoFromDropboxPath:(NSString*)pathOnDropbox withPressedFile:(File*)passedFile {
    
    //search for a navigation client wrapper if it alrady exists
    //if it exists take the old one and edit the passed in file
    //and other things to match the new request, and use that old
    //wrapper. The alternative to this was putting break; statements
    //in the loadedetadata loop through the _dbQueryWrapperHolder
    //array and that caused problems because we couldn't be
    //sure we were getting the right query wrapper(or we could but it will break if we change our app).
    dispatch_sync(_dbQueryWrapperQueue, ^{
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
            [oldQueryWrapper incrementCustomRequestCount];
            //calls to loadmetadata with % characters in the thing do not appear to work.
            [[oldQueryWrapper getRestClient] loadMetadata:[@"/" stringByAppendingPathComponent:pathOnDropbox] atRev:nil];
        }else{
            navigationWrapper = [self wrapRestClient:[self restClientForNavigation] andTypeOfQuery:DBLOADMETADATANORMAL andUUIDString:[[NSUUID UUID] UUIDString] andPassedFile:passedFile];
            [navigationWrapper incrementCustomRequestCount];
            [[self dbQueryWrapperHolder] addObject:navigationWrapper];
            //calls to loadmetadata with % characters in the thing do not appear to work.
            [[navigationWrapper getRestClient] loadMetadata:[@"/" stringByAppendingPathComponent:pathOnDropbox] atRev:nil];
        }
    });
}

#pragma mark - DBRestClientDelegate (the ones we actually use)

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    dispatch_sync(_dbQueryWrapperQueue, ^{
        
        NSMutableIndexSet* wrappedClientsToRemove = [[NSMutableIndexSet alloc] init];
        NSArray* staticQueryWrappers = [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]];
        
        for(DBQueryWrapper* eachQueryWrapper in [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]]){
            //if the metadata query is for a navigation load of sorts
            //we can decrement the request count
            //if the metadata is for a download or upload
            //we cannot decrement the requestcount because if we did
            //in the time between this code and the call to the method
            //our NStimer could go off and purge a query wrapper that we need
            if([[eachQueryWrapper getRestClient] isEqual:client]){
                //before we also had selected file metadata load, left this here in case
                if([eachQueryWrapper getTypeOfQuery] == DBLOADMETADATANORMAL){
                    //this request has finished so decrement custom
                    // request count
                    [eachQueryWrapper decrementCustomRequestCount];
                    //send the metadata to be processed.
                    [self navigationLoadWithClient:eachQueryWrapper loadedMetadata:metadata];
                    [wrappedClientsToRemove addIndex:[staticQueryWrappers indexOfObject:eachQueryWrapper]];
                }
            }
        }
        //get rid of requests attached to this failed thing.
        [[self dbQueryWrapperHolder] removeObjectsAtIndexes:wrappedClientsToRemove];
    });
}

/*https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/constant_group/URL_Loading_System_Error_Codes
 that url has the error codes for timeouts, etc*/
// implemented api errors that we can get.
// from here : https://www.dropbox.com/developers-v1/core/docs

- (void)restClient:(DBRestClient *)restClient loadMetadataFailedWithError:(NSError*)error{
    
//    //NSLog(@"LOADED METADATA FAILED %ld", (long)error.code);
//    //NSLog(@"localized description %@", [error localizedDescription]);
    
    dispatch_sync(_dbQueryWrapperQueue, ^{
        
        NSMutableIndexSet* wrappedClientsToRemove = [[NSMutableIndexSet alloc] init];
        NSArray* staticQueryWrappers = [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]];
        
        for(DBQueryWrapper* eachQueryWrapper in staticQueryWrappers){
             if([[eachQueryWrapper getRestClient] isEqual:restClient]){
                 //if there's a 401 code then unlink the session
                 //and re-authenticate the user from the app delegate
                 if(error){
                     if (error.code == 401) {
                         [[DBSession sharedSession] unlinkAll];
                         [[DBSession sharedSession] linkFromController:(UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController]];
                     } else if (error.code == 403) { // forbidden , no permission error
                         [_dbServiceManagerDelegate alertUserToInsufficientPermission:[eachQueryWrapper getPassedFile]];
                     } else if (error.code == 404) { //file not found error
                         [_dbServiceManagerDelegate alertUserToFileNotFound:[eachQueryWrapper getPassedFile]];
                     } else if (error.code == 429) { // rate limit error
                         [_dbServiceManagerDelegate alertUserToRateLimitFromService:[eachQueryWrapper getPassedFile].serviceType];
                     } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) { // timeout error
                         [_dbServiceManagerDelegate alerUserToCouldntReachService:[eachQueryWrapper getPassedFile].serviceType];
                     } else { //if there is some other unspecified error
                         [_dbServiceManagerDelegate alertUserToUnspecifiedErrorOnService:[eachQueryWrapper getPassedFile].serviceType];
                     }
                     [self cancelNavigationLoad];
                     //this will crash if we don't make a separate nsarray, because
                     //a purge could happen right before and cause the global array to crap out.
                    [wrappedClientsToRemove addIndex:[staticQueryWrappers indexOfObject:eachQueryWrapper]];
                 }
             }
        }
        //get rid of requests attached to this failed thing.
        [[self dbQueryWrapperHolder] removeObjectsAtIndexes:wrappedClientsToRemove];
    });
}

//delegate reponse to grab a link
- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path {

    dispatch_sync(_dbQueryWrapperQueue, ^{
        
        NSMutableIndexSet* wrappedClientsToRemove = [[NSMutableIndexSet alloc] init];
        NSArray* staticQueryWrappers = [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]];
        
        for(DBQueryWrapper* eachQueryWrapper in staticQueryWrappers){
            //if the metadata query is for a navigation load of sorts
            //we can decrement the request count
            //if the metadata is for a download or upload
            //we cannot decrement the requestcount because if we did
            //in the time between this code and the call to the method
            //our NStimer could go off and purge a query wrapper that we need
            if([[eachQueryWrapper getRestClient] isEqual:restClient]){
                if (link == nil) {
                    //if the lin request has not already failed, send delegate
                    if (![eachQueryWrapper getLinkRequestAlreadyFailed]) {
                        [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was a problem generating your links." withLinkGenerationUUID:[eachQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                    } else {
                        [eachQueryWrapper setLinkRequestAlreadyFailed];
                    }
                } else {
                    LinkJM *linkObject = (LinkJM*)[eachQueryWrapper getObjectforKeyInDropboxLinkToDropboxPathMap:path];
                    if ([linkObject.url isEqualToString:@""]) {
                        linkObject.url = link;
                    }
                    int emptyCount = 0;
                    for (NSString* key in eachQueryWrapper.dropboxLinkToDropboxPathMap) {
                        LinkJM *linkObject = (LinkJM*)[eachQueryWrapper getObjectforKeyInDropboxLinkToDropboxPathMap:key];
                        if ([linkObject.url isEqualToString:@""]) {
                            emptyCount++;
                        }
                    }
                    //if none of the things we want links for are missing
                    //we have all our our links the user requested, send
                    //them back. Else continue to wait for next link.
                    if (emptyCount == 0) {
                        //return a dictionary into the homeview
                        //needs to be on the main queue async
                         dispatch_async(dispatch_get_main_queue(), ^{
                             //reorder the links to match the original array.
                             //the reason this works is because the dictionary
                             //which has the original index numbers as its keys
                             //will have them sorted automatically... 0 , 1, 2 etc.
                            NSMutableArray* orderedReturnArray = [[NSMutableArray alloc] init];
                            // do not do for in over the keys in teh dictionary need count
                            int dictcount = (int)[[eachQueryWrapper.idToOriginalIndexPosition allKeys] count];
                            for (int i = 0; i < dictcount; i++) {
                                 [orderedReturnArray addObject:[eachQueryWrapper getObjectforKeyInDropboxLinkToDropboxPathMap:[eachQueryWrapper getValueforKeyInIdToOriginalIndexPosition:[NSString stringWithFormat:@"%d",i]]]];
                            }
                            [_retrieveLinksFromServiceManagerDelegate finishedPreparingLinks:orderedReturnArray withLinkGenerationUUID:[eachQueryWrapper getUUID]];
                         });
                        [wrappedClientsToRemove addIndex:[staticQueryWrappers indexOfObject:eachQueryWrapper]];
                    } 
                }
                [eachQueryWrapper decrementCustomRequestCount];
            }
        }
        //get rid of requests attached to this failed thing.
        [[self dbQueryWrapperHolder] removeObjectsAtIndexes:wrappedClientsToRemove];
    });
}

//delegate response to grab a link


- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error {
    dispatch_sync(_dbQueryWrapperQueue, ^{
        
        NSMutableIndexSet* wrappedClientsToRemove = [NSMutableIndexSet new];
        NSArray* staticQueryWrappers = [[NSArray alloc] initWithArray:[self dbQueryWrapperHolder]];
        
        for(DBQueryWrapper* eachQueryWrapper in staticQueryWrappers){
            //if the metadata query is for a navigation load of sorts
            //we can decrement the request count
            //if the metadata is for a download or upload
            //we cannot decrement the requestcount because if we did
            //in the time between this code and the call to the method
            //our NStimer could go off and purge a query wrapper that we need
            if([[eachQueryWrapper getRestClient] isEqual:restClient]){
                //NSLog(@"parent %@", [eachQueryWrapper getPassedFile].displayName);

                if (error.code == 401) {
                    if (![eachQueryWrapper getLinkRequestAlreadyFailed]) {
                        [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"You gotta re-log in to Dropbox!"] withLinkGenerationUUID:[eachQueryWrapper getUUID]];
                        //if it has not already failed then set the failure mechanism
                    }
                }
                // currently we DO NOT retry to get a link on error we just send a message
                // saying that link retrieval has failed, no point really this is virtually instant
                else if (error.code == 404) {
                    if (![eachQueryWrapper getLinkRequestAlreadyFailed]) {
                        [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"The file at '%@' no longer exists.", [error.userInfo objectForKey:@"path"]] withLinkGenerationUUID:[eachQueryWrapper getUUID]];
                        //if it has not already failed then set the failure mechanism
                    }
                } else if (error.code == 429) {
                    if (![eachQueryWrapper getLinkRequestAlreadyFailed]) {
                        [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"You are being rate limited by Dropbox."] withLinkGenerationUUID:[eachQueryWrapper getUUID]];
                    }
                } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
                    if (![eachQueryWrapper getLinkRequestAlreadyFailed]) {
                        [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was a problem generating your links." withLinkGenerationUUID:[eachQueryWrapper getUUID]];
                        //if it has not already failed then set the failure mechanism
                    }
                    //if there is some other unspecified error
                } else {
                    if (![eachQueryWrapper getLinkRequestAlreadyFailed]) {
                        [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was a problem generating your links from Dropbox" withLinkGenerationUUID:[eachQueryWrapper getUUID]];
                        //if it has not already failed then set the failure mechanism
                    }
                }
                if (![eachQueryWrapper getLinkRequestAlreadyFailed]) {
                    [eachQueryWrapper setLinkRequestAlreadyFailed];
                }
                [wrappedClientsToRemove addIndex:[staticQueryWrappers indexOfObject:eachQueryWrapper]];
            }
        }

        // DO NOT FOR THE LOVE OF DEUS VULT take this update
        // off of the async main queue. it will not work otherwise
        // there's something deeply wrong with this delegate method.
        //get rid of requests attached to this failed thing.
         dispatch_async(dispatch_get_main_queue(), ^{
             [[self dbQueryWrapperHolder] removeObjectsAtIndexes:wrappedClientsToRemove];
         });
    });
}

// - END REST CLIENT DELEGATES - //

#pragma mark - Methods for Navigation Load, Download, and Upload

-(void) navigationLoadWithClient:(DBQueryWrapper *)passedQueryWrapper loadedMetadata:(DBMetadata *)metadata{
    //if our metadata query says it's a directory
    if (metadata.isDirectory){
        NSMutableArray* filesForBatchWrite = [[NSMutableArray alloc] init];
        NSString* newFileParentPath = @"";
        //if the requested metadata is a directory (the thing the user pressed)
        for (DBMetadata *file in metadata.contents) {
            
            NSString* newFileUUID = [[NSUUID UUID] UUIDString];
            NSString* newFileUUIDName = newFileUUID;
            if (!file.isDirectory){
                newFileUUIDName = [newFileUUID stringByAppendingPathExtension:[file.filename pathExtension]];
            }
            
            newFileParentPath = [passedQueryWrapper getPassedFile].codedPath;
            
            File* newFile = [[File alloc] init];
            newFile.serviceType = [AppConstants serviceTypeForString:@"Dropbox"];
            newFile.displayName = file.filename;
            newFile.displayPath = [@"/Dropbox" stringByAppendingPathComponent:file.path];
            newFile.codedName = newFileUUIDName;
            newFile.codedPath = [newFileParentPath stringByAppendingPathComponent:newFileUUIDName];
            newFile.parentFile = [passedQueryWrapper getPassedFile];
            newFile.isDirectory = file.isDirectory;
            newFile.dateCreated = [NSDate date];
            newFile.idOnService = @"-1";// when upgrade to swift change to metadata.fileID
            
            [filesForBatchWrite addObject:newFile];
        }
        [[self fsInterface] saveBatchOfFilesToFileSystemRealm:filesForBatchWrite forParentDirectory:[passedQueryWrapper getPassedFile]];
        //if this is the root dropbox directory, actually does this trigger ever? I think just for getting metadata on one file.
    }else{
        NSString* newFileUUID = [[NSUUID UUID] UUIDString];
        NSString* newFileUUIDName  = newFileUUID;
        NSString* newFileParentPath = [passedQueryWrapper getPassedFile].codedPath;
        
        if (!metadata.isDirectory){
            newFileUUIDName = [newFileUUID stringByAppendingPathExtension:[metadata.filename pathExtension]];
        }
        
        File* newFile = [[File alloc] init];
        newFile.serviceType = [AppConstants serviceTypeForString:@"Dropbox"];
        newFile.displayName = metadata.filename;
        newFile.displayPath = [@"/Dropbox" stringByAppendingPathComponent:metadata.path];
        newFile.codedName = newFileUUIDName;
        newFile.codedPath = [newFileParentPath stringByAppendingPathComponent:newFileUUIDName];
        newFile.parentFile = [passedQueryWrapper getPassedFile];
        newFile.isDirectory = metadata.isDirectory;
        newFile.dateCreated = [NSDate date];
        newFile.idOnService = @"-1"; // when upgrade to swift change to metadata.fileID
        [[self fsInterface] saveSingleFileToFileSystemRealm:newFile forParentDirectory:[passedQueryWrapper getPassedFile]];
    }
    
    // push the file we're navigating into
    // popualte the current directory and resolve any selected files.
    // only do this if the boolean is set to true
    // we added this boolean because sometimes we load this data into
    // selectedfiles view and we don't want to reload anything on the main
    // collection view while we're in the selected files view.
    [[self fsAbstraction] pushOntoPathStack:[passedQueryWrapper getPassedFile]];
    
    //populate the current directory
    [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:[passedQueryWrapper getPassedFile]];
    
    // send a notification to update the toolbar oncewe've pushed.
    if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[AppConstants rootPathStringIdentifier]]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
        
    } else if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[AppConstants presentableStringForServiceType:ServiceTypeDropbox]]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
        
    } else if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[AppConstants presentableStringForServiceType:ServiceTypeBox]]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
        
    } else if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[AppConstants presentableStringForServiceType:ServiceTypeGoogleDrive]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
}

// add an empty entry for each path that we want a shareable
// link for
-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify andParentFile:(File*)parentFile andUUID:(NSString*)uuidString {
    
    //NSLog(@"passsed parent %@", parentFile);
    //none of these matter except client, I need a wrapper for just the client and the path it's linking...
    DBQueryWrapper* wrapper = [self wrapRestClient:[self produceRestClient] andTypeOfQuery:DBLOADSHAREABLELINK andUUIDString:uuidString andPassedFile:nil];
    
    //storing int values in dictionary as nsnumber http://stackoverflow.com/questions/1705069/storing-ints-in-a-dictionary
    // add all the queries to the query wrapper.
    // http://stackoverflow.com/questions/1372715/how-can-i-convert-an-int-to-an-nsstring
    for (File* fileToGetLinkFor in filesToLinkify) {
        LinkJM *linkObject = [LinkJM createLinkJMWithURL:@""
                                      AndLinkDescription:fileToGetLinkFor.displayName
                                              AndService:[AppConstants stringForServiceType:ServiceTypeDropbox]];
        //set the link object in the local dict.
        [wrapper setObject:linkObject forKeyInDropboxLinkToDropboxPathMap:[fileToGetLinkFor.displayPath substringFromIndex:8]];
        [wrapper setValue:[fileToGetLinkFor.displayPath substringFromIndex:8] forKeyInIdToOriginalIndexPosition:[[NSNumber numberWithInteger:[filesToLinkify indexOfObject:fileToGetLinkFor]]stringValue]];
        [wrapper incrementCustomRequestCount];
    }
    
    //add the aquery wrapper to the global holder array.
    dispatch_sync(_dbQueryWrapperQueue, ^{
        [[self dbQueryWrapperHolder] addObject:wrapper];
    });
    
    //actually fire off each request
    for (File* fileToGetLinkFor in filesToLinkify) {
        [self produceShareableLinkForFile:fileToGetLinkFor withQueryWrapper:wrapper];
    }
}

//call to the class to produce a link
-(void) produceShareableLinkForFile:(File*)fileToLinkify withQueryWrapper:(DBQueryWrapper*)passedQueryWrapper{
    //need the rest client on a global var or else the delegate reference to self deallocates
    [[passedQueryWrapper getRestClient] loadSharableLinkForFile:[fileToLinkify.displayPath substringFromIndex:8]];
}

@end
