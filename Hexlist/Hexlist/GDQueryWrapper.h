//
//  GDQueryWrapper.h
//  Hexlist
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
@property (nonatomic) NSMutableDictionary* googledriveLinkToGoogleIDMap;
@property (nonatomic) NSMutableDictionary* idToOriginalIndexPosition; // for maintaining link order in the sendback array

-(instancetype) initWithServiceTicket:(GTLServiceTicket*)serviceTicket andTypeOfQuery:(int)typeOfQuery andUUIDString:(NSString*)uuidString andPassedFile:(File*)passedFile;

-(GTLServiceTicket*) getServiceTicket;
-(void) setServiceTicket:(GTLServiceTicket *)serviceTicket;

-(int) getTypeOfQuery;
-(void) setTypeOfQuery:(int)typeToSet;

-(NSString*) getUUID;
-(File*) getPassedFile;

-(void) setObject:(id)obj forKeyInGoogledriveLinkToGoogleIDMap:(NSString*)key;
-(id) getObjectforKeyInGoogledriveLinkToGoogleIDMap:(NSString*)key;

-(void) setValue:(id)obj forKeyInIdToOriginalIndexPosition:(NSString*)key;
-(id) getValueforKeyInIdToOriginalIndexPosition:(NSString*)key;

-(void) incrementCustomRequestCount;
-(void) decrementCustomRequestCount;
-(int) getCustomRequestCount;
-(void) setCustomRequestCount:(int)customRequestCount;

-(void) setPresentFromForReAuthentication:(UIViewController*)viewControllerSet;
-(UIViewController*) getPresentFromForReAuthentication;

-(BOOL) getLinkRequestAlreadyFailed;
-(void) setLinkRequestAlreadyFailed;

@end
