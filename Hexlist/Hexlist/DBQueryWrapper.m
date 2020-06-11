//
//  DBQueryWrapper.m
//  Hexlist
//
//  Created by Yvan Scher on 8/8/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "DBQueryWrapper.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DBQueryWrapper ()

@property (nonatomic, strong) DBRestClient* restClient;
@property (nonatomic) int typeOfQuery;
@property (nonatomic) File* passedFile;
@property (nonatomic) int customRequestCount; //incremented and decremeted counter for requests to the API. Built in one doesn't work right.
@property (nonatomic) NSString* uuidString;
@property (nonatomic) BOOL linkRequestFailed;

@end

@implementation DBQueryWrapper

-(instancetype) initWithRestClient:(id)restClient andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile {
    _passedFile = passedFile;
    _restClient = (DBRestClient*) restClient;
    _typeOfQuery = typeOfQuery;
    _uuidString = uuidString;
    _dropboxLinkToDropboxPathMap = [[NSMutableDictionary alloc] init];
    _idToOriginalIndexPosition = [[NSMutableDictionary alloc] init];
    _customRequestCount = 0;
    return self;
}

-(id) getRestClient {
    return _restClient;
}

-(int) getTypeOfQuery {
    return _typeOfQuery;
}

-(NSString*) getUUID {
    return  [NSString stringWithString:_uuidString];
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

-(void) setObject:(id)value forKeyInDropboxLinkToDropboxPathMap:(NSString*)key {
    [_dropboxLinkToDropboxPathMap setObject:value forKey:key];
}

-(id) getObjectforKeyInDropboxLinkToDropboxPathMap:(NSString*)key {
    return [_dropboxLinkToDropboxPathMap objectForKey:key];
}

-(void) setValue:(id)obj forKeyInIdToOriginalIndexPosition:(NSString*)key {
    [_idToOriginalIndexPosition setValue:obj forKey:key];
}

-(id) getValueforKeyInIdToOriginalIndexPosition:(NSString*)key {
    return [_idToOriginalIndexPosition valueForKey:key];
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

/* Request Counters */

// These bad boys basically do the job of abstracting away requests.
// so because dropbox didn't build their request counter properly
// i had to make my own that starts/complete things when I want
// they all get treated as requests that get started
// and completed when the completion handler triggers

-(void) setCustomRequestCount:(int)customRequestCount {
    _customRequestCount = customRequestCount;
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

@end
