//
//  FileSystemAbstraction.h
//  Hexlist
//
//  Created by Yvan Scher on 3/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

@interface FileSystemAbstraction : NSObject

+(id) sharedFileSystemAbstraction;

#pragma mark NavigationSelectionAbstractions

@property (nonatomic) NSMutableArray* selectedFiles;
@property (nonatomic) NSMutableArray* currentDirectoryChildren;
@property (nonatomic) NSMutableArray* currentDirectoryFilesStack;
@property (nonatomic) File* root;

#pragma mark Array Method Wrappers

-(void) removeObjectFromSelectedFiles:(id)object;
-(void) removeObjectsFromSelectedFilesAtIndexes:(NSMutableIndexSet*)mutableIndexSet;
-(void) removeAllObjectsFromSelectedFilesArray;
-(void) addObjectToSelectedFiles:(id)object;
-(void) addObjectsToSelectedFilesFromArray:(NSArray*)arrayToAddFrom;

#pragma mark FileSystem Abstraction Arrays

-(NSMutableArray*) selectedFiles;
-(NSMutableArray*) currentDirectoryFilesStack;
-(NSMutableArray*) currentDirectoryChildren;

#pragma mark FileSystemAbstracitons

-(void) pushOntoPathStack:(File*)pathComponentToPush;
-(File*) popDirectoryOffFileStack;
-(NSString *) getCurrentDirectoryPath;
-(File*) getRootRealmFile;

@end