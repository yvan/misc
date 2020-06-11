//
//  Link.m
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import "Link.h"

@implementation Link

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

//Constants
+(NSString*)LINK_TYPE_DROPBOX{
    return @"dropbox";
}

+(NSString*)LINK_TYPE_GOOGLE_DRIVE {
    return @"google_drive";
}

@end
