//
//  APIServiceManager.h
//  Hexlist
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "File.h"
#import "DBQueryWrapper.h"
#import "FileSystemInterface.h"
#import "FileSystemAbstraction.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "RetrieveLinksFromServiceManagerDelegate.h"
#import "LinkJM.h"
#import "AppConstants.h"

@protocol DBServiceManagerDelegate <NSObject>

-(void) unselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath;
-(void) alertUserToFileNotFound:(File*)file;
-(void) alertUserToRateLimitFromService:(ServiceType)serviceType;
-(void) alertUserToInsufficientPermission:(File*)file;
-(void) alerUserToCouldntReachService:(ServiceType)serviceType;
-(void) alertUserToUnspecifiedErrorOnService:(ServiceType)serviceType;

@end

@interface DBServiceManager : NSObject

@property (nonatomic) int globalActiveRequestCount;
@property (nonatomic) NSMutableArray* dbQueryWrapperHolder;
@property (nonatomic) BOOL canLoadAndNavigateAfterAuth;

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;
@property (nonatomic) File* passedFileForAuth;

@property (nonatomic, strong) dispatch_queue_t dbQueryWrapperQueue;

@property (nonatomic, weak) id <RetrieveLinksFromServiceManagerDelegate> retrieveLinksFromServiceManagerDelegate;
@property (nonatomic, weak) id <DBServiceManagerDelegate> dbServiceManagerDelegate;

-(void) unlinkService;
-(BOOL) isAuthorized;
-(void) cancelNavigationLoad;
-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify andParentFile:(File*)parentFile andUUID:(NSString*)uuidString;
-(void) pressedDropboxFolder:(UIViewController*)passedController withFile:(File*)passedFile;

@end
