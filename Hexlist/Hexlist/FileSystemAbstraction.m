//
//  FileSystemAbstraction.m
//  Hexlist
//
//  Created by Yvan Scher on 3/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "FileSystemAbstraction.h"

@implementation FileSystemAbstraction

#pragma mark FilSystemAbstractionInit

+(id) sharedFileSystemAbstraction {
    
    static dispatch_once_t pred;
    static FileSystemAbstraction* sharedFileSystemAbstraction = nil;
    
    dispatch_once(&pred, ^{
        if(sharedFileSystemAbstraction == nil){
            sharedFileSystemAbstraction = [[self alloc] init];
        }
    });
    
    return sharedFileSystemAbstraction;
}

// do not instantiate if it doesn't exist.
// it needs to be isntatiated in filesysteminit
// to add services to it.

-(File*) getRootRealmFile {
    return _root;
}

#pragma mark NavigationSelectionAbstractions

-(NSMutableArray*) currentDirectoryChildren{
    if(!_currentDirectoryChildren){_currentDirectoryChildren = [[NSMutableArray alloc]init];}
    return _currentDirectoryChildren;
}

-(NSMutableArray*) currentDirectoryFilesStack{
    if(!_currentDirectoryFilesStack){_currentDirectoryFilesStack = [[NSMutableArray alloc]init];}
    return _currentDirectoryFilesStack;
}

-(NSMutableArray*) selectedFiles{
    if(!_selectedFiles){_selectedFiles = [[NSMutableArray alloc]init];}
    return _selectedFiles;
}

#pragma mark SelectedFiles Method Wrappers

//these wrappers were only written for the selected files array
//and only for operations that can cahnge the structure of the array
//operations on other arrays and operations that don't change the
//selected files array didn't get wrappers because. deal w/ it.

//(•_•)
//( •_•)>⌐■-■
//(⌐■_■)

-(void) removeObjectFromSelectedFiles:(id)object{
    [[self selectedFiles] removeObject:object];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) removeObjectsFromSelectedFilesAtIndexes:(NSMutableIndexSet*)mutableIndexSet{
    [[self selectedFiles] removeObjectsAtIndexes:mutableIndexSet];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) removeAllObjectsFromSelectedFilesArray{
    [[self selectedFiles] removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) addObjectToSelectedFiles:(id)object{
    [[self selectedFiles] addObject:object];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) addObjectsToSelectedFilesFromArray:(NSArray*)arrayToAddFrom{
    [[self selectedFiles] addObjectsFromArray:arrayToAddFrom];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

#pragma mark FileSystemAbstracitons

-(void) pushOntoPathStack:(File*)fileToPush{
    [[self currentDirectoryFilesStack] addObject:fileToPush];
}

-(File*) popDirectoryOffFileStack {
    File* returnFile = [[self currentDirectoryFilesStack] lastObject];
    [[self currentDirectoryFilesStack] removeLastObject];
    return returnFile;
}

-(NSString *) getCurrentDirectoryPath {
    NSString* path = @"/";
    for (File* pathFile in [self currentDirectoryFilesStack]) {
        path = [path stringByAppendingPathComponent:pathFile.displayName];
    }
    return path;
}

@end