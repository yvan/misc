//
//  sendLinksFromServiceManagerDelegate.h
//  Envoy
//
//  Created by Yvan Scher on 10/18/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#ifndef Envoy_sendLinksFromServiceManagerDelegate_h
#define Envoy_sendLinksFromServiceManagerDelegate_h

@protocol SendLinksFromServiceManagerDelegate <NSObject>

-(void) sendLinkDictionaryFromServiceManagerDelegate:(NSDictionary*)linksToSend;
-(void) sendLinkDictionaryFailedToRetrieveAllLinks;

@end

#endif
