//
//  MultipeerInitializerTabBarController.m
//  Airdoc
//
//  Created by Roman Scher on 1/21/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "MultipeerInitializerTabBarController.h"

@interface MultipeerInitializerTabBarController ()

@property (nonatomic) SessionWrapper *sessionWrapper;
@property (nonatomic) AdvertiserWrapper *advertiserWrapper;
@property (nonatomic) BrowserWrapper *browserWrapper;

@property BOOL sendTimerInvalidated;
@property (nonatomic, strong) NSTimer *alertToResetSessionConnectionTimer;
@property (nonatomic, assign) BOOL tabBarCurrentlyAnimating;
@property (strong, nonatomic) NSTimer *tabBarAnimationTimer;
//@property int outgoingSendProgressHelper;

@end

@implementation MultipeerInitializerTabBarController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Setup
    self.delegate = (id)self;
    
    // LocalstorageManager, UITabBarControllerDelegate And connectedPeople Initialization
    // CONNECTVIEWCONTROLLER & REQUESTVIEWCONTROLLERDELEGATES ARE SET IN THEIR CLASSES BY USING 'SELF.TABBARCONTROLLER'
    _localStorageManager = [[LocalStorageManager alloc] init];
    _inboxManager = [InboxManager sharedInboxManager];
    _connectedPeopleManager = [ConnectedPeopleManager sharedConnectedPeopleManager];
    _tabBarCurrentlyAnimating = NO;
    
    UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
    
    //Set inbox badge value
    NSString *totalNumUncheckedPackages = [InboxManager getTotalNumberOfUncheckedPackages];
    if ([totalNumUncheckedPackages isEqualToString:@"0"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            inboxTab.badgeValue = nil;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            inboxTab.badgeValue = totalNumUncheckedPackages;
        });
    }
        
    // Multipeer Wrappers Intitializations
    // INITIALIZE USER'S displayName WITH UNIQUE UUID APPENDED, USE CORRECT LocalStorageManager CLASS METHOD TO SPLIT IT OFF WHEN NEEDED TO DISPLAY TO USERS
    [_connectedPeopleManager startCurrentlySearchingForPeersStateTimer];
    NSString *UUID = [@"|" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    _sessionWrapper = [[SessionWrapper alloc] init];
    _sessionWrapper.sessionWrapperDelegate = self;
    _sessionWrapper = [_sessionWrapper initSessionWithMyPeerName:[[LocalStorageManager getUserDisplayableFullName] stringByAppendingString:UUID]];
    _advertiserWrapper = [[AdvertiserWrapper alloc] init];
    _advertiserWrapper.advertiserWrapperDelegate = self;
    _advertiserWrapper = [_advertiserWrapper startAdvertising:_sessionWrapper.myPeerID];
    _browserWrapper = [[BrowserWrapper alloc] init];
    _browserWrapper.browserWrapperDelegate = self;
    _browserWrapper = [_browserWrapper startBrowsing:_sessionWrapper.myPeerID];
    
    _browserWrapper.browserWrapperDelegate = self;
    _inboxManager = [InboxManager sharedInboxManager];
    
    // Add thiis VC as a listener for notifications when the app goes into the background, enters foreground, or closes, so we can actively destroy session/advertising/browsing (and rebuild it) isntead of letting multipeer do it whenever
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    // Add this VC as a listener for notifications on receiving new files and links from peers (Posted from MultiPeerInitializerTabBarController)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successfullyReceivedFilePackageFromPeer)
                                                 name:@"successfullyReceivedFilePackageFromPeer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLinkPackageFromPeer)
                                                 name:@"receivedLinkPackageFromPeer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSession) name:@"triggerResetSession" object:nil];

//    TEST 1 - Adds dummy peers to connected people arrays and friends list where necessary (NOTE THAT THIS TEST IS MAINLY FOR DISPLAY ON TABLES AND MAY BREAK CERTAIN FEATURES BECAUSE THESE ARE NOT REAL PEERS)
//    [_localStorageManager deleteJSONFileInDocumentsDirectoryWithFileIdentifier:[AppConstants friendsJSONFileIdentifier]];
//    [self addDummyPeersToConnectedPeople];
//    [_localStorageManager deleteJSONFileInDocumentsDirectoryWithFileIdentifier:[AppConstants inboxJSONFileIdentifier]];
    
    //TEST 2 - Idle Timer
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(printIdleTimerStatus) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(FileSystemInterface*) fsInterface{
    
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}

#pragma mark - UITabBarControllerDelegate

/* - Handles quick return to root home directory, and sets inbox badge to zero and modifies json file when we are about to select the inbox tab - */

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        UIViewController *topViewController = ((UINavigationController*)viewController).topViewController;
        UIViewController *secondToTopViewController;
        UIViewController *rootViewController = ((UINavigationController*)viewController).viewControllers[0];
        NSUInteger numberOfViewControllersOnStack = [((UINavigationController*)viewController).viewControllers count];
        if (numberOfViewControllersOnStack > 1) {
            secondToTopViewController = ((UINavigationController*)viewController).viewControllers[numberOfViewControllersOnStack - 2];
        }
        
        // Handles badge count on inboxViewController
        if ([rootViewController isKindOfClass:[InboxViewController class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _tabBarCurrentlyAnimating = NO;
                [_tabBarAnimationTimer invalidate];
            });
            if ([tabBarController selectedIndex] == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"inboxTabSelectedNotification" object:self];
            }
        }
        else if ([rootViewController isKindOfClass:[ConnectViewController class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"nearbyTabSelectedNotification" object:self];
            });
        }
        // Handles return to root directory on home view controller
        else if ([rootViewController isKindOfClass:[HomeViewController class]]){
            //Allows a tap on home tab to bring us back to root directory if we are already on home tab
            if ([tabBarController selectedIndex] == 0)  {
                if ([topViewController isKindOfClass:[HomeViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"returnHomeViewControllerToRootDirectoryNotification" object:self];
                }
                else if ([topViewController isKindOfClass:[SettingsViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popSettingsViewController" object:self];
                    return NO;
                }
                else if ([topViewController isKindOfClass:[sendViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popSendViewController" object:self];
                    return NO;
                }
                else if ([topViewController isKindOfClass:[SelectedFilesViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popSelectedFilesVC" object:self];
                    return NO;
                }
            }
        }
        
    }

    return YES;
}

#pragma mark - NSNotificationCenter

/* - Restarts the user's session, advertising, & browsing - */

-(void)resetSession {
    
    NSLog(@"Killing User's multipeer session");
    
    // DESTROY SESSION, STOP ADVERTISING & BROWSING
    [_sessionWrapper destroySession];
    [_advertiserWrapper stopAdvertising];
    [_browserWrapper stopBrowsing];
    
    [self cleanUpSessionRelatedVariables];
    
    [_connectedPeopleManager startCurrentlySearchingForPeersStateTimer];
    NSLog(@"Restarting Session");
    
    // NOW RESTART SESSION, ADVERTISING & BROWSING
    NSString *UUID = [@"|" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    _sessionWrapper = [_sessionWrapper initSessionWithMyPeerName:[[LocalStorageManager getUserDisplayableFullName] stringByAppendingString:UUID]];
    [_advertiserWrapper startAdvertising:_sessionWrapper.myPeerID];
    [_browserWrapper startBrowsing:_sessionWrapper.myPeerID];
}

/* - Updates the badge on the inbox tab after new file package is received from a peer - */
 
-(void)successfullyReceivedFilePackageFromPeer {
    //If we are currently on inbox tab, send notification to inbox to update badges itself
    if ((self.selectedIndex == 1)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBadgesForNewFilePackage" object:self];
    }
    else {
        UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
        
        [InboxManager incrementnumberOfUncheckedFilePackages];
        if (!_tabBarCurrentlyAnimating) {
            NSString *numUncheckedPackages = [InboxManager getTotalNumberOfUncheckedPackages];
            dispatch_async(dispatch_get_main_queue(), ^{
                inboxTab.badgeValue = numUncheckedPackages;
            });
        }
    }
}

/* - Updates the badge on the inbox tab after new link package is received from a peer - */
 
-(void)receivedLinkPackageFromPeer {
    //If we are currently on inbox tab, let inbox update itself.
    if (!(self.selectedIndex == 1)) {
        UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
        
        [InboxManager incrementnumberOfUncheckedLinkPackages];
        if (!_tabBarCurrentlyAnimating) {
            NSString *numUncheckedPackages = [InboxManager getTotalNumberOfUncheckedPackages];
            dispatch_async(dispatch_get_main_queue(), ^{
                inboxTab.badgeValue = numUncheckedPackages;
            });
        }
    }
}


/* - Actively destroys session/advertising/browsing when app goes into the background - */

-(void)applicationDidEnterBackground {
    NSLog(@"Killing User's multipeer session");
    
    // DESTROY SESSION, STOP ADVERTISING & BROWSING
    [_sessionWrapper destroySession];
    [_advertiserWrapper stopAdvertising];
    [_browserWrapper stopBrowsing];
    
    [_connectedPeopleManager stopCurrentlySearchingForPeersStateTimer];
    [self cleanUpSessionRelatedVariables];
}

/* - Restarts session/advertising/browsing when app comes into the foreground - */

-(void)appWillEnterForeground {
    // NOW RESTART SESSION, ADVERTISING & BROWSING
    [_connectedPeopleManager startCurrentlySearchingForPeersStateTimer];
    NSString *UUID = [@"|" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    _sessionWrapper = [_sessionWrapper initSessionWithMyPeerName:[[LocalStorageManager getUserDisplayableFullName] stringByAppendingString:UUID]];
    [_advertiserWrapper startAdvertising:_sessionWrapper.myPeerID];
    [_browserWrapper startBrowsing:_sessionWrapper.myPeerID];
}

/* - Actively destroys session/advertising/browsing when app closes - */

-(void)appWillTerminate {
    NSLog(@"Killing User's multipeer session");
    
    // MANUALLY DESTROYS SESSION, STOP ADVERTISING & BROWSING (so that other peers get quicker updates on disconnected peers)
    [_sessionWrapper destroySession];
    [_advertiserWrapper stopAdvertising];
    [_browserWrapper stopBrowsing];
    
    [self cleanUpSessionRelatedVariables];
}

#pragma mark - SettingsViewControllerDelegate

/* - Kills User's session when they return to intro screen - */

-(void)backToIntroScreenTapped {
    NSLog(@"Killing User's multipeer session");
    
    // DESTROY SESSION, STOP ADVERTISING & BROWSING
    [_sessionWrapper destroySession];
    [_advertiserWrapper stopAdvertising];
    [_browserWrapper stopBrowsing];
    
    [self cleanUpSessionRelatedVariables];
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //Remember progress from any number of sends can be shown here. Need to used passed context to identify which peer send the progress corresponds to.
    
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        if ([_connectedPeopleManager progressIsAnOutgoingSendProgress:(NSProgress*)object]) {
            ////Reset timer for progress stall alert
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_sendTimerInvalidated) {
                    [_alertToResetSessionConnectionTimer invalidate];
                    _alertToResetSessionConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                                                           target:self
                                                                                         selector:@selector(alertUserToResetSessionConnection)
                                                                                         userInfo:nil
                                                                                          repeats:NO];
                }
            });
            
            for (UIViewController *viewController in [self childViewControllers]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [((ProgressNavigationViewController*)viewController).sendProgress setProgress:([(NSProgress *)object fractionCompleted]) animated:NO];
                    [((ProgressNavigationViewController*)viewController).sendProgress setHidden:NO];
                });
            }
            
//            if ((int)([(NSProgress *)object fractionCompleted] * 100) >= _outgoingSendProgressHelper + 1) {
                NSLog(@"Sending File progress: %f", ([(NSProgress *)object fractionCompleted] * 100));
//                _outgoingSendProgressHelper = (int)([(NSProgress *)object fractionCompleted] * 100);
//            }
        }
        else if ([_connectedPeopleManager progressIsAnIncomingSendProgress:(NSProgress*)object]) {
            NSLog(@"Sending File progress: %f", ([(NSProgress *)object fractionCompleted] * 100));
        }
    }
}

#pragma mark - SendViewControllerDelegate

-(void)sendFiles:(NSMutableArray*)filesToBeSent ToPeers:(NSMutableArray *)peersToSendTo{
    
    NSLog(@"Sending files To Peers");
    
    //Stops phone from going to sleep while we're sending/preparing to send
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //OK so instead of all this crap we 1. loop through once and record all parentURLS
    //2 Loop through again and see if those parent urls are in the array.
    //if they are we remove the indcides of each child whose parent was in the array.
    
    NSMutableIndexSet* indiciesToRemove = [[NSMutableIndexSet alloc]init];
    NSMutableArray* arrayOfParentPaths = [[NSMutableArray alloc]init];
    NSMutableDictionary* pathToChildIndicies = [[NSMutableDictionary alloc] init];
    
    //TWO PASS FILE FILTERING TO GET RID OF SUBCHILDREN AND DEEP SUBCHILDREN
    
    //Pass one saves all parent urls and saves the indicies at index keys
    for(File* fileToCheck in [[NSArray alloc]initWithArray:filesToBeSent]){
        [arrayOfParentPaths addObject:fileToCheck.parentURLPath];
        NSMutableIndexSet* tempIndexSet;
        //if the key does exist add the index to the index set stored there.
        if((tempIndexSet = [pathToChildIndicies objectForKey:fileToCheck.parentURLPath])){
            [tempIndexSet addIndex:[filesToBeSent indexOfObject:fileToCheck]];
            [pathToChildIndicies setValue:tempIndexSet forKeyPath:fileToCheck.parentURLPath];
             //if the key does not exist create the array where it should be.
        }else{
            [pathToChildIndicies setValue:[[NSMutableIndexSet alloc] initWithIndex:[filesToBeSent indexOfObject:fileToCheck]] forKeyPath:fileToCheck.parentURLPath];
        }
    }
    
    //Pass two to get rid of children whose paths derive from the removed parent paths.
    for(File* fileToCheck in [[NSArray alloc]initWithArray:filesToBeSent]){
        
        //ifthe fileToCheck is a parent of other file(s) in the array
        //then add the indicies for those child files in the array who
        //have this parent
        if([arrayOfParentPaths containsObject:fileToCheck.path]){
            [indiciesToRemove addIndexes:[pathToChildIndicies objectForKey:fileToCheck.path]];
        }
    }
    
    //remove all files that need removign from selected files.
    [filesToBeSent removeObjectsAtIndexes:indiciesToRemove];
    
    NSLog(@"SENDING RESOURCES...");
    NSMutableArray* filePaths = [[NSMutableArray alloc]init];
    for (int i=0; i<[filesToBeSent count]; i++) {
        
        // zipping files requires the FULL path
        [filePaths addObject:[[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:((File*)[filesToBeSent objectAtIndex:i]).path ]];
    }
    
    // Create a UUID for the zip file on the sending end to make sure the file the recipient receives has a unique name
    NSString *UUID = [[NSUUID UUID] UUIDString];
    // make the path at which we'd like to place the new zip files at least tmeporarily
    NSString *zippedPath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"ZippedFilePackages"] stringByAppendingPathComponent:UUID] stringByAppendingPathExtension:@"zip"];
    //resourcename for the file is the uuid with zip extension
    NSString *resourceName = [UUID stringByAppendingPathExtension:@"zip"];
    
    //Put zipping of files & sending in background thread, as it otherwise blocks main thread & UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        MBProgressHUD *alertHud = [self alertUserToPreparingSend];
        [_connectedPeopleManager setCurrentlyInTheProcessOfZippingTo:YES];
        //ACTUALLY MAKE THE ZIP FILES AND PLACE THEM SOMEWHERE
        BOOL doneZippingFiles = [SSZipArchive createZipFileAtPath:zippedPath withFilesAtPaths:filePaths];
        if (doneZippingFiles) {
            [self dismissPreparingSendAlert:alertHud];
            [_connectedPeopleManager setCurrentlyInTheProcessOfZippingTo:NO];
        }
        
        BOOL isValid = [[NSFileManager defaultManager] fileExistsAtPath:[[zippedPath stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"%s ISVALIDPATH %d PATH: %@", __PRETTY_FUNCTION__, isValid, zippedPath);
        
        for (MCPeerID* peerToSendTo in peersToSendTo) {
            
            //File* fileToSend = [filesToBeSent objectAtIndex:i];
            //        BOOL isValid = [[NSFileManager defaultManager] fileExistsAtPath:[[[fileToSend.url path] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //        NSLog(@"%s ISVALIDPATH %d PATH: %@", __PRETTY_FUNCTION__,isValid, [fileToSend.url path]);
            
            //CHECK OF #FileSendsQueued NEEDS TO BE MADE ON VALUE OBTAINED BEFORE THIS SEND IS QUEUED
            BOOL currentlyInTheProcessOfSending = [_connectedPeopleManager currentlyInTheProcessOfSending];
            
            [_connectedPeopleManager queueZippedFilePath:zippedPath WithResourceName:resourceName ToSendToPeer:peerToSendTo];
            
            //If there are no files currently being sent, start up the performNextSendInSendQueueLoop
            if (!currentlyInTheProcessOfSending) {
                [self performNextSendInSendQueue];
            }
        }
    });
}

-(void)sendLinks:(NSMutableArray *)linksToBeSent ToPeers:(NSMutableArray *)peersToSendTo {
    NSLog(@"Sending links To Peers");
    
    //Form linkPackage
    LinkPackageJM *linkPackage = [[LinkPackageJM alloc] init];
    linkPackage.packageUUID = [[NSUUID UUID] UUIDString];
    linkPackage.senderName = [LocalStorageManager getUserDisplayableFullName];
    linkPackage.senderUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    linkPackage.timestamp = @"";
    
    NSMutableArray *linkDictionaries = [[NSMutableArray alloc] init];
    for (LinkJM *link in linksToBeSent) {
        [linkDictionaries addObject:[link toDictionary]];
    }
    linkPackage.links = [linkDictionaries copy];
    
    //Convert linkpackage into nsdata to be send to peer
    NSString *linkPackageJson = [linkPackage toJSONString];
    NSData *linkPackageData = [linkPackageJson dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"linkPackageJson %@", linkPackageJson);
    NSLog(@"linkPackageData byte size: %lu", (unsigned long)linkPackageData.length);
    
    NSError *error;
    BOOL success = [[_sessionWrapper session] sendData:linkPackageData toPeers:peersToSendTo withMode:MCSessionSendDataReliable error:&error];
    
    if(error || !success) {
        NSLog(@"Link Send error: %s %@", __PRETTY_FUNCTION__, [error description]);
        [self alertUserToFailedToSendLinks];
    }
    else {
        [self alertUserToLinksSent];
    }
}

-(void)performNextSendInSendQueue {
    
    NSDictionary *nextFileSend = [_connectedPeopleManager getNextFileSendInFileSendsQueue];
    MCPeerID *peerToSendTo = [nextFileSend objectForKey:[AppConstants peerIDStringIdentifier]];
    NSString *zippedPath = [nextFileSend objectForKey:[AppConstants zippedFilePathStringIdentifier]];
    NSString *resourceName = [nextFileSend objectForKey:[AppConstants resourceNameStringIdentifier]];

    __block NSProgress *progress = [_sessionWrapper.session sendResourceAtURL:[NSURL fileURLWithPath:zippedPath] withName:resourceName toPeer:peerToSendTo withCompletionHandler:^(NSError* error){
        
        if (error == nil) {
            NSLog(@"FILE SUCCUESSFULLY SENT!!!");
            [self alertSendingUserToFilesSentSuccessfully];
        }
        else{
            NSLog(@"MULTIPEER SENDING ERROR: %@", error);
            [self alertSendingUserToMultipeerSendingError: error forPeer:peerToSendTo];
        }
        
        //Stop observing changes to progress object of current send. (Prevents 'ghost' progress updates)
        [_connectedPeopleManager removeOutgoingSendProgress:progress];
        for (UIViewController *viewController in [self childViewControllers]) {
            NSLog(@"Setting visual progress feedback to zero and hiding for view %@", [viewController class]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [((ProgressNavigationViewController*)viewController).sendProgress setProgress:0.0 animated:NO];
                [((ProgressNavigationViewController*)viewController).sendProgress setHidden:YES];
            });
        }
        
        //Lets application know we disabled timer outside of progress update (because we still get ghost progress updates which would otherwise reset timer for alert)
        _sendTimerInvalidated = YES;
        //Disable timer for progress stall alert
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertToResetSessionConnectionTimer invalidate];
        });
        
        //This keeps track of what peers we're sending to and how many sends are queued
        [_connectedPeopleManager removeQueuedZippedFilePath:zippedPath ToSendToPeer:peerToSendTo];
        
        //Only put the device's idle timer back on if there are no other sends/receptions in progress.
        if (![_connectedPeopleManager currentlyInTheProcessOfSending] && ![_connectedPeopleManager currentlyInTheProcessOfReceiving]) {
            //Allow phone to go back to sleep after send is finished
            if (![LocalStorageManager getKeepDeviceAwakeSetting]) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }
        }
        else if ([_connectedPeopleManager currentlyInTheProcessOfSending]) {
            [self performNextSendInSendQueue];
        }
    }];
    
//    //Reset progress helper;
//    _outgoingSendProgressHelper = 0;
    
    if (progress != nil) {
        [_connectedPeopleManager addOutgoingSendProgress:progress withResourceName:resourceName andPeerID:peerToSendTo AndAddObserver:self];
        for (UIViewController *viewController in [self childViewControllers]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [((ProgressNavigationViewController*)viewController).sendProgress setProgress:([progress fractionCompleted]) animated:NO];
                [((ProgressNavigationViewController*)viewController).sendProgress setHidden:NO];
            });
        }
    }
    
    
    _sendTimerInvalidated = NO;
    //Start timer for progress stall alert
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alertToResetSessionConnectionTimer invalidate];
        _alertToResetSessionConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                     target:self
                                   selector:@selector(alertUserToResetSessionConnection)
                                   userInfo:nil
                                    repeats:NO];
    });
}

#pragma mark - SessionWrapperDelegate

-(void) peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    //Explicit if-else statement, otherwise state is returned as a digit and unclear
    if (state == MCSessionStateNotConnected) {
        NSLog(@"PEER CHANGED STATE TO: NotConnected - %@ %@ %@",[LocalStorageManager getPeerNameFromDisplayName:peerID.displayName], @"-", [LocalStorageManager getUUIDFromDisplayName:peerID.displayName]);
    }
    else if (state == MCSessionStateConnecting) {
        NSLog(@"PEER CHANGED STATE TO: Connecting - %@ %@ %@",[LocalStorageManager getPeerNameFromDisplayName:peerID.displayName], @"-", [LocalStorageManager getUUIDFromDisplayName:peerID.displayName]);
    }
    else if (state == MCSessionStateConnected) {
        NSLog(@"PEER CHANGED STATE TO: Connected - %@ %@ %@",[LocalStorageManager getPeerNameFromDisplayName:peerID.displayName], @"-", [LocalStorageManager getUUIDFromDisplayName:peerID.displayName]);
    }
    
    // If a peer state changes to Connected or NotConnected, update connectedPeople
    if (state == MCSessionStateConnected || state == MCSessionStateNotConnected) {
        [self updateConnectedPeopleWithPeer:peerID State:state];
    }
    
    //If we just diconnected from a peer we are sending files to, alert the user and properly update needed variables.
    //WE NEED THIS IN ADDITION TO THE CODE IN sendResourceAtUrl completion callback, BECAUSE THERE IS NO COMPLETION CALLBACK IF PEER DISCONNECTS DURING SEND. LIKE COME ON.
    if (state == MCSessionStateNotConnected && [_connectedPeopleManager currentlySendingToPeer:peerID]) {
        [self alertSendingUserToPeerDisconnectedDuringSend:peerID];
        
        //Lets application know we disabled timer outside of progress update (because we still get ghost progress updates which would otherwise reset timer for alert)
        _sendTimerInvalidated = YES;
        //Disable timer for progress stall alert
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertToResetSessionConnectionTimer invalidate];
        });
        
        //Stop observing changes to progress object of current send. (Prevents 'ghost' progress updates)
        [_connectedPeopleManager removeOutgoingSendProgressForResourceName:[_connectedPeopleManager getResourceNameOfCurrentSend] andPeerID:peerID];
        for (UIViewController *viewController in [self childViewControllers]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [((ProgressNavigationViewController*)viewController).sendProgress setProgress:0.0 animated:NO];
                [((ProgressNavigationViewController*)viewController).sendProgress setHidden:YES];
            });
        }
        
        [_connectedPeopleManager removeAllQueuedSendsForPeer:peerID];
        
        //Only put the device's idle timer back on if there are no other sends in progres
        if (![_connectedPeopleManager currentlyInTheProcessOfSending] && ![_connectedPeopleManager currentlyInTheProcessOfReceiving]) {
            //Allow phone to go back to sleep after send is finished
            if (![LocalStorageManager getKeepDeviceAwakeSetting]) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }
        }
        else if ([_connectedPeopleManager currentlyInTheProcessOfSending]) {
            [self performNextSendInSendQueue];
        }
    }
}

-(void)didStartReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    NSLog(@"%s STARTED RECEIVEING RESOURCE: %@, FROM PEER: %@", __PRETTY_FUNCTION__, resourceName, peerID);
    
    //This increment keeps track of what peers we're receiving from and how many receptions are in progress from a peer
    [_connectedPeopleManager addFileReceptionInProgressWithResourceName:resourceName ReceivingFromPeer:peerID];
    
    //Stops phone from going to sleep while we're sending
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    UIViewController *inboxViewController = nil;
    
    for (UIViewController* viewController in self.childViewControllers) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *rootViewController = ((UINavigationController*)viewController).viewControllers[0];
            if ([rootViewController isKindOfClass:[InboxViewController class]]) {
                inboxViewController = rootViewController;
            }
        }
    }
    
    [_connectedPeopleManager addIncomingSendProgress:progress withResourceName:resourceName andPeerID:peerID AndAddObserver:inboxViewController];
    
    // Send a notification to InboxViewController to reload its table view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startedReceivingNewFilePackageFromPeer" object:self];
    
    if (!_tabBarCurrentlyAnimating && !(self.selectedIndex == 1)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _tabBarCurrentlyAnimating = YES;
            [_tabBarAnimationTimer invalidate];
            _tabBarAnimationTimer = [NSTimer timerWithTimeInterval:.4 target:self selector:@selector(animateTabBarText) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_tabBarAnimationTimer forMode:NSRunLoopCommonModes];
        });
    }
}

-(void) didFinishReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    NSLog(@"%s FINISHED RECEIVEING RESOURCE: %@, FROM PEER: %@", __PRETTY_FUNCTION__, resourceName, peerID);
    
    UIViewController *inboxViewController = nil;
    
    for (UIViewController* viewController in self.childViewControllers) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *rootViewController = ((UINavigationController*)viewController).viewControllers[0];
            if ([rootViewController isKindOfClass:[InboxViewController class]]) {
                inboxViewController = rootViewController;
            }
        }
    }
    
    //Remove this class as an observer for the progress of the file reception
    [_connectedPeopleManager removeIncomingSendProgressForResourceName:resourceName andPeerID:peerID];
    
    //This decrement keeps track of what peers we're receiving from and how many receptions are in progress from a peer
    [_connectedPeopleManager removeFileReceptionInProgressWithResourceName:resourceName ReceivingFromPeer:peerID];
    
    //Only put the device's idle timer back on if there are no other receptions/sends in progress
    if (![_connectedPeopleManager currentlyInTheProcessOfReceiving] && ![_connectedPeopleManager currentlyInTheProcessOfSending]) {
        //Allow phone to go back to sleep after send is finished
        if (![LocalStorageManager getKeepDeviceAwakeSetting]) {
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        }
    }
    
    if (self.selectedIndex != 1) {
        //Turn off tabBarAnimation if we are not receiving files anymore.
        if (![_connectedPeopleManager currentlyInTheProcessOfReceiving]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _tabBarCurrentlyAnimating = NO;
                [_tabBarAnimationTimer invalidate];
            });
        }
    }
    
    if (error) {
        NSLog(@"MULTIPEER SENDING ERROR: %@", error);
//        [self alertReceivingUserToMultipeerSendingError: error];
        if (self.selectedIndex != 1) {
            //Turn off tabBarAnimation if we are not receiving files anymore.
            if (![_connectedPeopleManager currentlyInTheProcessOfReceiving]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
                    inboxTab.badgeValue = nil;
                });
            }
        }
    }
    else {
    
        // Create a new UUID for the zip file on the receiving end
        NSString* UUID = [[resourceName stringByDeletingPathExtension] stringByDeletingPathExtension];
        NSLog(@"DA UUID: %@", UUID);
        
        NSString* escapedDestinationStub = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[AppConstants incomingStringIdentifier]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* destinationPath = [escapedDestinationStub stringByAppendingPathComponent:UUID];
        NSLog(@"DA destinationPath: %@", destinationPath);
        
        // create a temporary zip file in inbox.
        NSURL* newURL = [NSURL fileURLWithPath:[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[AppConstants incomingStringIdentifier]] stringByAppendingPathComponent:resourceName] isDirectory:NO];
        NSData* dataForTemporaryFilePath = [NSData dataWithContentsOfURL:localURL];
        [[NSFileManager defaultManager] createFileAtPath:[newURL path] contents:dataForTemporaryFilePath attributes:nil];

    //    //create a file in the Inbox folder for our new zip file to unzip to.
    //    [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"CREATE FILE ERROR: %@", error);
        
        // unzip the file at the temporary place we created it to the destination path.
        NSString *zipPath = [newURL path];
        NSLog(@"DA ZIP PATH: %@", zipPath);
        [SSZipArchive unzipFileAtPath:zipPath toDestination:[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[AppConstants incomingStringIdentifier]] stringByAppendingPathComponent:UUID]];
        
        [[NSFileManager defaultManager] removeItemAtPath:[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[AppConstants incomingStringIdentifier]] stringByAppendingPathComponent:resourceName] error:&error];
        NSLog(@"DESTROY FILE ERROR: %@", error);

        BOOL isDir = 0;
        BOOL isValid = [[NSFileManager defaultManager] fileExistsAtPath:[[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[AppConstants incomingStringIdentifier]] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isDirectory:&isDir];
        NSLog(@"%s ISVALIDPATH %d PATH: %@", __PRETTY_FUNCTION__,isValid, [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[AppConstants incomingStringIdentifier]]);
        NSLog(@"IS IT A DIR?: %d", isDir);
        
        NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL URLWithString:[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[AppConstants incomingStringIdentifier] ] stringByAppendingPathComponent:UUID]]
            includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error)
                                             {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }];

        for(NSURL* fileURL in enumerator){
            NSString *filename;
            BOOL isDirectory;
            [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
            [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path] isDirectory:&isDirectory];
            if(isDirectory){
                NSLog(@"IS DIRECTORY TRUE");
            }else{
                NSLog(@"IS DIRECTORY FALSE");
            }
            filename = [filename stringByRemovingPercentEncoding];
            File* file = [[File alloc]initWithName:filename andPath:[[self fsInterface] resolveFilePath:[[fileURL path] stringByRemovingPercentEncoding] excludingUpToDirectory:@"Documents"]  andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:(BOOL)isDirectory andBoxId:@"-1"];
            NSLog(@"DA FILE NAME WE ADDING: %@", file.name);
            NSLog(@"DAT FILE PATH WE BE ADD: %@", file.path);
            
            NSLog(@"Adding newly received file to inbox json");
            [_inboxManager addSingleFileToInboxJsonWithFilePackageUUID:UUID andFile:file fromPeer: peerID];
        }
        
        [self alertReceivingUserToNewFilesReceived];
        
        
        // Send a notification to update the badge on the inbox tab
        [[NSNotificationCenter defaultCenter] postNotificationName:@"successfullyReceivedFilePackageFromPeer" object:self];
        
    //    FileSystem* daSystem = [[FileSystem alloc]init];
    //    NSLog(@"BLAH::::%@", [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"Local"] stringByAppendingPathComponent:resourceName]);
    //    NSLog(@"DA NEW URL: %@", [newURL path]);
    //    NSURL* newURL = [NSURL fileURLWithPath:[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"Local"] stringByAppendingPathComponent:resourceName] isDirectory:NO];
    //    NSData* dataForTemporaryFilePath = [NSData dataWithContentsOfURL:localURL];
        //File* newFile = [daSystem createNewFile:resourceName withURL:newURL andRevision:@"a" isDirectory:NO hasBoxId:@"-1" withContents:dataForTemporaryFilePath];
        //[[NSFileManager defaultManager] createFileAtPath:[newURL path] contents:dataForTemporaryFilePath attributes:nil];
        //[daSystem saveSinglefileToJSON:newFile inDir:[daSystem resolveFilePathForFile:newFile]];
    }
    
    //Send a notification to reload file packages view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedReceivingFilePackageFromPeer" object:self];
}

-(void) didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
//    NSLog(@"%s RECEIVED DATA: %@, FROM PEER: %@", __PRETTY_FUNCTION__, data, peerID);
    
    NSString *linkPackageJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"linkPackageJson %@", linkPackageJson);
    
    NSError *error;
    LinkPackageJM *linkPackageJM = [[LinkPackageJM alloc] initWithString:linkPackageJson error:&error];
    if(error) {
        NSLog(@"Error parsing link package: %s %@", __PRETTY_FUNCTION__, [error description]);
        return;
    }
   
    [_inboxManager saveLinkPackage:linkPackageJM];
    
    //Update inbox tab badge
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedLinkPackageFromPeer" object:self];
    [self alertUserToNewLinksReceived];
}

-(void) didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
    NSLog(@"%s RECEIVED RESOURCE: %@, FROM PEER: %@", __PRETTY_FUNCTION__, streamName, peerID);
}

#pragma mark - AdvertiserWrapperDelegate

/* - method gets triggered from AdvertiserHelper-didreceiveInvitaiton - */

-(void) acceptInvitationFromPeer:(MCPeerID *)foreignPeerID
               invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
    invitationHandler(YES, _sessionWrapper.session);
    
    NSLog(@"INVITATION FROM PEER %@ ACCEPTED", [LocalStorageManager getPeerNameFromDisplayName:foreignPeerID.displayName]);
}

-(void) failedToAdvertise:(NSError *)error{
    
    NSLog(@"%s FAILED TO START ADVERTISING ALL TOGETHER WITH ERROR: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - BrowserWrapperDelegate

-(void) inviteFoundPeer:(MCPeerID *)foreignPeerID withContext:(NSString *)context{
    
    NSData* contextData = [context dataUsingEncoding:NSUTF8StringEncoding];
    
    //Let peer with higher compare value from display name invite
    BOOL shouldInvite = ([[_sessionWrapper getMyPeerID].displayName compare:foreignPeerID.displayName]==NSOrderedDescending);
    
    if (shouldInvite) {
        [_browserWrapper.autobrowser invitePeer:foreignPeerID toSession:_sessionWrapper.session withContext:contextData timeout:5.0];
        NSLog(@"INVITED FOREIGN PEER: %@", [LocalStorageManager getPeerNameFromDisplayName:foreignPeerID.displayName]);
    }
    else {
        NSLog(@"Letting %@ invite me.", [LocalStorageManager getPeerNameFromDisplayName:foreignPeerID.displayName]);
    }
}

-(void) alertToLostPeer:(MCPeerID *)lostForeignPeerID{
}

-(void) failedToBrowse:(NSError *)error{
    
    NSLog(@"%s FAILED TO START BROWSING ALL TOGETHER WITH ERROR: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - Helper methods

-(void)alertSendingUserToFilesSentSuccessfully {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Files sent successfully!";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)alertReceivingUserToNewFilesReceived {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"New files received!";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)alertUserToNewLinksReceived {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"New links received!";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)alertUserToFileSendsCanceled {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"File sends canceled";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(MBProgressHUD*)alertUserToPreparingSend {
    __block MBProgressHUD *hud;
    dispatch_sync(dispatch_get_main_queue(), ^{
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Preparing Send";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
    });
    
    return hud;
}

-(void)alertUserToLinksSent {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Links Sent";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)dismissPreparingSendAlert: (MBProgressHUD*)hud {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [hud hide:YES];
    });
}

-(void)alertUserToResetSessionConnection {
    UIAlertController *options = [UIAlertController alertControllerWithTitle:@"Notice"
                                                                     message:@"Sending is taking longer than usual. Would you like to refresh your session connection? This will cancel any sends in progress, but may fix connection and sending issues."
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *action) {
                                                         [options dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self alertUserToFileSendsCanceled];
                                                          [self resetSession];
                                                      }];
    
    [options addAction:noAction];
    [options addAction:yesAction];
    [self presentViewController:options animated:YES completion:nil];
}

-(void)alertUserToFailedToSendLinks {
    UIAlertController* alert;
    
    alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Your links didn't go through. Try refreshing your session on the nearby tab or send page before sending again."] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertSendingUserToPeerDisconnectedDuringSend: (MCPeerID*)peer {
    UIAlertController* alert;
    
    alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Your files didn't go through. Looks like %@ disconnected. Try refreshing your session on the nearby tab or send page before sending again.", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertSendingUserToMultipeerSendingError: (NSError*)error forPeer: (MCPeerID*)peer{
    UIAlertController* alert;
    
    if ([error.domain  isEqualToString: @"MCSession"] && error.code == 1) {
        alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Your files didn't go through. Looks like %@ disconnected. Try refreshing your session on the nearby tab or send page before sending again.", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]] preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:@"Your files didn't go through. Looks like something went wrong. Try refreshing your session on the nearby tab or send page before sending again." preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//-(void)alertReceivingUserToMultipeerSendingError: (NSError*)error {
//    UIAlertController* alert;
//    if ([error.domain  isEqual: @"MCSession"] && error.code == 1) {
//        alert = [UIAlertController alertControllerWithTitle:@"Error"
//                                                    message:@"File transfer failed. Peer disconnected during send. Try refreshing your session on the nearby tab."
//                                             preferredStyle:UIAlertControllerStyleAlert];
//    }
//    else {
//        alert = [UIAlertController alertControllerWithTitle:@""
//                                                    message:@"File transfer failed."
//                                             preferredStyle:UIAlertControllerStyleAlert];
//    }
//
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {}];
//    [alert addAction:defaultAction];
//    [self presentViewController:alert animated:YES completion:nil];
//}

/* - Updates corresponding array when a peer connects/disconnects - */

-(void)updateConnectedPeopleWithPeer: (MCPeerID*)peer State: (MCSessionState)state {
    
    //Check if peer is a friend. If not, they are a stranger. Check if connected or disconnected for both cases and add/remove from corresponding connected arrays
    
    NSString *peerUUID = [LocalStorageManager getUUIDFromDisplayName:peer.displayName];
    
    BOOL peerIsAFriend = NO;
    if ([_localStorageManager FriendDoesExistWithUUID:peerUUID]) {
            peerIsAFriend = YES;
    }
    
    // This code prevents Multipeer from causing user to find themselves as a peer (weird bug)
    BOOL peerMatchesCurrentUsersUUID = NO;
    if ([[LocalStorageManager getUUIDFromDisplayName:peer.displayName] isEqualToString:[LocalStorageManager getUUIDFromDisplayName:[_sessionWrapper getMyPeerID].displayName]]) {
        peerMatchesCurrentUsersUUID = YES;
    }
    
    //Update found friend or stranger
    if (state == MCSessionStateConnected && !peerMatchesCurrentUsersUUID) {
        
        if (peerIsAFriend) { //Peer is a friend
            
            //This code prevents Multipeer from adding more than one peer with the same UUID to connectedStrangers or connectedfriends (ghost peers)
            BOOL peerMatchesCurrentlyConnectedFriend = NO;
            for (MCPeerID *friend in [_connectedPeopleManager getConnectedFriends]) {
                if ([[LocalStorageManager getUUIDFromDisplayName:friend.displayName] isEqualToString:[LocalStorageManager getUUIDFromDisplayName:peer.displayName]]) {
                    peerMatchesCurrentlyConnectedFriend = YES;
                }
            }
            
            if (!peerMatchesCurrentlyConnectedFriend) {
                [_connectedPeopleManager addConnectedFriend:peer];
                //Update friend's name if name has changed since last connection
                [_localStorageManager updateNameOfFriend:[LocalStorageManager getUUIDFromDisplayName:peer.displayName] IfNameChanged:[LocalStorageManager getPeerNameFromDisplayName:peer.displayName]];
            }
        }
        else { //Peer is a stranger
            //This code prevents Multipeer from adding more than one peer with the same UUID to connectedStrangers or connectedfriends (ghost peers)
            BOOL peerMatchesCurrentlyConnectedStranger = NO;
            for (MCPeerID *stranger in [_connectedPeopleManager getConnectedStrangers]) {
                if ([[LocalStorageManager getUUIDFromDisplayName:stranger.displayName] isEqualToString:[LocalStorageManager getUUIDFromDisplayName:peer.displayName]]) {
                    peerMatchesCurrentlyConnectedStranger = YES;
                }
            }
            
            if (!peerMatchesCurrentlyConnectedStranger) {
                [_connectedPeopleManager addConnectedStranger:peer];
            }
        }
            
        NSDictionary *peerInfo = @{@"peerID": peer, @"state": @"MCSessionStateConnected", @"friendStatus":[NSString stringWithFormat:@"%@", peerIsAFriend ? @"YES" : @"NO"]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCPeerDidChangeStateNotification" object:self userInfo:peerInfo];
        [_connectedPeopleManager stopCurrentlySearchingForPeersStateTimer];
    }
    //Update lost friend or stranger
    else if (state == MCSessionStateNotConnected && !peerMatchesCurrentUsersUUID) {
        
        if (peerIsAFriend) { //Peer is a friend
            [_connectedPeopleManager removeConnectedFriend:peer];
        }
        else { //Peer is a stranger
            [_connectedPeopleManager removeConnectedStranger:peer];
        }
            
        NSDictionary *peerInfo = @{@"peerID": peer, @"state": @"MCSessionStateNotConnected", @"friendStatus":[NSString stringWithFormat:@"%@", peerIsAFriend ? @"YES" : @"NO"]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCPeerDidChangeStateNotification" object:self userInfo:peerInfo];
    }
}

/* - Called when we manually kill a session - */

-(void)cleanUpSessionRelatedVariables {
    
    [_connectedPeopleManager removeAllPeersFromPeersSendingToAndPeersReceivingFrom];
    [_connectedPeopleManager removeAllOutgoingAndIncomingSendProgresses];
    [_connectedPeopleManager removeAllConnectedFriends];
    [_connectedPeopleManager removeAllConnectedStrangers];
    
    //Reset progress bar
    for (UIViewController *viewController in [self childViewControllers]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [((ProgressNavigationViewController*)viewController).sendProgress setProgress:0.0 animated:NO];
            [((ProgressNavigationViewController*)viewController).sendProgress setHidden:YES];
        });
    }
    
    //Turn off tabBarAnimation
    dispatch_async(dispatch_get_main_queue(), ^{
        _tabBarCurrentlyAnimating = NO;
        [_tabBarAnimationTimer invalidate];
    });
    
    UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
    
    //Set inbox badge value
    NSString *totalNumUncheckedPackages = [InboxManager getTotalNumberOfUncheckedPackages];
    if ([totalNumUncheckedPackages isEqualToString:@"0"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            inboxTab.badgeValue = nil;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            inboxTab.badgeValue = totalNumUncheckedPackages;
        });
    }
    
    //Lets application know we disabled timer after manually killing a session (because we still get ghost progress updates which would otherwise reset timer for alert)
    _sendTimerInvalidated = YES;
    //Disable timer for progress stall alert
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alertToResetSessionConnectionTimer invalidate];
    });
}

/* - Animates a change in the inbox tab's text - */
-(void)animateTabBarText {
    UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([_tabBarAnimationTimer isValid]) {
            if ([inboxTab.badgeValue isEqualToString:@"   "]) {
                inboxTab.badgeValue = @".  ";
            }
            else if ([inboxTab.badgeValue isEqualToString:@".  "]) {
                inboxTab.badgeValue = @".. ";
            }
            else if ([inboxTab.badgeValue isEqualToString:@".. "]) {
                inboxTab.badgeValue = @"...";
            }
            else if ([inboxTab.badgeValue isEqualToString:@"..."]) {
                inboxTab.badgeValue = @"   ";
            }
            else {
                inboxTab.badgeValue = @"   ";
            }
        }
    });
}

#pragma mark - TEST

-(void)addDummyPeersToConnectedPeople {
    
//    [_localStorageManager addFriendWithName:@"FriendA" AndUUID:@"i34gwn3-ev4inier-fkh3ni-wnwrf"];
//    [_localStorageManager addFriendWithName:@"FriendB" AndUUID:@"3nfvh2-f3jbeo2-w32w4ff-3jbfw3n"];
//    [_localStorageManager addFriendWithName:@"FriendB" AndUUID:@"4irfnwe-3khvwihr-wefkb3be-3nfww3i"];
    
//    [_connectedPeopleManager addConnectedFriend:[[MCPeerID alloc] initWithDisplayName:@"FriendA|i34gwn3-ev4inier-fkh3ni-wnwrf"]];
//    [_connectedPeopleManager addConnectedFriend:[[MCPeerID alloc] initWithDisplayName:@"FriendB|3nfvh2-f3jbeo2-w32w4ff-3jbfw3n"]];
//    [_connectedPeopleManager addConnectedFriend:[[MCPeerID alloc] initWithDisplayName:@"FriendC|4irfnwe-3khvwihr-wefkb3be-3nfww3i"]];
    
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"strangerYoWasupLonggggg1|12rjwf-rfanefuwn-wfnjwf-2mfiq23"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger2|n3riuh2-23rhbfwi2-fcjw3b4j2-3ej2bf2"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger3|kjhif132-12eihi23-3e1hbr13-12ejb12eb"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger4|3kihu3n4i-12eihi23-3e1sdfjiw23-12ejb12eb"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger5|fkgje04i-12eihi23-3e1hbr13-12ejb12eb"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger6|lsfigj9449-12eihi23-3e1hbr13-12ejb12eb"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger7|sfligj944-12eihi23-3e1hbr13-12ejb12eb"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger8|srligj49-12eihi23-3e1hbr13-12ejb12eb"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger9|dlfgji4iwl-12eihi23-3e1hbr13-12ejb12eb"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"stranger10|ldfjgni4of-12eihi23-3e1hbr13-12ejb12eb"]];
}

-(void)printIdleTimerStatus {
    NSLog(@"Idle timer is disabled? %@", [UIApplication sharedApplication].idleTimerDisabled? @"Yes" : @"NO");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
