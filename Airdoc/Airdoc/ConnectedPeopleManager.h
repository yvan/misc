//
//  ConnectedPeopleManager.h
//  Airdoc
//
//  Created by Roman Scher on 3/16/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "LocalStorageManager.h"
#import "FileSystemInterface.h"

@interface ConnectedPeopleManager : NSObject

#pragma mark - Singleton

+(id)sharedConnectedPeopleManager;

#pragma mark - Initialization

-(id)initAllConnectedPeopleArrays;

#pragma mark - searchingForPeersStateTimer

-(void)startCurrentlySearchingForPeersStateTimer;
-(void)stopCurrentlySearchingForPeersStateTimer;
-(BOOL)currentlySearchingForPeers;

#pragma mark - connectedFriends

-(NSMutableArray*)getConnectedFriends;
-(void)addConnectedFriend: (MCPeerID*)friend;
-(void)removeConnectedFriend: (MCPeerID*)friend;
-(void)removeAllConnectedFriends;

#pragma mark - connectedStrangers

-(NSMutableArray*)getConnectedStrangers;
-(void)addConnectedStranger: (MCPeerID*)stranger;
-(void)removeConnectedStranger: (MCPeerID*)stranger;
-(void)removeAllConnectedStrangers;

#pragma mark - peersSendingTo

-(NSDictionary*)getNextFileSendInFileSendsQueue;
-(NSInteger)getTotalNumberOfFileSendsQueued;
-(BOOL)currentlySendingToPeer:(MCPeerID*)peer;
-(BOOL)currentlyInTheProcessOfSending;
-(BOOL)currentlyInTheProcessOfZipping;
-(void)setCurrentlyInTheProcessOfZippingTo: (BOOL)currentlyInTheProcessOfZipping;
-(NSString*)getResourceNameOfCurrentSend;
-(void)queueZippedFilePath: (NSString*)zippedFilePath WithResourceName: (NSString*)resourceName ToSendToPeer: (MCPeerID*)peer;
-(void)removeQueuedZippedFilePath: (NSString*)zippedFilePath ToSendToPeer: (MCPeerID*)peer;
-(void)removeAllQueuedSendsForPeer: (MCPeerID*)peer;

#pragma mark - peersReceivingFrom

-(NSInteger)getTotalNumberOfFileReceptionsInProgress;
-(BOOL)currentlyReceivingFromPeer:(MCPeerID*)peer;
-(BOOL)currentlyInTheProcessOfReceiving;
-(void)addFileReceptionInProgressWithResourceName: (NSString*)resourceName ReceivingFromPeer: (MCPeerID*)peer;
-(void)removeFileReceptionInProgressWithResourceName: (NSString*)resourceName ReceivingFromPeer: (MCPeerID*)peer;
-(void)removeFileReceptionInProgressFromPeer: (MCPeerID*)peer;
-(void)removeAllFileReceptionsInProgress;

#pragma mark - Outgoing Send Progress

-(void)addOutgoingSendProgress: (NSProgress*)sendProgress withResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID AndAddObserver: (UIViewController*)viewController;
-(void)removeOutgoingSendProgress: (NSProgress*)sendProgress;
-(void)removeOutgoingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID;
-(void)removeAllOutgoingSendProgresses;
-(BOOL)progressIsAnOutgoingSendProgress: (NSProgress*)progress;
-(double)getProgressOfCurrentOutgoingSend;
//-(NSProgress*)getOutgoingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID;
//-(NSArray*)getAllOutgoingSendProgresses;

#pragma mark - Incoming Send Progress

-(void)addIncomingSendProgress: (NSProgress*)sendProgress withResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID AndAddObserver: (UIViewController*)viewController;
-(void)removeIncomingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID;
-(void)removeAllIncomingSendProgresses;
-(BOOL)progressIsAnIncomingSendProgress: (NSProgress*)progress;
//-(NSProgress*)getIncomingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID;
-(NSArray*)getAllIncomingSendProgresses;

#pragma mark - Convenience methods

-(void)removeAllPeersFromPeersSendingToAndPeersReceivingFrom;
-(void)removeAllOutgoingAndIncomingSendProgresses;

@end
