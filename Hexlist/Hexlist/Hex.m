//
//  Hex.m
//  Hexlist
//
//  Created by Roman Scher on 1/13/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "Hex.h"

@implementation Hex

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
+(Hex*)createHexWithUUID:(NSString*)UUID
           AndSenderUUID:(NSString*)senderUUID
           AndSenderName:(NSString*)senderName
       AndHexDescription:(NSString*)hexDescription
             AndHexColor:(NSString*)hexColor {
    
    Hex *hex = [[Hex alloc] init];
    hex.UUID = UUID;
    hex.senderUUID = senderUUID;
    hex.senderName = senderName;
    hex.hexDescription = hexDescription;
    hex.hexColor = hexColor;
    
    return hex;
}

@end
