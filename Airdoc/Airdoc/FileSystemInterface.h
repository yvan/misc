//
//  FileSystemInterface.h
//
//
//  Created by Yvan Scher on 3/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

@interface FileSystemInterface : NSObject

+(id) sharedFileSystemInterface;
@property (nonatomic, strong) dispatch_queue_t sharedFSInterfaceAsync;

#pragma mark DocumentsDirectoryMethods

-(NSString*) getDocumentsDirectory;

#pragma mark FileSystemStateMethods

-(BOOL) isValidPath:(NSString*)rawPath;
-(NSString *) resolveFilePathForPath:(NSString*)rawPath withName:(NSString*)fileName;
-(NSString*) resolveFilePath:(NSString*)filePath excludingUpToDirectory:(NSString*)directoryName;
-(BOOL) filePath:(NSString*)filePath isLocatedInsideDirectoryName:(NSString*)directoryName;
+(NSString*) getRootDirectoryOfFilePath:(NSString*)filePath;
+(BOOL) fileIsRootDirectory:(File*)file;

#pragma mark FileOperationsMethods

-(BOOL) createDirectoryAtPath:(NSString*)rawPath withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes;
-(BOOL) createFileAtPath:(NSString*)rawPath contents:(NSData *)data attributes:(NSDictionary *)attr;
-(BOOL) moveItemAtPath:(NSString*)rawPath toPath:(NSString *)destinationPath;
-(BOOL) copyItemAtPath:(NSString*)rawPath toPath:(NSString *)rawDestinationPath;
-(NSDirectoryEnumerator*) getEnumeratorForPath:(NSString*)rawPath option:(NSDirectoryEnumerationOptions)option;
-(NSArray*) getArrayFromEnumeratorForPath:(NSString*)rawPath option:(NSDirectoryEnumerationOptions)option;
-(NSData*) getDataForfilePath:(NSString*)rawPath;
-(NSURL*) getProperlyFormedNSURLFromPath:(NSString*)rawPath;
-(NSString*) getFileSizeRecursive:(NSString*)rawPath;
-(BOOL) deleteFileAtPath:(NSString*)rawPath;

#pragma mark FileSystemJSONMethods

-(NSMutableArray*) populateArrayWithFileSystemJSON:(NSMutableArray*)arrayToPopulate inDirectoryPath:(NSString*)rawPath;
-(BOOL) saveArrayToFileSystemJSON:(NSMutableArray*)arrayToSave inDirectoryPath:(NSString*)rawPath;
-(BOOL) saveSingleFileToFileSystemJSON:(File*)fileToSave inDirectoryPath:(NSString*)rawPath;
-(BOOL) removeSingleFileFromFileSystemJSON:(File*)fileToRemove inDirectoryPath:(NSString*)rawPath;
-(BOOL) saveBatchOfFilesToFileSystemJSON:(NSArray*)arrayOfFilesToSave inDirectoryPath:(NSString*)rawPath;
-(BOOL) removeBatchOfFilesFromFileSystemJSON:(NSArray*)arrayOfFilesToSave inDirectoryPath:(NSString*)rawPath;

@end
