//
//  BXServiceManager.h
//  Hexlist
//
//  Created by Yvan Scher on 1/9/16.
//  Copyright (c) 2016 Yvan Scher. All rights reserved.
//
// see: http://stackoverflow.com/questions/23386868/get-share-link-file-link-for-box-in-ios
// for shareable links, nvm his is on the old API.
// checkout the sample app and look for BOXFileRequest
// https://github.com/box/box-ios-sdk/tree/master/BoxContentSDKSampleApp
// https://github.com/box/box-ios-sdk/tree/master/doc
// https://developers.box.com/get-started/

#import "LinkJM.h"
#import "AppConstants.h"
#import "BXQueryWrapper.h"
#import "KeychainItemWrapper.h"
#import <Foundation/Foundation.h>
#import "FileSystemInterface.h"
#import "FileSystemAbstraction.h"
#import <BoxContentSDK/BOXContentSDK.h>
#import "RetrieveLinksFromServiceManagerDelegate.h"

@protocol BXServiceManagerDelegate <NSObject>

-(void) unselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath;
-(void) alertUserToFileNotFound:(File*)file;
-(void) alertUserToRateLimitFromService:(ServiceType)serviceType;
-(void) alertUserToInsufficientPermission:(File*)file;
-(void) alerUserToCouldntReachService:(ServiceType)serviceType;
-(void) alertUserToUnspecifiedErrorOnService:(ServiceType)serviceType;

@end

@interface BXServiceManager : NSObject

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;
@property (nonatomic) BOXFolderItemsRequest* navigationRequest;
@property (nonatomic, weak) UIViewController* passedInController; //still need the global for cancelling the auth sequence
@property (nonatomic) BOOL canLoadAndNavigateAfterAuth;
@property (nonatomic) NSMutableArray* bxQueryWrapperHolder;
@property (nonatomic) File* passedFileForAuth;

@property (nonatomic, strong) dispatch_queue_t bxQueryWrapperQueue;

@property (nonatomic, weak) id <BXServiceManagerDelegate> bxServiceManagerDelegate;
@property (nonatomic, weak) id <RetrieveLinksFromServiceManagerDelegate> retrieveLinksFromServiceManagerDelegate;

-(void) pressedBoxFolder:(UIViewController*)passedController withFile:(File*)passedFile;
-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify andParentFile:(File*)parentFile andUUID:(NSString*)uuidString;
-(void) cancelNavigationLoad;
-(BOOL) isAuthorized;
-(void) unlinkService;

@end
