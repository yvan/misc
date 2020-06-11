//
//  RetrieveLinksFromServiceManagerDelegate.h
//  
//
//  Created by Roman Scher on 1/11/16.
//
//

#import "LinkJM.h"

#ifndef Envoy_retrieveLinksFromServiceManagerDelegate_h
#define Envoy_retrieveLinksFromServiceManagerDelegate_h

@protocol RetrieveLinksFromServiceManagerDelegate <NSObject>

@required

-(void)finishedPreparingLinks:(NSArray<LinkJM*>*)links withLinkGenerationUUID:(NSString*)uuidString;
-(void)failedToRetrieveAllLinks:(NSString*)errorMessageToDisplay withLinkGenerationUUID:(NSString*)uuidString;

@end

#endif
