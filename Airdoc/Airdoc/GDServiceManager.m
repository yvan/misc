//
//  GDServiceManager.m
//  Airdoc
//
//  Created by Yvan Scher on 1/18/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "GDServiceManager.h"
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>


// we try a query 3 times, after that
// we kill it.

static int const GLOBALQUERYATTEMPTLIMIT = 3;

// type of query that we will
// use to check against the
// typeOfQuery field in the
// DBQueryWrapper class

static int const GDLOADMETADATANORMAL = 1;
static int const GDLOADMETADATASELECTED = 2;
static int const GDLOADMETADATAENVOYUPLOADS = 3;
static int const GDLOADFILE = 4;
static int const GDUPLOADFILE = 5;
static int const GDDELETEFILE = 6;
//static int const GDMOVEFROM = 7;

static NSString *const keychainItemName = @"Airdoc-GoogleDrive";
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
    
    //create a timer that purges google drive clients that have no more requests to make every minute.
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

-(NSMutableDictionary*) dictionaryWithShareableLinks {
    if(!_dictionaryWithShareableLinks){
        _dictionaryWithShareableLinks = [[NSMutableDictionary alloc] init];
    }
    return _dictionaryWithShareableLinks;
}

// produce a GTLServiceTicket that will
// represent a query once the query is made
// wrap that service ticket

- (GTLServiceTicket *) produceServiceTicket{
    GTLServiceTicket* serviceTicketToReturn = [[GTLServiceTicket alloc] init];
    return serviceTicketToReturn;
}

-(GDQueryWrapper*) wrapServiceTicket:(GTLServiceTicket*)serviceTicket withStoredReduceStackToPath:(NSString*)pathToWrap andTypeOfQuery:(int)typeOfQuery andPassedFile:(File*)passedFile andshouldReloadSelectedFilesView:(BOOL)shouldReload andMoveToGD:(BOOL)moveToGDPressed cameFromAuth:(BOOL)cameFromAuth andMovedFromGD:(BOOL)moveFromGDPressed andSelectedFiles:(NSMutableArray*)selectedFiles {
    GDQueryWrapper* queryWrapper = [[GDQueryWrapper alloc] initWithServiceTicket:serviceTicket andStoredReduceStackToPath:pathToWrap andTypeOfQuery:typeOfQuery andPassedFile:passedFile andshouldReloadMainView:shouldReload andMoveToGD:moveToGDPressed cameFromAuth:cameFromAuth andMovedFromGD:moveFromGDPressed andSelectedFiles:selectedFiles];
    return queryWrapper;
}

#pragma mark - prepare files for move methods

// - DOWNLOADING
// - this method helps us download files from google drive, to somewhere else

-(void) prepareForExportToOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToGD:(BOOL)moveToGDPressed andMovedFromGD:(BOOL)moveFromGDPressed{
    
    GTLServiceTicket* newServiceTicket = [self produceServiceTicket];
    
    GDQueryWrapper* newGDQueryWrapper = [self wrapServiceTicket:newServiceTicket withStoredReduceStackToPath:storedReduceStackToPath andTypeOfQuery:GDLOADFILE andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToGD:moveToGDPressed cameFromAuth:NO andMovedFromGD:moveFromGDPressed andSelectedFiles:selectedFilesForMove];
    
    dispatch_async(_gdQueryWrapperQueue, ^{
        [[self gdQueryWrapperHolder] addObject:newGDQueryWrapper];
    });
    
    //remove files that are not in googledrive
    //we only want to download googledrive files
    //from googlegrive
    for (int i = 0; i<[selectedFilesForMove count]; i++) {
        
        File* tempFile = ((File*)selectedFilesForMove[i]);
        
        // only query the googledrive ones.
        //if the file were downlaoding from the selected array is in google drive and if it isn't a removed file.
        //then we download this file from the google drive client.
        if ([[self fsInterface] filePath:tempFile.path isLocatedInsideDirectoryName:@"GoogleDrive"]) {
            [self loadFilesRecursively:tempFile andQueryWrapper:newGDQueryWrapper isSelectedFile:YES];
        }
    }
}

// - UPLOADING
// - method takes folders in the prepared array and gets them ready to be put into googledrive.
// - fundamentally should be the SAME method in every class where we need to import files INTO.
// - each one will differ slightly in the way that it UPLOADS stuff to the cloud.

-(void) prepareToSaveFilesExportedFromOther:(NSMutableArray*)selectedFilesForMove calledFromInbox:(BOOL)calledFromInbox storedReduceStackToPath:(NSString*)storedReduceStackToPath andMoveToGD:(BOOL)moveToGDPressed andMovedFromGD:(BOOL)moveFromGDPressed{
    
    GTLServiceTicket* newServiceTicket = [self produceServiceTicket];
    
    GDQueryWrapper* newGDQueryWrapper = [self wrapServiceTicket:newServiceTicket withStoredReduceStackToPath:storedReduceStackToPath andTypeOfQuery:GDUPLOADFILE andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToGD:moveToGDPressed cameFromAuth:NO andMovedFromGD:moveFromGDPressed andSelectedFiles:selectedFilesForMove];
    
    dispatch_async(_gdQueryWrapperQueue, ^{

        [[self gdQueryWrapperHolder] addObject:newGDQueryWrapper];
    
    });
    
    // - next section gets the box / googledrive id from the parent of the folder where you moved stuff into.
    // - the idea being that we need this ID to start off the recursion of uploading files or all files
    // - will just upload into the root, the servicemanager and API needs to know where to start uploading
    // - files to. we pass this into the first recursive method call below. Don't need this for dropbox
    // - because dropbox is a path based and not a id based api. The IDs come from the stored information
    // - that gets loaded into the filesystem.json of the place you're trying to move to when you navigate there
    // - before pressing move.
    
    NSString* initialParentId = @"";

    //if we moved directly to google drive
    //we set the initialy parent ID
    //to the stored id of the EnvoyUploads
    //folder
    if(moveToGDPressed){
        initialParentId = [self getEnvoyUploadsFolderIDInUserDefaults];
    }else{
        NSMutableArray* specialArrayForGettingInitialFolderId = [[NSMutableArray alloc] init];
        
        [[self fsInterface] populateArrayWithFileSystemJSON:specialArrayForGettingInitialFolderId inDirectoryPath:[storedReduceStackToPath stringByDeletingLastPathComponent]];
        
        for(File* child in specialArrayForGettingInitialFolderId){
            if([child.path isEqualToString: storedReduceStackToPath]){
                initialParentId = child.boxid;
            }
        }
    }
    
    NSMutableIndexSet* filesToRemove = [[NSMutableIndexSet alloc] init];
    
    //add the first directory (the one originally called upon if it is not in the array
    //prepared to be exported. This make sure the original directory will appear
    // in the new folder, if we don't do this, it will not appear.
    
    // otuer selects a file, the inner loop selected another file
    // the outer file is checked to see if it is the parent of the
    // inner file.
    for (int i = 0; i<[selectedFilesForMove count]; i++) {
        
        File* tempFile = ((File*)selectedFilesForMove[i]);
        
        //if the user is moving INTO googledrive and the file's path is not located inside googledrive (the file isn't in google drive)
        //and also if it isn't a file we removed (see explanation directly above in the doubel for loop)
        //then upload the file to google drive.
        if ([[self fsInterface] filePath:storedReduceStackToPath isLocatedInsideDirectoryName:@"GoogleDrive"] && ![[self fsInterface] filePath:tempFile.path isLocatedInsideDirectoryName:@"GoogleDrive"] && ![filesToRemove containsIndex:i]) {
            [self pullFilesToUploadFromOther:tempFile withParentId:initialParentId withQueryWrapper:newGDQueryWrapper];
        }
    }
}

#pragma mark - Authentication for Google Drive

// Helper to check if user is authorized
-(BOOL)isAuthorized{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}

-(void) pressedGoogleDriveFolder:(UIViewController*)passedController withFile:(File*)file shouldReloadMainView:(BOOL)shouldReloadSelectedFilesView andMoveToGD:(BOOL)moveToGDPressed{
    
    _canLoadAndNavigateAfterAuth = YES;
    _passedInController = passedController;
    
    //if we're not authorized to do stuff present the auth for the user.
    if (![self isAuthorized]){
        
        [self presentAuthenticationControllerForGoogleDrive:passedController invalidToken:NO];
        
    }else{
        GDQueryWrapper* newQueryWrapper = [self wrapServiceTicket:[self serviceTicketForNavigationLoad] withStoredReduceStackToPath:nil andTypeOfQuery:GDLOADMETADATANORMAL andPassedFile:file andshouldReloadSelectedFilesView:shouldReloadSelectedFilesView andMoveToGD:moveToGDPressed cameFromAuth:NO andMovedFromGD:NO andSelectedFiles:[[NSMutableArray alloc] init]];
        
        [newQueryWrapper setPresentFromForReAuthentication:passedController];
        
        if(!shouldReloadSelectedFilesView){
            [newQueryWrapper setTypeOfQuery:GDLOADMETADATASELECTED];
        }
        
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
//come from clicking google drive invalid token or checking for Envoyuploads folder wiht invalid token.
-(void) cancelAuthButtonPressedFourOhOne{
    //pop google drive off.
    [[self fsAbstraction] popDirectoryOffPathStack];
    [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:@"/"];
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
            File* dummyGoogleDriveFileToPass = [[File alloc] initWithName:@"GoogleDrive" andPath:@"/GoogleDrive" andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
            GDQueryWrapper* newQueryWrapper = [self wrapServiceTicket:[self serviceTicketForNavigationLoad] withStoredReduceStackToPath:nil andTypeOfQuery:GDLOADMETADATANORMAL andPassedFile:dummyGoogleDriveFileToPass andshouldReloadSelectedFilesView:NO andMoveToGD:NO cameFromAuth:YES andMovedFromGD:NO andSelectedFiles:[[NSMutableArray alloc] init]];
            
            dispatch_async(_gdQueryWrapperQueue, ^{
                [[self gdQueryWrapperHolder] removeObject:newQueryWrapper];
                [[self gdQueryWrapperHolder] addObject:newQueryWrapper];
            });
            [self navigationLoadWithQueryWrapper:newQueryWrapper];
        } else{ // if we want to check for/create teh EnvoyUploads
            GTLServiceTicket* newServiceTicket = [self produceServiceTicket];
            
            GDQueryWrapper* newQueryWrapper = [self wrapServiceTicket:newServiceTicket withStoredReduceStackToPath:nil andTypeOfQuery:GDLOADMETADATAENVOYUPLOADS andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToGD:YES cameFromAuth:NO andMovedFromGD:NO andSelectedFiles:[[NSMutableArray alloc] init]];
            
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
            
            // construct a query for the root folder and send that query
            query.q = [NSString stringWithFormat:@"'%@' IN parents", @"root"];
            [newQueryWrapper incrementCustomRequestCount];
            [newQueryWrapper setServiceTicket:[_driveService executeQuery:query completionHandler:[self getEnvoyUploadsCheckBlockWithQueryWrapper:newQueryWrapper]]];
            [[self gdQueryWrapperHolder] addObject:newQueryWrapper];
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
}

-(void)cancelNavigationLoadFromBackPress{
    
    for(GDQueryWrapper* wrappedServiceTicket in [self gdQueryWrapperHolder]){
        if ([[wrappedServiceTicket getServiceTicket] isEqual:[self serviceTicketForNavigationLoad]]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionViewFromGDLoadCancel" object:self];
            [[self serviceTicketForNavigationLoad] cancelTicket];
            [wrappedServiceTicket decrementCustomRequestCount];
        }
    }
    //don't need to decrement here because the custom request count
    //is for purging query wrappers and this isn't set up on a query
    //wrapper and we don't need to worry about it being purged.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionViewFromGDLoadCancel" object:self];
    [[self serviceTicketForNavigationLoad] cancelTicket];
}

-(BOOL)cancelFileLoadWithFile:(File*)fileToStopDownloadingFrom {
    
    for (GDQueryWrapper* queryWrapper in [[NSArray alloc] initWithArray:[self gdQueryWrapperHolder]]) {
        NSString* pathToTackOn = @"";
        //if the stored reduce stack to path and the parent url of the file are NOT
        //the same then that MUST mean this file was downloaded as part of a folder.
        //so we tack on the name of the folder/path to get from teh stored reducestack
        //to the actual file we want to cancel to the stored reduce stack [queryWrapper getStoredReduceStackToPath]
        if (![[queryWrapper getStoredReduceStackToPath] isEqualToString:fileToStopDownloadingFrom.parentURLPath]) {
            pathToTackOn = [[self fsInterface] resolveFilePath:fileToStopDownloadingFrom.parentURLPath excludingUpToDirectory:[[queryWrapper getStoredReduceStackToPath] lastPathComponent]];
        }
        
        //if the path we're downloading the file to the "storedreducestacktopath" is equal to the parent of the file we want to stop downloading, then we've  (probably)found the right file.
        //potentially and we check the dictionary with the key in teh dictionary being the path of this file to stop fetching on the fetcher that fetches for this file.
        //each file gets their own fetcher so stopping one fetcher should not interefer with other downloading files
        if ([[[queryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:pathToTackOn] isEqualToString:[fileToStopDownloadingFrom.path stringByDeletingLastPathComponent]]) {
            
            //get a fetcher for the file we want to stop downloading
            GTMHTTPFetcher* fetcher = [queryWrapper getObjectforKeyInDownloadPathToFetcher:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopDownloadingFrom.path]];
            
            //if the fetcher is fetching stop it and return YES out of the loop.
            if([fetcher isFetching]){
                [queryWrapper decrementCustomRequestCount];
                [fetcher stopFetching];
                //path1 is source
                //path2 is destination
                [self destroyObjectFromQueryLimitQueueWithServiceTicketOrFetcher:fetcher andPath:fileToStopDownloadingFrom.path andTypeOfQuery:GDLOADFILE];
                [queryWrapper.downloadPathToFetcher removeObjectForKey:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopDownloadingFrom.path]];
                [[self fsInterface] deleteFileAtPath:fileToStopDownloadingFrom.path];
                return YES;
            }
        }
    }
    //if we were unable to stop the file from downloading return NO
    return NO;
}

-(BOOL)cancelFileUploadWithFile:(File*)fileToStopUploadingFrom {
    
    for (GDQueryWrapper* queryWrapper in [[NSArray alloc] initWithArray:[self gdQueryWrapperHolder]]) {
        NSString* pathToTackOn = @"";
        //if the stored reduce stack to path and the parent url of the file are NOT
        //the same then that MUST mean this file was downloaded as part of a folder.
        //so we tack on the name of the folder/path to get from teh stored reducestack
        //to the actual file we want to cancel to the stored reduce stack [queryWrapper getStoredReduceStackToPath]
        if (![[queryWrapper getStoredReduceStackToPath] isEqualToString:fileToStopUploadingFrom.parentURLPath]) {
            pathToTackOn = [[self fsInterface] resolveFilePath:fileToStopUploadingFrom.parentURLPath excludingUpToDirectory:[[queryWrapper getStoredReduceStackToPath] lastPathComponent]];
        }
        
        //if the path we're downloading the file to the "storedreducestacktopath" is equal to the parent of the file we want to stop downloading, then we've  (probably)found the right file.
        //potentially and we check the dictionary with the key in teh dictionary being the path of this file to stop fetching on the fetcher that fetches for this file.
        //each file gets their own fetcher so stopping one fetcher should not interefer with other downloading files
        if ([[[queryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:pathToTackOn] isEqualToString:[fileToStopUploadingFrom.path stringByDeletingLastPathComponent]]) {
            
            //get a fetcher for the file we want to stop downloading
            GTLServiceTicket* uploadTicket = [queryWrapper getObjectforKeyInDownloadPathToFetcher:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopUploadingFrom.path]];
            [uploadTicket cancelTicket];
            //if the fetcher is fetching stop it and return YES out of the loop.
            [queryWrapper decrementCustomRequestCount];
            [self destroyObjectFromQueryLimitQueueWithServiceTicketOrFetcher:uploadTicket andPath:fileToStopUploadingFrom.path andTypeOfQuery:GDLOADFILE];
            [queryWrapper.downloadPathToFetcher removeObjectForKey:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent: fileToStopUploadingFrom.path]];
            [[self fsInterface] deleteFileAtPath:fileToStopUploadingFrom.path];
            return YES;
        }
    }
    //if we were unable to stop the file from downloading return NO
    return NO;
}

#pragma mark - Recursive algorithms For doing Google Drive Operations

-(void) deleteFileFromGoogleDrive:(File*)file{
    
    NSLog(@"DELETING BOX ID %@", file.boxid);
    //create new query wrapper with dummy service ticket
    GDQueryWrapper* queryWrapperForDelete = [self wrapServiceTicket:[self produceServiceTicket] withStoredReduceStackToPath:nil andTypeOfQuery:GDDELETEFILE andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToGD:NO cameFromAuth:NO andMovedFromGD:NO andSelectedFiles:[[NSMutableArray alloc] initWithObjects:file, nil]];
    //cosntruct google drive query
    GTLQueryDrive* query = [GTLQueryDrive queryForFilesDeleteWithFileId:file.boxid];
    //execute the query and set the dumym service ticket to the real service ticket for this operation
    [queryWrapperForDelete setServiceTicket:[_driveService executeQuery:query completionHandler:[self getDeleteFileBlockWithQueryWrapper:queryWrapperForDelete]]];
    //add the querywrapper to the global array for query wrappers.
    [[self gdQueryWrapperHolder] addObject:queryWrapperForDelete];
}

// - actual lifting method for uploading files, this part no worku

-(void) pullFilesToUploadFromOther:(File*) oldFile withParentId:(NSString*)parentID withQueryWrapper:(GDQueryWrapper*)passedQueryWrapper{
    
    //the problem with this method is that for some reasons trying to upload multiple files
    //it fails. It works for one file tho.
    //something about the GTL objects doesn't work 
    
    BOOL isDirectory = NO;
    NSMutableArray* prepareToSaveFilesOthArray = [[NSMutableArray alloc]init];
    NSString* queryPath = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:
                           
                               [[[oldFile.path stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           
                           ];
    
    [[NSFileManager defaultManager] fileExistsAtPath:queryPath isDirectory:&isDirectory];
    
    if (isDirectory){ // recursively call if it's a directory
        NSString* pathForNewDir = [[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:oldFile.path] stringByDeletingLastPathComponent];
        
        //&& ![[urlForNewDir path] isEqualToString:[self urlPathMiddleOut:[urlForNewDir path]]]
        //check if the parent is presentat at new location, it it's not then save directly in place we want to move to.
        while (![[self fsInterface] isValidPath:pathForNewDir]){
            pathForNewDir = [self urlPathMiddleOut:pathForNewDir onQueryWrapper:passedQueryWrapper];
        }
        
        //save the new directory.
        File* newDir = [[File alloc] initWithName:oldFile.name andPath:[pathForNewDir stringByAppendingPathComponent:oldFile.name] andDate:[NSDate date] andRevision:oldFile.revision andDirectoryFlag:oldFile.isDirectory andBoxId:@"-1"];
        [[self fsInterface] createDirectoryAtPath:newDir.path withIntermediateDirectories:NO attributes:nil];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:newDir.parentURLPath];
        
        GTLDriveFile *driveFile = [GTLDriveFile object];
        driveFile.title = oldFile.name;
        driveFile.mimeType = @"application/vnd.google-apps.folder";
        GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
        parentRef.identifier = (parentID) ? parentID : @"";
        driveFile.parents = (parentID) ? @[parentRef] : @[];
        
        // NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[oldFile.url path]];
        // MIME type to create a directory : "application/vnd.google-apps.folder"
        // GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
        // MIMEType:driveFile.mimeType];
        
        void (^uploadCompletionBlock)(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error) = ^(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error) {
            
            if (error == nil) {
                
                //destroy the query limit object upon successful completion of file download
                [self destroyObjectFromQueryLimitQueueWithPath1:newDir.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE];
                
                //purpose of thos code is to imemdtaiely update the google drive id
                //on the disk so user can delete the thing w/o having to reload
                
                BOOL isDir = NO;
                NSString* revision = @"";
                NSString* newFileExtension = @"";
                NSString* fileNameAndExtensionToActuallyUse = @"";
                NSString* specialDownloadString = @"";
                NSMutableDictionary *jsonDict = uploadedFile.exportLinks.JSON;
                
                for (NSString* filetype in jsonDict) {
                    //special check for pptx, docx, xlsx,
                    //get the export path.
                    if ([filetype containsString:@"application/vnd.openxmlformats"]) { // then we're dealing with pptx, docx, or xlsx
                        NSString* exportpath = [jsonDict objectForKey:filetype];
                        NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                        newFileExtension = [arrayWithTwoStrings lastObject];
                        specialDownloadString = exportpath;
                        
                        //it it's a special drawing file.
                    }else if([uploadedFile.mimeType isEqualToString:@"application/vnd.google-apps.drawing"]){ // we're dealing with google drawing
                        NSString* exportpath = [jsonDict objectForKey:@"image/png"];
                        NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                        newFileExtension = [arrayWithTwoStrings lastObject];
                        specialDownloadString = exportpath;
                        
                    } // all other intrinsic mime types native to google docs do not have export URLS.
                }
                
                if ((uploadedFile.fileExtension == (id)[NSNull null]) || (uploadedFile.fileExtension.length == 0)){
                    isDir = YES;
                }else{
                    isDir = NO;
                }
                
                if ((uploadedFile.headRevisionId == (id)[NSNull null]) || (uploadedFile.headRevisionId.length == 0)) {
                    revision = @"a";
                }else{
                    revision = uploadedFile.headRevisionId;
                }
                
                if(![newFileExtension isEqualToString:@""]){
                    isDir = NO;
                    fileNameAndExtensionToActuallyUse = [[uploadedFile.title stringByAppendingString: @"." ] stringByAppendingString: newFileExtension];
                }else{
                    fileNameAndExtensionToActuallyUse = uploadedFile.title;
                }
                
                //update the json on teh filesystem and selected files with the
                //appropriate google file id (so it can be immediately deleted).
                NSMutableArray* loadingDirProxy = [[NSMutableArray alloc] init];
                [[self fsInterface] populateArrayWithFileSystemJSON:loadingDirProxy inDirectoryPath:newDir.parentURLPath];
                
                //DO NOT REGULARIZE SELECTED FILES FOR FOLDERS THEY CAN't BE SELECTED WHILE LOADING CUZ THEY DONT LOAD
                
                //find and update the "boxid" field with the right google id for this file
                //that was jsut loaded in.
                for(File* potentialLoadedFile in loadingDirProxy){
                    if ([potentialLoadedFile.name isEqualToString:fileNameAndExtensionToActuallyUse]){
                        potentialLoadedFile.boxid = uploadedFile.identifier;
                    }
                }
                
                //delete old filesystem.json
                [[self fsInterface] deleteFileAtPath:[newDir.parentURLPath stringByAppendingPathComponent:@".filesystem.json"]];
                
                //add all files and the old filesystem.json back to disk.
                [[self fsInterface] saveArrayToFileSystemJSON:loadingDirProxy inDirectoryPath:newDir.parentURLPath];
                
                //reset current directory array and selected files
                [[[self fsAbstraction] currentDirectory] removeAllObjects];
                [[[self fsAbstraction] currentDirectory] addObjectsFromArray:loadingDirProxy];
                
                //reset teh folders/nonfolders arrays
                [[NSNotificationCenter defaultCenter] postNotificationName:@"splitFoldersAndDontReloadCollectionView" object:self];
                
                //recursively trigger the upload on a folder than finishes.
                [[self fsInterface] populateArrayWithFileSystemJSON:prepareToSaveFilesOthArray inDirectoryPath:oldFile.path];
                for(File* child in prepareToSaveFilesOthArray){
                    [self pullFilesToUploadFromOther:child withParentId:uploadedFile.identifier withQueryWrapper:passedQueryWrapper];
                }
            }else{
                
                NSLog(@"An error IN UPLOAD occurred: %@", error);
                
                //decrement global request queue
                _globalActiveRequestCount--;
                
                GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:driveFile uploadParameters:nil];
                GTLServiceTicket* uploadTicket = [[GTLServiceTicket alloc] initWithService:_driveService];
                
                //if we're maxed out
                if([self globalActiveRequestsMaxedOut]){
                    
                    NSLog(@" MAXED OUT loadFileFailedWithError : path1: %@, path2: %@",[error.userInfo objectForKey:@"path"], [error.userInfo objectForKey:@"destinationPath"]);
                    GDOperationWrapper* operationWrapper = [[GDOperationWrapper alloc] initWithSeviceTicketOrFetcher:uploadTicket andPath1:newDir.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE andFilename:nil];
                    [operationWrapper setDriveQuery:query];
                    [operationWrapper setUploadCompletionBlock:uploadCompletionBlock];
                    [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                    
                }else{
                    
                    NSLog(@"NOT MAXED OUT loadFileFailedWithError : path1: %@, path2: %@",[error.userInfo objectForKey:@"path"], [error.userInfo objectForKey:@"destinationPath"]);
                    // GTL service ticket class has some kind of progress block on it.
                    uploadTicket = [_driveService executeQuery:query completionHandler:uploadCompletionBlock];
                    _globalActiveRequestCount++;
                    [self dequeueDBOperationsUpToGlobalMax];
                }
            }
        };
        
        GTLQueryDrive *query1 = [GTLQueryDrive queryForFilesInsertWithObject:driveFile uploadParameters:nil];
        // GTL service ticket class has some kind of progress block on it.
        [_driveService executeQuery:query1 completionHandler:uploadCompletionBlock];
        
    }else{
        
        NSString* pathForNewFile = [[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:oldFile.path]stringByDeletingLastPathComponent];
        
        // while the path leading up to the file is not valid delete the path component at
        // the start of the path right after /Documents
        // /Documents/Local/Manual/somefile/blah becomes /Documents/Local/somefile/blah becomes /Documents/Local/blah
        while (![[self fsInterface] isValidPath:pathForNewFile]){
            
            pathForNewFile = [self urlPathMiddleOut:pathForNewFile onQueryWrapper:passedQueryWrapper];
        }
        
        File* newFile = [[File alloc] initWithName:oldFile.name andPath:[pathForNewFile stringByAppendingPathComponent:oldFile.name] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:NO andBoxId:@"-1"];
        
        // we don't want to move the filesystem.json file...
        if(![newFile.name isEqualToString:@".filesystem.json"]){
            
            //create the file loading object
            [_gdServiceManagerDelegate gdCreateFileLoadingObjectWithFile:newFile andReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
            
            [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
            
            // - get the mim type for a particular file's path extension - //
            CFStringRef pathExtension = (__bridge_retained CFStringRef)[oldFile.path pathExtension];
            CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
            CFRelease(pathExtension);
            
            // The UTI can be converted to a mime type:
            
            NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
            if (type != NULL)
                CFRelease(type);
            
            //setup the google drive file object to upload
            GTLDriveFile* driveFile = [GTLDriveFile object];
            driveFile.title = oldFile.name;
            driveFile.mimeType = mimeType;
            GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
            parentRef.identifier = (parentID) ? parentID : @"";
            driveFile.parents = (parentID) ? @[parentRef] : @[];
            
            void (^uploadCompletionBlock)(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error) = ^(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error) {
                
                if(error == nil){
                    
                    //destroy the query limit object upon successful completion of file download
                    [self destroyObjectFromQueryLimitQueueWithPath1:newFile.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE];
                    
                    //decrement the global requet count and
                    //check if we can dequeue mor stuff
                    _globalActiveRequestCount--;
                    if(![self globalActiveRequestsMaxedOut]){
                        [self dequeueDBOperationsUpToGlobalMax];
                    }
                    
                    // if we don't send a progress event on finish then the animation can
                    // freeze
                    CGFloat progress = 1.0;
                    [_reloadCollectionViewProgressDelegate reloadCollectionViewFilePath:newFile.path withProgress:progress withReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
                    
                    NSLog(@"File uploaded: %@", uploadedFile.title);
                    
                    //purpose of thos code is to imemdtaiely update the google drive id
                    //on the disk so user can delete the thing w/o having to reload
                    
                    BOOL isDir = NO;
                    NSString* revision = @"";
                    NSString* newFileExtension = @"";
                    NSString* fileNameAndExtensionToActuallyUse = @"";
                    NSString* specialDownloadString = @"";
                    NSMutableDictionary *jsonDict = uploadedFile.exportLinks.JSON;
                    
                    for(NSString* filetype in jsonDict){
                        //special check for pptx, docx, xlsx,
                        //get the export path.
                        if ([filetype containsString:@"application/vnd.openxmlformats"]) { // then we're dealing with pptx, docx, or xlsx
                            NSString* exportpath = [jsonDict objectForKey:filetype];
                            NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                            newFileExtension = [arrayWithTwoStrings lastObject];
                            specialDownloadString = exportpath;
                            
                            //it it's a special drawing file.
                        }else if([uploadedFile.mimeType isEqualToString:@"application/vnd.google-apps.drawing"]){ // we're dealing with google drawing
                            NSString* exportpath = [jsonDict objectForKey:@"image/png"];
                            NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                            newFileExtension = [arrayWithTwoStrings lastObject];
                            specialDownloadString = exportpath;
                            
                        } // all other intrinsic mime types native to google docs do not have export URLS.
                    }
                    
                    if ((uploadedFile.fileExtension == (id)[NSNull null]) || (uploadedFile.fileExtension.length == 0)){
                        isDir = YES;
                    }else{
                        isDir = NO;
                    }
                    
                    if ((uploadedFile.headRevisionId == (id)[NSNull null]) || (uploadedFile.headRevisionId.length == 0)) {
                        revision = @"a";
                    }else{
                        revision = uploadedFile.headRevisionId;
                    }
                    
                    if(![newFileExtension isEqualToString:@""]){
                        isDir = NO;
                        fileNameAndExtensionToActuallyUse = [[uploadedFile.title stringByAppendingString: @"." ] stringByAppendingString: newFileExtension];
                    }else{
                        fileNameAndExtensionToActuallyUse = uploadedFile.title;
                    }
                    
                    //update the json on teh filesystem and selected files with the
                    //appropriate google file id (so it can be immediately deleted).
                    NSMutableArray* loadingDirProxy = [[NSMutableArray alloc] init];
                    [[self fsInterface] populateArrayWithFileSystemJSON:loadingDirProxy inDirectoryPath:newFile.parentURLPath];
                    
                    //regularizze/update selected files with proper boxid fields
                    //for unqiue google identifiers
                    for(File* selectedFile in [[self fsAbstraction] selectedFiles]){
                        //if the selected file is the same
                        if([selectedFile.path isEqualToString:newFile.path]){
                            selectedFile.boxid = uploadedFile.identifier;
                        }
                    }
                    
                    //find and update the "boxid" field with the right google id for this file
                    //that was jsut loaded in.
                    for(File* potentialLoadedFile in loadingDirProxy){
                        if ([potentialLoadedFile.name isEqualToString:fileNameAndExtensionToActuallyUse]){
                            potentialLoadedFile.boxid = uploadedFile.identifier;
                        }
                    }
                    
                    //delete old filesystem.json
                    [[self fsInterface] deleteFileAtPath:[newFile.parentURLPath stringByAppendingPathComponent:@".filesystem.json"]];
                    
                    //add all files and the old filesystem.json back to disk.
                    [[self fsInterface] saveArrayToFileSystemJSON:loadingDirProxy inDirectoryPath:newFile.parentURLPath];
                    
                    //reset current directory array and selected files
                    [[[self fsAbstraction] currentDirectory] removeAllObjects];
                    [[[self fsAbstraction] currentDirectory] addObjectsFromArray:loadingDirProxy];
                    
                    //reset teh folders/nonfolders arrays to includ new objects w/ new ids
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"splitFoldersAndDontReloadCollectionView" object:self];
                    
                }else{
                    NSLog(@"An error in FILE UPLOAD occurred: %@", error);
                    
                    NSLog(@"An error IN UPLOAD occurred: %@", error);
                    
                    //decrement global request queue
                    _globalActiveRequestCount--;
                    
                    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:driveFile uploadParameters:nil];
                    GTLServiceTicket* uploadTicket = [[GTLServiceTicket alloc] initWithService:_driveService];
                    
                    if (![self overQueryOccurrenceLimitForQueryWithPath1:newFile.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE]) {
                        //if we're maxed out
                        if([self globalActiveRequestsMaxedOut]){
                            
                            NSLog(@" MAXED OUT loadFileFailedWithError : path1: %@, path2: %@",[error.userInfo objectForKey:@"path"], [error.userInfo objectForKey:@"destinationPath"]);
                            GDOperationWrapper* operationWrapper = [[GDOperationWrapper alloc] initWithSeviceTicketOrFetcher:uploadTicket andPath1:newFile.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE andFilename:nil];
                            [operationWrapper setDriveQuery:query];
                            [operationWrapper setUploadCompletionBlock:uploadCompletionBlock];
                            [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                            
                        }else{
                            
                            NSLog(@"NOT MAXED OUT loadFileFailedWithError : path1: %@, path2: %@",[error.userInfo objectForKey:@"path"], [error.userInfo objectForKey:@"destinationPath"]);
                            // GTL service ticket class has some kind of progress block on it.
                            uploadTicket = [_driveService executeQuery:query completionHandler:uploadCompletionBlock];
                            
                            GDQueryLimitWrapper* queryLimitWrapper = [[GDQueryLimitWrapper alloc] initWithServiceTicketOrFetcher:uploadTicket Path1:newFile.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE];
                            [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                            
                            _globalActiveRequestCount++;
                            [self dequeueDBOperationsUpToGlobalMax];
                        }
                    }
                }
            };
            
            GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:[[self fsInterface] getDataForfilePath:oldFile.path] MIMEType:mimeType];
            GTLQueryDrive* query = [GTLQueryDrive queryForFilesInsertWithObject:driveFile uploadParameters:uploadParameters];
            GTLServiceTicket* uploadTicket = [[GTLServiceTicket alloc] initWithService:_driveService];
            
            if (![self overQueryOccurrenceLimitForQueryWithPath1:newFile.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE]) {
                if ([self globalActiveRequestsMaxedOut]) {
                    GDOperationWrapper* operationWrapper = [[GDOperationWrapper alloc] initWithSeviceTicketOrFetcher:uploadTicket andPath1:newFile.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE andFilename:nil];
                    [operationWrapper setDriveQuery:query];
                    [operationWrapper setUploadCompletionBlock:uploadCompletionBlock];
                    [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                } else {
                    uploadTicket = [_driveService executeQuery:query completionHandler:uploadCompletionBlock];
                    
                    GDQueryLimitWrapper* queryLimitWrapper = [[GDQueryLimitWrapper alloc] initWithServiceTicketOrFetcher:uploadTicket Path1:newFile.path andPath2:oldFile.path andTypeOfQuery:GDUPLOADFILE];
                    [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                    
                    _globalActiveRequestCount++;
                    [self dequeueDBOperationsUpToGlobalMax];
                }
            }
            
            //add an entry in the query wrapper mapping this particular fetcher to the path where we're downloading the file
            //basically this fetcher now becomes linked to that downloading file and can be used to cancel just that file
            [passedQueryWrapper setObject:uploadTicket forKeyInDownloadPathToFetcher:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:newFile.path]];
            
            [passedQueryWrapper incrementCustomRequestCount];
            //I kept this block in the global state because I didn't want to search for the client on
            //every upload progress event, it's ok. [passedQueryWrapper getStoredReduceStackToPath]
            // requires the state of this function.
            
            [uploadTicket setUploadProgressBlock:^(GTLServiceTicket *ticket, unsigned long long totalBytesWritten, unsigned long long totalBytesExpectedToWrite)
             {
                 CGFloat progress = ((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
                 NSLog(@"BYTES WRITTEN: %llu EXPECTED BYTES: %llu", totalBytesWritten, totalBytesExpectedToWrite);
                 NSLog(@"PROGRESS %f", progress);
                 [_reloadCollectionViewProgressDelegate reloadCollectionViewFilePath:newFile.path withProgress:progress withReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
             }];
        }
    }
    
    if([[passedQueryWrapper getStoredReduceStackToPath] isEqualToString:[[self fsAbstraction] reduceStackToPath]]){
        [[self fsInterface]populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getStoredReduceStackToPath]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
    }
    
    //uncommented because we use unselect all images now instead of reload on collection view
//    if([passedQueryWrapper getMoveToGDPressed]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
//    }
//    if([passedQueryWrapper getMoveFromGDPressed]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
//    }
}

- (void) navigationLoadWithQueryWrapper:(GDQueryWrapper*)passedQueryWrapper {
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    
    // This query works because the only thing that ever gets passed to it are files
    // this format of query "%@ in PARENTS will not work on non directory fiels
    if ([[passedQueryWrapper getPassedFile].name isEqualToString:@"GoogleDrive"]){
        query.q = [NSString stringWithFormat:@"'%@' IN parents", @"root"];
    }else{
        query.q = [NSString stringWithFormat:@"'%@' IN parents", [passedQueryWrapper getPassedFile].boxid];
    }
    //set the service ticket into the passedQuery wrapper to point to the global navigation service ticket object
    [passedQueryWrapper setServiceTicket:[self serviceTicketForNavigationLoad]];
    //get the result of the this query to also point to the global service ticket object.
    if([passedQueryWrapper getTypeOfQuery] == GDLOADMETADATASELECTED){
        [self setNavigationLoadServiceTicket:[_driveService executeQuery:query completionHandler:[self getSelectedFilesMetadataBlockWithQueryWrapper:passedQueryWrapper]]];
    }else{
        [self setNavigationLoadServiceTicket:[_driveService executeQuery:query completionHandler:[self getBasicMetadataBlockWithQueryWrapper:passedQueryWrapper]]];
    }
    [passedQueryWrapper incrementCustomRequestCount];
}

/*  - loads files in recursively the export them to another folder
    - this load will beam them direclty into the new folder
    - this algorithnm takes the fiel object that was called
    - upon recursively. If the files in the selected array 
    - are folders we have to do a complex recursion,
    - in the other case
    */

-(void) loadFilesRecursively:(File*)recursionFile andQueryWrapper:(GDQueryWrapper*)passedQueryWrapper isSelectedFile:(BOOL)isSelected{
    
    GTLQueryDrive *query  = [[GTLQueryDrive alloc] init];
        
    //BEGIN RECURSION FILE IS DIRECTORY BLOCK
    if(recursionFile.isDirectory){
        
        //for saving metadata of getting the children of a directory
        //this trigggers when we get the metadata for a file
        //inside we make sure there was no error
        //then we go through all the files.
        
        //BEGIN METADATA COMPLETION BLOCK
        void (^queryDirMetaDataCompletionBlock) (GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) = ^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) {
            
            //BEGIN NO ERROR
            if (error == nil){
                
                BOOL isDir = NO;
                NSString* revision = @"";
                //BEGIN FOR LOOP
                for(int i=0; i<[files.items count]; i++){
                    
                    NSString* newFileExtension = @"";
                    NSString* fileNameAndExtensionToActuallyUse = @"";
                    NSMutableDictionary *jsonDict = ((GTLDriveFile*)[files.items objectAtIndex:i]).exportLinks.JSON;
                    NSString* specialDownloadString = @"";
                    GTMHTTPFetcher* fetcher;
                    
                    for(NSString* filetype in jsonDict){
                        //special check for pptx, docx, xlsx,
                        //get the export path.
                        if ([filetype containsString:@"application/vnd.openxmlformats"]) { // then we're dealing with pptx, docx, or xlsx
                            NSString* exportpath = [jsonDict objectForKey:filetype];
                            NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                            newFileExtension = [arrayWithTwoStrings lastObject];
                            specialDownloadString = exportpath;
                            
                        //it it's a special drawing file.
                        }else if([((GTLDriveFile*)[files.items objectAtIndex:i]).mimeType isEqualToString:@"application/vnd.google-apps.drawing"]){ // we're dealing with google drawing
                            NSString* exportpath = [jsonDict objectForKey:@"image/png"];
                            NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                            newFileExtension = [arrayWithTwoStrings lastObject];
                            specialDownloadString = exportpath;

                        } // all other intrinsic mime types native to google docs do not have export URLS.
                    }
                    
                    // cerate the Gdrive file object and make sure it's extensions
                    //are properly setup
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
                    
                    //if the file from the list is a directory
                    //RECURSIVE CASE
                    if(isDir){ // if it's a directory make the recursive call on the newly created file.
                        NSString* pathForNewDirTemp = [[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:[[self fsInterface] resolveFilePath:recursionFile.path excludingUpToDirectory:@"GoogleDrive"]];
                        
                        //check if the parent is presentat at new location, it it's not then save directly in place we want to move to.
                        
                        while (![[self fsInterface] isValidPath:pathForNewDirTemp]) {
                            
                            pathForNewDirTemp = [self urlPathMiddleOut:pathForNewDirTemp onQueryWrapper:passedQueryWrapper];
                        }
                        
                        NSString* pathForNewDir = [pathForNewDirTemp stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse];

                        File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:pathForNewDir andDate:[NSDate date] andRevision:revision andDirectoryFlag:isDir andBoxId:file.identifier];
                        
                        //if the encoded file name is too long truncate that thing and its path
                        if([newFile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
                            NSString* extension = [newFile.name pathExtension];
                            newFile.name = [[newFile.name substringToIndex:newFile.name.length/2] stringByAppendingPathExtension:extension];
                            newFile.path = [[newFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name];
                            fileNameAndExtensionToActuallyUse = newFile.name;
                        }
                        
                        [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
                        [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
                        
                        //if we even get one Directory we are not at the bottom level.
                        //make a recursive call to the method with the next folder/file object
                        [self loadFilesRecursively:newFile andQueryWrapper:passedQueryWrapper isSelectedFile:NO];
                        
                    // BASE CASE
                    }else{ // if it's a file to send then download the file, and save if to our filesToSend directory
                        
                        
                        NSString* pathForNewFile = [[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:[[self fsInterface] resolveFilePath:recursionFile.path excludingUpToDirectory:@"GoogleDrive"]];
                        
                        while (![[self fsInterface] isValidPath:pathForNewFile]) {
                            
                            pathForNewFile = [self urlPathMiddleOut:pathForNewFile onQueryWrapper:passedQueryWrapper];
                        }
                        
                        File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:[pathForNewFile stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse] andDate:[NSDate date] andRevision:revision andDirectoryFlag:isDir andBoxId:file.identifier];
                        
                        // we don't want to move the filesystem.json file...
                        if(![newFile.name isEqualToString:@".filesystem.json"]){
                        
                            //if the encoded file name is too long truncate that thing and its path
                            if([newFile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
                                NSString* extension = [newFile.name pathExtension];
                                newFile.name = [[newFile.name substringToIndex:newFile.name.length/2] stringByAppendingPathExtension:extension];
                                newFile.path = [[newFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name];
                                fileNameAndExtensionToActuallyUse = newFile.name;
                            }
                            
                            //create the file loading object
                            [_gdServiceManagerDelegate gdCreateFileLoadingObjectWithFile:newFile andReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
                            //save new file to JSON
                            [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
                            //create a dummy file there to recieve incoming google drive data
                            [[self fsInterface] createFileAtPath:newFile.path contents:nil attributes:nil];
                            
                            void (^fetcherDataCompletionBlock)(NSData *data, NSError *error) = ^(NSData *data, NSError *error) {
                                //if there's no error
                                if (error == nil) {
                                    
                                    //destroy the query limit object upon successful completion of file download
                                    [self destroyObjectFromQueryLimitQueueWithPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE];
                                    
                                    _globalActiveRequestCount--;
                                    if(![self globalActiveRequestsMaxedOut]){
                                        [self dequeueDBOperationsUpToGlobalMax];
                                    }
                                    
                                    [passedQueryWrapper decrementCustomRequestCount];
                                    // create a file with the retrieved data, save it to JSON, and add it to Files to Send.
                                    [[self fsInterface] createFileAtPath:[pathForNewFile stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse] contents:data attributes:nil];
                                
                                //if there is an error
                                } else {
                                    NSLog(@"GLOBAL COUNT ONEL %d", _globalActiveRequestCount);
                                    //if we haven't exceeded this particular request's failure count
                                    if (![self overQueryOccurrenceLimitForQueryWithPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE]) {
                                        if ([self globalActiveRequestsMaxedOut]) {
                                            
                                            NSLog(@"GOOGLE DRIVE MAXED OUT beginFetchWithCompletionHandler: FILENAME: %@", fileNameAndExtensionToActuallyUse);
                                            GDOperationWrapper* operationWrapper = [[GDOperationWrapper alloc] initWithSeviceTicketOrFetcher:fetcher andPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE andFilename:fileNameAndExtensionToActuallyUse];
                                            [operationWrapper setFetcherDataCompletionBlock:fetcherDataCompletionBlock];
                                            [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                                            
                                        } else {
                                            NSLog(@"GOOGLE DRIVE NOT MAXED OUT beginFetchWithCompletionHandler: FILENAME: %@", fileNameAndExtensionToActuallyUse);
                                            
                                            //start getting the thing.
                                            [fetcher beginFetchWithCompletionHandler:fetcherDataCompletionBlock];
                                            
                                            //add to the global query limit array if it doesn't already exist.
                                            GDQueryLimitWrapper* queryLimitWrapper = [[GDQueryLimitWrapper alloc] initWithServiceTicketOrFetcher:fetcher Path1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE];
                                            [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                                            
                                            _globalActiveRequestCount++;
                                            //dequeue stuff until we're at the max.
                                            [self dequeueDBOperationsUpToGlobalMax];
                                        }
                                    }
                                }
                            };
                            
                            //make sure the file has a download url
                            if(((GTLDriveFile*)[files.items objectAtIndex:i]).downloadUrl != NULL){
                                
                                fetcher = [_driveService.fetcherService fetcherWithURLString:((GTLDriveFile*)[files.items objectAtIndex:i]).downloadUrl];
                            } else {// if there is no download url then we throw some kind of error message to the user
                                
                                fetcher = [_driveService.fetcherService fetcherWithURLString:specialDownloadString];
                            }

                            // - actually download the file data and not just its metadata need a new query - //
                            fetcher.delegate = self;
                            fetcher.retryEnabled = YES;
                            [fetcher setReceivedDataBlock:^(NSData *data) {
                                
                                CGFloat progress = (100.0 / [file.fileSize longLongValue] * [data length]) / 100.0;
                                
    //                            NSLog(@"PROGRESS : %f", progress / 1);
                                NSString* pathForNewFile = [[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:[[self fsInterface] resolveFilePath:recursionFile.path excludingUpToDirectory:@"GoogleDrive"]];
                                
                                while (![[self fsInterface] isValidPath:pathForNewFile]) {
                                    
                                    pathForNewFile = [self urlPathMiddleOut:pathForNewFile onQueryWrapper:passedQueryWrapper];
                                }
                                
                                [_reloadCollectionViewProgressDelegate reloadCollectionViewFilePath:[pathForNewFile stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse] withProgress:progress withReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
                            }];
                            
                            //add an entry in the query wrapper mapping this particular fetcher to the path where we're downloading the file
                            //basically this fetcher now becomes linked to that downloading file and can be used to cancel just that file
                            [passedQueryWrapper setObject:fetcher forKeyInDownloadPathToFetcher:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:newFile.path]];
                            //increment the request counter
                            [passedQueryWrapper incrementCustomRequestCount];
                            
                            NSLog(@"GLOBAL COUNT TWO %d", _globalActiveRequestCount);
                            //if this particular query has not failed the max number of times.
                            if (![self overQueryOccurrenceLimitForQueryWithPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE]) {
                                if ([self globalActiveRequestsMaxedOut]) {
                                    
                                    NSLog(@"GOOGLE DRIVE MAXED OUT beginFetchWithCompletionHandler: FILENAME: %@", fileNameAndExtensionToActuallyUse);
                                    GDOperationWrapper* operationWrapper = [[GDOperationWrapper alloc] initWithSeviceTicketOrFetcher:fetcher andPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE andFilename:fileNameAndExtensionToActuallyUse];
                                    [operationWrapper setFetcherDataCompletionBlock:fetcherDataCompletionBlock];
                                    [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                                    
                                } else {
                                    NSLog(@"GOOGLE DRIVE NOT MAXED OUT beginFetchWithCompletionHandler: FILENAME: %@", fileNameAndExtensionToActuallyUse);
                                    
                                    //start getting the thing.
                                    [fetcher beginFetchWithCompletionHandler:fetcherDataCompletionBlock];
                                    
                                    GDQueryLimitWrapper* queryLimitWrapper = [[GDQueryLimitWrapper alloc] initWithServiceTicketOrFetcher:fetcher Path1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE];
                                                                              
                                    [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                                    
                                    _globalActiveRequestCount++;
                                    //dequeue stuff until we're at the max.
                                    [self dequeueDBOperationsUpToGlobalMax];
                                }
                            }
                        }
                    }
                }
                //END FOR LOOP
            }
            //END NO ERROR
            //BEGIN ERROR BLOCK
            else {

            }
            //END ERROR BLOCK
            
            if([[passedQueryWrapper getStoredReduceStackToPath] isEqualToString:[[self fsAbstraction]reduceStackToPath]]){
                [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getStoredReduceStackToPath]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];

            }
            if([passedQueryWrapper getMoveToGDPressed]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
            }
            if([passedQueryWrapper getMoveFromGDPressed]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
            }
        };
        //END METADATA COMPLETION BLOCK
        
        // saves an originally selected file if it's a directory and gets recursively passed into the function
        // only affects the recursionfile, does NOT perfrom recursive operations
        
       //BEGIN SELECTED DIRECTORY METADATA COMPLETIONBLOCK
       void (^queryOriginalSelectedDirMetaDataCompletionBlock) (GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error)= ^(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error) {
           
           if (error == nil){
               
               BOOL isDir = NO;
               NSString* revision = @"";
               
                   NSString* newFileExtension = @"";
                   NSString* fileNameAndExtensionToActuallyUse = @"";
                   NSMutableDictionary *jsonDict = file.exportLinks.JSON;
               
                   for(NSString* filetype in jsonDict){
                       //nedd this if to get metadata for files and proper extensions
                       if ([filetype containsString:@"application/vnd.openxmlformats"]) { // then we're dealing with pptx, docx, or xlsx
                           NSString* exportpath = [jsonDict objectForKey:filetype];
                           NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                           newFileExtension = [arrayWithTwoStrings lastObject];
                        
                       }else if([file.mimeType isEqualToString:@"application/vnd.google-apps.drawing"]){ // we're dealing with google drawing
                           NSString* exportpath = [jsonDict objectForKey:@"image/png"];
                           NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                           newFileExtension = [arrayWithTwoStrings lastObject];
                       } // all other intrinsic mime types native to google docs do not have export URLS.
                   }
               
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
               
                    File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse] andDate:[NSDate date] andRevision:revision andDirectoryFlag:isDir andBoxId:file.identifier];
               
                   // we don't want to move the filesystem.json file...
                   if(![newFile.name isEqualToString:@".filesystem.json"]){
               
                        //if the encoded file name is too long truncate that thing and its path
                        if([newFile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
                            NSString* extension = [newFile.name pathExtension];
                            newFile.name = [[newFile.name substringToIndex:newFile.name.length/2] stringByAppendingPathExtension:extension];
                            newFile.path = [[newFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name];
                            fileNameAndExtensionToActuallyUse = newFile.name;
                        }
                   
                        if(isDir){
                            [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
                        }
                        [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
                    }
               
               //since this entire block is for dealing with initailly selected files we need to make the query to get
               // the initially selected files' children here once the first callback finishes and not below.
               GTLQueryDrive *query  = [[GTLQueryDrive alloc] init];
               query = [GTLQueryDrive queryForFilesList];
               query.q = [NSString stringWithFormat:@"'%@' IN parents", recursionFile.boxid];
               
               [_driveService executeQuery:query completionHandler:queryDirMetaDataCompletionBlock];
           }
           
           if([[passedQueryWrapper getStoredReduceStackToPath] isEqualToString:[[self fsAbstraction] reduceStackToPath]]){
               
               [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getStoredReduceStackToPath]];
               [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
           }
           if([passedQueryWrapper getMoveToGDPressed]){
               [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
           }
           if([passedQueryWrapper getMoveFromGDPressed]){
               [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
           }
        };
        //END SELECTED DIRECTORY METADATA COMPLETIONBLOCK
        
        //teh reason I did not put the below queries service tickets
        //into a gdquery wrapper is because if they fail, they don't
        //affect anything.

        if (isSelected) {
            //query to save the original file (will only trigger on directories)
            query = [GTLQueryDrive queryForFilesGetWithFileId:recursionFile.boxid];
            [_driveService executeQuery:query completionHandler:queryOriginalSelectedDirMetaDataCompletionBlock];
            
        }else{ // recursionfile directory is not a selected file,
            //query to get metadata on the original file's children.
            query = [GTLQueryDrive queryForFilesList];
            query.q = [NSString stringWithFormat:@"'%@' IN parents", recursionFile.boxid];
            [_driveService executeQuery:query completionHandler:queryDirMetaDataCompletionBlock];
        }
    }
    //END RECURSION FILE IS DIRECTORY BLOCK
    
    //BEGIN RECURSION FILE IS NOT A DIRECTORY BLOCK
    else{//get metadata for the file, only, this is a bit redundant, it only downloads the file metdata
        //this else just makes it so that files that are originally selected in the selected array
        //can just have their meta data queried and then file url downloaded directly from a url
           
           //- this block gets triggered first and returns the meta data for a single selected file
           void (^queryFileMetaDataCompletionBlock)(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error)  = ^(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error) {
               
               if(error == nil){
                   
                   NSString* revision = @"";
                   NSString* newFileExtension = @"";
                   NSString* fileNameAndExtensionToActuallyUse = @"";
                   NSMutableDictionary *jsonDict = file.exportLinks.JSON;
                   NSString* specialDownloadString = @"";
                   
                   GTMHTTPFetcher* fetcher;
                   
                   for(NSString* filetype in jsonDict){
                       if ([filetype containsString:@"application/vnd.openxmlformats"]) { // then we're dealing with pptx, docx, or xlsx
                           NSString* exportpath = [jsonDict objectForKey:filetype];
                           NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                           newFileExtension = [arrayWithTwoStrings lastObject];
                           specialDownloadString = exportpath;
                           
                       }else if([file.mimeType isEqualToString:@"application/vnd.google-apps.drawing"]){ // we're dealing with google drawing
                           NSString* exportpath = [jsonDict objectForKey:@"image/png"];
                           NSArray *arrayWithTwoStrings = [exportpath componentsSeparatedByString:@"exportFormat="];
                           newFileExtension = [arrayWithTwoStrings lastObject];
                           specialDownloadString = exportpath;
                       } // all other intrinsic mime types native to google docs do not have export URLS.
                   }
                   
                   if ((file.headRevisionId == (id)[NSNull null]) || (file.headRevisionId.length == 0)) {
                       revision = @"a";
                   }else{
                       revision = file.headRevisionId;
                   }
                   
                   if(![newFileExtension isEqualToString:@""]){
                       fileNameAndExtensionToActuallyUse = [[file.title stringByAppendingString: @"." ] stringByAppendingString: newFileExtension];
                   }else{
                       fileNameAndExtensionToActuallyUse = file.title;
                   }
                   
                   //only needs to the be _storedreducestck + file name
                   //DO NOT NEED THE URLMIDDLE OUT, WHILE LOOP
                   //this is because all files here are directly selected
                   //files meaning they will go straight into stored reduce stack to path +name.
                   File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse] andDate:[NSDate date] andRevision:revision andDirectoryFlag:NO andBoxId:file.identifier];
                   
                   // we don't want to move the filesystem.json file...
                   if(![newFile.name isEqualToString:@".filesystem.json"]){
                   
                           //if the encoded file name is too long truncate that thing and its path
                           if([newFile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
                               NSString* extension = [newFile.name pathExtension];
                               newFile.name = [[newFile.name substringToIndex:newFile.name.length/2] stringByAppendingPathExtension:extension];
                               newFile.path = [[newFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name];
                               fileNameAndExtensionToActuallyUse = newFile.name;
                           }
                           
                           //create the file loading object
                           [_gdServiceManagerDelegate gdCreateFileLoadingObjectWithFile:newFile andReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
                           
                           //save new fiel to JSON
                           [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
                           
                           //create a dummy file so the path can be valid and progress events will trigger a loading animation
                           [[self fsInterface] createFileAtPath:newFile.path contents:nil attributes:nil];
                           
                           // completion block for the call to beginFetchWithCompletionHandler
                           // this block triggers second and gets physical files data (bytes)
                           // based on the meta data in the original callback.
                           void (^fetcherDataCompletionBlock) (NSData *data, NSError *error) = ^(NSData *data, NSError *error){
                               
                               if (error == nil) {
                                   
                                   //destroy the query limit object upon successful completion of file download
                                   [self destroyObjectFromQueryLimitQueueWithPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE];
                                   
                                   _globalActiveRequestCount--;
                                   if(![self globalActiveRequestsMaxedOut]){
                                       [self dequeueDBOperationsUpToGlobalMax];
                                   }
                                   // create a file with the retrieved data, save it to JSON, and add it to Files to Send.
                                   File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse] andDate:[NSDate date] andRevision:revision andDirectoryFlag:NO andBoxId:file.identifier];
                                   
                                   [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
                                   
                                   [[self fsInterface] createFileAtPath:[[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse] contents:data attributes:nil];
                                   [passedQueryWrapper decrementCustomRequestCount];
                                   
                               } else {
                                   
                                   NSLog(@"GLOBAL COUNT THREE %d", _globalActiveRequestCount);
                                   if (![self overQueryOccurrenceLimitForQueryWithPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE]) {
                                       NSLog(@"GLOBAL COUNT THREE %d", _globalActiveRequestCount);
                                       if ([self globalActiveRequestsMaxedOut]) {
                                           
                                           NSLog(@"MAXED OUT beginFetchWithCompletionHandler, FILENAME: %@ ", fileNameAndExtensionToActuallyUse);
                                           
                                           GDOperationWrapper* operationWrapper = [[GDOperationWrapper alloc] initWithSeviceTicketOrFetcher:fetcher andPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE andFilename:fileNameAndExtensionToActuallyUse];
                                           [operationWrapper setFetcherDataCompletionBlock:fetcherDataCompletionBlock];
                                           [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                                           
                                       } else {
                                           
                                           NSLog(@"NOT MAXED OUT beginFetchWithCompletionHandler, FILENAME: %@", fileNameAndExtensionToActuallyUse);
                                           
                                           NSLog(@"FETCHERDATA COMPLETION BLOCK %@", fetcherDataCompletionBlock);
                                           
                                           //actually fetch the file data
                                           [fetcher beginFetchWithCompletionHandler:fetcherDataCompletionBlock];
                                           
                                           GDQueryLimitWrapper* queryLimitWrapper = [[GDQueryLimitWrapper alloc] initWithServiceTicketOrFetcher:fetcher Path1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE];
                                           
                                           [self addObjectToQueryLimitQueueIfNotExists:queryLimitWrapper];
                                           
                                           _globalActiveRequestCount++;
                                           [self dequeueDBOperationsUpToGlobalMax];
                                       }
                                   }
                               }
                           };
                       
                       //make sure the file has a download url
                       if(file.downloadUrl != NULL){
                           fetcher = [_driveService.fetcherService fetcherWithURLString:file.downloadUrl];
                       } else {// if there is no download url then we throw some kind of error message to the user
                           fetcher = [_driveService.fetcherService fetcherWithURLString:specialDownloadString];
                       }
                       
                       // - actually make the call to get data from google drive. and completionHandler trigger's the above block - //
                       fetcher.delegate = self;
                       fetcher.retryEnabled = YES;
                       [fetcher setReceivedDataBlock:^(NSData *data) {
                           
                           CGFloat progress = (100.0 / [file.fileSize longLongValue] * [data length]) / 100.0;
    //                       NSLog(@"PROGRESS : %f", progress / 1);
                           NSString* pathForNewFile = [[passedQueryWrapper getStoredReduceStackToPath] stringByAppendingPathComponent:fileNameAndExtensionToActuallyUse];
                           [_reloadCollectionViewProgressDelegate reloadCollectionViewFilePath:pathForNewFile withProgress:progress withReduceStack:[passedQueryWrapper getStoredReduceStackToPath]];
                       }];
                       
                       //add an entry in the query wrapper mapping this particular fetcher to the path where we're downloading the file
                       //basically this fetcher now becomes linked to that downloading file and can be used to cancel just that file
                       [passedQueryWrapper setObject:fetcher forKeyInDownloadPathToFetcher:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:newFile.path]];
                       
                       //increment the request count
                       [passedQueryWrapper incrementCustomRequestCount];
                       
                       NSLog(@"GLOBAL COUNT LAST: %d", _globalActiveRequestCount);
                       if ([self globalActiveRequestsMaxedOut]) {
                           
                           NSLog(@"MAXED OUT beginFetchWithCompletionHandler, FILENAME: %@ ", fileNameAndExtensionToActuallyUse);
                           
                           GDOperationWrapper* operationWrapper = [[GDOperationWrapper alloc] initWithSeviceTicketOrFetcher:fetcher andPath1:recursionFile.path andPath2:newFile.path andTypeOfQuery:GDLOADFILE andFilename:fileNameAndExtensionToActuallyUse];
                           [operationWrapper setFetcherDataCompletionBlock:fetcherDataCompletionBlock];
                           [self queueDBOperationOnGlobalRequestQueue:operationWrapper];
                           
                       } else {
                           
                           NSLog(@"NOT MAXED OUT beginFetchWithCompletionHandler, FILENAME: %@", fileNameAndExtensionToActuallyUse);
                           NSLog(@"An error IN DOWNLOAD %@", error);

                           //actually fetch the file data
                           [fetcher beginFetchWithCompletionHandler:fetcherDataCompletionBlock];
                           _globalActiveRequestCount++;
                           [self dequeueDBOperationsUpToGlobalMax];
                       }

                   }
               }
               
               if([[passedQueryWrapper getStoredReduceStackToPath] isEqualToString:[[self fsAbstraction] reduceStackToPath]]){
                   [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getStoredReduceStackToPath]];
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
               }
               if([passedQueryWrapper getMoveToGDPressed]){
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
               }
               if([passedQueryWrapper getMoveFromGDPressed]){
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
               }
           };
           
           // executes the first query to get file metadata from googledrive
           query = [GTLQueryDrive queryForFilesGetWithFileId:recursionFile.boxid];
           [_driveService executeQuery:query completionHandler:queryFileMetaDataCompletionBlock];
       }
    //END RECURSION FILE IS NOT A DIRECTORY BLOCK
}

-(NSString*) getShareableLinksWithFiles:(NSArray*)filesToLinkify {
    
    [[self dictionaryWithShareableLinks] removeAllObjects];
    
    //first set the dictionary keys
    for (File* fileToGetLinkFor in filesToLinkify) {
        NSLog(@"GETTING LINK FOR : %@", fileToGetLinkFor.name);
        NSLog(@"GETTING LINK FOR : %@,", fileToGetLinkFor.boxid);
        //if a key doesn't already exist we add it, don't want to replace keys
        //if the user selects another file much later.
        //keys are unique ids here instead of
        
        LinkJM *linkObject = [[LinkJM alloc] init];
        linkObject.url = @"";
        linkObject.fileName = fileToGetLinkFor.name;
        linkObject.type = [LinkJM LINK_TYPE_GOOGLE_DRIVE];
        
//        if ([[self dictionaryWithShareableLinks] objectForKey:fileToGetLinkFor.path] == nil) {
            [[self dictionaryWithShareableLinks] setObject:linkObject forKey:fileToGetLinkFor.boxid];
//        }
    }
    
    //create a new permission to add to the file
    GTLDrivePermission* newPermissionForFile = [GTLDrivePermission object];
    newPermissionForFile.type = @"anyone";
    newPermissionForFile.role = @"reader";
    
    void (^queryFileMetaDataCompletionBlock)(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error)  = ^(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error) {
        //there was no error from getting the file
        if (error == nil) {
            NSString *downloadLink = file.alternateLink;
            
            if (file.webContentLink == nil) {
                [_sendLinksFromServiceManagerDelegate sendLinkDictionaryFailedToRetrieveAllLinks];
            }
            else {
                LinkJM *linkObject = (LinkJM*)[[self dictionaryWithShareableLinks] objectForKey:file.identifier];
                
                if ([linkObject.url isEqualToString:@""]) {
                    NSLog(@"WEBCONTENT link: %@", downloadLink);
                    linkObject.url = downloadLink;
                }
                
                //measure how many empty things are left in the dictionary, shareable links
                //that have not been returned yet.
                int emptyCount = 0;
                for (NSString* key in [self dictionaryWithShareableLinks]) {
                    LinkJM *linkObject = (LinkJM*)[[self dictionaryWithShareableLinks] objectForKey:key];
                    if ([linkObject.url isEqualToString:@""]) {
                        emptyCount++;
                    }
                }
                
                //if none of the things we want links for are missing
                //we have all our our links the user requested, send
                //them back.
                if (emptyCount == 0) {
                    //return a dictionary into the homeview
                    [_sendLinksFromServiceManagerDelegate sendLinkDictionaryFromServiceManagerDelegate:[[NSMutableDictionary alloc] initWithDictionary:[self dictionaryWithShareableLinks]]];
                }
            }
        //there was clearly an error from getting the file
        } else {
            [_sendLinksFromServiceManagerDelegate sendLinkDictionaryFailedToRetrieveAllLinks];
        }
    };
    
    for (File* fileToLinkify in filesToLinkify) {
        //create a query with the new permission and the file's id (there because it's stored in metadata on google drive navigate.
        GTLQueryDrive* queryToAddPermission = [GTLQueryDrive queryForPermissionsInsertWithObject:newPermissionForFile fileId:fileToLinkify.boxid];
        GTLQueryDrive* queryForFileMetadata = [GTLQueryDrive queryForFilesGetWithFileId:fileToLinkify.boxid];
        
        [_driveService executeQuery:queryToAddPermission completionHandler:^(GTLServiceTicket *ticket, GTLDrivePermission *permission, NSError *error) {
            //if we successfully add the permission then get the webContentLink from File metadata
            if (error == nil) {
                [_driveService executeQuery:queryForFileMetadata completionHandler:queryFileMetaDataCompletionBlock];
            } else {
                NSLog(@"An error occurred: %@", error);
                [_sendLinksFromServiceManagerDelegate sendLinkDictionaryFailedToRetrieveAllLinks];
            }
        }];
    }
    
    return @"";
}

/*  - This method basically reduces a url path from the front (excluding the path to the current directory
 - where we are currently located (as returned by pushDirectoryOnToStack). Basically it takes the full
 - potential path to a folder from dropbox and subsequently checks whether a cut off path exists
 - the idea is to always be able to move subdirectories into the new folder.
 - takes /Blah/blah/blah/Documents/Anaphora/Subfile/ - >checks the validity of this path.
 - turns it into /Blah/blah/blah/Documents/Subfile/ - >checks the validity
 - turns the path to save into /Blah/blah/blah/Documents/ + filename if non of the parents of the
 - child directory are present.
 -*/

-(NSString*) urlPathMiddleOut:(NSString*)pathToMiddleOut onQueryWrapper:(GDQueryWrapper*)passedQueryWrapper{
    
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

-(void) checkForAndCreateEnvoyUploadsFolderThenUpload:(UIViewController*)passedController {
    
    _passedInController = passedController;
    
    if (![self isAuthorized]) {//if we're not authorized on google yet
        //create the three view controllers!
        UINavigationController *authNavigationController = [[UINavigationController alloc] init];
        UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"GOOGLE DRIVE"];
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, passedController.view.frame.size.width, 64)];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, navigationBar.frame.size.height)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAuthButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        
        UIButton *buttonToGoInside = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, navigationBar.frame.size.height)];
        UIBarButtonItem *barButtonItemPlaceholder = [[UIBarButtonItem alloc] initWithCustomView:buttonToGoInside];
        
        [navigationItem setLeftBarButtonItem:barButtonItemPlaceholder];
        [navigationItem setRightBarButtonItem:barButtonItemCancel];
        
        //set the navigation item to have a title of a google drive icon.
        UIImage *titleImage = [UIImage imageNamed:[AppConstants googleDriveStringIdentifier]];
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
    } else {
        _canLoadAndNavigateAfterAuth = NO;
        GTLServiceTicket* newServiceTicket = [self produceServiceTicket];
        GDQueryWrapper* newQueryWrapper = [self wrapServiceTicket:newServiceTicket withStoredReduceStackToPath:nil andTypeOfQuery:GDLOADMETADATAENVOYUPLOADS andPassedFile:nil andshouldReloadSelectedFilesView:NO andMoveToGD:YES cameFromAuth:NO andMovedFromGD:NO andSelectedFiles:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]]];
        
        GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
        
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
                    [_gdServiceManagerDelegate gdUnselectHomeCollectionViewCellAtIndexPath:indexPathForFile];
                }
            }
        }
        
        //clear global selected files array
        [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        
        [newQueryWrapper incrementCustomRequestCount];
        // construct a query for the root folder and send that query
        query.q = [NSString stringWithFormat:@"'%@' IN parents", @"root"];
        [newQueryWrapper setServiceTicket:[_driveService executeQuery:query completionHandler:[self getEnvoyUploadsCheckBlockWithQueryWrapper:newQueryWrapper]]];
        [[self gdQueryWrapperHolder] addObject:newQueryWrapper];
    }
}

-(void) processWhetherEnvoyUploadsExistsOnGoogleDrive:(BOOL) envoyUploadsExist withGTLDriveFile:(GTLDriveFile*)driveFileObject withPassedQueryWrapper:(GDQueryWrapper*)passedQueryWrapper{
    //start the upload if the folder exists.
    if(envoyUploadsExist){
        //create the Envoy Uploads folder if it currently does not exist in teh Google Drive folder
        if(![[self fsInterface] isValidPath:[@"/GoogleDrive" stringByAppendingPathComponent:@"Envoy Uploads"]]){
            File* newFile = [[File alloc] initWithName:@"Envoy Uploads" andPath:[@"/GoogleDrive" stringByAppendingPathComponent:@"Envoy Uploads"] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
            [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
            [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:newFile.parentURLPath];
        }
        //explicit trashing ".explicitlyTrashed" is a file the user trashed by pressing "trash this file"
        //non expclicit trsahing ".labels.trashed" is when something that was a child
        //of something that was explicitly trashed. I think for explicitly trashed files
        //also get their normal trashed flag set.
        //reason this was triggering before even when thigns were untrashed
        //was because the NSNumber is always valid. Said online this was a boolean.
        //the fuck google?
        if([driveFileObject.explicitlyTrashed isEqualToNumber:[NSNumber numberWithInt:1]] || [driveFileObject.labels.trashed isEqualToNumber:[NSNumber numberWithInt:1]]){
            [self createEnvoyUploadsFolderInRootAndLaunchUploads:[passedQueryWrapper getOriginallySelectedFiles]];
        }else {
            // if the file exists, is not trashed, and the google drive ID matches our locally stored one
            // then we treat it as a valid upload file and start the upload, just send a notification
            if([driveFileObject.identifier isEqualToString:[self getEnvoyUploadsFolderIDInUserDefaults]]){
                [_gdServiceManagerDelegate uploadAfterCreatingUploadFolderGDWithOriginallySelectedFiles:[passedQueryWrapper getOriginallySelectedFiles]];
            }
        }
    }else{
        [self createEnvoyUploadsFolderInRootAndLaunchUploads:[passedQueryWrapper getOriginallySelectedFiles]];
    }
}

-(void) createEnvoyUploadsFolderInRootAndLaunchUploads:(NSMutableArray*)originallySelectedFiles {
    
    GTLDriveFile *driveFile = [GTLDriveFile object];
    driveFile.title = @"Envoy Uploads";
    driveFile.mimeType = @"application/vnd.google-apps.folder";
    GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
    parentRef.identifier = @"root";
    driveFile.parents = @[parentRef];
    
    GTLQueryDrive *query1 = [GTLQueryDrive queryForFilesInsertWithObject:driveFile uploadParameters:nil];
    
    // GTL service ticket class has some kind of progress block on it.
    [_driveService executeQuery:query1 completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *insertedFile, NSError *error) {
        if (error == nil) {
            [self setEnvoyUploadsFolderIDInUserDefaults:insertedFile.identifier];
            [[self fsInterface] createDirectoryAtPath:[@"/GoogleDrive" stringByAppendingPathComponent:@"Envoy Uploads"]withIntermediateDirectories:NO attributes:nil];
            [_gdServiceManagerDelegate uploadAfterCreatingUploadFolderGDWithOriginallySelectedFiles:originallySelectedFiles];
        }else{
            NSLog(@"DA SERVICE TICKET: %@", ticket);
            NSLog(@"An error IN FOLDER CREATION occurred: %@", error);
        }
    }];
}

//a getter and setter for the stored envoy folder ID
//
-(void) setEnvoyUploadsFolderIDInUserDefaults:(NSString*)folderID {
    [[NSUserDefaults standardUserDefaults] setObject:folderID forKey:@"GDEnvoyUploadsFolder"];
}

-(NSString*) getEnvoyUploadsFolderIDInUserDefaults {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"GDEnvoyUploadsFolder"];
}

-(void) removeEnvoyUploadsFolderIDInUserDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GDEnvoyUploadsFolder"];
}

// method that removes all rest clients that have 0
// outstanding requests from the array. removes
// inactive rest clients and their wrappers from memory
// used statusCode and not hasCalledCallback because hasCalledCallback
// seems like it could cause a race condition on our recursive methods
// we might have called a callback and be about to launch another
// query on a ticket passed recursively.
// A status code of "not 0" means that the user has gotten
// a file back (statusCode 200) or that there was an error response code
// (almost anything other response code that is not 200)
// might be smarter to make this == 200? not sure.
// while a thing is downloading it is onot considered
// to be a statusCode 200 yet, so this works well.

-(void) checkForAndPurgeInactiveClients {
    dispatch_async(_gdQueryWrapperQueue, ^{
        NSMutableIndexSet* wrappedServiceTicketsToRemove = [[NSMutableIndexSet alloc] init];
        for(GDQueryWrapper* wrappedServiceTicket in [self gdQueryWrapperHolder]){
            if (([wrappedServiceTicket getCustomRequestCount] == 0)){
                [wrappedServiceTicketsToRemove addIndex:[[self gdQueryWrapperHolder] indexOfObject:wrappedServiceTicket]];
            }
        }
        [[self gdQueryWrapperHolder] removeObjectsAtIndexes:wrappedServiceTicketsToRemove];
    });
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
            NSString* newFileParentPath = @"";
            
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
                NSString* pathForNewFile = [[passedQueryWrapper getPassedFile].path stringByAppendingPathComponent:file.title];
                
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
                    File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:pathForNewFile andDate:[NSDate date] andRevision:revision andDirectoryFlag:isDir andBoxId:file.identifier];
                    if(isDir){
                        [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
                        
                    }
                    [filesForBatchWrite addObject:newFile];
                    newFileParentPath = newFile.parentURLPath;
                }
                
            } // END FOR LOOP
            
            [[self fsInterface] saveBatchOfFilesToFileSystemJSON:filesForBatchWrite inDirectoryPath:newFileParentPath];
            
            if([passedQueryWrapper getShouldReloadMainView]){
                [[self fsAbstraction] pushOntoPathStack:[passedQueryWrapper getPassedFile]];
                [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getPassedFile].path];
                
                // send a notification to update the toolbar onc ewe've pushed.
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
            [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy  inDirectoryPath:[passedQueryWrapper getPassedFile].path];
            //used a delegate instead of a notification because we needed to post some data back to the other view
            [_selectedFilesViewCloudNavDelegate populateWithFilesToDisplay:currentDirProxy withPassed:[passedQueryWrapper getPassedFile]];
            [passedQueryWrapper setShouldReloadMainView:YES];
            
            // we need this here otherwise the stack path gets fucked (extra dropboxes added)
            // the problem is that on load after the auth this causes dropbox
            // to crash because we're iterating through it somewhere else.
            // if we came from just authorizing the google drive we need
            // to push a think onto the stack.
            if([passedQueryWrapper getCameFromAuth]){
                [[self fsAbstraction] pushOntoPathStack:[passedQueryWrapper getPassedFile]];
                // send a notification to update the toolbar oncewe've pushed.
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
            }
            
            //if this is not inside this if statement it populates the current directory when trying to load
            //cloud files in the selected files view
            [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[passedQueryWrapper getPassedFile].path];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
            //re-show a previously hidden collection view as soon as there's new files to show.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showCollectionView" object:self];
            
            //once we've done our business and we got our metadata then
            //decrement the request count on the query wrapper
            [passedQueryWrapper decrementCustomRequestCount];
            
        }else{
            NSLog(@"An error occurred: %@", error);
            NSLog(@"ERROR CODE %ld",(long)error.code);
            //if on a navigation load we get a 400 or 401 error re auth the user
            if(error.code == 400 || error.code == 401){
                [self presentAuthenticationControllerForGoogleDrive:[passedQueryWrapper getPresentFromForReAuthentication] invalidToken:YES];
            } else if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
                NSLog(@"EGAH!");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCollectionViewMessageForTimeout" object:self];
            }
        }
    };
}


//metadata block for selectedfiles navigation

-(void(^)(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error)) getSelectedFilesMetadataBlockWithQueryWrapper:(GDQueryWrapper*)passedQueryWrapper {
    
    return ^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) {
        
        if (error == nil){
            BOOL isDir = NO;
            NSString* revision = @"";
            NSMutableArray* filesForBatchWrite = [[NSMutableArray alloc] init];
            NSString* newFileParentPath = @"";
            
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
                NSString* pathForNewFile = [[passedQueryWrapper getPassedFile].path stringByAppendingPathComponent:file.title];
                
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
                    File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:pathForNewFile andDate:[NSDate date] andRevision:revision andDirectoryFlag:isDir andBoxId:file.identifier];
                    if(isDir){
                        [[self fsInterface] createDirectoryAtPath:newFile.path withIntermediateDirectories:NO attributes:nil];
                        
                    }
                    [filesForBatchWrite addObject:newFile];
                    newFileParentPath = newFile.parentURLPath;
                }
                
            } // END FOR LOOP
            
            [[self fsInterface] saveBatchOfFilesToFileSystemJSON:filesForBatchWrite inDirectoryPath:newFileParentPath];
            
        }else{
            NSLog(@"An error occurred: %@", error);
            if (error.code == -1009 || error.code == -1001 || error.code == -1003 || error.code == -1004 || error.code == -1005) {
                NSLog(@"EGAH!");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCollectionViewMessageForTimeout" object:self];
            }
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
        [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy  inDirectoryPath:[passedQueryWrapper getPassedFile].path];
        //used a delegate instead of a notification because we needed to post some data back to the other view
        [_selectedFilesViewCloudNavDelegate populateWithFilesToDisplay:currentDirProxy withPassed:[passedQueryWrapper getPassedFile]];
        [passedQueryWrapper setShouldReloadMainView:YES];
        
        
        //once we've done our business and we got our metadata then
        //decrement the request count on the query wrapper
        // i know we're about to delete it but heh.
        [passedQueryWrapper decrementCustomRequestCount];
        
        // remove the query wrapper from the global array
        // this dispatch async is to preotect the
        // dbQueryWrapper holder array
        // you can see below
        // in the purge method there
        // is another dispatch async. checkForAndPurgeInactiveClients
//        dispatch_async(_gdQueryWrapperQueue, ^{
//            [[self gdQueryWrapperHolder] removeObject:passedQueryWrapper];
//        });
    };
}

//Block just for checking if the EnvoyUploads Folder exists.

-(void(^)(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error)) getEnvoyUploadsCheckBlockWithQueryWrapper:(GDQueryWrapper*)passedQueryWrapper {
    
    return ^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) {
        
        if (error == nil){
            BOOL isDir = NO;
            BOOL envoyUploadsExists = NO;
            GTLDriveFile* locatedEnvoyUploadsFolder;
            NSString* revision = @"";
            
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
                NSString* pathForNewFile = [[passedQueryWrapper getPassedFile].path stringByAppendingPathComponent:file.title];
                
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
                
                File* newFile = [[File alloc] initWithName:fileNameAndExtensionToActuallyUse andPath:pathForNewFile andDate:[NSDate date] andRevision:revision andDirectoryFlag:isDir andBoxId:file.identifier];
                
                //if we are dealing with a request to check for the EnvoyUploads
                //folder on google, and the id has to match the one we
                //have locally.
                if([passedQueryWrapper getTypeOfQuery] == GDLOADMETADATAENVOYUPLOADS){
                    if(
                       [newFile.name isEqualToString:@"Envoy Uploads"]
                       &&
                       [newFile.boxid isEqualToString:[self getEnvoyUploadsFolderIDInUserDefaults]]
                    ){
                        envoyUploadsExists = YES;
                        locatedEnvoyUploadsFolder = file;
                    }
                }
            } // END FOR LOOP
            
            // if we're checking for a EnvoyUploads folder based on this flag
            // trigger the method that handles this.
            if([passedQueryWrapper getTypeOfQuery] == GDLOADMETADATAENVOYUPLOADS){
                [self processWhetherEnvoyUploadsExistsOnGoogleDrive:envoyUploadsExists withGTLDriveFile:locatedEnvoyUploadsFolder withPassedQueryWrapper:passedQueryWrapper];
            }
        }else{
            NSLog(@"An error occurred: %@", error);
            //if when we check for the folder we have an expired access token
            if(error.code == 400 || error.code == 401){
                
                [self presentAuthenticationControllerForGoogleDrive:[passedQueryWrapper getPresentFromForReAuthentication] invalidToken:YES];
            }
        }
    };
}

-(void(^)(GTLServiceTicket *ticket, id object, NSError *error)) getDeleteFileBlockWithQueryWrapper:(GDQueryWrapper*)passedQueryWrapper {
    
    return ^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (error == nil) {
            NSLog(@"File deleted: %@", ticket);
            [self removeEnvoyUploadsFolderIDInUserDefaults];
            [passedQueryWrapper decrementCustomRequestCount];
        }else{
            NSLog(@"An error occurred: %@", error);
        }
    };
}

-(void) presentAuthenticationControllerForGoogleDrive:(UIViewController*)passedController invalidToken:(BOOL)tokenWasInvalid{
    
    //create the three view controllers!
    UINavigationController *authNavigationController = [[UINavigationController alloc] init];
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"GOOGLE DRIVE"];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, passedController.view.frame.size.width, 64)];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, navigationBar.frame.size.height)];
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
    UIImage *titleImage = [UIImage imageNamed:[AppConstants googleDriveStringIdentifier]];
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

// this is effectively an ENQUEUE operation
//quques up an operation on a global queue
//waiting to be executed.

-(void) queueDBOperationOnGlobalRequestQueue:(GDOperationWrapper*) queryOperationToEnqueue {
    [[self gdOperationWrapperHolder] addObject:queryOperationToEnqueue];
}

//this oepration dequeues until we meet our global max or have dequeued everything

-(void) dequeueDBOperationsUpToGlobalMax {
    NSMutableIndexSet* gdOperationWrappersToRemove = [[NSMutableIndexSet alloc] init];
    for (int opWrapperIndex=0; opWrapperIndex < [[self gdOperationWrapperHolder] count]; opWrapperIndex++) {
        if(![self globalActiveRequestsMaxedOut]) {
            GDOperationWrapper* operationWrapper = [[self gdOperationWrapperHolder] objectAtIndex:opWrapperIndex];
            [gdOperationWrappersToRemove addIndex:opWrapperIndex];
            [self executeQueryFromDBOperationWrapper:operationWrapper];
        }
    }
    [[self gdOperationWrapperHolder] removeObjectsAtIndexes:gdOperationWrappersToRemove];
}

// this is effectively a DEQUEUE operation.

-(GDOperationWrapper*) dequeueDBOperationOnGlobalRequestQueue {
    GDOperationWrapper* operationWrapper = [[self gdOperationWrapperHolder] firstObject];
    [[self gdOperationWrapperHolder] removeObjectAtIndex:0];
    return operationWrapper;
}

-(void) executeQueryFromDBOperationWrapper:(GDOperationWrapper*) queryOperationToDequeue  {
    
    switch ([queryOperationToDequeue getTypeOfQuery]) {
        
        case GDLOADFILE: {
            _globalActiveRequestCount++;
            GTMHTTPFetcher* fetcher = [queryOperationToDequeue getServiceTicketOrFetcher];
            [fetcher beginFetchWithCompletionHandler:[queryOperationToDequeue getFetcherDataCompletionBlock]];
            break;
        }
        case GDUPLOADFILE: {
            _globalActiveRequestCount++;
            [_driveService executeQuery:[queryOperationToDequeue getDriveQuery] completionHandler:[queryOperationToDequeue getUploadCompletionHandler]];
            break;
        }
        default: {
            break;
        }
    }
}

//the logic here is that if the path passed to this thing matches
//either path1 or path2 of a Operation Wrapper, this is actually a
//cool strategy. 1. create a copy of the array. 2. iterate through
//and store index paths, 3. remove index paths.
//you can't get an error of iterating while editing somewhere else
//and you can't remove something that's not there becuase removing
//via index set only removes indicies that are there.

-(void) destroyGDOperationsWithFilePaths:(NSArray*)arrayOfFileLoadingObjects{
    
    NSMutableIndexSet* indiciesToRemove = [[NSMutableIndexSet alloc] init];
    NSArray* arrayCopy = [[NSMutableArray alloc] initWithArray:[self gdOperationWrapperHolder]];
    
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
    [[self gdOperationWrapperHolder] removeObjectsAtIndexes:indiciesToRemove];
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

-(void) incrementNumberOfTimesQueriedWithPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery {
    for (GDQueryLimitWrapper* queryWrapper in [self gdQueryOccurrenceLimitHolder]) {
        if ([queryWrapper.path1 isEqualToString:path1] && [queryWrapper.path2 isEqualToString:path2] && (queryWrapper.typeOfQuery == typeOfQuery)){
            queryWrapper.numberOfTimesQueried++;
        }
    }
}

// these checks are done GLOBALLY and not on individual querywrappers
// because we want to limit a particular query and not oen instance of
// it. these return YES if we are over or at the limit and NO if we have
// room to try the query again.

-(BOOL) overQueryOccurrenceLimitForQueryWithPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery{
    for (GDQueryLimitWrapper* queryWrapper in [self gdQueryOccurrenceLimitHolder]) {
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

-(void) addObjectToQueryLimitQueueIfNotExists:(GDQueryLimitWrapper*)queryLimitToAdd {
    BOOL limitObjectAlreadyExists = NO;
    for (GDQueryLimitWrapper* queryWrapper in [self gdQueryOccurrenceLimitHolder]){
        if ([queryWrapper.path1 isEqualToString:queryLimitToAdd.path1] && [queryWrapper.path2 isEqualToString:queryLimitToAdd.path2] && (queryWrapper.typeOfQuery == queryLimitToAdd.typeOfQuery)){
            limitObjectAlreadyExists = YES;
        }
    }
    if (!limitObjectAlreadyExists) {
        [[self gdQueryOccurrenceLimitHolder] addObject:queryLimitToAdd];
    }
}

//for destroying a file query limit object on successful completion of a thing.
-(void) destroyObjectFromQueryLimitQueueWithPath1:(NSString*) path1 andPath2:(NSString*) path2 andTypeOfQuery:(int)typeOfQuery {
    NSMutableIndexSet* indiciesToRemove = [[NSMutableIndexSet alloc] init];
    
    for (GDQueryLimitWrapper* queryWrapper in [self gdQueryOccurrenceLimitHolder]) {
        if ([queryWrapper.path1 isEqualToString:path1] && [queryWrapper.path2 isEqualToString:path2] && (queryWrapper.typeOfQuery == typeOfQuery)){
            [indiciesToRemove addIndex:[[self gdQueryOccurrenceLimitHolder] indexOfObject:queryWrapper ]];
        }
    }
    [[self gdQueryOccurrenceLimitHolder] removeObjectsAtIndexes:indiciesToRemove];
}

//for destroying ad file query limit object on a cancel of the upload or download
-(void) destroyObjectFromQueryLimitQueueWithServiceTicketOrFetcher:(id) serviceTicketOrFetcher andPath:(NSString*)path andTypeOfQuery:(int)typeOfQuery{
    NSMutableIndexSet* indiciesToRemove = [[NSMutableIndexSet alloc] init];
    
    //if we match a fetcher or a service ticket
    for (GDQueryLimitWrapper* queryWrapper in [self gdQueryOccurrenceLimitHolder]) {
        if ([queryWrapper.serviceTicketOrFetcher isEqualToString:serviceTicketOrFetcher] && [queryWrapper.path2 isEqualToString:path] && (queryWrapper.typeOfQuery == typeOfQuery)){
            [indiciesToRemove addIndex:[[self gdQueryOccurrenceLimitHolder] indexOfObject:queryWrapper]];
        } else if ([queryWrapper.serviceTicketOrFetcher isEqualToString:serviceTicketOrFetcher] && [queryWrapper.path1 isEqualToString:path] && (queryWrapper.typeOfQuery == typeOfQuery)) {
            [indiciesToRemove addIndex:[[self gdQueryOccurrenceLimitHolder] indexOfObject:queryWrapper]];
        }
    }
    [[self gdQueryOccurrenceLimitHolder] removeObjectsAtIndexes:indiciesToRemove];
}


@end

