//
//  BXQueryWrapper.m
//  Hexlist
//
//  Created by Yvan Scher on 1/9/16.
//  Copyright (c) 2016 Yvan Scher. All rights reserved.
//

#import "BXQueryWrapper.h"

@interface BXQueryWrapper ()

@property (nonatomic) id contentClient;
@property (nonatomic) id boxRequest;
@property (nonatomic) int typeOfQuery;
@property (nonatomic) File* passedFile;
@property (nonatomic) int customRequestCount; //incremented and decremeted counter for requests to the API. Built in one doesn't work right.
@property (nonatomic) BOOL linkRequestFailed;
@property (nonatomic) NSString* uuidString;

@end

@implementation BXQueryWrapper

-(instancetype) initWithContentClient:(id)contentClient andBOXRequest:(BOXRequest*)boxRequest andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile {
    _contentClient = (BOXContentClient*)contentClient;
    _boxRequest = boxRequest;
    _typeOfQuery = typeOfQuery;
    _passedFile = passedFile;
    _uuidString = uuidString;
    _boxLinkToBoxIDMap = [[NSMutableDictionary alloc] init];
    _idToOriginalIndexPosition = [[NSMutableDictionary alloc] init];
    _customRequestCount = 0;
    return self;
}

-(id) getContentClient {
    return _contentClient;
}

-(id) getBOXRequest {
    return _boxRequest;
}

-(NSString*) getUUID {
    return _uuidString;
}

-(void) setBOXRequest:(BOXRequest*)boxRequest {
    _boxRequest = boxRequest;
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

-(void) setObject:(id)value forKeyInBoxLinkToBoxIDMap:(NSString*)key {
    [_boxLinkToBoxIDMap setObject:value forKey:key];
}
-(id) getObjectforKeyInBoxLinkToBoxLinkToBoxIDMap:(NSString*)key {
    return [_boxLinkToBoxIDMap objectForKey:key];
}

-(void) setValue:(id)obj forKeyInIdToOriginalIndexPosition:(NSString*)key {
    [_idToOriginalIndexPosition setValue:obj forKey:key];
}

-(id) getValueforKeyInIdToOriginalIndexPosition:(NSString*)key {
    return [_idToOriginalIndexPosition valueForKey:key];
}

-(void) incrementCustomRequestCount {
    _customRequestCount++;
}

-(void) decrementCustomRequestCount {
    _customRequestCount--;
}

-(int) getCustomRequestCount{
    return _customRequestCount;
}

-(void) setCustomRequestCount:(int)customRequestCount {
    _customRequestCount = customRequestCount;
}

// if a link request fails this gets
// set so we can know not to send multiple
// failure delegate responses
-(BOOL) getLinkRequestAlreadyFailed {
    return _linkRequestFailed;
}

-(void) setLinkRequestAlreadyFailed {
    _linkRequestFailed = YES;
}

@end
