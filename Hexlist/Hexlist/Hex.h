//
//  Hex.h
//  Hexlist
//
//  Created by Roman Scher on 1/13/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <Realm/Realm.h>
#import "Link.h"

@interface Hex : RLMObject

@property NSString *UUID;
@property NSString *senderUUID;
@property NSString *senderName;
@property NSString *hexDescription;
@property NSString *hexColor;
@property RLMArray<Link*><Link> *links;

@property NSDate* timestamp;

//Constructor
+(Hex*)createHexWithUUID:(NSString*)UUID
           AndSenderUUID:(NSString*)senderUUID
           AndSenderName:(NSString*)senderName
       AndHexDescription:(NSString*)hexDescription
             AndHexColor:(NSString*)hexColor;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Hex>
RLM_ARRAY_TYPE(Hex)
