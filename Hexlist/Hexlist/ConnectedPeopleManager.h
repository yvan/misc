//
//  ConnectedPeopleManager.h
//  Hexlist
//
//  Created by Roman Scher on 3/16/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppConstants.h"
#import "FileSystemInterface.h"

@interface ConnectedPeopleManager : NSObject

#pragma mark - Singleton

+(id)sharedConnectedPeopleManager;

#pragma mark - Initialization

-(id)initAllConnectedPeopleArrays;

#pragma mark - Helper Methods

+(NSString*)getPeerNameFromDisplayName: (NSString*)displayName;
+(NSString*)getUUIDFromDisplayName: (NSString*)displayName;

#pragma mark - searchingForPeersStateTimer

-(void)startCurrentlySearchingForPeersStateTimer;
-(void)stopCurrentlySearchingForPeersStateTimer;
-(BOOL)currentlySearchingForPeers;

#pragma mark - connectedStrangers

-(NSMutableArray*)getConnectedStrangers;
-(void)addConnectedStranger: (MCPeerID*)stranger;
-(void)removeConnectedStranger: (MCPeerID*)stranger;
-(void)removeAllConnectedStrangers;

@end
