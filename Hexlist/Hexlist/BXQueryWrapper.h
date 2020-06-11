//
//  BXQueryWrapper.h
//  Hexlist
//
//  Created by Yvan Scher on 1/9/16.
//  Copyright (c) 2016 Yvan Scher. All rights reserved.
//

#import "File.h"
#import <Foundation/Foundation.h>
#import <BoxContentSDK/BOXContentSDK.h>

@interface BXQueryWrapper : NSObject

@property (nonatomic) NSMutableDictionary* boxLinkToBoxIDMap;
@property (nonatomic) NSMutableDictionary* idToOriginalIndexPosition; // for maintaining link order in the sendback array

-(instancetype) initWithContentClient:(id)contentClient andBOXRequest:(BOXRequest*)boxRequest andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile;

-(id) getContentClient;
-(id) getBOXRequest;
-(NSString*) getUUID;
-(void) setBOXRequest:(BOXRequest*)boxRequest;

-(int) getTypeOfQuery;
-(void) setTypeOfQuery:(int)typeToSet;

-(File*) getPassedFile;
-(void) setPassedFile:(File*)inputToSet;

-(void) setObject:(id)value forKeyInBoxLinkToBoxIDMap:(NSString*)key;
-(id) getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:(NSString*)key;

-(void) setValue:(id)obj forKeyInIdToOriginalIndexPosition:(NSString*)key;
-(id) getValueforKeyInIdToOriginalIndexPosition:(NSString*)key;

-(void) incrementCustomRequestCount;
-(void) decrementCustomRequestCount;
-(int) getCustomRequestCount;
-(void) setCustomRequestCount:(int)customRequestCount;

-(BOOL) getLinkRequestAlreadyFailed;
-(void) setLinkRequestAlreadyFailed;

@end
