//
//  DBQueryWrapper.h
//  Envoy
//
//  Created by Yvan Scher on 8/8/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "File.h"

@interface DBQueryWrapper : NSObject

//for some reason this needs to be here to be accessible externally
//because [self getdonwloadPathTOOriginaPathMAp]
//doens't work for setting values properly
@property (nonatomic) NSMutableDictionary* downloadPathToOriginalPathMap;//maps download location to original DB path, '/Local' : {"/misc/funtimes/blah"}

//needs to be id and not DBRestClient because we can't import dropbox sdk in teh .h
-(instancetype) initWithRestClient:(id)restClient andStoredReduceStackToPath:(NSString*)storedReduceStackToPath andTypeOfQuery:(int)typeOfQuery andPassedFile:(File*)passedFile andshouldReloadMainView:(BOOL)shouldReload andMoveToDB:(BOOL)moveToDBPressed cameFromAuth:(BOOL)cameFromAuth andMovedFromDB:(BOOL)moveFromDBPressed andSelectedFiles:(NSMutableArray*)originallySelectedFiles;

-(id) getRestClient;
-(NSString*) getStoredReduceStackToPath;
-(int) getTypeOfQuery;
-(void) setTypeOfQuery:(int)typeToSet;
-(File*) getPassedFile;
-(void) setPassedFile:(File*)inputToSet;
-(BOOL) getShouldReloadMainView;
-(void) setShouldReloadMainView:(BOOL)boolToUse;
-(BOOL) getMoveToDBPressed;
-(void) setMoveToDBPressed:(BOOL)moveToDBPressed;
-(BOOL) getMoveFromDBPressed;
-(BOOL) getCameFromAuth;
-(void) setCameFromAuth:(BOOL)cameFromAuth;
-(void) setObject:(id)value forKeyInDownloadPathToOriginalPathMap:(NSString*)key;
-(id) getObjectforKeyInDownloadPathToOriginalPathMap:(NSString*)key;
-(void) incrementCustomRequestCount;
-(void) decrementCustomRequestCount;
-(int) getCustomRequestCount;
-(NSMutableArray*) getOriginallySelectedFiles;

@end
