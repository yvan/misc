//
//  Link.h
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import <Realm/Realm.h>
#import "AppConstants.h"

@interface Link : RLMObject

@property NSString *UUID;
@property NSString *url;
@property NSString *linkDescription;
@property NSString *service;

//Constructor
+(Link*)createLinkWithUUID:(NSString*)UUID
                    AndURL:(NSString*)url
       AndLinkDescription:(NSString*)linkDescription
               AndService:(ServiceType)service;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Link>
RLM_ARRAY_TYPE(Link)
