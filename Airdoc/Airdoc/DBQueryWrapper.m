//
//  DBQueryWrapper.m
//  Envoy
//
//  Created by Yvan Scher on 8/8/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "DBQueryWrapper.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DBQueryWrapper ()

@property (nonatomic, strong) DBRestClient* restClient;
@property (nonatomic) NSString* storedReduceStackToPath;
@property (nonatomic) int typeOfQuery;
@property (nonatomic) File* passedFile;
@property (nonatomic) BOOL shouldReloadMainView;
@property (nonatomic) BOOL moveToDBPressed;
@property (nonatomic) BOOL moveFromDBPressed;
@property (nonatomic) BOOL cameFromAuth;
@property (nonatomic) int customRequestCount; //incremented and decremeted counter for requests to the API. Built in one doesn't work right.
@property (nonatomic) NSMutableArray* originallySelectedFiles;

@end

@implementation DBQueryWrapper

-(instancetype) initWithRestClient:(id)restClient andStoredReduceStackToPath:(NSString*)storedReduceStackToPath andTypeOfQuery:(int)typeOfQuery andPassedFile:(File*)passedFile andshouldReloadMainView:(BOOL)shouldReload andMoveToDB:(BOOL)moveToDBPressed cameFromAuth:(BOOL)cameFromAuth andMovedFromDB:(BOOL)moveFromDBPressed andSelectedFiles:(NSMutableArray*)originallySelectedFiles{
    
    _passedFile = [[File alloc] initWithName:passedFile.name andPath:passedFile.path andDate:passedFile.dateCreated andRevision:passedFile.revision andDirectoryFlag:passedFile.isDirectory andBoxId:passedFile.boxid];
    _restClient = (DBRestClient*) restClient;
    _storedReduceStackToPath = storedReduceStackToPath;
    _typeOfQuery = typeOfQuery;
    _shouldReloadMainView = shouldReload;
    _moveToDBPressed = moveToDBPressed;
    _moveFromDBPressed = moveFromDBPressed;
    _cameFromAuth = cameFromAuth;
    _downloadPathToOriginalPathMap = [[NSMutableDictionary alloc] init];
    _customRequestCount = 0;
    _originallySelectedFiles = [[NSMutableArray alloc] initWithArray:originallySelectedFiles];
    return self;
}

-(id) getRestClient {
    return _restClient;
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

-(void) setPassedFile:(File*)inputToSet {
    _passedFile = inputToSet;
}


-(BOOL) getShouldReloadMainView {
    return _shouldReloadMainView;
}

-(void) setShouldReloadMainView:(BOOL)boolToUse {
    _shouldReloadMainView = boolToUse;
}

-(BOOL) getMoveToDBPressed {
    return _moveToDBPressed;
}

-(void) setMoveToDBPressed:(BOOL)moveToDBPressed {
    _moveToDBPressed = moveToDBPressed;
}


-(BOOL) getCameFromAuth {
    return _cameFromAuth;
}

-(void) setCameFromAuth:(BOOL)cameFromAuth {
    _cameFromAuth = cameFromAuth;
}


-(BOOL) getMoveFromDBPressed{
    return _moveFromDBPressed;
}

-(void) setObject:(id)obj forKeyInDownloadPathToOriginalPathMap:(NSString*)key {
    
    [_downloadPathToOriginalPathMap setObject:obj forKey:key];
}

-(id) getObjectforKeyInDownloadPathToOriginalPathMap:(NSString*)key {
    
    return [_downloadPathToOriginalPathMap objectForKey:key];
}

/* Request Counters */

// These bad boys basically do the job of abstracting away requests.
// so because dropbox didn't build their request counter properly
// i had to make my own that starts/complete things when I want
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

@end
