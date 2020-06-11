//
//  FileSystem.m
//  malamute
//
//  Created by Yvan Scher on 1/3/15.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "File.h"

@implementation File

// 36 char codedname is the primary key

+ (NSString *)primaryKey {
    return @"codedName";
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

// things that we want to be indexed

@end