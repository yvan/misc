//
//  GDQueryWrapper.m
//  Hexlist
//
//  Created by Yvan Scher on 8/8/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "GDQueryWrapper.h"

@interface GDQueryWrapper ()

@property (nonatomic, strong) GTLServiceTicket* serviceTicket;
@property (nonatomic) int typeOfQuery;
@property (nonatomic) File* passedFile;
@property (nonatomic) int customRequestCount; //incremented and decremeted counter for requests to the API. Built in one doesn't work right.
@property (nonatomic) NSString* uuidString;
@property (nonatomic) UIViewController* presentFromForReAuthentication;
@property (nonatomic) BOOL linkRequestFailed;

@end

@implementation GDQueryWrapper

-(instancetype) initWithServiceTicket:(GTLServiceTicket*)serviceTicket andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile {
    _serviceTicket = serviceTicket;
    _typeOfQuery = typeOfQuery;
    _passedFile = passedFile;
    _uuidString = uuidString;
    _googledriveLinkToGoogleIDMap = [[NSMutableDictionary alloc] init];
    _idToOriginalIndexPosition = [[NSMutableDictionary alloc] init];
    _customRequestCount = 0;
    return self;
}

-(GTLServiceTicket*) getServiceTicket {
    return _serviceTicket;
}

-(void) setServiceTicket:(GTLServiceTicket *)serviceTicket{
    _serviceTicket = serviceTicket;
}

-(NSString*) getUUID {
    return _uuidString;
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

-(void) setObject:(id)obj forKeyInGoogledriveLinkToGoogleIDMap:(NSString*)key {
    
    [_googledriveLinkToGoogleIDMap setObject:obj forKey:key];
}

-(id) getObjectforKeyInGoogledriveLinkToGoogleIDMap:(NSString*)key {
    
    return [_googledriveLinkToGoogleIDMap objectForKey:key];
}

-(void) setValue:(id)obj forKeyInIdToOriginalIndexPosition:(NSString*)key {
    [_idToOriginalIndexPosition setValue:obj forKey:key];
}

-(id) getValueforKeyInIdToOriginalIndexPosition:(NSString*)key {
    return [_idToOriginalIndexPosition valueForKey:key];
}

-(BOOL) getLinkRequestAlreadyFailed {
    return _linkRequestFailed;
}

-(void) setLinkRequestAlreadyFailed {
    _linkRequestFailed = YES;
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

-(void) setCustomRequestCount:(int)customRequestCount {
    _customRequestCount = customRequestCount;
}

-(void) setPresentFromForReAuthentication:(UIViewController*)viewControllerSet{
    _presentFromForReAuthentication = viewControllerSet;
}

-(UIViewController*) getPresentFromForReAuthentication{
    return _presentFromForReAuthentication;
}

@end
