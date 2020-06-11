//
//  Location.m
//  Hexlist
//
//  Created by Roman Scher on 1/23/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "Location.h"

@implementation Location

+ (NSString *)primaryKey {
    return @"hexLocation";
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
+(Location*)createLocationWithHexLocation:(HexLocationType)hexLocationType {
    
    Location *location = [[Location alloc] init];
    location.hexLocation = [AppConstants stringForHexLocationType:hexLocationType];
    
    return location;
}

@end
