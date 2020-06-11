//
//  InboxManager.h
//  Airdoc
//
//  Created by Roman Scher on 3/19/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "LocalStorageManager.h"
#import "FileSystemInterface.h"
#import "File.h"
#import "Link.h"
#import "LinkPackage.h"
#import "LinkJM.h"
#import "LinkPackageJM.h"


@interface InboxManager : NSObject

@property (nonatomic, strong) dispatch_queue_t inboxJsonUpdateQueue;

#pragma mark - Singleton

+(id)sharedInboxManager;

#pragma mark - Inbox NSUserDefaults

//File Packages
+(void)incrementnumberOfUncheckedFilePackages;
+(void)reduceNumberOfUncheckedFilePackagesToZero;
+(NSString*)getNumberOfUncheckedFilePackages;

//Link Packages
+(void)incrementnumberOfUncheckedLinkPackages;
+(void)reduceNumberOfUncheckedLinkPackagesToZero;
+(NSString*)getNumberOfUncheckedLinkPackages;

//General
+(NSString*)getTotalNumberOfUncheckedPackages;

#pragma mark - LinkPackage methods

-(RLMResults*)getAllLinkPackages;
-(void)saveLinkPackage:(LinkPackageJM *)linkPackageJM;
-(void)deleteLinkPackage:(LinkPackage*)linkPackage;

#pragma mark - Inbox.json methods

-(void)createInboxJsonFile;

-(void)addSingleFileToInboxJsonWithFilePackageUUID:(NSString*)filePackageUUID andFile:(File*)file fromPeer: (MCPeerID*)peer;
-(void)removeFilePackageFromInboxJsonWithFilePackageUUID: (NSString*)filePackageUUID;
-(NSArray*)getFilePackagesFromInboxJson;

@property (nonatomic) FileSystemInterface* fsInterface;

@end
