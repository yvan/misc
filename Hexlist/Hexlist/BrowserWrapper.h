//
// BrowserWrapper.h
// Hexlist
//
//
//  Created by Yvan Scher on 10/7/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppConstants.h"
#import "ConnectedPeopleManager.h"

@protocol BrowserWrapperDelegate <NSObject>

-(void) inviteFoundPeer:(MCPeerID *)foreignPeerID withContext: (NSString*)context;
-(void) alertToLostPeer:(MCPeerID *)lostForeignPeerID;
-(void) failedToBrowse:(NSError *)error;

-(void)updateConnectedPeopleWithPeer: (MCPeerID*)peer State: (MCSessionState)state;

@end

@interface BrowserWrapper : NSObject <MCNearbyServiceBrowserDelegate>{
    
}

@property (nonatomic, readonly) MCNearbyServiceBrowser *autobrowser;
@property (nonatomic, readonly) BOOL browsing;
@property (nonatomic) id <BrowserWrapperDelegate> browserWrapperDelegate;

-(instancetype) startBrowsing:(MCPeerID *)myPeerID;
-(void) stopBrowsing;
-(void) restartBrowsing;

@end
