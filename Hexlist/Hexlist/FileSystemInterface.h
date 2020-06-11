//
//  FileSystemInterface.h
//
//
//  Created by Yvan Scher on 3/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "File.h"
#import <Foundation/Foundation.h>

@interface FileSystemInterface : NSObject

+(id) sharedFileSystemInterface;

#pragma mark LocationDeterminationMethods

+(RLMRealm*) getFileSystemRealm;

#pragma mark FileSystemRealmMethods

-(void) populateArrayWithFileSystemRealm:(NSMutableArray*)arrayToPopulate forParentDirectory:(File*)parent;
-(void) saveBatchOfFilesToFileSystemRealm:(NSArray*)arrayOfFilesToSave forParentDirectory:(File*)parent;
-(void) saveSingleFileToFileSystemRealm:(File*)fileToSave forParentDirectory:(File*)parent;
-(void) removeBatchOfFilesToFileSystemRealm:(NSArray*)arrayOfFilesToSave forParentDirectory:(File*)parent;
-(void) removeSingleFileFromFileSystemRealm:(File*)fileToRemove forParentDirectory:(File*)parent;

@end