//
//  DBQueryWrapper.h
//  Hexlist
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
@property (nonatomic) NSMutableDictionary* dropboxLinkToDropboxPathMap;//maps download location to original DB path, '/Local' : {"/misc/funtimes/blah"}
@property (nonatomic) NSMutableDictionary* idToOriginalIndexPosition; // for maintaining link order in the sendback array

//needs to be id and not DBRestClient because we can't import dropbox sdk in teh .h
-(instancetype) initWithRestClient:(id)restClient andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile;

-(id) getRestClient;
-(NSString*) getUUID;

-(int) getTypeOfQuery;
-(void) setTypeOfQuery:(int)typeToSet;

-(File*) getPassedFile;
-(void) setPassedFile:(File*)inputToSet;

-(void) setObject:(id)value forKeyInDropboxLinkToDropboxPathMap:(NSString*)key;
-(id) getObjectforKeyInDropboxLinkToDropboxPathMap:(NSString*)key;

-(void) setValue:(id)obj forKeyInIdToOriginalIndexPosition:(NSString*)key;
-(id) getValueforKeyInIdToOriginalIndexPosition:(NSString*)key;

-(void) incrementCustomRequestCount;
-(void) decrementCustomRequestCount;
-(int) getCustomRequestCount;
-(void) setCustomRequestCount:(int)customRequestCount;

-(BOOL) getLinkRequestAlreadyFailed;
-(void) setLinkRequestAlreadyFailed;

@end
