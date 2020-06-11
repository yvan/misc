//
// SessionWrapper.m
// Airdoc
//
//
//  Created by Yvan Scher on 10/7/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "SessionWrapper.h"

static NSString* const ServiceName = @"Envoy";

@interface SessionWrapper()

@property (nonatomic) MCPeerID *myPeerID;

@end

@implementation SessionWrapper

#pragma mark - Getters/Setters/Initializers/Destroyers

/* - Returns our app name in "service name"
   - terms important for browsing/advertising 
   - on dif. services 
   - */

-(NSString*) getServiceName{
    
    return ServiceName;
}

/* - Returns local user's peerID - */

-(MCPeerID*) getMyPeerID{
    
    return _myPeerID;
}

/* - Returns number of peers in peer array - */

-(NSUInteger) numberConnectedPeers{
    
    return _session.connectedPeers.count;
}

/* - get peer at index - */

-(MCPeerID *) getPeerAtIndex:(NSUInteger)index{
    
    if(index >= _session.connectedPeers.count) return nil;
    return _session.connectedPeers[index];
}

/* - initializes a sesssion (called from MultipeerInitializerTabBarController.m) 
   - advertising/browsing are done in respective helpers - */

-(instancetype) initSessionWithMyPeerName: (NSString *)name{
    
    NSLog(@"STARTED SESSION WITH NAME: %@", name);
    
    _myPeerID = [[MCPeerID alloc] initWithDisplayName:name];
    _session = [[MCSession alloc] initWithPeer: _myPeerID];
    _session.delegate = self;
    
    return self;
}

/* - destroys a session - */

-(void) destroySession{
    
    [_session disconnect];
}

#pragma mark - MCSessionDelegate

/* - REMOTE PEER HAS ALTERED ITS STATE SOMEHOW - */

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
    [_sessionWrapperDelegate peer:peerID didChangeState:state];
}

/* - STARTED RECEIVING RESOURCE FROM REMOTE PEER - */

-(void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)foreignPeerID withProgress:(NSProgress *)progress{
    
    [_sessionWrapperDelegate didStartReceivingResource:session resourceName:resourceName fromPeer:foreignPeerID withProgress:progress];
}

/* - FINISHED RECEIVEING RESOURCE FROM PEER - */

-(void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)foreignPeerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    [_sessionWrapperDelegate didFinishReceivingResource:session resourceName:resourceName fromPeer:foreignPeerID atURL:localURL withError:error];
}

/* - RECEIVED DATA FROM REMOTE PEER - */

-(void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
    [_sessionWrapperDelegate didReceiveData:data fromPeer:peerID];
}

/* - RECEIVED STREAM FROM PEER - */

-(void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
    [_sessionWrapperDelegate didReceiveStream:stream withName:streamName fromPeer:peerID];
}

#pragma mark - sendFiles
/* - takes an array of files and an array of peerIds and sends
 - all of those files to those peer ids, remake into
 - asynchonous function w/ dispatch???
 - */
-(void)sendFiles:(NSArray *)localFiles toPeers:(NSArray *)peerIDs{
    
    NSLog(@"%s SENDING FILES", __PRETTY_FUNCTION__);
    // - this way of formulating the URL is slightly different from filename.url's way of formulating the URL and apparently - //
    // - for sending resources the .url field's way on the File object does not work. We need the code below - //
    NSURL *docDirURL = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    for(int i = 0; i < [localFiles count]; i++) {
        File *fileToSend = [localFiles objectAtIndex:i];
        NSURL *urlToSend = [docDirURL URLByAppendingPathComponent:fileToSend.name];
        for(int j = 0; j < [peerIDs count]; j++){
            MCPeerID* idToSend = [peerIDs objectAtIndex:j];
            [_session sendResourceAtURL:urlToSend withName:fileToSend.name toPeer: idToSend withCompletionHandler:^(NSError *error) {
                if(error){NSLog(@"%@",[error localizedDescription]);}
            }];
        }
    }
}

#pragma mark - EXTRA METHOD

/* - RECEIVED CERTIFICATE FROM PEER ~This method is not in the docs...THANKS, OBAMA~ - */

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)cert fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certHandler {
    
    certHandler(YES);
}


@end
