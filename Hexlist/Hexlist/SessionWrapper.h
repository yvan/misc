//
// SessionWrapper.h
// Hexlist
//
//
//  Created by Yvan Scher on 10/7/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "File.h"

@protocol SessionWrapperDelegate <NSObject>

-(void) peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state;

-(void)didStartReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress;

-(void) didFinishReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error;

-(void) didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;

-(void) didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID;

@end

@interface SessionWrapper : NSObject <MCSessionDelegate>{
    
}

@property (nonatomic) MCSession *session;
@property (nonatomic, readonly) MCPeerID *myPeerID;
@property (nonatomic) id <SessionWrapperDelegate> sessionWrapperDelegate;

-(NSString*) getServiceName;
-(MCPeerID*) getMyPeerID;
-(NSUInteger) numberConnectedPeers;
-(MCPeerID *) getPeerAtIndex:(NSUInteger)index;
-(instancetype) initSessionWithMyPeerName: (NSString *)name;
-(void) destroySession;

@end
