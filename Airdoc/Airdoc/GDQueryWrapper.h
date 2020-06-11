//
//  GDQueryWrapper.h
//  Envoy
//
//  Created by Yvan Scher on 8/8/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GTLDrive.h"
#import "File.h"

@interface GDQueryWrapper : NSObject

//maps the download path to the file fetchers inside a query wrapper. (we want to stop the fetchers from fetching)
@property (nonatomic) NSMutableDictionary* downloadPathToFetcher;

-(instancetype) initWithServiceTicket:(GTLServiceTicket*)serviceTicket  andStoredReduceStackToPath:(NSString*)storedReduceStackToPath andTypeOfQuery:(int)typeOfQuery andPassedFile:(File*)passedFile andshouldReloadMainView:(BOOL)shouldReload andMoveToGD:(BOOL)moveToGDPressed cameFromAuth:(BOOL)cameFromAuth andMovedFromGD:(BOOL)moveFromGDPressed andSelectedFiles:(NSMutableArray*)originallySelectedFiles;

-(GTLServiceTicket*) getServiceTicket;
-(void) setServiceTicket:(GTLServiceTicket *)serviceTicket;
-(NSString*) getStoredReduceStackToPath;
-(int) getTypeOfQuery;
-(void) setTypeOfQuery:(int)typeToSet;
-(File*) getPassedFile;
-(BOOL) getShouldReloadMainView;
-(void) setShouldReloadMainView:(BOOL)boolToUse;
-(BOOL) getMoveToGDPressed;
-(BOOL) getMoveFromGDPressed;
-(BOOL) getCameFromAuth;
-(void) setObject:(id)obj forKeyInDownloadPathToFetcher:(NSString*)key;
-(id) getObjectforKeyInDownloadPathToFetcher:(NSString*)key;
-(void) incrementCustomRequestCount;
-(void) decrementCustomRequestCount;
-(int) getCustomRequestCount;
-(NSMutableArray*) getOriginallySelectedFiles;
-(void) setPresentFromForReAuthentication:(UIViewController*)viewControllerSet;
-(UIViewController*) getPresentFromForReAuthentication;

@end
