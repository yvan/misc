//
// AdvertiserWrapper.h
// Hexlist
//
//
//  Created by Yvan Scher on 10/7/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppConstants.h"

@protocol AdvertiserWrapperDelegate <NSObject>

-(void) acceptInvitationFromPeer:(MCPeerID *)foreignPeerID invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler;
-(void) failedToAdvertise:(NSError *)error;

@end

@interface AdvertiserWrapper : NSObject <MCNearbyServiceAdvertiserDelegate>{
    
}

@property (nonatomic, readonly) MCNearbyServiceAdvertiser *autoadvertiser;
@property (nonatomic, readonly) BOOL advertising;
@property (nonatomic) id <AdvertiserWrapperDelegate> advertiserWrapperDelegate;

-(instancetype) startAdvertising:(MCPeerID *) myPeerID;
-(void) stopAdvertising;
-(void) restartAdvertising;

@end
