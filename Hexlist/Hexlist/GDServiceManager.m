//
//  GDServiceManager.m
//  Hexlist
//
//  Created by Yvan Scher on 1/18/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "GDServiceManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "HighlightButton.h"


// type of query that we will
// use to check against the
// typeOfQuery field in the
// DBQueryWrapper class

static int const GDLOADMETADATANORMAL = 1;
static int const GDLOADSHAREABLELINK = 2;


static NSString *const keychainItemName = @"Hexlist-GoogleDrive";
static NSString *const clientId = @"394904128377-dkitaafdg8r14mjg7apc4sckqd25vcmh.apps.googleusercontent.com";
static NSString *const clientSecret = @"e_jj5Wh8rW_seXiQVLoRdEF9";

@implementation GDServiceManager

-(id) init{
    
    self = [super init];
    _passedInController = [[UIViewController alloc]init];
    _driveService = [[GTLServiceDrive alloc] init];
    _driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName: keychainItemName clientID: clientId clientSecret: clientSecret];
    
    _gdQueryWrapperQueue = dispatch_queue_create("dbQueryWrapperQueue", DISPATCH_QUEUE_SERIAL);
    
  
    //triggered from home view controller when the user
    //cancels a load based on a back press.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelNavigationLoadFromBackPress)
                                                 name:@"googledriveLoadCancelledByBackButtonPress"
                                               object:nil];
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

-(GTLServiceTicket*) serviceTicketForNavigationLoad {
    if(!_serviceTicketForNavigationLoad){
        _serviceTicketForNavigationLoad = [self produceServiceTicket];
    }
    return _serviceTicketForNavigationLoad;
}

-(void) setNavigationLoadServiceTicket:(GTLServiceTicket *)serviceTicketForNavigationLoad{
    _serviceTicketForNavigationLoad = serviceTicketForNavigationLoad;
}

-(NSMutableArray*) gdQueryWrapperHolder {
    if(!_gdQueryWrapperHolder){
        _gdQueryWrapperHolder = [[NSMutableArray alloc] init];
    }
    return _gdQueryWrapperHolder;
}

-(NSMutableArray*) gdOperationWrapperHolder {
    if(!_gdOperationWrapperHolder){
        _gdOperationWrapperHolder = [[NSMutableArray alloc] init];
    }
    return _gdOperationWrapperHolder;
}

-(NSMutableArray*) gdQueryOccurrenceLimitHolder {
    if(!_gdQueryOccurrenceLimitHolder){
        _gdQueryOccurrenceLimitHolder = [[NSMutableArray alloc] init];
    }
    return _gdQueryOccurrenceLimitHolder;
}

// produce a GTLServiceTicket that will
// represent a query once the query is made
// wrap that service ticket

- (GTLServiceTicket *) produceServiceTicket{
    GTLServiceTicket* serviceTicketToReturn = [[GTLServiceTicket alloc] init];
    return serviceTicketToReturn;
}

-(GDQueryWrapper*) wrapServiceTicket:(GTLServiceTicket*)serviceTicket andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile {
    GDQueryWrapper* queryWrapper = [[GDQueryWrapper alloc] initWithServiceTicket:serviceTicket andTypeOfQuery:typeOfQuery andUUIDString:uuidString andPassedFile:passedFile];
    return queryWrapper;
}

#pragma mark SharedServiceManager methods


// Helper to check if user is authorized
-(BOOL)isAuthorized{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}

-(void) unlinkService {
    _driveService.authorizer = nil;
}

#pragma mark - Authentication for Google Drive

-(void) pressedGoogleDriveFolder:(UIViewController*)passedController withFile:(File*)passedFile {
    
    _canLoadAndNavigateAfterAuth = YES;
    _passedInController = passedController;
    _passedFileForAuth = passedFile;
    //if we're not authorized to do stuff present the auth for the user.
    if (![self isAuthorized]){
        [self presentAuthenticationControllerForGoogleDrive:passedController invalidToken:NO];
    }else{
        GDQueryWrapper* newQueryWrapper = [self wrapServiceTicket:[self serviceTicketForNavigationLoad] andTypeOfQuery:GDLOADMETADATANORMAL andUUIDString:[[NSUUID UUID] UUIDString] andPassedFile:passedFile];
        [newQueryWrapper setPresentFromForReAuthentication:passedController];
        dispatch_async(_gdQueryWrapperQueue, ^{
            [[self gdQueryWrapperHolder] removeObject:newQueryWrapper];
            [[self gdQueryWrapperHolder] addObject:newQueryWrapper];
        });
        [self navigationLoadWithQueryWrapper:newQueryWrapper];
    }
}

//gets rid of the google authorization prompt, this is a login cancel.
//if the user was trying to authorize but then decided to cancel.
-(void) cancelAuthButtonPressed{ //ON AUTH ONLY
    [_passedInController dismissViewControllerAnimated:YES completion:nil];
    _canLoadAndNavigateAfterAuth = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterGoogleCancel" object:self];
}

//cancel auth button that comes from the authentication promtp that comes from a 401 or 400 error.
//come from clicking google drive invalid token or checking for Hexlistuploads folder wiht invalid token.
-(void) cancelAuthButtonPressedFourOhOne{
    //pop google drive off.
    [[self fsAbstraction] popDirectoryOffFileStack];
    [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:[[self fsAbstraction] getRootRealmFile]];
    [_passedInController dismissViewControllerAnimated:YES completion:nil];
    _canLoadAndNavigateAfterAuth = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterGoogleCancel" object:self];
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error{
    if (error != nil){
        [viewController dismissViewControllerAnimated:YES completion:nil];
        self.driveService.authorizer = nil;
    }else{
        
        [viewController dismissViewControllerAnimated:YES completion:nil];
        self.driveService.authorizer = authResult;
        //if we're authing as a result of a press
        //we can navigate, if authing as a result
        //of direct move to GD then don't nvigate.
        if(_canLoadAndNavigateAfterAuth){
            
            GDQueryWrapper* newQueryWrapper = [self wrapServiceTicket:[self serviceTicketForNavigationLoad] andTypeOfQuery:GDLOADMETADATANORMAL andUUIDString:[[NSUUID UUID] UUIDString] andPassedFile:_passedFileForAuth];
            
            dispatch_async(_gdQueryWrapperQueue, ^{
                [[self gdQueryWrapperHolder] removeObject:newQueryWrapper];
                [[self gdQueryWrapperHolder] addObject:newQueryWrapper];
            });
            [self navigationLoadWithQueryWrapper:newQueryWrapper];
        }
    }
}

// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController{
    
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                                clientID:clientId
                                                            clientSecret:clientSecret
                                                        keychainItemName:keychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

//gets the naivgation service ticket and cancels it, which should cancel google drive load
-(void)cancelNavigationLoad{
    dispatch_async(_gdQueryWrapperQueue, ^{
        for(GDQueryWrapper* wrappedServiceTicket in [self gdQueryWrapperHolder]){
            if ([[wrappedServiceTicket getServiceTicket] isEqual:[self serviceTicketForNavigationLoad]]){
                [[wrappedServiceTicket getServiceTicket] cancelTicket];
                [wrappedServiceTicket decrementCustomRequestCount];
            }
        }
        //don't need to decrement here because the custom request count
        //is for purging query wrappers and this isn't set up on a query
        //wrapper and we don't need to worry about it being purged.
        [[self serviceTicketForNavigationLoad] cancelTicket];
    });
}

-(void)cancelNavigationLoadFromBackPress{
    dispatch_async(_gdQueryWrapperQueue, ^{
        NSMutableIndexSet* indexesToRemove = [[NSMutableIndexSet alloc] init];
        for(GDQueryWrapper* wrappedServiceTicket in [self gdQueryWrapperHolder]){
            if ([[wrappedServiceTicket getServiceTicket] isEqual:[self serviceTicketForNavigationLoad]]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionViewFromGDLoadCancel" object:self];
                [[self serviceTicketForNavigationLoad] cancelTicket];
                [wrappedServiceTicket decrementCustomRequestCount];
                [indexesToRemove addIndex:[[self gdQueryWrapperHolder] indexOfObject:wrappedServiceTicket]];
            }
        }
        [[self gdQueryWrapperHolder] removeObjectsAtIndexes:indexesToRemove];
        //don't need to decrement here because the custom request count
        //is for purging query wrappers and this isn't set up on a query
        //wrapper and we don't need to worry about it being purged.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionViewFromGDLoadCancel" object:self];
        [[self serviceTicketForNavigationLoad] cancelTicket];
    });
}

#pragma mark - Recursive algorithms For doing Google Drive Operations


- (void) navigationLoadWithQueryWrapper:(GDQueryWrapper*)passedQueryWrapper {
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    // This query works because the only thing that ever gets passed to it are files
    // this format of query "%@ in PARENTS will not work on non directory fiels
    query.q = [NSString stringWithFormat:@"'%@' IN parents", [passedQueryWrapper getPassedFile].idOnService];


    //get the result of the this query to also point to the global service ticket object.
    [self setNavigationLoadServiceTicket:[_driveService executeQuery:query completionHandler:[self getBasicMetadataBlockWithQueryWrapper:passedQueryWrapper]]];
    //set the service ticket into the passedQuery wrapper to point to the global navigation service ticket object
    //leave this HERE to AFTER the service ticket is set from query, or else the service
    //ticket won't be recognized on back press (even tho it's memory addr?)
    //and this will cause a memory leake of the querywrappers building up
    //eveyrtime you cancel a load via back press because the query wrapper
    // doesn't get dismissed.
    [passedQueryWrapper setServiceTicket:[self serviceTicketForNavigationLoad]];
    [passedQueryWrapper incrementCustomRequestCount];
}

-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify andParentFile:(File*)parentFile andUUID:(NSString*)uuidString {
    
    //create a new permission to add to the fils
    GTLDrivePermission* newPermissionForFile = [GTLDrivePermission object];
    newPermissionForFile.type = @"anyone";
    newPermissionForFile.role = @"reader";
    newPermissionForFile.withLink = [[NSNumber alloc] initWithBool:YES];
    
   GDQueryWrapper* wrapper = [self wrapServiceTicket:[self produceServiceTicket] andTypeOfQuery:GDLOADSHAREABLELINK andUUIDString:uuidString andPassedFile:parentFile];
    
    for (File* fileToLinkify in filesToLinkify) {
        //create a query with the new permission and the file's id (there because it's stored in metadata on google drive navigate.
        GTLQueryDrive* queryToAddPermission = [GTLQueryDrive queryForPermissionsInsertWithObject:newPermissionForFile fileId:fileToLinkify.idOnService];
        GTLQueryDrive* queryForFileMetadata = [GTLQueryDrive queryForFilesGetWithFileId:fileToLinkify.idOnService];
        
        [_driveService executeQuery:queryToAddPermission completionHandler:^(GTLServiceTicket *ticket, GTLDrivePermission *permission, NSError *error) {
            //if we successfully add the permission then get the webContentLink from File metadata
            if (error == nil) {
                
                //NSLog(@"GETTING LINK FOR : %@,", fileToLinkify.idOnService);
                //if a key doesn't already exist we add it, don't want to replace keys
                //if the user selects another file much later.
                //keys are unique ids here instead of
                
                LinkJM *linkObject = [LinkJM createLinkJMWithURL:@""
                                              AndLinkDescription:fileToLinkify.displayName
                                                      AndService:[AppConstants stringForServiceType:ServiceTypeGoogleDrive]];
                
                //set the link object in the local dict.
                [wrapper setObject:linkObject forKeyInGoogledriveLinkToGoogleIDMap:fileToLinkify.idOnService];
                [wrapper setValue:fileToLinkify.idOnService forKeyInIdToOriginalIndexPosition:[[NSNumber numberWithInteger:[filesToLinkify indexOfObject:fileToLinkify]]stringValue]];
                [wrapper incrementCustomRequestCount];
                
                //add the aquery wrapper to the global holder array.
                dispatch_async(_gdQueryWrapperQueue, ^{
                    [[self gdQueryWrapperHolder] addObject:wrapper];
                });
                
                [_driveService executeQuery:queryForFileMetadata completionHandler:[self getShareableLinkCompletionBlock:wrapper]];
            } else {
                //NSLog(@"An error occurred: %@", error);
                if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
                    if (![wrapper getLinkRequestAlreadyFailed]) {
                        [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was an internet error!" withLinkGenerationUUID:[wrapper getUUID]];
                        //if it has not already failed then set the failure mechanism
                    } else {
                        [wrapper setLinkRequestAlreadyFailed];
                    }
                } else {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"Couldn't update your file permissions to get a link." withLinkGenerationUUID:[wrapper getUUID]];
                }

            }
        }];
    }
}

-(void (^)(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error)) getShareableLinkCompletionBlock:(GDQueryWrapper*)passedQueryWrapper {
    
    return ^(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error) {
        //there was no error from getting the file
        if (error == nil) {
            NSString *downloadLink = file.alternateLink;
            
            if (file.alternateLink == nil) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was a problem generating your links." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                    [passedQueryWrapper setLinkRequestAlreadyFailed];

                }
                dispatch_async(_gdQueryWrapperQueue, ^{
                    //get rid of requests attached to this failed thing.
                    [[self gdQueryWrapperHolder] removeObject:passedQueryWrapper];
                });
            }else {
                LinkJM *linkObject = (LinkJM*)[passedQueryWrapper getObjectforKeyInGoogledriveLinkToGoogleIDMap:file.identifier];
                
                if ([linkObject.url isEqualToString:@""]) {
                    linkObject.url = downloadLink;
                }
                
                //measure how many empty things are left in the dictionary, shareable links
                //that have not been returned yet.
                int emptyCount = 0;
                for (NSString* key in passedQueryWrapper.googledriveLinkToGoogleIDMap) {
                    LinkJM *linkObject = (LinkJM*)[passedQueryWrapper getObjectforKeyInGoogledriveLinkToGoogleIDMap:key];
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
                        [orderedReturnArray addObject:[passedQueryWrapper getObjectforKeyInGoogledriveLinkToGoogleIDMap:[passedQueryWrapper getValueforKeyInIdToOriginalIndexPosition:[NSString stringWithFormat:@"%d",i]]]];
                    }
                    [_retrieveLinksFromServiceManagerDelegate finishedPreparingLinks:orderedReturnArray withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    
                    dispatch_async(_gdQueryWrapperQueue, ^{
                        //get rid of requests attached to this failed thing.
                        [[self gdQueryWrapperHolder] removeObject:passedQueryWrapper];
                    });
                }
            }
            [passedQueryWrapper decrementCustomRequestCount];
            //there was clearly an error from getting the file
        } else {
            
            if (error.code == 400 || error.code == 401) {
                [self presentAuthenticationControllerForGoogleDrive:[passedQueryWrapper getPresentFromForReAuthentication] invalidToken:YES];
            } else if (error.code == 404) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"The file at '%@' no longer exists.", [error.userInfo objectForKey:@"path"]] withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                } else {
                    [passedQueryWrapper setLinkRequestAlreadyFailed];
                }
            } else if (error.code == 429) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:[NSString stringWithFormat:@"You are being rate limited by Google Drive."] withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                }
            }  else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was an internet error!" withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                } else {
                    [passedQueryWrapper setLinkRequestAlreadyFailed];
                }
            } else {
                if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                    [_retrieveLinksFromServiceManagerDelegate failedToRetrieveAllLinks:@"There was a problem generating your links." withLinkGenerationUUID:[passedQueryWrapper getUUID]];
                    //if it has not already failed then set the failure mechanism
                } else {
                    [passedQueryWrapper setLinkRequestAlreadyFailed];
                }
            }
            if (![passedQueryWrapper getLinkRequestAlreadyFailed]) {
                [passedQueryWrapper setLinkRequestAlreadyFailed];
                dispatch_async(_gdQueryWrapperQueue, ^{
                    //get rid of requests attached to this failed thing.
                    [[self gdQueryWrapperHolder] removeObject:passedQueryWrapper];
                });
            }
        }
    };
}

#pragma mark - Blocks For Google Drive Completion Handlers

// this is our basic metadata block that gets called on a navigation load into GoogleDrive
// it loads up the metadata and puts it on the file system so it can be displayed
// in the collectionview

-(void(^)(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error)) getBasicMetadataBlockWithQueryWrapper:(GDQueryWrapper*)passedQueryWrapper {
    
    return ^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) {
        
        if (error == nil){
            BOOL isDir = NO;
            NSString* revision = @"";
            NSMutableArray* filesForBatchWrite = [[NSMutableArray alloc] init];
            
            for(int i=0; i<[files.items count]; i++){
                
                NSString* newFileExtension = @"";
                NSString* fileNameAndExtensionToActuallyUse = @"";
                NSMutableDictionary *jsonDict = ((GTLDriveFile*)[files.items objectAtIndex:i]).exportLinks.JSON;
                
                for(NSString* filetype in jsonDict){
                    if ([filetype containsString:@"application/vnd.openxmlformats"]) { // then we're dealing with pptx, docx, or xlsx
                        NSString* exportpath = [jsonDict objectForKey:filetype];
                        NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                        newFileExtension = [arrayWithTwoStrings lastObject];
                    }else if([((GTLDriveFile*)[files.items objectAtIndex:i]).mimeType isEqualToString:@"application/vnd.google-apps.drawing"]){ // we're dealing with google drawing
                        NSString* exportpath = [jsonDict objectForKey:@"image/png"];
                        NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                        newFileExtension = [arrayWithTwoStrings lastObject];
                    } // all other intrinsic mime types native to google docs do not have export URLS.
                }
                
                GTLDriveFile* file = ((GTLDriveFile*)[files.items objectAtIndex:i]);
                
                if ((file.fileExtension == (id)[NSNull null]) || (file.fileExtension.length == 0)){
                    isDir = YES;
                    
                }else{
                    isDir = NO;
                }
                
                if ((file.headRevisionId == (id)[NSNull null]) || (file.headRevisionId.length == 0)) {
                    revision = @"a";
                }else{
                    revision = file.headRevisionId;
                }
                
                if(![newFileExtension isEqualToString:@""]){
                    isDir = NO;
                    fileNameAndExtensionToActuallyUse = [[file.title stringByAppendingString: @"." ] stringByAppendingString: newFileExtension];
                }else{
                    fileNameAndExtensionToActuallyUse = file.title;
                }
                
                if(!([file.explicitlyTrashed isEqualToNumber:[NSNumber numberWithInt:1]] || [file.labels.trashed isEqualToNumber:[NSNumber numberWithInt:1]])){
                    
                    NSString* newFileUUID = [[NSUUID UUID] UUIDString];
                    NSString* newFileUUIDName = newFileUUID;
                    if (!isDir){
                        newFileUUIDName = [newFileUUID stringByAppendingPathExtension:[fileNameAndExtensionToActuallyUse pathExtension]];
                    }
                    NSString* pathForNewFileDisplay = [[passedQueryWrapper getPassedFile].displayPath stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse];
                    NSString* pathForNewFileCoded = [[passedQueryWrapper getPassedFile].codedPath stringByAppendingPathComponent:newFileUUIDName];
                    
                    File* newFile = [[File alloc] init];
                    newFile.serviceType = [AppConstants serviceTypeForString:@"GoogleDrive"];
                    newFile.displayName = fileNameAndExtensionToActuallyUse;
                    newFile.displayPath = pathForNewFileDisplay;
                    newFile.codedName = newFileUUIDName;
                    newFile.codedPath = pathForNewFileCoded;
                    newFile.parentFile = [passedQueryWrapper getPassedFile];
                    newFile.isDirectory = isDir;
                    newFile.dateCreated = [NSDate date];
                    newFile.idOnService = file.identifier;
            
                    [filesForBatchWrite addObject:newFile];
                }
            } // END FOR LOOP
            
            [[self fsInterface] saveBatchOfFilesToFileSystemRealm:filesForBatchWrite forParentDirectory:[passedQueryWrapper getPassedFile]];
            
            [[self fsAbstraction] pushOntoPathStack:[passedQueryWrapper getPassedFile]];
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
            
            //if this is not inside this if statement it populates the current directory when trying to load
            //cloud files in the selected files view
            [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:[passedQueryWrapper getPassedFile]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
            //re-show a previously hidden collection view as soon as there's new files to show.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
            
            dispatch_async(_gdQueryWrapperQueue, ^{
                //get rid of requests attached to this failed thing.
                [[self gdQueryWrapperHolder] removeObject:passedQueryWrapper];
            });
        }else{
//            //NSLog(@"An error occurred: %@", error);
//            //NSLog(@"ERROR CODE %ld",(long)error.code);
            
            //if on a navigation load we get a 400 or 401 error re auth the user
            if (error.code == 400 || error.code == 401) { //authentication error, re-auth user
                [self presentAuthenticationControllerForGoogleDrive:[passedQueryWrapper getPresentFromForReAuthentication] invalidToken:YES];
            } else if (error.code == 403) { // no permissions
                [_gdServiceManagerDelegate alertUserToInsufficientPermission:[passedQueryWrapper getPassedFile]];
            } else if (error.code == 404) { //not found
                [_gdServiceManagerDelegate alertUserToFileNotFound:[passedQueryWrapper getPassedFile]];
            } else if (error.code == 429) { // rate limit
                [_gdServiceManagerDelegate alertUserToRateLimitFromService:[passedQueryWrapper getPassedFile].serviceType];
            } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) { //timeout
                [_gdServiceManagerDelegate alerUserToCouldntReachService:[passedQueryWrapper getPassedFile].serviceType];
            } else { //mystical error
                [_gdServiceManagerDelegate alertUserToUnspecifiedErrorOnService:[passedQueryWrapper getPassedFile].serviceType];
            }
            
            dispatch_async(_gdQueryWrapperQueue, ^{
                //get rid of requests attached to this failed thing.
                [[self gdQueryWrapperHolder] removeObject:passedQueryWrapper];
            });
        }
    };
}

-(void) presentAuthenticationControllerForGoogleDrive:(UIViewController*)passedController invalidToken:(BOOL)tokenWasInvalid{
    
    //create the three view controllers!
    UINavigationController *authNavigationController = [[UINavigationController alloc] init];
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"GOOGLE DRIVE"];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, passedController.view.frame.size.width, 64)];
    
    HighlightButton *cancelButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 60, navigationBar.frame.size.height)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    if(tokenWasInvalid){
        [cancelButton addTarget:self action:@selector(cancelAuthButtonPressedFourOhOne) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [cancelButton addTarget:self action:@selector(cancelAuthButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIButton *buttonToGoInside = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, navigationBar.frame.size.height)];
    UIBarButtonItem *barButtonItemPlaceholder = [[UIBarButtonItem alloc] initWithCustomView:buttonToGoInside];
    
    [navigationItem setLeftBarButtonItem:barButtonItemPlaceholder];
    [navigationItem setRightBarButtonItem:barButtonItemCancel];
    
    //set the navigation item to have a title of a google drive icon.
    UIImage *titleImage = [UIImage imageNamed:[AppConstants googleDriveImageStringIdentifier]];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 4, 50, 36)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:titleImage];
    navigationItem.titleView = imageView;
    
    [navigationBar setTranslucent:NO];
    [navigationBar setItems:[NSArray arrayWithObjects: navigationItem,nil]];
    
    GTMOAuth2ViewControllerTouch* authViewController = [self createAuthController];
    [authNavigationController.view addSubview:navigationBar];
    [authNavigationController addChildViewController:authViewController];
    
    [passedController presentViewController:authNavigationController animated:YES completion:nil];
}

@end

