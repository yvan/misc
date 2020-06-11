//
//  FileSystemAbstraction.m
//  Airdoc
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

#pragma mark NavigationSelectionAbstractions

-(NSMutableArray*) currentDirectory{
    
    if(!_currentDirectory){_currentDirectory = [[NSMutableArray alloc]init];}
    return _currentDirectory;
}

-(NSMutableArray*) directoryPathStack{
    
    if(!_directoryPathStack){_directoryPathStack = [[NSMutableArray alloc]init];}
    return _directoryPathStack;
}

-(NSMutableArray*) selectedFiles{
    
    if(!_selectedFiles){_selectedFiles = [[NSMutableArray alloc]init];}
    return _selectedFiles;
}

-(NSMutableArray*) filesToSend{
    if(!_filesToSend){_filesToSend = [[NSMutableArray alloc]init];}
    return _filesToSend;
}

-(NSMutableArray*) arrayForLoadObjects{
    if(!_arrayForLoadObjects){_arrayForLoadObjects = [[NSMutableArray alloc] init];}
    return _arrayForLoadObjects;
}

-(NSMutableArray*) arrayForLoadingFiles{
    if(!_arrayForLoadingFiles){_arrayForLoadingFiles = [[NSMutableArray alloc] init];}
    return _arrayForLoadingFiles;
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
//    NSLog(@"removeObjectFromSelectedFiles");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) removeObjectsFromSelectedFilesAtIndexes:(NSMutableIndexSet*)mutableIndexSet{
    [[self selectedFiles] removeObjectsAtIndexes:mutableIndexSet];
//    NSLog(@"removeObjectsFromSelectedFilesAtIndexes");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) removeAllObjectsFromSelectedFilesArray{
    [[self selectedFiles] removeAllObjects];
//    NSLog(@"removeAllObjectsFromSelectedFilesArray");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) addObjectToSelectedFiles:(id)object{
    [[self selectedFiles] addObject:object];
//    NSLog(@"addObjectToSelectedFiles");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

-(void) addObjectsToSelectedFilesFromArray:(NSArray*)arrayToAddFrom{
    [[self selectedFiles] addObjectsFromArray:arrayToAddFrom];
//    NSLog(@"addObjectsToSelectedFilesFromArray");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedFilesUpdated" object:self];
}

// files to send wrapper method.

-(void) removeObjectFromFilesToSend:(id)object{
    [[self filesToSend] removeObject:object];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"filesToSendUpdated" object:self];
}

-(void) removeObjectsFromFilesToSendAtIndexes:(NSMutableIndexSet*)mutableIndexSet{
    [[self filesToSend] removeObjectsAtIndexes:mutableIndexSet];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"filesToSendUpdated" object:self];
}

-(void) removeAllObjectsFromFilesToSendArray{
    [[self filesToSend] removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"filesToSendUpdated" object:self];
}

-(void) addObjectToFilesToSend:(id)object{
    [[self filesToSend] addObject:object];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"filesToSendUpdated" object:self];
}

-(void) addObjectsToFilesToSendFromArray:(NSArray*)arrayToAddFrom{
    [[self filesToSend] addObjectsFromArray:arrayToAddFrom];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"filesToSendUpdated" object:self];
}

// array for loading files

-(void) removeObjectFromArrayForLoadingObjects:(id)object{
    [[self arrayForLoadObjects] removeObject:object];
}

-(void) removeObjectsFRomArrayForLoadingObjects:(NSMutableIndexSet*)mutableIndexSet{
    [[self arrayForLoadObjects] removeObjectsAtIndexes:mutableIndexSet];
}

-(void) removeAllObjectsFromArrayForLoadingObjects{
    [[self arrayForLoadObjects] removeAllObjects];
}

-(void) addObjectToArrayForLoadingObjects:(id)object{
    [[self arrayForLoadObjects] addObject:object];
}

-(void) addObjectsToArrayForLoadingObjectsFromArray:(NSArray *)arrayToAddFrom{
    [[self arrayForLoadObjects] addObjectsFromArray:arrayToAddFrom];
}

// array for load objects

-(void) removeObjectFromArrayForLoadingFiles:(id)object{
    [[self arrayForLoadingFiles] removeObject:object];
}

-(void) removeObjectsFRomArrayForLoadingFiles:(NSMutableIndexSet*)mutableIndexSet{
    [[self arrayForLoadingFiles] removeObjectsAtIndexes:mutableIndexSet];
}

-(void) removeAllObjectsFromArrayForLoadingFiles{
    [[self arrayForLoadingFiles] removeAllObjects];
}

-(void) addObjectToArrayForLoadingFiles:(id)object{
    [[self arrayForLoadingFiles] addObject:object];
}

-(void) addObjectsToArrayForLoadingFilesFromArray:(NSArray *)arrayToAddFrom{
    [[self arrayForLoadingFiles] addObjectsFromArray:arrayToAddFrom];
}


#pragma mark FileSystemAbstracitons

-(BOOL) pushOntoPathStack:(File*) directoryToPush{
    
    if (directoryToPush.isDirectory == YES) {
        [[self directoryPathStack] addObject:directoryToPush];
        NSLog(@"%s DIRECTORY PUSHED ONTO STACK: %@", __PRETTY_FUNCTION__, directoryToPush.name);
        NSLog(@"REDUCE AFTER PUSH: %@", [self reduceStackToPath]);
        return YES;
    }
    NSLog(@"%s YOU LITTLE SHIT, WHY YOU TRY TO PUSH NON-FOLDER ONTO STACK?: %@", __PRETTY_FUNCTION__, directoryToPush.name);
    return NO;
}

-(void) replaceFileInPathStack:(File*) fileToReplace withFile:(File*) newFile{
    [[self directoryPathStack] replaceObjectAtIndex:[[self directoryPathStack] indexOfObject:fileToReplace] withObject:newFile];
}

-(File*) popDirectoryOffPathStack{
    
    File* returnObj = [[self directoryPathStack] lastObject];
    if (returnObj) {
        [[self directoryPathStack] removeLastObject];
        NSLog(@"%s DIRECTORY POPPED OFF OF STACK: %@", __PRETTY_FUNCTION__, returnObj.name);
    }
    return returnObj;
}

-(NSString *) reduceStackToPath{
    
    NSString* path = @"/";
    for(File* file in [self directoryPathStack]){
        path = [path stringByAppendingPathComponent:file.name];
    }
    return path;
}

@end