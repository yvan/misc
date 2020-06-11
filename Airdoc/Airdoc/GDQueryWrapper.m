//
//  GDQueryWrapper.m
//  Envoy
//
//  Created by Yvan Scher on 8/8/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "GDQueryWrapper.h"

@interface GDQueryWrapper ()

@property (nonatomic, strong) GTLServiceTicket* serviceTicket;
@property (nonatomic) NSString* storedReduceStackToPath;
@property (nonatomic) int typeOfQuery;
@property (nonatomic) File* passedFile;
@property (nonatomic) BOOL shouldReloadMainView;
@property (nonatomic) BOOL moveToGDPressed;
@property (nonatomic) BOOL moveFromGDPressed;
@property (nonatomic) BOOL cameFromAuth;
@property (nonatomic) int customRequestCount; //incremented and decremeted counter for requests to the API. Built in one doesn't work right.
@property (nonatomic) NSMutableArray* originallySelectedFiles;
@property (nonatomic) UIViewController* presentFromForReAuthentication;

@end

@implementation GDQueryWrapper

-(instancetype) initWithServiceTicket:(GTLServiceTicket*)serviceTicket andStoredReduceStackToPath:(NSString*)storedReduceStackToPath andTypeOfQuery:(int)typeOfQuery andPassedFile:(File*)passedFile andshouldReloadMainView:(BOOL)shouldReload andMoveToGD:(BOOL)moveToGDPressed cameFromAuth:(BOOL)cameFromAuth andMovedFromGD:(BOOL)moveFromGDPressed andSelectedFiles:(NSMutableArray*)originallySelectedFiles{
 
    _serviceTicket = serviceTicket;
    _storedReduceStackToPath = storedReduceStackToPath;
    _typeOfQuery = typeOfQuery;
    _passedFile = passedFile;
    _shouldReloadMainView = shouldReload;
    _moveToGDPressed = moveToGDPressed;
    _moveFromGDPressed = moveFromGDPressed;
    _cameFromAuth = cameFromAuth;
    _downloadPathToFetcher = [[NSMutableDictionary alloc]init];
    _customRequestCount = 0;
    _originallySelectedFiles = [[NSMutableArray alloc] initWithArray:originallySelectedFiles];
    return self;
}

-(GTLServiceTicket*) getServiceTicket {
    return _serviceTicket;
}

-(void) setServiceTicket:(GTLServiceTicket *)serviceTicket{
    _serviceTicket = serviceTicket;
}

-(NSString*) getStoredReduceStackToPath {
    return _storedReduceStackToPath;
}

-(int) getTypeOfQuery {
    return _typeOfQuery;
}

-(void) setTypeOfQuery:(int)typeToSet {
    _typeOfQuery = typeToSet;
}

-(File*) getPassedFile {
    return _passedFile;
}

-(BOOL) getShouldReloadMainView {
    return _shouldReloadMainView;
}

-(void) setShouldReloadMainView:(BOOL)boolToUse {
    _shouldReloadMainView = boolToUse;
}

-(BOOL) getMoveToGDPressed {
    return _moveToGDPressed;
}

-(BOOL) getCameFromAuth {
    return _cameFromAuth;
}

-(BOOL) getMoveFromGDPressed{
    return _moveFromGDPressed;
}

-(void) setObject:(id)obj forKeyInDownloadPathToFetcher:(NSString*)key {
    
    [_downloadPathToFetcher setObject:obj forKey:key];
}

-(id) getObjectforKeyInDownloadPathToFetcher:(NSString*)key {
    
    return [_downloadPathToFetcher objectForKey:key];
}

/* Request Counters */

// These bad boys basically do the job of abstracting away requests.
// so whether it's a fetcher or a constructed/executed query object
// they all get treated as requests that get started
// and completed when the completion handler triggers

-(void) incrementCustomRequestCount {
    _customRequestCount++;
}

-(void) decrementCustomRequestCount {
    _customRequestCount--;
}

-(int) getCustomRequestCount{
    return _customRequestCount;
}

-(NSMutableArray*) getOriginallySelectedFiles {
    return _originallySelectedFiles;
}

-(void) setPresentFromForReAuthentication:(UIViewController*)viewControllerSet{
    _presentFromForReAuthentication = viewControllerSet;
}

-(UIViewController*) getPresentFromForReAuthentication{
    return _presentFromForReAuthentication;
}

@end
