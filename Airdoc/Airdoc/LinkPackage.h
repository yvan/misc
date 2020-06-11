//
//  LinkPackage.h
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import <Realm/Realm.h>
#import "Link.h"

@interface LinkPackage : RLMObject

@property NSString *packageUUID;
@property NSString *senderUUID;
@property NSString *senderName;
@property RLMArray<Link> *links;
@property NSDate* timestamp;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<LinkPackage>
RLM_ARRAY_TYPE(LinkPackage)
