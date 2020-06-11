//
//  sendLinksFromServiceManagerDelegate.h
//  Hexlist
//
//  Created by Yvan Scher on 10/18/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#ifndef Hexlist_sendLinksFromServiceManagerDelegate_h
#define Hexlist_sendLinksFromServiceManagerDelegate_h

@protocol SendLinksFromServiceManagerDelegate <NSObject>

-(void) sendLinkDictionaryFromServiceManagerDelegate:(NSDictionary*)linksToSend;
-(void) sendLinkDictionaryFailedToRetrieveAllLinks:(NSString*)stringToDisplay;

@end

#endif
