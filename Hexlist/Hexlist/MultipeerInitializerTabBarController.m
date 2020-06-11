//
//  MultipeerInitializerTabBarController.m
//  Hexlist
//
//  Created by Roman Scher on 1/21/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "MultipeerInitializerTabBarController.h"

#define HOME_TAB 0
#define INBOX_TAB 1
#define MY_HEXLIST_TAB 2
#define NEARBY_TAB 3

@implementation MultipeerInitializerTabBarController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Setup
    self.delegate = (id)self;
    _connectedPeopleManager = [ConnectedPeopleManager sharedConnectedPeopleManager];
    
    UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
    
    //Set inbox badge value
    NSString *numUncheckedHexes = [HexManager getNumberOfUncheckedHexes];
    if ([numUncheckedHexes isEqualToString:@"0"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            inboxTab.badgeValue = nil;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            inboxTab.badgeValue = numUncheckedHexes;
        });
    }
        
    // Multipeer Wrappers Intitializations
    // INITIALIZE USER'S displayName WITH UNIQUE UUID APPENDED, USE CORRECT SettingsManager CLASS METHOD TO SPLIT IT OFF WHEN NEEDED TO DISPLAY TO USERS
    [_connectedPeopleManager startCurrentlySearchingForPeersStateTimer];
    NSString *UUID = [@"|" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    _sessionWrapper = [[SessionWrapper alloc] init];
    _sessionWrapper.sessionWrapperDelegate = self;
    _sessionWrapper = [_sessionWrapper initSessionWithMyPeerName:[[SettingsManager getUserDisplayableFullName] stringByAppendingString:UUID]];
    _advertiserWrapper = [[AdvertiserWrapper alloc] init];
    _advertiserWrapper.advertiserWrapperDelegate = self;
    _advertiserWrapper = [_advertiserWrapper startAdvertising:_sessionWrapper.myPeerID];
    _browserWrapper = [[BrowserWrapper alloc] init];
    _browserWrapper.browserWrapperDelegate = self;
    _browserWrapper = [_browserWrapper startBrowsing:_sessionWrapper.myPeerID];
    
    _browserWrapper.browserWrapperDelegate = self;
    
    // Add thiis VC as a listener for notifications when the app goes into the background, enters foreground, or closes, so we can actively destroy session/advertising/browsing (and rebuild it) isntead of letting multipeer do it whenever
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    // Add this VC as a listener for notifications on changing our name,
    //and receiving new links from peers (Posted from MultiPeerInitializerTabBarController)
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetSession)
                                                 name:@"userChangedNameNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedHexFromPeer)
                                                 name:@"receivedHexFromPeer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSession) name:@"triggerResetSession" object:nil];

    //TEST 1 - Adds dummy peers to connected people arrays where necessary
    //(NOTE THAT THIS TEST IS MAINLY FOR DISPLAY ON TABLES AND MAY BREAK CERTAIN FEATURES BECAUSE THESE ARE NOT REAL PEERS)
//    [self addDummyPeersToConnectedPeople];
//    [self addDummyDouchesToConnectedPeople];
    
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

/* - Handles actions related to selecting tabs - */

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
            if ([tabBarController selectedIndex] == INBOX_TAB) {
                if ([topViewController isKindOfClass:[InboxViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"inboxTabSelectedNotification" object:self];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popBackToRootViewController" object:self];
                    return NO;
                }
            }
            else {
                UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
           
                //Set inbox badge value
                [HexManager reduceNumberOfUncheckedHexesToZero];
                dispatch_async(dispatch_get_main_queue(), ^{
                    inboxTab.badgeValue = nil;
                });
            }
        }
        else if ([rootViewController isKindOfClass:[MyHexlistViewController class]]) {
            if ([tabBarController selectedIndex] == MY_HEXLIST_TAB) {
                if ([topViewController isKindOfClass:[MyHexlistViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"myHexlistTabSelectedNotification" object:self];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popBackToRootViewController" object:self];
                    return NO;
                }
            }
        }
        else if ([rootViewController isKindOfClass:[ConnectViewController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"nearbyTabSelectedNotification" object:self];
        }
        // Handles return to root directory on home view controller
        else if ([rootViewController isKindOfClass:[HomeViewController class]]){
            //Allows a tap on home tab to bring us back to root directory if we are already on home tab
            if ([tabBarController selectedIndex] == HOME_TAB)  {
                if ([topViewController isKindOfClass:[HomeViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"returnHomeViewControllerToRootDirectoryNotification" object:self];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"popBackToRootViewController" object:self];
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
    
    //NSLog(@"Killing User's multipeer session");
    
    // DESTROY SESSION, STOP ADVERTISING & BROWSING
    [_sessionWrapper destroySession];
    [_advertiserWrapper stopAdvertising];
    [_browserWrapper stopBrowsing];
    
    [self cleanUpSessionRelatedVariables];
    
    [_connectedPeopleManager startCurrentlySearchingForPeersStateTimer];
    //NSLog(@"Restarting Session");
    
    // NOW RESTART SESSION, ADVERTISING & BROWSING
    NSString *UUID = [@"|" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    _sessionWrapper = [_sessionWrapper initSessionWithMyPeerName:[[SettingsManager getUserDisplayableFullName] stringByAppendingString:UUID]];
    [_advertiserWrapper startAdvertising:_sessionWrapper.myPeerID];
    [_browserWrapper startBrowsing:_sessionWrapper.myPeerID];
}

/* - Updates the badge on the inbox tab after new hex is received from a peer - */
 
-(void)receivedHexFromPeer {
    //If we are currently on inbox tab, let inbox update itself.
    if (!(self.selectedIndex == INBOX_TAB)) {
        UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBar.items objectAtIndex:1];
        
        [HexManager incrementnumberOfUncheckedHexes];
        NSString *numUncheckedHexes = [HexManager getNumberOfUncheckedHexes];
        dispatch_async(dispatch_get_main_queue(), ^{
            inboxTab.badgeValue = numUncheckedHexes;
        });
    }
}

/* - Actively destroys session/advertising/browsing when app goes into the background - */

-(void)applicationDidEnterBackground {
    //NSLog(@"Killing User's multipeer session");
    
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
    _sessionWrapper = [_sessionWrapper initSessionWithMyPeerName:[[SettingsManager getUserDisplayableFullName] stringByAppendingString:UUID]];
    [_advertiserWrapper startAdvertising:_sessionWrapper.myPeerID];
    [_browserWrapper startBrowsing:_sessionWrapper.myPeerID];
}

/* - Actively destroys session/advertising/browsing when app closes - */

-(void)appWillTerminate {
    //NSLog(@"Killing User's multipeer session");
    
    // MANUALLY DESTROYS SESSION, STOP ADVERTISING & BROWSING (so that other peers get quicker updates on disconnected peers)
    [_sessionWrapper destroySession];
    [_advertiserWrapper stopAdvertising];
    [_browserWrapper stopBrowsing];
    
    [self cleanUpSessionRelatedVariables];
}

#pragma mark - SettingsViewControllerDelegate

/* - Kills User's session when they return to intro screen - */

-(void)backToIntroScreenTapped {
    //NSLog(@"Killing User's multipeer session");
    
    // DESTROY SESSION, STOP ADVERTISING & BROWSING
    [_sessionWrapper destroySession];
    [_advertiserWrapper stopAdvertising];
    [_browserWrapper stopBrowsing];
    
    [self cleanUpSessionRelatedVariables];
}

#pragma mark - SendViewControllerDelegate

-(void)sendHexJMs:(NSArray<HexJM*>*)hexJMsToSend ToPeers:(NSMutableArray *)peersToSendTo {
    for (HexJM *hexJM in hexJMsToSend) {
        //Form dataSendWrapper
        DataSendWrapper *dataSendWrapper = [DataSendWrapper
                                            createDataSendWrapperWithVersionID:[SettingsManager getAppVersion]
                                            AndOperationType:OperationTypeStore
                                            AndJMObjectType:JMObjectTypeHex
                                            AndJMObject:hexJM];
        
        //Convert dataSendWrapper into nsdata to be send to peer
        NSString *dataSendWrapperJson = [dataSendWrapper toJSONString];
        NSData *dataSendWrapperData = [dataSendWrapperJson dataUsingEncoding:NSUTF8StringEncoding];
        
        //NSLog(@"\ndataSendWrapperJson: %@\n", dataSendWrapperJson);
        //NSLog(@"dataSendWrapperData byte size: %lu", (unsigned long)dataSendWrapperData.length);
        
        NSError *error;
        BOOL success = [[_sessionWrapper session] sendData:dataSendWrapperData toPeers:peersToSendTo withMode:MCSessionSendDataReliable error:&error];
        
        if(error || !success) {
            //NSLog(@"Link Send error: %s %@", __PRETTY_FUNCTION__, [error description]);
            [self alertUserToFailedToSendHex];
        }
        else {
            [self alertUserToSendingHex];
        }
    }
}

-(void)sendHexes:(NSArray<Hex*>*)hexesToSend ToPeers:(NSMutableArray *)peersToSendTo {
    for (Hex *hex in hexesToSend) {
        //Form hex
        HexJM *hexJM = [HexManager generateSendableHexJMFromHex:hex];
        //Form dataSendWrapper
        DataSendWrapper *dataSendWrapper = [DataSendWrapper
                                            createDataSendWrapperWithVersionID:[SettingsManager getAppVersion]
                                            AndOperationType:OperationTypeStore
                                            AndJMObjectType:JMObjectTypeHex
                                            AndJMObject:hexJM];
        
        //Convert dataSendWrapper into nsdata to be send to peer
        NSString *dataSendWrapperJson = [dataSendWrapper toJSONString];
        NSData *dataSendWrapperData = [dataSendWrapperJson dataUsingEncoding:NSUTF8StringEncoding];
        
        //NSLog(@"\ndataSendWrapperJson: %@\n", dataSendWrapperJson);
        //NSLog(@"dataSendWrapperData byte size: %lu", (unsigned long)dataSendWrapperData.length);
        
        NSError *error;
        BOOL success = [[_sessionWrapper session] sendData:dataSendWrapperData toPeers:peersToSendTo withMode:MCSessionSendDataReliable error:&error];
        
        if(error || !success) {
            //NSLog(@"Link Send error: %s %@", __PRETTY_FUNCTION__, [error description]);
            [self alertUserToFailedToSendHex];
        }
        else {
            [self alertUserToSendingHex];
        }
    }
}

#pragma mark - SessionWrapperDelegate

-(void) peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
//    NSString *peerName = [ConnectedPeopleManager getPeerNameFromDisplayName:peerID.displayName];
//    NSString *peerUUID = [ConnectedPeopleManager getUUIDFromDisplayName:peerID.displayName];
    
    //Explicit if-else statement, otherwise state is returned as a digit and unclear
    if (state == MCSessionStateNotConnected) {
        //NSLog(@"PEER CHANGED STATE TO: NotConnected - %@ %@ %@", peerName, @"-", peerUUID);
    }
    else if (state == MCSessionStateConnecting) {
        //NSLog(@"PEER CHANGED STATE TO: Connecting - %@ %@ %@", peerName, @"-", peerUUID);
    }
    else if (state == MCSessionStateConnected) {
        //NSLog(@"PEER CHANGED STATE TO: Connected - %@ %@ %@", peerName, @"-", peerUUID);
    }
    
    //Update a peer's connection status only if they've connected or disconnected
    if (state == MCSessionStateConnected || state == MCSessionStateNotConnected) {
        [self updateConnectedPeopleWithPeer:peerID State:state];
    }
}

-(void)didStartReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    //NSLog(@"%s STARTED RECEIVEING RESOURCE: %@, FROM PEER: %@", __PRETTY_FUNCTION__, resourceName, peerID);
}

-(void) didFinishReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    //NSLog(@"%s FINISHED RECEIVEING RESOURCE: %@, FROM PEER: %@", __PRETTY_FUNCTION__, resourceName, peerID); 
}

-(void) didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
    NSLog(@"%s RECEIVED DATA: %@, FROM PEER: %@", __PRETTY_FUNCTION__, data, peerID);
    
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%s RECEIVED DATA: %@, FROM PEER: %@", __PRETTY_FUNCTION__, dataString, peerID);
    
    //Interpret the dataString as a dataSendWrapper json string
    NSError *error;
    DataSendWrapper *dataSendWrapper = [[DataSendWrapper alloc] initWithString:dataString error:&error];
    if(error) {
        [AlertManager alertUserToFailedToReadIncomingData];
        //NSLog(@"Error parsing dataSendWrapper: %s %@", __PRETTY_FUNCTION__, [error description]);
        return;
    }

    if ([AppConstants operationTypeForString:dataSendWrapper.operationType] == OperationTypeAlert) {
        [self alertUserToAlertWithMessage:dataSendWrapper.message];
    }
    else {
        if (![SettingsManager userWithUUIDIsBlocked:[ConnectedPeopleManager getUUIDFromDisplayName:peerID.displayName]]) {
            //Store operation - store the contained object in app
            if ([AppConstants operationTypeForString:dataSendWrapper.operationType] == OperationTypeStore) {
                
                //Hex object was sent to us
                if ([AppConstants jmObjectTypeForString:dataSendWrapper.jmObjectType] == JMObjectTypeHex) {
                    HexJM *hexJM = [[HexJM alloc] initWithDictionary:dataSendWrapper.jmObject error:&error];
                    if(error) {
                        //NSLog(@"Error parsing hex: %s %@", __PRETTY_FUNCTION__, [error description]);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [AlertManager alertUserToFailedToReadIncomingHex];
                        });
                        return;
                    }
                    
                    //Get Hex from HexJM & Get Links From Hex's LinkJMs
                    Hex *hex = [HexManager generateHexFromHexJM:hexJM];
                    NSArray *links = [HexManager generateArrayOfLinksFromLinksJM:[LinkJM arrayOfModelsFromDictionaries:hexJM.links]];
                    [HexManager saveNewHexToInbox:hex WithLinks:links];
                    
                    //NSLog(@"Saving hex to inbox:%@", hex);
                    
                    //Update inbox tab badge
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedHexFromPeer" object:self];
                    [self alertUserToNewHexReceived];
                }
            }
        }
        else {
            //NSLog(@"Blocked send from blocked user");
            
            //Form dataSendWrapper
            DataSendWrapper *dataSendWrapper = [DataSendWrapper
                                                createDataSendWrapperWithVersionID:[SettingsManager getAppVersion]
                                                AndOperationType:OperationTypeAlert
                                                AndMessage:[NSString stringWithFormat: @"%@ blocked you.", [SettingsManager getUserDisplayableFullName]]];
            
            //Convert dataSendWrapper into nsdata to be send to peer
            NSString *dataSendWrapperJson = [dataSendWrapper toJSONString];
            NSData *dataSendWrapperData = [dataSendWrapperJson dataUsingEncoding:NSUTF8StringEncoding];
            
            //NSLog(@"\ndataSendWrapperJson: %@\n", dataSendWrapperJson);
            //NSLog(@"dataSendWrapperData byte size: %lu", (unsigned long)dataSendWrapperData.length);
            
            NSError *error;
            [[_sessionWrapper session] sendData:dataSendWrapperData toPeers:[NSArray arrayWithObject:peerID] withMode:MCSessionSendDataReliable error:&error];
            
        }
    }
}

-(void) didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
    //NSLog(@"%s RECEIVED STREAM: %@, FROM PEER: %@", __PRETTY_FUNCTION__, streamName, peerID);
}

#pragma mark - AdvertiserWrapperDelegate

/* - method gets triggered from AdvertiserHelper-didreceiveInvitaiton - */

-(void) acceptInvitationFromPeer:(MCPeerID *)foreignPeerID
               invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
    invitationHandler(YES, _sessionWrapper.session);
    
    //NSLog(@"INVITATION FROM PEER %@ ACCEPTED", [ConnectedPeopleManager getPeerNameFromDisplayName:foreignPeerID.displayName]);
}

-(void) failedToAdvertise:(NSError *)error{
    
    //NSLog(@"%s FAILED TO START ADVERTISING ALL TOGETHER WITH ERROR: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - BrowserWrapperDelegate

-(void) inviteFoundPeer:(MCPeerID *)foreignPeerID withContext:(NSString *)context{
    
    NSData* contextData = [context dataUsingEncoding:NSUTF8StringEncoding];
    
    //Let peer with higher compare value from display name invite
    BOOL shouldInvite = ([[_sessionWrapper getMyPeerID].displayName compare:foreignPeerID.displayName]==NSOrderedDescending);
    
    if (shouldInvite) {
        [_browserWrapper.autobrowser invitePeer:foreignPeerID toSession:_sessionWrapper.session withContext:contextData timeout:5.0];
        //NSLog(@"INVITED FOREIGN PEER: %@", [ConnectedPeopleManager getPeerNameFromDisplayName:foreignPeerID.displayName]);
    }
    else {
        //NSLog(@"Letting %@ invite me.", [ConnectedPeopleManager getPeerNameFromDisplayName:foreignPeerID.displayName]);
    }
}

-(void) alertToLostPeer:(MCPeerID *)lostForeignPeerID{
}

-(void) failedToBrowse:(NSError *)error{
    
    //NSLog(@"%s FAILED TO START BROWSING ALL TOGETHER WITH ERROR: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - Helper methods

-(void)alertUserToNewHexReceived {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"New hex received!";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)alertUserToSendingHex {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Sending Hex";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)alertUserToAlertWithMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = message;
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)alertUserToFailedToSendHex {
    UIAlertController* alert;
    
    alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Your hex didn't go through. Try refreshing your session on the nearby tab or send page before sending again."] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/* - Updates corresponding array when a peer connects/disconnects - */

-(void)updateConnectedPeopleWithPeer: (MCPeerID*)peer State: (MCSessionState)state {
    
    NSString *peerUUID = [ConnectedPeopleManager getUUIDFromDisplayName:peer.displayName];
    NSString *userUUID = [ConnectedPeopleManager getUUIDFromDisplayName:[_sessionWrapper getMyPeerID].displayName];
    
    // This code prevents Multipeer from causing user to find themselves as a peer (weird bug)
    BOOL peerMatchesCurrentUsersUUID = NO;
    if ([peerUUID isEqualToString:userUUID]) {
        peerMatchesCurrentUsersUUID = YES;
    }
    
    if (!peerMatchesCurrentUsersUUID) {
        //Update found peer
        if (state == MCSessionStateConnected) {
            
            //This code prevents Multipeer from adding more than one peer with the same UUID to  (ghost peers)
            BOOL peerMatchesCurrentlyConnectedStranger = NO;
            for (MCPeerID *stranger in [_connectedPeopleManager getConnectedStrangers]) {
                if ([[ConnectedPeopleManager getUUIDFromDisplayName:stranger.displayName] isEqualToString:peerUUID]) {
                    peerMatchesCurrentlyConnectedStranger = YES;
                }
            }
            
            if (!peerMatchesCurrentlyConnectedStranger) {
                [_connectedPeopleManager addConnectedStranger:peer];
            }
            
            NSDictionary *peerInfo = @{@"peerID": peer, @"state": @"MCSessionStateConnected"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCPeerDidChangeStateNotification" object:self userInfo:peerInfo];
            [_connectedPeopleManager stopCurrentlySearchingForPeersStateTimer];
        }
        //Update lost peer
        else if (state == MCSessionStateNotConnected) {
            [_connectedPeopleManager removeConnectedStranger:peer];
    
            NSDictionary *peerInfo = @{@"peerID": peer, @"state": @"MCSessionStateNotConnected"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCPeerDidChangeStateNotification" object:self userInfo:peerInfo];
        }
    }
}

/* - Called when we manually kill a session - */

-(void)cleanUpSessionRelatedVariables {
    [_connectedPeopleManager removeAllConnectedStrangers];
}

#pragma mark - TEST

-(void)addDummyPeersToConnectedPeople {
    
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

-(void)addDummyDouchesToConnectedPeople {
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"Blake Albright|12rjwf-rfanefuwn-wfnjwf-2mfiq23"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"Chad Brooks|n3riuh2-23rhbfwi2-fcjw3b4j2-3ej2bf2"]];
    [_connectedPeopleManager addConnectedStranger:[[MCPeerID alloc]initWithDisplayName:@"Trent Parnell|kjhif132-12eihi23-3e1hbr13-12ejb12eb"]];
}

-(void)printIdleTimerStatus {
    //NSLog(@"Idle timer is disabled? %@", [UIApplication sharedApplication].idleTimerDisabled? @"Yes" : @"NO");
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
