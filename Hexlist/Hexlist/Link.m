//
//  Link.m
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import "Link.h"

@implementation Link

+ (NSString *)primaryKey {
    return @"UUID";
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

//Constructor
+(Link*)createLinkWithUUID:(NSString*)UUID
                    AndURL:(NSString*)url
        AndLinkDescription:(NSString*)linkDescription
                AndService:(ServiceType)service; {
    
    Link *link = [[Link alloc] init];
    link.UUID = UUID;
    link.url = url;
    link.linkDescription = linkDescription;
    link.service = [AppConstants stringForServiceType:service];
    
    return link;
}

@end
