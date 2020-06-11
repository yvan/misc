//
//  ConnectedPeopleManager.m
//  Airdoc
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

@property (nonatomic, strong) NSMutableArray *connectedFriends;
@property (nonatomic, strong) NSMutableArray *connectedStrangers;
@property (nonatomic, strong) NSMutableArray *peersSendingTo;
@property (nonatomic, strong) NSMutableArray *peersReceivingFrom;
@property BOOL currentlyZipping;
@property NSMutableArray *outgoingSendsProgressesArray;
@property NSMutableArray *incomingSendsProgressesArray;

@property (nonatomic, strong) dispatch_queue_t connectedFriendsQueue;
@property (nonatomic, strong) dispatch_queue_t connectedStrangersQueue;
@property (nonatomic, strong) dispatch_queue_t peersSendingToQueue;
@property (nonatomic, strong) dispatch_queue_t peersReceivingFromQueue;
@property (nonatomic, strong) dispatch_queue_t currentlyZippingQueue;
@property (nonatomic, strong) dispatch_queue_t outgoingSendsProgressesQueue;
@property (nonatomic, strong) dispatch_queue_t incomingSendsProgressesQueue;

@end

@implementation ConnectedPeopleManager

#pragma mark - Singleton

+(id)sharedConnectedPeopleManager {
    
    static dispatch_once_t pred;
    static ConnectedPeopleManager *sharedConnectedPeopleManager = nil;
    
    dispatch_once(&pred, ^{
        if(sharedConnectedPeopleManager == nil) {
            sharedConnectedPeopleManager = [[self alloc] initAllConnectedPeopleArrays];
            
            sharedConnectedPeopleManager.connectedFriendsQueue = dispatch_queue_create("Connected Friends Queue", DISPATCH_QUEUE_SERIAL);
            sharedConnectedPeopleManager.connectedStrangersQueue = dispatch_queue_create("Connected Strangers Queue", DISPATCH_QUEUE_SERIAL);
            sharedConnectedPeopleManager.peersSendingToQueue= dispatch_queue_create("Peers Sending To Queue", DISPATCH_QUEUE_SERIAL);
            sharedConnectedPeopleManager.peersReceivingFromQueue = dispatch_queue_create("Peers Receiving From Queue", DISPATCH_QUEUE_SERIAL);
            sharedConnectedPeopleManager.currentlyZippingQueue = dispatch_queue_create("Currently Zipping", DISPATCH_QUEUE_SERIAL);
            sharedConnectedPeopleManager.outgoingSendsProgressesQueue = dispatch_queue_create("Outgoing Sends Queue", DISPATCH_QUEUE_SERIAL);
            sharedConnectedPeopleManager.incomingSendsProgressesQueue = dispatch_queue_create("Incoming Sends Queue", DISPATCH_QUEUE_SERIAL);
        }
     });
    
    return sharedConnectedPeopleManager;
}

#pragma mark - Initialization

-(id)initAllConnectedPeopleArrays {
    self = [super init];
    
    _searchTimeCount = 0;
    _currentlySearchingForPeers = NO;
    _connectedFriends = [[NSMutableArray alloc] init];
    _connectedStrangers = [[NSMutableArray alloc] init];
    _peersSendingTo = [[NSMutableArray alloc] init];
    _peersReceivingFrom = [[NSMutableArray alloc] init];
    _currentlyZipping = NO;
    _outgoingSendsProgressesArray = [[NSMutableArray alloc] init];
    _incomingSendsProgressesArray = [[NSMutableArray alloc] init];
    
    return self;
}

-(FileSystemInterface*) fsInterface{
    
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
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

#pragma mark - connectedFriends

-(NSMutableArray*)getConnectedFriends {
    
    __block NSMutableArray *connectedFriends;
    dispatch_sync(_connectedFriendsQueue, ^{
        connectedFriends =  [[NSMutableArray alloc] initWithArray:_connectedFriends copyItems:YES];
    });
    
    return connectedFriends;
}

-(void)addConnectedFriend: (MCPeerID*)friend {
    
    dispatch_sync(_connectedFriendsQueue, ^{
        [_connectedFriends addObject:friend];
        NSArray *connectedFriendsSorted = [[NSArray alloc] initWithArray:[self sortPeers:_connectedFriends] copyItems:YES];
        _connectedFriends = [connectedFriendsSorted mutableCopy];
    });
}

-(void)removeConnectedFriend: (MCPeerID*)friend {
    
    dispatch_sync(_connectedFriendsQueue, ^{
        [_connectedFriends removeObject:friend];
    });
}

-(void)removeAllConnectedFriends {
    dispatch_sync(_connectedFriendsQueue, ^{
        [_connectedFriends removeAllObjects];
    });
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

#pragma mark - peersSendingTo

/* - Uses an NSDictionary to store peers we are sending to and their corresponding set of paths for files to send - */

-(NSDictionary*)getNextFileSendInFileSendsQueue {
    __block NSDictionary *nextFileSend;
    dispatch_sync(_peersSendingToQueue, ^{
        if ([_peersSendingTo count] > 0) {
            nextFileSend = [_peersSendingTo objectAtIndex:0];
        }
    });
    
    NSLog(@"Next file send is %@", nextFileSend);
    return nextFileSend;
}

/* - Returns total number of sends in progress - */
-(NSInteger)getTotalNumberOfFileSendsQueued {
    __block NSInteger numberOfFileSendsQueued = 0;
    dispatch_sync(_peersSendingToQueue, ^{
        numberOfFileSendsQueued = [_peersSendingTo count];
    });
    
    NSLog(@"Total Number of file sends queued: %ld", (long)numberOfFileSendsQueued);
    return numberOfFileSendsQueued;
}

/* - Returns true if we are currently sending to a peer. Returns false otherwise. - */
-(BOOL)currentlySendingToPeer:(MCPeerID*)peer {
    __block BOOL currentlySendingToPeer = NO;
    dispatch_sync(_peersSendingToQueue, ^{
        //Find matching peer if they exist.
        if ([_peersSendingTo count] > 0) {
            NSDictionary *peerAndZippedFilePathPair = [_peersSendingTo objectAtIndex:0];
            if ([[peerAndZippedFilePathPair objectForKey:[AppConstants peerIDStringIdentifier]] isEqual: peer]) {
                currentlySendingToPeer = YES;
            }
        }
    });
    
    if (currentlySendingToPeer) {
        NSLog(@"We are currently sending to %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
    }
    else {
        NSLog(@"We are not currently sending to %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
    }
    return currentlySendingToPeer;
}

-(BOOL)currentlyInTheProcessOfSending {
    __block BOOL currentlyInTheProcessOfSending = NO;
    dispatch_sync(_peersSendingToQueue, ^{
        if ([_peersSendingTo count] != 0) {
            currentlyInTheProcessOfSending = YES;
        }
    });
                  
    return currentlyInTheProcessOfSending;
}

-(BOOL)currentlyInTheProcessOfZipping {
    __block BOOL currentlyInTheProcessOfZipping = NO;
    dispatch_sync(_currentlyZippingQueue, ^{
        currentlyInTheProcessOfZipping = _currentlyZipping;
    });
    
    return currentlyInTheProcessOfZipping;
}

-(void)setCurrentlyInTheProcessOfZippingTo: (BOOL)currentlyInTheProcessOfZipping {
    dispatch_sync(_currentlyZippingQueue, ^{
        _currentlyZipping = currentlyInTheProcessOfZipping;
    });
}

-(NSString*)getResourceNameOfCurrentSend {
    __block NSString *resourceNameOfCurrentSend;
    dispatch_sync(_peersSendingToQueue, ^{
        //Find matching peer if they exist.
        if ([_peersSendingTo count] > 0) {
            NSDictionary *peerAndZippedFilePathPair = [_peersSendingTo objectAtIndex:0];
            resourceNameOfCurrentSend = [peerAndZippedFilePathPair objectForKey:[AppConstants resourceNameStringIdentifier]];
        }
    });

    return resourceNameOfCurrentSend;
}

/* - Adds a peer-zippedFilePath pair to peersSendingTo - */
-(void)queueZippedFilePath: (NSString*)zippedFilePath WithResourceName: (NSString*)resourceName ToSendToPeer: (MCPeerID*)peer {
    dispatch_sync(_peersSendingToQueue, ^{
        //Add a new peer-zippedFilePath pair to peersSendingTo
        NSDictionary *peerAndZippedFilePathPair = @{
                                                    [AppConstants zippedFilePathStringIdentifier]:zippedFilePath,
                                                    [AppConstants resourceNameStringIdentifier]:resourceName,
                                                    [AppConstants peerIDStringIdentifier]:peer
                                                    };
        [_peersSendingTo addObject:peerAndZippedFilePathPair];
        NSLog(@"Queued file send for %@. Now have %lu sends queued.", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName], (unsigned long)[_peersSendingTo count]);
        NSLog(@"Structure of peersSendingTo after [addZippedFilePathPeerPair]: %@", _peersSendingTo);
    });
}

/* - Removes a peer-zippedFilePath pair from peersSendingTo - */
-(void)removeQueuedZippedFilePath: (NSString*)zippedFilePath ToSendToPeer: (MCPeerID*)peer {
    dispatch_sync(_peersSendingToQueue, ^{
        //Find matching peer-zippedFilePath pair and remove it if it exists.
        NSDictionary *matchedPeerAndZippedFilePathPair;
        for (NSDictionary *peerAndZippedFilePathPair in _peersSendingTo) {
            if ([[peerAndZippedFilePathPair objectForKey:[AppConstants zippedFilePathStringIdentifier]] isEqualToString:zippedFilePath] && [[peerAndZippedFilePathPair objectForKey:[AppConstants peerIDStringIdentifier]] isEqual:peer] ) {
                NSLog(@"Matched peer-ZippedFilePath pair to remove %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
                matchedPeerAndZippedFilePathPair = peerAndZippedFilePathPair;
                [self deleteFilePackage: [peerAndZippedFilePathPair objectForKey:[AppConstants zippedFilePathStringIdentifier]]];
            }
        }
        [_peersSendingTo removeObject:matchedPeerAndZippedFilePathPair];
        NSLog(@"-1 Finished file send for %@. Now have %lu sends queued", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName], (unsigned long)[_peersSendingTo count]);
        NSLog(@"Structure of peersSendingTo after [removeZippedFilePathPeerPair]: %@", _peersSendingTo);
    });
}

-(void)removeAllQueuedSendsForPeer: (MCPeerID*)peer {
    dispatch_sync(_peersSendingToQueue, ^{
        //Find matching peer remove them if they exist.
        NSMutableArray *matchedPeerAndZippedFilePathPairs = [[NSMutableArray alloc] init];
        for (NSDictionary *peerAndZippedFilePathPair in _peersSendingTo) {
            if ([[peerAndZippedFilePathPair objectForKey:[AppConstants peerIDStringIdentifier]] isEqual: peer]) {
                NSLog(@"Matched zippedFilePathPeer pair to remove %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
                [matchedPeerAndZippedFilePathPairs addObject:peerAndZippedFilePathPair];
                [self deleteFilePackage: [peerAndZippedFilePathPair objectForKey:[AppConstants zippedFilePathStringIdentifier]]];
            }
        }
        [_peersSendingTo removeObjectsInArray:matchedPeerAndZippedFilePathPairs];
        NSLog(@"Removing any queued sends for peer %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
        NSLog(@"Structure of peersSendingTo After [removeAllQueuedSendsForPeer]: %@", _peersSendingTo);
    });
}

-(void)removeAllQueuedSends {
    dispatch_sync(_peersSendingToQueue, ^{
        for (NSDictionary *peerAndZippedFilePathPair in _peersSendingTo) {
            [self deleteFilePackage: [peerAndZippedFilePathPair objectForKey:[AppConstants zippedFilePathStringIdentifier]]];
        }
        [_peersSendingTo removeAllObjects];
        NSLog(@"Removing all peers from peersSendingTo");
    });
}

-(void)deleteFilePackage: (NSString*)filePackagePath {
    NSLog(@"Zipped File Path to delete: %@", filePackagePath);
    
    NSString* filePackageQueryPath = [[[filePackagePath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *filePackageUrl = [[NSURL alloc] initWithString:filePackageQueryPath];
    
    NSArray *parts = [[filePackageUrl path] componentsSeparatedByString:@"/"];
    NSString *item = [parts lastObject];
    [[self fsInterface] deleteFileAtPath:[@"/ZippedFilePackages"stringByAppendingPathComponent: item]];
    
}

#pragma mark - peersReceivingFrom

/* - Returns total number of file receptions in progress - */
-(NSInteger)getTotalNumberOfFileReceptionsInProgress {
    __block NSInteger numberOfFileReceptionsInProgress = 0;
    dispatch_sync(_peersReceivingFromQueue, ^{
        numberOfFileReceptionsInProgress = [_peersReceivingFrom count];
    });
    
    NSLog(@"Total Number of file receptions in progress: %ld", (long)numberOfFileReceptionsInProgress);
    return numberOfFileReceptionsInProgress;
}

/* - Returns true if we are currently receiving files from a peer or false otherwise - */
-(BOOL)currentlyReceivingFromPeer:(MCPeerID*)peer {
    __block BOOL currentlyReceivingFromPeer;
    dispatch_sync(_peersReceivingFromQueue, ^{
        //Find matching peer if they exist.
        for (NSDictionary *peerAndResourceNamePair in _peersReceivingFrom) {
            if ([[peerAndResourceNamePair objectForKey:[AppConstants peerIDStringIdentifier]] isEqual: peer]) {
                currentlyReceivingFromPeer = YES;
            }
        }
    });
    
    if (currentlyReceivingFromPeer) {
        NSLog(@"We are currently receiving from %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
    }
    else {
        NSLog(@"We are not currently receiving from %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
    }
    return currentlyReceivingFromPeer;
}

-(BOOL)currentlyInTheProcessOfReceiving {
    __block BOOL currentlyInTheProcessOfReceiving = NO;
    dispatch_sync(_peersReceivingFromQueue, ^{
        if ([_peersReceivingFrom count] != 0) {
            currentlyInTheProcessOfReceiving = YES;
        }
    });
    
    return currentlyInTheProcessOfReceiving;
}

/* - Adds a new file reception in progress with a peer-resourceName pair from peersReceivingFrom - */
-(void)addFileReceptionInProgressWithResourceName: (NSString*)resourceName ReceivingFromPeer: (MCPeerID*)peer{
    dispatch_sync(_peersReceivingFromQueue, ^{
        //Add a new peer-resourceName pair to peersReceivingFrom
        NSDictionary *peerAndResourceNamePair = @{
                                                    [AppConstants resourceNameStringIdentifier]:resourceName,
                                                    [AppConstants peerIDStringIdentifier]:peer
                                                    };
        [_peersReceivingFrom addObject:peerAndResourceNamePair];
        NSLog(@"Added new file reception for %@. Now have %lu receptions in progress.", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName], (unsigned long)[_peersReceivingFrom count]);
        NSLog(@"Structure of peersReceivingFrom after [addFileReception]: %@", _peersReceivingFrom);
    });
}

/* - Removes a file reception in progress with a peer-resourceName pair from peersReceivingFrom - */
-(void)removeFileReceptionInProgressWithResourceName: (NSString*)resourceName ReceivingFromPeer: (MCPeerID*)peer{
    dispatch_sync(_peersReceivingFromQueue, ^{
        //Find matching peer-resourceName pair and remove it if it exists.
        NSDictionary *matchedPeerAndResourceNamePair;
        for (NSDictionary *peerAndResourceNamePair in _peersReceivingFrom) {
            if ([[peerAndResourceNamePair objectForKey:[AppConstants resourceNameStringIdentifier]] isEqualToString:resourceName] && [[peerAndResourceNamePair objectForKey:[AppConstants peerIDStringIdentifier]] isEqual:peer] ) {
                NSLog(@"Matched peerResourceName pair to remove %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
                matchedPeerAndResourceNamePair = peerAndResourceNamePair;
            }
        }
        [_peersReceivingFrom removeObject:matchedPeerAndResourceNamePair];
        NSLog(@"-1 Finished file reception for %@. Now have %lu receptions in progress", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName], (unsigned long)[_peersReceivingFrom count]);
        NSLog(@"Structure of peersReceiving after [removePeerResourceNamePair]: %@", _peersReceivingFrom);
    });
}

-(void)removeFileReceptionInProgressFromPeer: (MCPeerID*)peer {
    dispatch_sync(_peersReceivingFromQueue, ^{
        //Find matching peer and remove them if they exist.
        NSDictionary *matchedPeerAndResourceNamePair;
        for (NSDictionary *peerAndResourceNamePair in _peersReceivingFrom) {
            if ([[peerAndResourceNamePair objectForKey:[AppConstants peerIDStringIdentifier]] isEqual: peer]) {
                NSLog(@"Matched peerResourceName pair to remove %@", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
                matchedPeerAndResourceNamePair = peerAndResourceNamePair;
            }
        }
        [_peersReceivingFrom removeObject:matchedPeerAndResourceNamePair];
        NSLog(@"Removing file reception in progress for peer %@ if it exists", [LocalStorageManager getPeerNameFromDisplayName:peer.displayName]);
        NSLog(@"Structure of peersReceivingFrom After [removeAllFileReceptionFromPeer]: %@", _peersReceivingFrom);
    });
}

-(void)removeAllFileReceptionsInProgress {
    dispatch_sync(_peersReceivingFromQueue, ^{
        [_peersReceivingFrom removeAllObjects];
        NSLog(@"Removing all peers from peersReceivingFrom");
    });
}

#pragma mark - Outgoing Send Progress

-(void)addOutgoingSendProgress: (NSProgress*)sendProgress withResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID AndAddObserver: (UIViewController*)viewController {
    dispatch_sync(_outgoingSendsProgressesQueue, ^{
        [sendProgress addObserver:viewController forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        NSDictionary *outgoingSendProgressDictionary = @{
                                                         [AppConstants sendProgressStringIdentifier]:sendProgress,
                                                         [AppConstants resourceNameStringIdentifier]:resourceName,
                                                         [AppConstants peerIDStringIdentifier]:peerID,
                                                         [AppConstants observerStringIdentifier]: viewController
                                                         };
        [_outgoingSendsProgressesArray addObject:outgoingSendProgressDictionary];
    });
}

-(void)removeOutgoingSendProgress: (NSProgress*)sendProgress {
    dispatch_sync(_outgoingSendsProgressesQueue, ^{
        //Find matching sendProgress and remove it if it exists
        NSDictionary *matchedSendProgressDictionary;
        for (NSDictionary *sendProgressDictionary in _outgoingSendsProgressesArray) {
            if ([[sendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]] isEqual:sendProgress]) {
                matchedSendProgressDictionary = sendProgressDictionary;
            }
        }
        if (matchedSendProgressDictionary != nil) {
            [sendProgress removeObserver:[matchedSendProgressDictionary objectForKey:[AppConstants observerStringIdentifier]] forKeyPath:@"fractionCompleted"];
        }
        [_outgoingSendsProgressesArray removeObject:matchedSendProgressDictionary];
    });
}

-(void)removeOutgoingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID {
    dispatch_sync(_outgoingSendsProgressesQueue, ^{
        //Find matching sendProgress and remove it if it exists
        NSDictionary *matchedSendProgressDictionary;
        for (NSDictionary *sendProgressDictionary in _outgoingSendsProgressesArray) {
            if ([[sendProgressDictionary objectForKey:[AppConstants resourceNameStringIdentifier]] isEqualToString:resourceName] && [[sendProgressDictionary objectForKey:[AppConstants peerIDStringIdentifier]] isEqual:peerID]) {
                
                NSLog(@"Matched outgoingSendProgress to remove.");
                matchedSendProgressDictionary = sendProgressDictionary;
            }
        }
        if (matchedSendProgressDictionary != nil) {
            NSProgress *outgoingSendProgress = [matchedSendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]];
            [outgoingSendProgress removeObserver:[matchedSendProgressDictionary objectForKey:[AppConstants observerStringIdentifier]]forKeyPath:@"fractionCompleted"];
        }
        [_outgoingSendsProgressesArray removeObject:matchedSendProgressDictionary];
    });
}

-(void)removeAllOutgoingSendProgresses {
    dispatch_sync(_outgoingSendsProgressesQueue, ^{
        for (NSDictionary *outgoingSendProgressDictionary in _outgoingSendsProgressesArray) {
            NSProgress *outgoingSendProgress = [outgoingSendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]];
            [outgoingSendProgress removeObserver:[outgoingSendProgressDictionary objectForKey:[AppConstants observerStringIdentifier]] forKeyPath:@"fractionCompleted"];
        }
        [_outgoingSendsProgressesArray removeAllObjects];
    });
}

-(BOOL)progressIsAnOutgoingSendProgress: (NSProgress*)progress {
    //Find matching sendProgress
    __block BOOL matchedSendProgressDictionary = NO;
    
    dispatch_sync(_outgoingSendsProgressesQueue, ^{
        for (NSDictionary *sendProgressDictionary in _outgoingSendsProgressesArray) {
            if ([[sendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]] isEqual:progress]) {
                matchedSendProgressDictionary = YES;
            }
        }
    });
    
    return matchedSendProgressDictionary;
}

-(double)getProgressOfCurrentOutgoingSend {
    __block double progressOfCurrentOutgoingSend;
    dispatch_sync(_outgoingSendsProgressesQueue, ^{
        if ([_outgoingSendsProgressesArray count] > 0) {
            NSDictionary *sendProgressDictionary = [_outgoingSendsProgressesArray objectAtIndex:0];
            progressOfCurrentOutgoingSend = [(NSProgress*)[sendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]] fractionCompleted];
        }
    });
    
    return progressOfCurrentOutgoingSend;
}

//-(NSProgress*)getOutgoingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID {
//    __block NSProgress *sendProgress;
//    dispatch_sync(_outgoingSendsProgressesQueue, ^{
//        //Find matching sendProgress
//        for (NSDictionary *outgoingSendProgressDictionary in _outgoingSendsProgressesArray) {
//            if ([[outgoingSendProgressDictionary objectForKey:[AppConstants resourceNameStringIdentifier]] isEqualToString:resourceName] && [[outgoingSendProgressDictionary objectForKey:[AppConstants peerIDStringIdentifier]] isEqual:peerID]) {
//
//                sendProgress = [outgoingSendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]];
//            }
//        }
//    });
//
//    return sendProgress;
//}

//-(NSArray*)getAllOutgoingSendProgresses {
//    __block NSArray *allOutgoingSendProgressesDictionaries;
//
//    dispatch_sync(_outgoingSendsProgressesQueue, ^{
//        allOutgoingSendProgressesDictionaries = [[NSArray alloc] initWithArray:_outgoingSendsProgressesArray copyItems:NO];
//    });
//
//    return allOutgoingSendProgressesDictionaries;
//}

#pragma mark - Incoming Send Progress

-(void)addIncomingSendProgress: (NSProgress*)sendProgress withResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID AndAddObserver: (UIViewController*)viewController {
    dispatch_sync(_incomingSendsProgressesQueue, ^{
        [sendProgress addObserver:viewController forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        NSDictionary *incomingSendProgressDictionary = @{
                                                         [AppConstants sendProgressStringIdentifier]:sendProgress,
                                                         [AppConstants resourceNameStringIdentifier]:resourceName,
                                                         [AppConstants peerIDStringIdentifier]:peerID,
                                                         [AppConstants observerStringIdentifier]: viewController
                                                         };
        [_incomingSendsProgressesArray insertObject:incomingSendProgressDictionary atIndex:0];
    });
}

-(void)removeIncomingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID {
    dispatch_sync(_incomingSendsProgressesQueue, ^{
        //Find matching sendProgress and remove it if it exists
        NSDictionary *matchedSendProgressDictionary;
        for (NSDictionary *sendProgressDictionary in _incomingSendsProgressesArray) {
            if ([[sendProgressDictionary objectForKey:[AppConstants resourceNameStringIdentifier]] isEqualToString:resourceName] && [[sendProgressDictionary objectForKey:[AppConstants peerIDStringIdentifier]] isEqual:peerID]) {
                
                NSLog(@"Matched incomingSendProgress to remove.");
                matchedSendProgressDictionary = sendProgressDictionary;
            }
        }
        if (matchedSendProgressDictionary != nil) {
            NSProgress *incomingSendProgress = [matchedSendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]];
            [incomingSendProgress removeObserver:[matchedSendProgressDictionary objectForKey:[AppConstants observerStringIdentifier]] forKeyPath:@"fractionCompleted"];
        }
        [_incomingSendsProgressesArray removeObject:matchedSendProgressDictionary];
    });
}

-(void)removeAllIncomingSendProgresses {
    dispatch_sync(_incomingSendsProgressesQueue, ^{
        for (NSDictionary *incomingSendProgressDictionary in _incomingSendsProgressesArray) {
            NSProgress *incomingSendProgress = [incomingSendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]];
            [incomingSendProgress removeObserver:[incomingSendProgressDictionary objectForKey:[AppConstants observerStringIdentifier]] forKeyPath:@"fractionCompleted"];
        }
        [_incomingSendsProgressesArray removeAllObjects];
    });
}

-(BOOL)progressIsAnIncomingSendProgress: (NSProgress*)progress {
    //Find matching sendProgress
     __block BOOL matchedSendProgressDictionary = NO;
    
    dispatch_sync(_incomingSendsProgressesQueue, ^{
        for (NSDictionary *sendProgressDictionary in _incomingSendsProgressesArray) {
            if ([[sendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]] isEqual:progress]) {
                matchedSendProgressDictionary = YES;
            }
        }
    });
    
    return matchedSendProgressDictionary;
}

//-(NSProgress*)getIncomingSendProgressForResourceName: (NSString*)resourceName andPeerID: (MCPeerID*)peerID {
//    __block NSProgress *sendProgress;
//    dispatch_sync(_incomingSendsProgressesQueue, ^{
//        //Find matching sendProgress
//        for (NSDictionary *incomingSendProgressDictionary in _incomingSendsProgressesArray) {
//            if ([[incomingSendProgressDictionary objectForKey:[AppConstants resourceNameStringIdentifier]] isEqualToString:resourceName] && [[incomingSendProgressDictionary objectForKey:[AppConstants peerIDStringIdentifier]] isEqual:peerID]) {
//
//                sendProgress = [incomingSendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]];
//            }
//        }
//    });
//
//    return sendProgress;
//}

//-(NSProgress*)getIncomingSendProgressForPeerID: (MCPeerID*)peerID {
//    __block NSProgress *sendProgress;
//    dispatch_sync(_incomingSendsProgressesQueue, ^{
//        //Find matching sendProgress
//        for (NSDictionary *incomingSendProgressDictionary in _incomingSendsProgressesArray) {
//            if ([[incomingSendProgressDictionary objectForKey:[AppConstants peerIDStringIdentifier]] isEqual:peerID]) {
//
//                sendProgress = [incomingSendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]];
//            }
//        }
//    });
//
//    return sendProgress;
//}

-(NSArray*)getAllIncomingSendProgresses {
    __block NSArray *allIncomingSendProgressesArray;

    dispatch_sync(_incomingSendsProgressesQueue, ^{
        allIncomingSendProgressesArray = [[NSArray alloc] initWithArray:_incomingSendsProgressesArray copyItems:NO];
    });

    return allIncomingSendProgressesArray;
}

#pragma mark - Convenience methods

-(void)removeAllPeersFromPeersSendingToAndPeersReceivingFrom {
    [self removeAllQueuedSends];
    [self removeAllFileReceptionsInProgress];
}

-(void)removeAllOutgoingAndIncomingSendProgresses {
    [self removeAllOutgoingSendProgresses];
    [self removeAllIncomingSendProgresses];
}

#pragma mark - Helper methods

/* - Sorts array of peers by displayname - */

-(NSArray*)sortPeers: (NSArray*)peersArray {
    
    NSArray *peersArraySorted = [peersArray sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSLog(@"Sorting peer array");
        NSString *name1 = [LocalStorageManager getPeerNameFromDisplayName:((MCPeerID*)obj1).displayName];
        NSString *name2 = [LocalStorageManager getPeerNameFromDisplayName:((MCPeerID*)obj2).displayName];
        return [name1 caseInsensitiveCompare:name2];
    }];
    
    return peersArraySorted;
}

@end
