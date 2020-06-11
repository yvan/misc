//
//  FileSystemInit.h
//  Airdoc
//
//  Created by Yvan Scher on 3/24/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "FileSystemInterface.h"
#import "FileSystemAbstraction.h"
#import "LocalStorageManager.h"

@interface FileSystemInit : NSObject

#pragma mark FileSystemLazyLoad

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;

-(FileSystemAbstraction*) fsAbstraction;
-(FileSystemInterface*) fsInterface;

#pragma mark FileSystemInitialization

-(BOOL) fileSystemRootExists;
-(void) cleanFileSystem;
-(void) cleanFileSystemExceptFiles:(NSMutableArray*)filesToNotClean;
-(int) flatEnumerateAndCleanCorruptFilesOnNavigate:(NSString*)pathToEnumerate andCurrentDirectory:(NSArray*)currentDirectory;
-(void) addFourRootFilesToCurrentDirectory;
-(void) addThreeRootCloudFilesToCurrentDirectory;
-(void) checkForAndAddDownloadsFolderInLocal;

@end
