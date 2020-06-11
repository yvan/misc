//
// AdvertiserWrapper.m
// Airdoc
//
//
//  Created by Yvan Scher on 10/7/14
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "AdvertiserWrapper.h"

@interface AdvertiserWrapper ()

@property (nonatomic) MCNearbyServiceAdvertiser *autoadvertiser;
@property (nonatomic) BOOL advertising;

@end

@implementation AdvertiserWrapper

#pragma mark - Getters/Setters/Initializers/Destroyers

/* - external use, starts the advertising and returns the AdvertiserHelper object - */

-(instancetype) startAdvertising:(MCPeerID *) myPeerID{
    
    NSLog(@"STARTED ADVERTISING WITH MY PEERID: %@", myPeerID);
        
    _autoadvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerID
                                                         discoveryInfo: nil
                                                         serviceType:[AppConstants appName]];
    [_autoadvertiser startAdvertisingPeer];
    _advertising = YES;
    _autoadvertiser.delegate = self;
    return self;
}

/* - stops advertising the peer by 
   - shutting down peer's advertiser 
   - */

-(void) stopAdvertising{
    
    [_autoadvertiser stopAdvertisingPeer];
    _advertising = NO;
}

/* - restarts advertising the 
   - peer by restarting peer's advertiser 
   - */

-(void) restartAdvertising{
    
    [_autoadvertiser startAdvertisingPeer];
    _advertising = YES;
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

/* - triggers automatically when we get an invitiation from a foreign peer, calls a delegate method in MultipeerInitializerTabBarController.m - */

-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)foreignPeerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    
    //Auto accept invite to session from friend or stranger alike
    [_advertiserWrapperDelegate acceptInvitationFromPeer:foreignPeerID invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler];
}

/* - triggers automatically when we failed to start advertising in the first place, does not call a delegate method in MultipeerInitializerTabBarController.m - */

-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    
    [_advertiserWrapperDelegate failedToAdvertise:error];
}

@end
