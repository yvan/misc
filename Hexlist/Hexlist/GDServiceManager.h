//
//  GDServiceManager.h
//  Hexlist
//
//  Created by Yvan Scher on 1/18/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "LinkJM.h"
#import "File.h"
#import "GTLDrive.h"
#import "AppConstants.h"
#import "GDQueryWrapper.h"
#import "FileSystemInterface.h"
#import "FileSystemAbstraction.h"
#import <Foundation/Foundation.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "RetrieveLinksFromServiceManagerDelegate.h"


@protocol GDServiceManagerDelegate <NSObject>

-(void) unselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath;
-(void) alertUserToFileNotFound:(File*)file;
-(void) alertUserToRateLimitFromService:(ServiceType)serviceType;
-(void) alertUserToInsufficientPermission:(File*)file;
-(void) alerUserToCouldntReachService:(ServiceType)serviceType;
-(void) alertUserToUnspecifiedErrorOnService:(ServiceType)serviceType;

@end

@interface GDServiceManager : NSObject <UINavigationControllerDelegate>

@property (nonatomic) GTMOAuth2Authentication *auth;
@property (nonatomic, retain) GTLServiceDrive *driveService;
@property (nonatomic, strong) GTLServiceTicket *serviceTicketForNavigationLoad;
@property (nonatomic) UIViewController* passedInController; //still need the global for cancelling the auth sequence
@property (nonatomic) NSMutableArray* gdQueryWrapperHolder;
@property (nonatomic) NSMutableArray* gdOperationWrapperHolder;
@property (nonatomic) NSMutableArray* gdQueryOccurrenceLimitHolder;
@property (nonatomic) int globalActiveRequestCount;
@property (nonatomic) BOOL canLoadAndNavigateAfterAuth;

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;
@property (nonatomic) File* passedFileForAuth;

@property (nonatomic, weak) id <RetrieveLinksFromServiceManagerDelegate> retrieveLinksFromServiceManagerDelegate;
@property (nonatomic, weak) id <GDServiceManagerDelegate> gdServiceManagerDelegate;

@property (nonatomic, strong) dispatch_queue_t gdQueryWrapperQueue;

// - no explicit move file, just combined upload and delete - //

-(void) cancelNavigationLoad;
-(BOOL) isAuthorized;
-(void) unlinkService;
-(void) getShareableLinksWithFiles:(NSArray*)filesToLinkify andParentFile:(File*)parentFile andUUID:(NSString*)uuidString;
-(void) pressedGoogleDriveFolder:(UIViewController*)passedController withFile:(File*)file;

@end
