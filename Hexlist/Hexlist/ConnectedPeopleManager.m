//
//  ConnectedPeopleManager.m
//  Hexlist
//
//  Created by Roman Scher on 3/16/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.

// This is a class is a thread safe singleton used to manage the types of peers currently connected to you through the multipeer framework

#import "ConnectedPeopleManager.h"

@interface ConnectedPeopleManager ()

@property (nonatomic, strong) FileSystemInterface* fsInterface;

@property int searchTimeCount;
@property BOOL currentlySearchingForPeers;
@property (nonatomic, strong) NSTimer *currentlySearchingForPeersTimer;

@property (nonatomic, strong) NSMutableArray *connectedStrangers;

@property (nonatomic, strong) dispatch_queue_t connectedStrangersQueue;

@end

@implementation ConnectedPeopleManager

#pragma mark - Singleton

+(id)sharedConnectedPeopleManager {
    
    static dispatch_once_t pred;
    static ConnectedPeopleManager *sharedConnectedPeopleManager = nil;
    
    dispatch_once(&pred, ^{
        if(sharedConnectedPeopleManager == nil) {
            sharedConnectedPeopleManager = [[self alloc] initAllConnectedPeopleArrays];
            
            sharedConnectedPeopleManager.connectedStrangersQueue = dispatch_queue_create("Connected Strangers Queue", DISPATCH_QUEUE_SERIAL);
        }
     });
    
    return sharedConnectedPeopleManager;
}

#pragma mark - Initialization

-(id)initAllConnectedPeopleArrays {
    self = [super init];
    
    _searchTimeCount = 0;
    _currentlySearchingForPeers = NO;
    
    _connectedStrangers = [[NSMutableArray alloc] init];
    
    return self;
}

-(FileSystemInterface*) fsInterface{
    
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}

#pragma mark - PeerDisplayNameManipulation

+(NSString*)getPeerNameFromDisplayName: (NSString*)displayName {
    NSArray *strings = [displayName componentsSeparatedByString:@"|"];
    return [strings objectAtIndex:0];
}

+(NSString*)getUUIDFromDisplayName: (NSString*)displayName {
    NSArray *strings = [displayName componentsSeparatedByString:@"|"];
    return [strings objectAtIndex:1];
}

#pragma mark - searchingForPeersStateTimer

/* - Allows us to broadcast searching for peers state to [send and nearby VCs] when users should be waiting for connections rather than trying to reset - */

-(void)startCurrentlySearchingForPeersStateTimer {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentlySearchingForPeersNotification" object:nil];
    _currentlySearchingForPeers = YES;
    _searchTimeCount = 0;
    [_currentlySearchingForPeersTimer invalidate];
    _currentlySearchingForPeersTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateSearchingForPeersState) userInfo:nil repeats:YES];
}

-(void)stopCurrentlySearchingForPeersStateTimer {
    [_currentlySearchingForPeersTimer invalidate];
    _currentlySearchingForPeers = NO;
    _searchTimeCount = 0;
}

-(void)updateSearchingForPeersState {
    if (_searchTimeCount >= 10) {
        [_currentlySearchingForPeersTimer invalidate];
        _currentlySearchingForPeers = NO;
        _searchTimeCount = 0;
    }
    else {
        _searchTimeCount++;
    }
}

#pragma mark - connectedStrangers

-(NSMutableArray*)getConnectedStrangers {
    
    __block NSMutableArray *connectedStrangers;
    dispatch_sync(_connectedStrangersQueue, ^{
        connectedStrangers = [[NSMutableArray alloc] initWithArray:_connectedStrangers copyItems:YES];
    });
    
    return connectedStrangers;
}

-(void)addConnectedStranger: (MCPeerID*)stranger {
    
    dispatch_sync(_connectedStrangersQueue, ^{
        [_connectedStrangers addObject:stranger];
        NSArray *connectedStrangersSorted = [[NSArray alloc] initWithArray:[self sortPeers:_connectedStrangers] copyItems:YES];
        _connectedStrangers = [connectedStrangersSorted mutableCopy];
    });
}

-(void)removeConnectedStranger: (MCPeerID*)stranger {
    
    dispatch_sync(_connectedStrangersQueue, ^{
        [_connectedStrangers removeObject:stranger];
    });
}

-(void)removeAllConnectedStrangers {
    
    dispatch_sync(_connectedStrangersQueue, ^{
        [_connectedStrangers removeAllObjects];
    });
}

#pragma mark - Helper methods

/* - Sorts array of peers by displayname - */

-(NSArray*)sortPeers: (NSArray*)peersArray {
    
    NSArray *peersArraySorted = [peersArray sortedArrayUsingComparator:^(id obj1, id obj2) {
        //NSLog(@"Sorting peer array");
        NSString *name1 = [[self class] getPeerNameFromDisplayName:((MCPeerID*)obj1).displayName];
        NSString *name2 = [[self class] getPeerNameFromDisplayName:((MCPeerID*)obj2).displayName];
        return [name1 caseInsensitiveCompare:name2];
    }];
    
    return peersArraySorted;
}

@end
