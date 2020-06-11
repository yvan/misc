//
//  FileSystemAbstraction.h
//  Airdoc
//
//  Created by Yvan Scher on 3/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

@interface FileSystemAbstraction : NSObject

+(id) sharedFileSystemAbstraction;

#pragma mark NavigationSelectionAbstractions

@property (nonatomic) NSMutableArray* currentDirectory;
@property (nonatomic) NSMutableArray* directoryPathStack;
@property (nonatomic) NSMutableArray* selectedFiles;
@property (nonatomic) NSMutableArray* filesToSend;
@property (nonatomic) NSMutableArray* arrayForLoadObjects;
@property (nonatomic) NSMutableArray* arrayForLoadingFiles;

#pragma mark Array Method Wrappers

-(void) removeObjectFromSelectedFiles:(id)object;
-(void) removeObjectsFromSelectedFilesAtIndexes:(NSMutableIndexSet*)mutableIndexSet;
-(void) removeAllObjectsFromSelectedFilesArray;
-(void) addObjectToSelectedFiles:(id)object;
-(void) addObjectsToSelectedFilesFromArray:(NSArray*)arrayToAddFrom;

-(void) removeObjectFromFilesToSend:(id)object;
-(void) removeObjectsFromFilesToSendAtIndexes:(NSMutableIndexSet*)mutableIndexSet;
-(void) removeAllObjectsFromFilesToSendArray;
-(void) addObjectToFilesToSend:(id)object;
-(void) addObjectsToFilesToSendFromArray:(NSArray*)arrayToAddFrom;


#pragma mark FileSystem Abstraction Arrays

-(NSMutableArray*) currentDirectory;
-(NSMutableArray*) directoryPathStack;
-(NSMutableArray*) selectedFiles;
-(NSMutableArray*) filesToSend;
-(NSMutableArray*) arrayForLoadObjects;
-(NSMutableArray*) arrayForLoadingFiles;

#pragma mark FileSystemAbstracitons

-(BOOL) pushOntoPathStack:(File*) directoryToPush;
-(void) replaceFileInPathStack:(File*) fileToReplace withFile:(File*) newFile;
-(File*) popDirectoryOffPathStack;
-(NSString *) reduceStackToPath;

@end
