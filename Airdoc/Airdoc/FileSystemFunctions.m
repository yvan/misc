//
//  FileSystemFunctions.m
//  Airdoc
//
//  Created by Yvan Scher on 3/25/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "FileSystemFunctions.h"

@implementation FileSystemFunctions

+(id) sharedFileSystemFunctions {
    
    static dispatch_once_t pred;
    static FileSystemFunctions* sharedFileSystemFunctions = nil;
    
    dispatch_once(&pred, ^{
        if(sharedFileSystemFunctions == nil){
            sharedFileSystemFunctions = [[self alloc] init];
        }
    });
    
    return sharedFileSystemFunctions;
}

#pragma mark FileSystemLazyLoad

-(FileSystemAbstraction*) fsAbstraction{
    
    if(!_fsAbstraction){
        _fsAbstraction = [FileSystemAbstraction sharedFileSystemAbstraction];
    }
    return _fsAbstraction;
}

-(FileSystemInterface*) fsInterface{
    
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}


#pragma mark MoveWithinLocalFolder

//this method is for calling the move by enumeration on a single file, it only ever gets called
//when the selected count is one so we don't/shouldn't make it work in other cases.
-(void) moveFileAndSubChildrenByEnumeration:(File*)oldFile fromPath:(NSString*)oldPath toPath:(NSString*)newPath {
 
    [self moveByEnumerationWithOldFile:oldFile fromPath:oldPath toPath:newPath andCalledFromInbox:NO];
}

//this method is for calling move by enumeration on an array of files.
-(void) moveFilesLocal:(NSMutableArray*) files calledFromInbox:(BOOL)calledFromInbox{
    
    NSString* storedReduceStackToPath;
    
    if(calledFromInbox)
    {
        storedReduceStackToPath = @"Local";
    }else{
        storedReduceStackToPath = [[self fsAbstraction] reduceStackToPath];
    }
    
    NSMutableIndexSet* filesToCopyFirst = [[NSMutableIndexSet alloc] init];
    
    //take the potentialSubFile and check if it's a subshild.
    for (File* selectedFile in [[self fsAbstraction] selectedFiles]) {
        for(File* potentialSubFile in [[self fsAbstraction] selectedFiles]){
            //if the potential subfile is a child of the selectedfile and not the selected file itself
            //also if the place were moving (storedreducestack) is is stored inside the selected file
            //don't add the index, because we don't want to copy when we're moving inside a directory (we jsut want to move)
            //even if that directory is selected.
            if(([potentialSubFile.path rangeOfString:selectedFile.path].location != NSNotFound) && ![potentialSubFile.path isEqualToString:selectedFile.path] && ([storedReduceStackToPath  rangeOfString:selectedFile.path].location == NSNotFound)) {
                [filesToCopyFirst addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:potentialSubFile]];
                NSLog(@"ADDING INDEX FOR CHILD : %@", potentialSubFile.path);
            }
        }
    }
    
    NSString* capturedReduceStack = [[self fsAbstraction] reduceStackToPath];
    NSMutableIndexSet* indiciesToRemove = [[NSMutableIndexSet alloc] init];
    
    //Pass one to get the direct parents in the selected files array that are one level direct children
    //of the place we're trying to move TO. The parent url paths should be EQUAL to the reduceStackto path.
    for(File* fileToCheck in files){
        
        //if we're trying to move a folder into itself remove that
        //path and don't allow that, it will crash teh fsFunctions
        //methods, PREVENTS A HUGE CRASH
        
        if ([capturedReduceStack rangeOfString: fileToCheck.path].location != NSNotFound) {
            [indiciesToRemove addIndex:[files indexOfObject:fileToCheck]];
        }
        //otherwise leave the file alone.
    }
    
    //remove all files that need removign from selected files.
    [files removeObjectsAtIndexes:indiciesToRemove];
    
    //first send the children that need to be moved (before their parents)
    //these are files that are inside of or subchildren of selected folders
    //they haved to be moved first or else the parent might move and the
    //selected file object will no longer represent the actual location
    //of the file on the disk. they are moving to a new place on their own
    //and as part of their parents, so we're actually copying them.
    
    
    //fileCopy is only needed for non folder files that are subchildren
    //folder files that are subchildren are guaraunteed to get called
    //before their parent, if fileCopy is true for a folder we just
    //don't delete it at the end of its moveByEnumeration method call
    for(File* subChild in files){
        
        if ( ([[ self fsInterface] filePath:subChild.path isLocatedInsideDirectoryName:@"Local"] || [[ self fsInterface] filePath:subChild.path isLocatedInsideDirectoryName:@"Incoming"]) && [[self fsInterface] filePath:storedReduceStackToPath isLocatedInsideDirectoryName:@"Local"] && ![storedReduceStackToPath isEqualToString:subChild.parentURLPath] && [filesToCopyFirst containsIndex:[files indexOfObject:subChild]]) {
            
            File* tempFileCopy = [[File alloc]initWithName:subChild.name andPath:subChild.path andDate:[NSDate date] andRevision:subChild.revision andDirectoryFlag:subChild.isDirectory andBoxId:subChild.boxid];
            
            //fileCopy is for a subchild that is also being moved as part of a group with one of it's parents
            //we copy it first to its new place and then the subchild version of it gets moved appropriatly later along w/ parent
            [self moveByEnumerating:tempFileCopy withStoredReduceStack:storedReduceStackToPath calledFromInbox:calledFromInbox andFileCopy:YES];
            NSLog(@"COPY IS YES");
            
            UIBackgroundTaskIdentifier bgTask = 0;
            bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            }];
        }
    }
    
    //move the non subchildren files/folders, these are top level files
    //that will starightup just be moved.
    
    for(File* topLevelFile in files){
        
        //if were in local or incoming (inbox folder name is reserved) and were moving into local and we're not trying to move a file to the same place it already is.
        if ( ([[ self fsInterface] filePath:topLevelFile.path isLocatedInsideDirectoryName:@"Local"] || [[ self fsInterface] filePath:topLevelFile.path isLocatedInsideDirectoryName:@"Incoming"]) && [[self fsInterface] filePath:storedReduceStackToPath isLocatedInsideDirectoryName:@"Local"] && ![storedReduceStackToPath isEqualToString:topLevelFile.parentURLPath] && ![filesToCopyFirst containsIndex:[files indexOfObject:topLevelFile]]) {
            
            File* tempFileCopy = [[File alloc]initWithName:topLevelFile.name andPath:topLevelFile.path andDate:[NSDate date] andRevision:topLevelFile.revision andDirectoryFlag:topLevelFile.isDirectory andBoxId:topLevelFile.boxid];
            
            //fileCopy is for a subchild that is also being moved as part of a group with one of it's parents
            //we copy it first to its new place and then the subchild version of it gets moved appropriatly later along w/ parent
            [self moveByEnumerating:tempFileCopy withStoredReduceStack:storedReduceStackToPath calledFromInbox:calledFromInbox andFileCopy:NO];
            
            UIBackgroundTaskIdentifier bgTask = 0;
            bgTask= [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            }];
        }
    }
}

//FOR MOVING FOLDERS w/ THE SAME NAME
// intended for us within the local directory. do not need a special upload by enumeration method
// for dropbox, we can just use the move by enumeration to put things into a special invisible directory
// this will create teh JSON files for that thing. Then once that's done we will queue a dropbox download
// from that folder.

//CANT get rid of the while autonaming loops because we could be moving multiple things that have the same name.

-(void) moveByEnumerating:(File*)fileorfolderToMove withStoredReduceStack:(NSString*)storedReduceStack calledFromInbox:(BOOL)calledFromInbox andFileCopy:(BOOL)fileCopy{
    
    storedReduceStack =[[[storedReduceStack stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //the thing we're moving is a directory
    if(fileorfolderToMove.isDirectory){
        
        File* newDir = [[File alloc]initWithName:fileorfolderToMove.name andPath:[storedReduceStack stringByAppendingPathComponent: fileorfolderToMove.name] andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:YES andBoxId:@"-1"];
        
        //For a folder we don't worry about path extensions
        NSString* stringBaseForFile = newDir.name;
        NSString* newPathForFile = [storedReduceStack stringByAppendingPathComponent:stringBaseForFile];
        
        int number = 1;
        //firgure out of the path exists in the directory we are moving TO
        while(!calledFromInbox && [[self fsInterface] isValidPath:newPathForFile]){
            newPathForFile = [storedReduceStack stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%d", stringBaseForFile, @"-", number]];
            number++;
            //figure out if the directory exists in teh path we are moving FROM (we don't want to set a temporary name that would override an existing path)
            while(!calledFromInbox && [[self fsInterface] isValidPath:[[fileorfolderToMove.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[newPathForFile lastPathComponent]]]){
                
                newPathForFile = [[fileorfolderToMove.path stringByDeletingLastPathComponent]  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%d", stringBaseForFile, @"-", number]];
                 number++;
            }
        }
        
        newDir.name = [newPathForFile lastPathComponent];
        newDir.path = newPathForFile;
        
        //this just does a rename in place of the old file.
        //it's not actually a move to the new location.
        NSString *newDirectoryName = [newPathForFile lastPathComponent];
        NSString *oldPath = fileorfolderToMove.path;
        NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newDirectoryName];
        [[self fsInterface] moveItemAtPath:oldPath toPath:newPath];
        
        NSLog(@"REMOVING FROM FILESYSTEM.JSON: %@",fileorfolderToMove.name);
        NSLog(@"...IN DIRECTORY: %@", [fileorfolderToMove.path stringByDeletingLastPathComponent]);
        if(!fileCopy){
            [[self fsInterface] removeSingleFileFromFileSystemJSON:fileorfolderToMove inDirectoryPath:fileorfolderToMove.parentURLPath];
        }
        
        // set the attributes for the old fileOrFolderToMove
        // to the new name but still in the old spot
        fileorfolderToMove.name = newDir.name;
        fileorfolderToMove.path = newPath;
        
        NSLog(@"NEWDIRULR: %@", newDir.path);
        [[self fsInterface] createDirectoryAtPath:newDir.path withIntermediateDirectories:NO attributes:nil];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:newDir.parentURLPath];
        
        NSLog(@"PRE PRINT FOR ENUMERATOR: %@", fileorfolderToMove.path);
        
        for (NSString* path in [[self fsInterface] getArrayFromEnumeratorForPath:fileorfolderToMove.path option:0]){
            
            NSString *filename = [[path lastPathComponent] stringByRemovingPercentEncoding];
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:[[[[[self fsInterface] getDocumentsDirectory]stringByAppendingPathComponent:path] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isDirectory:&isDirectory];
            NSArray *parts = [fileorfolderToMove.parentURLPath componentsSeparatedByString:@"/"];
            NSString* parentNameForExlcusion = [parts lastObject];
            NSLog(@"PARENT NAME FOR EXCLUSION: %@", parentNameForExlcusion);
            
            NSString* pathForNewLocation = [storedReduceStack stringByAppendingPathComponent:[[[self fsInterface] resolveFilePath:path excludingUpToDirectory:[parentNameForExlcusion stringByRemovingPercentEncoding]] stringByRemovingPercentEncoding]];
            
            NSLog(@"THE PATH: %@", pathForNewLocation);
            
            if(isDirectory){
                
                File* newDir = [[File alloc]initWithName:[filename stringByRemovingPercentEncoding] andPath:pathForNewLocation andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:YES andBoxId:@"-1"];
                
                //For a folder we don't worry about path extensions
                NSString* stringBaseForFile = newDir.name;
                NSString* newPathForFile = [[pathForNewLocation stringByDeletingLastPathComponent] stringByAppendingPathComponent:stringBaseForFile];
                
                int number = 1;
                while(!calledFromInbox && [[self fsInterface] isValidPath:newPathForFile]){
                    newPathForFile = [[pathForNewLocation stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%d", stringBaseForFile, @"-", number]];
                    number++;
                }
                
                newDir.name = [newPathForFile lastPathComponent];
                newDir.path = newPathForFile;
                
                NSLog(@"PREMOVE LOG 1 %@", pathForNewLocation);
                [[self fsInterface] createDirectoryAtPath:pathForNewLocation withIntermediateDirectories:NO attributes:nil];
                [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:[pathForNewLocation stringByDeletingLastPathComponent]];
                
            }else{
                
                if(![filename isEqualToString:@".filesystem.json"]){
                    
                    NSLog(@"PATH FOR NEW LOCATION : %@", pathForNewLocation);
                    File* newFile = [[File alloc] initWithName:[filename stringByRemovingPercentEncoding] andPath:pathForNewLocation andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:NO andBoxId:@"-1"];
                    
                    //get the name w/o the extension
                    NSString* stringBaseForFile = [newFile.name stringByDeletingPathExtension];
                    //get the full extected path to the new file including the extension.
                    NSString* newPathForFile = [[[pathForNewLocation stringByDeletingLastPathComponent] stringByAppendingPathComponent:stringBaseForFile] stringByAppendingPathExtension:[newFile.name pathExtension]];
                    
                    int number = 1;
                    while(!calledFromInbox && [[self fsInterface] isValidPath:newPathForFile]){
                        newPathForFile = [[pathForNewLocation stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%d.%@", stringBaseForFile, @"-", number, [newFile.name pathExtension]]];
                        number++;
                    }
                    
                    newFile.name = [newPathForFile lastPathComponent];
                    newFile.path = newPathForFile;
                    
                    //copies instead of moves
                    if(fileCopy){
                        [[self fsInterface] copyItemAtPath:path toPath:[[self fsInterface] resolveFilePath:newFile.path excludingUpToDirectory:@"Documents"]];
                    }else{
                        [[self fsInterface] moveItemAtPath:path toPath:[[self fsInterface] resolveFilePath:newFile.path excludingUpToDirectory:@"Documents"]];
                    }
                    [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:[newFile.path stringByDeletingLastPathComponent]];
                }
            }
        }
    
    //if the file or folder is not a directory
    }else{
        
        File* newFile = [[File alloc] initWithName:fileorfolderToMove.name andPath:[storedReduceStack stringByAppendingPathComponent:fileorfolderToMove.name] andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:NO andBoxId:@"-1"];
        
        //get the name w/o the extension
        NSString* stringBaseForFile = [newFile.name stringByDeletingPathExtension];
        //get the full extected path to the new file including the extension.
        NSString* newPathForFile = [[storedReduceStack stringByAppendingPathComponent:stringBaseForFile] stringByAppendingPathExtension:[newFile.name pathExtension]];
        
        int number = 1;
        while(!calledFromInbox && [[self fsInterface] isValidPath:newPathForFile]){
            newPathForFile = [storedReduceStack stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%d.%@", stringBaseForFile, @"-", number, [newFile.name pathExtension]]];
            number++;
        }
        
        NSLog(@"MOVING FILE TO NEW PATH: %@", newPathForFile);
        
        newFile.name = [newPathForFile lastPathComponent];
        newFile.path = newPathForFile;
        
        if(fileCopy){
            [[self fsInterface] copyItemAtPath:fileorfolderToMove.path toPath:[storedReduceStack stringByAppendingPathComponent:newFile.name]];
        }else{
            [[self fsInterface] moveItemAtPath:fileorfolderToMove.path toPath:[storedReduceStack stringByAppendingPathComponent:newFile.name]];
        }
        
        //we do this because we CANNOT store encoded urls in filesystem.json
        
        [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:storedReduceStack];
        //if file copy is not set destroy the json.
        if(!fileCopy){
            [[self fsInterface] removeSingleFileFromFileSystemJSON:fileorfolderToMove inDirectoryPath:fileorfolderToMove.parentURLPath];
        }
    }
    
    //if fileCopy is NO then destroy teh original
    //this is a top level file
    //if fileCopy is YES then keep the original
    //this is a subchild about to be moved.
    if(!fileCopy){
        //clean up the old selected file so it's remnant filesystem.json files don't just hang around
        [[self fsInterface] deleteFileAtPath:fileorfolderToMove.path];
        [[self fsInterface] removeSingleFileFromFileSystemJSON:fileorfolderToMove inDirectoryPath:fileorfolderToMove.parentURLPath];
    }

    
    [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    //send a notification to the homeview to reload the collectionview.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
}


//FOR RENAMING FOLDERS
//intended for use on a single file/folder that needs to be "moved" to a place with a new name
//this method is for renaming folders/files (mostly just folders, because they affect the metadata
//of all their subchildren and all that metadata needs to be rewritten we iterate though it
//and rewrite all that data, You'll notice this method doesn't have any while loops to rename the
//file/folder because we caheck for it on the move operation/rename operation and don't let the user get this far.
-(void) moveByEnumerationWithOldFile:(File*)fileorfolderToMove fromPath:(NSString*)oldPath toPath:(NSString*)newPath andCalledFromInbox:(BOOL)calledFromInbox {
    
    NSLog(@"moveByEnumerationWithOldFile");
    
    oldPath = [oldPath stringByRemovingPercentEncoding];
    newPath = [newPath stringByRemovingPercentEncoding];
    
    //the thing we're moving is a directory
    if(fileorfolderToMove.isDirectory){
        
        File* newDir = [[File alloc]initWithName:[newPath lastPathComponent] andPath:newPath andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:YES andBoxId:@"-1"];
        
        //removes the old folder we're moving from the JSON in it's parent.
        //basically get rid of the old index for that file.
        NSLog(@"REMOVING FROM FILESYSTEM.JSON: %@",fileorfolderToMove.name);
        NSLog(@"...IN DIRECTORY: %@", [fileorfolderToMove.path stringByDeletingLastPathComponent]);
        [[self fsInterface] removeSingleFileFromFileSystemJSON:fileorfolderToMove inDirectoryPath:fileorfolderToMove.parentURLPath];
        
        //set the new directory/renamed directory (same thing) into the metadata so it appears in its parent.
        NSLog(@"NEWDIRULR: %@ SAVED IN %@", newDir.path,newDir.parentURLPath);
        [[self fsInterface] createDirectoryAtPath:newDir.path withIntermediateDirectories:NO attributes:nil];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:newDir.parentURLPath];
        
        NSLog(@"PRE PRINT FOR ENUMERATOR: %@", fileorfolderToMove.path);
        for (NSString* path in [[self fsInterface] getArrayFromEnumeratorForPath:fileorfolderToMove.path option:0]){
            
            NSString *filename = [path lastPathComponent];
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:[[[[[self fsInterface] getDocumentsDirectory]stringByAppendingPathComponent:path] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isDirectory:&isDirectory];            filename = [filename stringByRemovingPercentEncoding];
            NSArray *parts = [fileorfolderToMove.path componentsSeparatedByString:@"/"];
            NSString* parentNameForExlcusion = [parts lastObject];
            
            NSLog(@"EXCLUDING PARENT NAME %@", parentNameForExlcusion);
            
            NSString* pathForNewLocation = [newPath stringByAppendingPathComponent:[[[self fsInterface] resolveFilePath:path excludingUpToDirectory:parentNameForExlcusion] stringByRemovingPercentEncoding]];
            
            NSLog(@"THE NEW PATH IN ENUMERATOR LOOP: %@", pathForNewLocation);
            
            if(isDirectory){
                
                File* newDir = [[File alloc]initWithName:filename andPath:pathForNewLocation andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:YES andBoxId:@"-1"];
                
                [[self fsInterface] createDirectoryAtPath:pathForNewLocation withIntermediateDirectories:NO attributes:nil];
                [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:[pathForNewLocation stringByDeletingLastPathComponent]];
                
            }else{
                
                if(![filename isEqualToString:@".filesystem.json"]){//if the file is NOT the filesystemjson file process it.
                    
                    File* newFile = [[File alloc] initWithName:filename andPath:pathForNewLocation andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:NO andBoxId:@"-1"];
                    
                    NSLog(@"TO PATH: %@", newFile.path);
                    [[self fsInterface] moveItemAtPath:path toPath:newFile.path];
                    [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:[newFile.path stringByDeletingLastPathComponent]];
                }
            }
        }
        
        //if the file or folder is not a directory
    }else{
        
        File* newFile = [[File alloc] initWithName:[newPath lastPathComponent] andPath:newPath andDate:[NSDate date] andRevision:fileorfolderToMove.revision andDirectoryFlag:NO andBoxId:@"-1"];
        
        [[self fsInterface] moveItemAtPath:fileorfolderToMove.path toPath:[[newPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile.name]];
        
        NSLog(@"SAVING FILE TO JSON: %@", newFile.name);
        NSLog(@"SAVING FILE TO JSON IN: %@", [newPath stringByDeletingLastPathComponent]);
        //we do this because we CANNOT store encoded urls in filesystem.json
        
        [[self fsInterface] saveSingleFileToFileSystemJSON:newFile inDirectoryPath:[newPath stringByDeletingLastPathComponent]];
        [[self fsInterface] removeSingleFileFromFileSystemJSON:fileorfolderToMove inDirectoryPath:fileorfolderToMove.parentURLPath];
    }
    
    
    //clean up this selected file
    [[self fsInterface] deleteFileAtPath:fileorfolderToMove.path];
    
    [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
    
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    
    //send a notification to the homeview to reload the collectionview.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
}


////truncates a name that is too long
//-(File*) truncateFileNameToFitLimits:(File*)fileToTruncateName {
//    
//    //if the path overall or the name is too long (past the limits) we need to reduce them.
//    //we may have some implicit protection becasue on most filesystems (dropbox probably)
//    //the length of file names is limited.
//    
//    //first if checks if the name is too long, if is we just truncate it so that it won't crash dropbox....has to be a better
//    //way like only encoding things EXCEPT japanese characters or other characters.
//    if([[[fileToTruncateName.name stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] length] > 255){
//        
//        NSString* extension = [fileToTruncateName.name pathExtension];
//        NSString* nameWithoutExten = [fileToTruncateName.name stringByDeletingPathExtension];
//        
//        fileToTruncateName.name = [[[[fileToTruncateName.name stringByRemovingPercentEncoding] substringToIndex:(nameWithoutExten.length-1-extension.length-1)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  stringByAppendingPathExtension:extension];
//        
//        fileToTruncateName.name = [fileToTruncateName.name stringByRemovingPercentEncoding];
//        
//        fileToTruncateName.path = [[fileToTruncateName.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileToTruncateName.name];
//        
//        fileToTruncateName.parentURLPath = [fileToTruncateName.path stringByDeletingLastPathComponent];
//    }
//    
//    return fileToTruncateName;
//}
//
////truncates a path that is too long, first by attempting totruncate the name by half
////then by
//-(File*) truncateFilePathToFitLimits:(File*)fileToTruncatePath {
//    
//    //If a path is too long we need to truncate the name again, we can't really truncate the parents of a filepath safely and easily.
//    //(we can but it's overcomplicated and confusing and it would be weird to do an operation on a parent to save a child).
//    if([[[fileToTruncatePath.path stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] length] > 1024){
//        
//        fileToTruncatePath.path = [[[[fileToTruncatePath.path stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileToTruncatePath.name];
//        
//        fileToTruncatePath.path = [fileToTruncatePath.path stringByRemovingPercentEncoding];
//        
//        fileToTruncatePath.parentURLPath = [fileToTruncatePath.path stringByDeletingLastPathComponent];
//    }
//    
//    return fileToTruncatePath;
//}

//convert an array of file loading objects "FileLoadingObject.h"
//into an array of file objects "File.h"
-(NSMutableArray*) convertFileLoadingObjectsIntoFileObjects:(NSMutableArray*)fileLoadingObjects {
    NSMutableArray* arrayToReturn = [[NSMutableArray alloc] init];
    for(FileLoadingObject* fileLoadingObj in fileLoadingObjects){
        [arrayToReturn addObject:fileLoadingObj.file];
    }
    return arrayToReturn;
}

//sort an array of stuff.
-(NSArray*) sortFoldersOrFiles: (NSMutableArray*)folderOrFilesArray {
    NSArray *peersArraySorted = [folderOrFilesArray sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [((File*)obj1).name caseInsensitiveCompare:((File*)obj2).name];
    }];
    return peersArraySorted;
}

@end
