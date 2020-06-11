//
//  FileSystem.m
//  malamute
//
//  Created by Yvan Scher on 1/3/15.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "Link.h"
#import "AppConstants.h"
#import <Realm/Realm.h>

// This protocol enables typed collections. i.e.:
// RLMArray<File>
RLM_ARRAY_TYPE(File)

@interface File : RLMObject

@property BOOL isDirectory;
@property NSDate* dateCreated;
@property NSString* codedPath;
@property NSString* codedName;
@property NSString* idOnService;
@property NSString* displayPath;
@property NSString* displayName;
@property ServiceType serviceType;
@property RLMArray<File*><File>*children;
@property File* parentFile;

@end


