//
//  BXServiceManager.m
//  Hexlist
//
//  Created by Yvan Scher on 1/9/16.
//  Copyright (c) 2016 Yvan Scher. All rights reserved.
// https://github.com/box/box-ios-sdk/tree/master/doc for box documentation on sdk

#import "BXServiceManager.h"
#import "HighlightButton.h"

static int const BXREQUESTQUERY = 0;
static int const BXLOADSHAREABLELINK = 3;

@implementation BXServiceManager

NSString *BOXROOTFOLDER = @"0";

-(id) init {
    
    //notification triggered from the home view controller on a bck button press
    //as we're loading.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelNavigationLoadFromBackPress)
                                                 name:@"boxLoadCancelledByBackButtonPress"
                                               object:nil];
    _bxQueryWrapperQueue = dispatch_queue_create("dbQueryWrapperQueue", DISPATCH_QUEUE_SERIAL);

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

-(NSMutableArray*) bxQueryWrapperHolder {
    if(!_bxQueryWrapperHolder){
        _bxQueryWrapperHolder = [[NSMutableArray alloc] init];
    }
    return _bxQueryWrapperHolder;
}

// store the navigation request object globally so
// just the requests sent out on it can be cancelled.
-(BOXFolderItemsRequest*) requestForNavigation {
    return _navigationRequest;
}

-(void) setRequestForNavigation:(BOXFolderItemsRequest *)boxFolderRequest{
    _navigationRequest = boxFolderRequest;
}

#pragma mark SharedServiceManager methods

-(BOOL) isAuthorized {
    
    BOOL foundUser = NO;
    NSArray* usersInKeyChain = [BOXContentClient users];
    if ([usersInKeyChain count] > 0) {
        foundUser = YES;
    }
    return foundUser;
}

-(void) unlinkService {
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    [contentClient logOut];
}

#pragma mark CancelButtons

-(void) cancelAuthButtonPressed {
    [_passedInController dismissViewControllerAnimated:YES completion:nil];
    _canLoadAndNavigateAfterAuth = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterBoxCancel" object:self];
}

//cancel's the things on whatever request is passed in.
-(void)cancelNavigationLoad{
    //NSLog(@"cancelNavigationLoad");
    [[self requestForNavigation] cancel];
}

-(void)cancelNavigationLoadFromBackPress{
    //NSLog(@"cancelNavigationLoadFromBackPress");
    dispatch_async(_bxQueryWrapperQueue, ^{
        for(BXQueryWrapper* bxQueryWrapper in [self bxQueryWrapperHolder]){
            if ([[bxQueryWrapper getBOXRequest] isEqual:[self requestForNavigation]]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
                [[bxQueryWrapper getBOXRequest] cancel];
                //NSLog(@"cancelling box");
            }
        }
    });
    //don't need to decrement here because the custom request count
    //is for purging query wrappers and this isn't set up on a query
    //wrapper and we don't need to worry about it being purged.
}

-(void) pressedBoxFolder:(UIViewController*)passedController withFile:(File*)passedFile {
    // This will present the necessary UI for a user to authenticate into Box
    _passedInController = passedController;
    _canLoadAndNavigateAfterAuth = YES;
    _passedFileForAuth = passedFile;
    
    BOOL foundUser = NO;
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    
    //find one user and set the content client to it
    //and then break
    NSArray* usersInKeyChain = [BOXContentClient users];
    for (BOXUserMini* miniuser in usersInKeyChain){
        foundUser = YES;
        contentClient = [BOXContentClient clientForUser:miniuser];
        break;
    }
    
    //we found an authed user
    if (foundUser) {
        //do a normal root metadata load
        BOXFolderItemsRequest *folderItemsRequest = [contentClient folderItemsRequestWithID:passedFile.idOnService];
        BXQueryWrapper* boxQueryWrapperForNav = [[BXQueryWrapper alloc] initWithContentClient:contentClient andBOXRequest:folderItemsRequest andTypeOfQuery:BXREQUESTQUERY andUUIDString:[[NSUUID UUID] UUIDString] andPassedFile:passedFile];
        [self setRequestForNavigation:folderItemsRequest];
        dispatch_async(_bxQueryWrapperQueue, ^{
            [[self bxQueryWrapperHolder] addObject:boxQueryWrapperForNav];
        });
        [[boxQueryWrapperForNav getBOXRequest] performRequestWithCompletion:[self getBOXItemsBlockForNavigationWithQueryWrapper:boxQueryWrapperForNav]];
        
    //we didn't find an authed user,
    //first auth and then
    } else {

        void (^userBlockForAuthenticate) (BOXAuthorizationViewController *authorizationViewController, BOXUser *user, NSError *error)  = ^(BOXAuthorizationViewController *authorizationViewController, BOXUser *user, NSError *error)
        {
//            //NSLog(@"beep box user with name %@ authenticated", user.name);
            // BOXUser is returned if authentication was successful.
            // Otherwise, error will contain the reason for failure (e.g. network connection)
            // You should dismiss authorizationViewController here.
            [_passedInController dismissViewControllerAnimated:YES completion:nil];
            
            //do a root metadata load
            BOXFolderItemsRequest *folderItemsRequest = [contentClient folderItemsRequestWithID:passedFile.idOnService];
            BXQueryWrapper* boxQueryWrapperForNav = [[BXQueryWrapper alloc] initWithContentClient:contentClient andBOXRequest:folderItemsRequest andTypeOfQuery:BXREQUESTQUERY andUUIDString:[[NSUUID UUID] UUIDString] andPassedFile:passedFile];
            [self setRequestForNavigation:folderItemsRequest];
            dispatch_async(_bxQueryWrapperQueue, ^{
                [[self bxQueryWrapperHolder] addObject:boxQueryWrapperForNav];
            });
            [[boxQueryWrapperForNav getBOXRequest] performRequestWithCompletion:[self getBOXItemsBlockForNavigationWithQueryWrapper:boxQueryWrapperForNav]];
        };
        
        BOXAuthorizationViewController *boxAuthViewController = [[BOXAuthorizationViewController alloc]
                                                                 initWithSDKClient:contentClient
                                                                 completionBlock:userBlockForAuthenticate cancelBlock:nil];
        //setup a cancel button
        UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"Box"];
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, passedController.view.frame.size.width, 64)];
        HighlightButton *cancelButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 60, navigationBar.frame.size.height)];
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAuthButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        [navigationItem setRightBarButtonItem:barButtonItemCancel];
        [navigationBar setItems:[NSArray arrayWithObjects: navigationItem,nil]];
        [navigationBar setTranslucent:NO];
        [boxAuthViewController.view addSubview:navigationBar];
        //present the view controller
        [_passedInController presentViewController:boxAuthViewController animated:YES completion:nil];
    }
}


#pragma mark Box Method


// generate a shared link to a file on box, changing permissions etc,
// see https://github.com/box/box-ios-sdk/blob/master/doc/Files.md#create-a-shared-link

-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify andParentFile:(File*)parentFile andUUID:(NSString*)uuidString {
    
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    
    //find one user and set the content client to it
    //and then break
    NSArray* usersInKeyChain = [BOXContentClient users];
    for (BOXUserMini* miniuser in usersInKeyChain){
        contentClient = [BOXContentClient clientForUser:miniuser];
        break;
    }
    
    //none of these matter except client, I need a wrapper for just the client and the path it's linking...
    BXQueryWrapper* wrapper = [[BXQueryWrapper alloc] initWithContentClient:contentClient andBOXRequest:nil andTypeOfQuery:BXLOADSHAREABLELINK andUUIDString:uuidString andPassedFile:parentFile];
    
    // completion for files that have generated links or errors
    BOXFileBlock bxFileSharedLinkRequestCompletion = [self getBOXFileBlockForLinkShare:wrapper];
    
    // completion for folders that have generated links or errors
    BOXFolderBlock bxFolderSharedLinkRequestCompletion = [self getBOXFolderBlockForLinkShare:wrapper];
    
    //setup the linkObjects and dictionary
    for (File* fileToLink in filesToLinkify) {
        LinkJM *linkObject = [LinkJM createLinkJMWithURL:@""
                                      AndLinkDescription:fileToLink.displayName
                                              AndService:[AppConstants stringForServiceType:ServiceTypeBox]];        
        [wrapper setObject:linkObject forKeyInBoxLinkToBoxIDMap:fileToLink.idOnService];
        [wrapper setValue:fileToLink.idOnService forKeyInIdToOriginalIndexPosition:[[NSNumber numberWithInteger:[filesToLinkify indexOfObject:fileToLink]]stringValue]];
        [wrapper incrementCustomRequestCount];
    }
    
    dispatch_async(_bxQueryWrapperQueue, ^{
        [[self bxQueryWrapperHolder] addObject:wrapper];
    });
    
    //construct and shoot off queries to get links for files
    for (File* fileToLink in filesToLinkify) {
        
        if (fileToLink.isDirectory) {
            BOXFolderShareRequest *shareRequestFolder = [contentClient sharedLinkCreateRequestForFolderWithID:fileToLink.idOnService];
            shareRequestFolder.accessLevel = BOXSharedLinkAccessLevelOpen;
            shareRequestFolder.canDownload = YES;
            shareRequestFolder.canPreview = YES;
            [shareRequestFolder performRequestWithCompletion:bxFolderSharedLinkRequestCompletion];
        } else {
            BOXFileShareRequest *shareRequestFile = [contentClient sharedLinkCreateRequestForFileWithID:fileToLink.idOnService];
            shareRequestFile.accessLevel = BOXSharedLinkAccessLevelOpen;
            shareRequestFile.canDownload = YES;
            shareRequestFile.canPreview = YES;
            [shareRequestFile performRequestWithCompletion:bxFileSharedLinkRequestCompletion];
        }
    }
}

-(BOXItemsBlock) getBOXItemsBlockForNavigationWithQueryWrapper:(BXQueryWrapper*)passedQueryWrapper {
    return ^(NSArray *boxItems, NSError *error) {
        if ( (error == nil) && ![[passedQueryWrapper getBOXRequest] isCancelled]) {
            
            NSMutableArray* filesForBatchWrite = [[NSMutableArray alloc] init];
            
            for (BOXItem* boxItem in boxItems) {
                
                NSString* newFileUUID = [[NSUUID UUID] UUIDString];
                NSString* newFileUUIDName = newFileUUID;
                //if it's a file an not a folder
                if (boxItem.isFile) {
                    newFileUUIDName = [newFileUUID stringByAppendingPathComponent:[boxItem.name pathExtension]];
                }
                NSString* pathForNewFileDisplay = [[passedQueryWrapper getPassedFile].displayPath stringByAppendingPathComponent:boxItem.name];
                NSString* pathForNewFileCoded = [[passedQueryWrapper getPassedFile].codedPath stringByAppendingPathComponent:newFileUUID];
                
                File* boxFile = [[File alloc] init];
                boxFile.serviceType = [AppConstants serviceTypeForString:@"Box"];
                boxFile.displayName = boxItem.name;
                boxFile.displayPath = pathForNewFileDisplay;
                boxFile.codedName = newFileUUIDName;
                boxFile.codedPath = pathForNewFileCoded;
                boxFile.parentFile = [passedQueryWrapper getPassedFile];
                boxFile.isDirectory = boxItem.isFolder;
                boxFile.dateCreated = [NSDate date];
                boxFile.idOnService = boxItem.modelID;
                
                [filesForBatchWrite addObject:boxFile];
            }
            
            //RLM QUERY
            [[self fsInterface] saveBatchOfFilesToFileSystemRealm:filesForBatchWrite forParentDirectory:[passedQueryWrapper getPassedFile]];
            
            [[self fsAbstraction] pushOntoPathStack:[passedQueryWrapper getPassedFile]];
            //RLM QUERY
            [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:[passedQueryWrapper getPassedFile]];
            
            // - if a folder that is passed in (entered) is in the _selectedFiles array, then
            // = all it's children should also be added to the selected file array.
            
            // we need to make sure a file doesn't already exist in the array before we add it
            
            // send a notification to update the toolbar oncewe've pushed.
            if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[AppConstants rootPathStringIdentifier]]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
                
            } else if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[[AppConstants rootPathStringIdentifier]stringByAppendingPathComponent:[AppConstants presentableStringForServiceType:ServiceTypeDropbox]]]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
                
            } else if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[[AppConstants rootPathStringIdentifier]stringByAppendingPathComponent:[AppConstants presentableStringForServiceType:ServiceTypeBox]]]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
                
            } else if ([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[[AppConstants rootPathStringIdentifier]stringByAppendingPathComponent:[AppConstants presentableStringForServiceType:ServiceTypeGoogleDrive]]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationToolBarUpdate" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAddButton" object:self];
            }
            
            //if this is not inside this if statement it populates the current directory when trying to load
            //cloud files in the selected files view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
        
        } else {
            if (error.code == 401) { // authentication err, logout and reauth the user.
                [[passedQueryWrapper getContentClient] logOut];
                [self pressedBoxFolder:_passedInController withFile:[passedQueryWrapper getPassedFile]];
            } else if (error.code == 403) { //forbidden
                [_bxServiceManagerDelegate alertUserToInsufficientPermission:[passedQueryWrapper getPassedFile]];
            } else if (error.code == 404) { //not found
                [_bxServiceManagerDelegate alertUserToFileNotFound:[passedQueryWrapper getPassedFile]];
            } else if (error.code == 429) { //rate limit
                [_bxServiceManagerDelegate alertUserToRateLimitFromService:[passedQueryWrapper getPassedFile].serviceType];
            } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) { //timeout
                [_bxServiceManagerDelegate alerUserToCouldntReachService:[passedQueryWrapper getPassedFile].serviceType];
            } else {//mystical error
                [_bxServiceManagerDelegate alertUserToUnspecifiedErrorOnService:[passedQueryWrapper getPassedFile].serviceType];
            }
            [self cancelNavigationLoad];
        }
        //when a request finishes error or no error, get rid of it.
        dispatch_async(_bxQueryWrapperQueue, ^{
            [[self bxQueryWrapperHolder] removeObject:passedQueryWrapper];
        });
    };
}

-(void (^)(BOXFile *file, NSError* error)) getBOXFileBlockForLinkShare:(BXQueryWrapper*)passedQueryWrapper {
    return ^(BOXFile *file, NSError* error)
    {
//        //NSLog(@"Errrrra in make link %@", [error localizedDescription]);
//        //NSLog(@"beep box shared link %@", file.sharedLink.url);
        
        if (error == nil) {
            //sometimes there's no error and a link is nil? eh. prob not...?
            LinkJM *linkObject = (LinkJM*)[passedQueryWrapper getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:file.modelID];
            
            if ([linkObject.url isEqualToString:@""]) {
                //convert url to string and set in object
                linkObject.url = [file.sharedLink.url absoluteString];
            }
            
            //measure how many empty things are left in the dictionary, shareable links
            //that have not been returned yet.
            int emptyCount = 0;
            for (NSString* key in passedQueryWrapper.boxLinkToBoxIDMap) {
                LinkJM *linkObject = (LinkJM*)[passedQueryWrapper getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:key];
                if ([linkObject.url isEqualToString:@""]) {
                    emptyCount++;
                }
            }
            
            //if none of the things we want links for are missing
            //we have all our our links the user requested, send
            //them back.
            if (emptyCount == 0) {
                //reorder the links to match the original array.
                //the reason this works is because the dictionary
                //which has the original index numbers as its keys
                //will have them sorted automatically... 0 , 1, 2 etc.
                NSMutableArray* orderedReturnArray = [[NSMutableArray alloc] init];
                // do not do for in over the keys in teh dictionary need count
                int dictcount = (int)[[passedQueryWrapper.idToOriginalIndexPosition allKeys] count];
                for (int i = 0; i < dictcount; i++) {
                    [orderedReturnArray addObject:[passedQueryWrapper getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:[passedQueryWrapper getValueforKeyInIdToOriginalIndexPosition:[NSString stringWithFormat:@"%d",i]]]];
                }
                [_retrieveLinksFromServiceManagerDelegate finishedPreparingLinks:orderedReturnArray withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                //once we send the links destroy the query wrapper from array
                dispatch_async(_bxQueryWrapperQueue, ^{
                    [[self bxQueryWrapperHolder] removeObject:passedQueryWrapper];
                });
            }
            //decrement the req count
            [passedQueryWrapper decrementCustomRequestCount];
        } else {
            
            if (error.code == 401) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"You gotta re-log in!"] withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
            } else if (error.code == 403) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    //cannot retrieve file name or even id from box error
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"You do not have permission to get one of those files! Figure it out, human." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                }
            }
            // currently we DO NOT retry to get a link on error we just send a message
            // saying that link retrieval has failed, no point really this is virtually instant
            else if (error.code == 404) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    //cannot retrieve file name or even id from box error
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"One of those files no longer exists! You've really got it together..." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
            } else if (error.code == 429) {
                [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"You are being rate limited by box."] withLinkGenerationUUID:[passedQueryWrapper getUUID]];

            } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was an internet problem generating your links." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
                //if there is some other unspecified error
            } else {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was a mystical problem generating your links." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
            }
            // since we're in the error block and if we haven't
            // yet set a linkreq already failed we should do that
            // to avoid sending 100 delegate messages
            if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                [passedQueryWrapper setLinkRequestAlreadyFailed];
                dispatch_async(_bxQueryWrapperQueue, ^{
                    [[self bxQueryWrapperHolder] removeObject:passedQueryWrapper];
                });
            }
        }
    };
}



-(void (^)(BOXFolder *folder, NSError* error)) getBOXFolderBlockForLinkShare:(BXQueryWrapper*)passedQueryWrapper {
    return ^(BOXFolder *folder, NSError* error)
    {
//        //NSLog(@"Errrrra in make link %@", [error localizedDescription]);
//        //NSLog(@"errrra userinfo %@", [error userInfo]);
        //check out the shared link object, BOXSharedItem or something
        // cmd + click to jump to definition.
//        //NSLog(@"beep box shared link %@", folder.sharedLink.url);
        
        //if there's an error
        if (error == nil) {
            LinkJM *linkObject = (LinkJM*)[passedQueryWrapper getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:folder.modelID];
            
            if ([linkObject.url isEqualToString:@""]) {
                //convert url to string and set in object
                linkObject.url = [folder.sharedLink.url absoluteString];
            }
            
            //measure how many empty things are left in the dictionary, shareable links
            //that have not been returned yet.
            int emptyCount = 0;
            for (NSString* key in passedQueryWrapper.boxLinkToBoxIDMap) {
                LinkJM *linkObject = (LinkJM*)[passedQueryWrapper getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:key];
                if ([linkObject.url isEqualToString:@""]) {
                    emptyCount++;
                }
            }
            
            //if none of the things we want links for are missing
            //we have all our our links the user requested, send
            //them back.
            if (emptyCount == 0) {
                //reorder the links to match the original array.
                //the reason this works is because the dictionary
                //which has the original index numbers as its keys
                //will have them sorted automatically... 0 , 1, 2 etc.
                NSMutableArray* orderedReturnArray = [[NSMutableArray alloc] init];
                // do not do for in over the keys in teh dictionary need count
                int dictcount = (int)[[passedQueryWrapper.idToOriginalIndexPosition allKeys] count];
                for (int i = 0; i < dictcount; i++) {
                    [orderedReturnArray addObject:[passedQueryWrapper getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:[passedQueryWrapper getValueforKeyInIdToOriginalIndexPosition:[NSString stringWithFormat:@"%d",i]]]];
                }
                [_retrieveLinksFromServiceManagerDelegate finishedPreparingLinks:orderedReturnArray withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                //once we send the links destroy the query wrapper from array
                dispatch_async(_bxQueryWrapperQueue, ^{
                    [[self bxQueryWrapperHolder] removeObject:passedQueryWrapper];
                });
            }
            //decrement the req count
            [passedQueryWrapper decrementCustomRequestCount];
            
        } else {
            
            if (error.code == 401) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"You gotta re-log in!"] withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
            } else if (error.code == 403) {
                //NSLog(@"4 0h 3 boxy");
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    //cannot retrieve file name or even id from box error
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"You do not have permission to get one of those folders! We dunno which."
                                                    withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                }
            }
            // currently we DO NOT retry to get a link on error we just send a message
            // saying that link retrieval has failed, no point really this is virtually instant
            else if (error.code == 404) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    //cannot retrieve file name or even id from box error
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"One of those folders no longer exists! Come on ..."
                                                                withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
            } else if (error.code == 429) {
                [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"You are being rate limited by box. Greedy ..."] withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                
            } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was an internet problem generating your links." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
                //if there is some other unspecified error
            } else {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was a mystical problem generating your links." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                }
            }
            // since we're in the error block and if we haven't
            // yet set a linkreq already failed we should do that
            // to avoid sending 100 delegate messages
            // only remove from bxQueryWrapperHolder if it hasn't already failed
            // if it's already failed it's already been removed.
            if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                [passedQueryWrapper setLinkRequestAlreadyFailed];
                dispatch_async(_bxQueryWrapperQueue, ^{
                    [[self bxQueryWrapperHolder] removeObject:passedQueryWrapper];
                });
            }
        }
    };
}

@end
