//
// BrowserWrapper.m
// Hexlist
//
//
//  Created by Yvan Scher on 10/7/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "BrowserWrapper.h"

@interface BrowserWrapper ()

@property (nonatomic) MCNearbyServiceBrowser *autobrowser;
@property (nonatomic) BOOL browsing;

@end

@implementation BrowserWrapper

#pragma mark - Getters/Setters/Initializers/Destroyers

/* - creates a browser, starts browsing - */

-(instancetype) startBrowsing:(MCPeerID *)myPeerID{
    
    //NSLog(@"STARTED BROWSING WITH MY PEERID: %@", myPeerID);
    _autobrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:myPeerID serviceType:[AppConstants appName]];
    _autobrowser.delegate = self;
    [_autobrowser startBrowsingForPeers];
    return self;
}

/* - stops the browser from browsing - */
-(void) stopBrowsing{
    
    [_autobrowser stopBrowsingForPeers];
}

/* - restarts a stopped browser - */

-(void) restartBrowsing{
    
    [_autobrowser startBrowsingForPeers];
}

#pragma mark - MCNearbyServiceBrowserDelegate

/* - FOUND A FOREIGN PEER NOW INVITE THAT SUCKER - */

-(void) browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)foreignPeerID withDiscoveryInfo:(NSDictionary *)info{
    
    //NSLog(@"FOUND FOREIGN PEER: %@", [ConnectedPeopleManager getPeerNameFromDisplayName: foreignPeerID.displayName]);
    
    //Automatically invite peers to session
    [_browserWrapperDelegate inviteFoundPeer:foreignPeerID withContext:@"auto"];
}

/* - LOST A PEER, ALERT THE VIEW CONTROLLER - */

-(void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)foreignPeerID {
    
    //NSLog(@"LOST FOREIGN PEER: %@", [ConnectedPeopleManager getPeerNameFromDisplayName: foreignPeerID.displayName]);
    
    [_browserWrapperDelegate alertToLostPeer:foreignPeerID];
}
/* - FOR SOME REASON WE FAILED TO START BROWSING, ALERT THE VIEW CONTROLLER- */

-(void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
    
    [_browserWrapperDelegate failedToBrowse:error];
}

@end
