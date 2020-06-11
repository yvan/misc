//
//  LinkPackage.m
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import "LinkPackage.h"

@implementation LinkPackage

+ (NSString *)primaryKey {
    return @"packageUUID";
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

@end
