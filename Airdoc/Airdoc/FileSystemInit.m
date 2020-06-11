//
//  FileSystemInit.m
//  Airdoc
//
//  Created by Yvan Scher on 3/24/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "FileSystemInit.h"

@implementation FileSystemInit

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

#pragma mark FileSystemInitialization

-(BOOL) fileSystemRootExists{
    
    NSString *fileSystemPath = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:@".filesystem.json"];
    return [[NSFileManager defaultManager] fileExistsAtPath:fileSystemPath];
}

//only cleans files at the top level of the GoogleDrive
//or Dropbox folder

-(void) cleanFileSystem{
    
    for (NSString* path in [[self fsInterface] getArrayFromEnumeratorForPath:@"/GoogleDrive" option:NSDirectoryEnumerationSkipsSubdirectoryDescendants]){
        NSString* lastComponent = [path lastPathComponent];
        [[self fsInterface] deleteFileAtPath:[@"/GoogleDrive" stringByAppendingPathComponent:lastComponent]];
    }
    
    for (NSString* path in [[self fsInterface] getArrayFromEnumeratorForPath:@"/Dropbox" option:NSDirectoryEnumerationSkipsSubdirectoryDescendants]){
        NSString* lastComponent = [path lastPathComponent];
        [[self fsInterface] deleteFileAtPath:[@"/Dropbox" stringByAppendingPathComponent:lastComponent]];
    }
    
    for (NSString* path in [[self fsInterface] getArrayFromEnumeratorForPath:@"/ZippedFilePackages" option:NSDirectoryEnumerationSkipsSubdirectoryDescendants]){
        NSString* lastComponent = [path lastPathComponent];
        [[self fsInterface] deleteFileAtPath:[@"/ZippedFilePackages" stringByAppendingPathComponent:lastComponent]];
    }
    
    [[[self fsAbstraction] currentDirectory] removeAllObjects];
}


//clean filesystem except for certain files, it takes a list of file objects?
//only cleans or exempts from cleaning files at the top level of the GoogleDrive
//or Dropbox folder

-(void) cleanFileSystemExceptFiles:(NSMutableArray*)filesToNotClean {
    
    BOOL shouldWipeEnvoyUploadsGD = YES;
    BOOL shouldWipeEnvoyUploadsDB = YES;
    BOOL envoyUploadsFoundInDB = NO;
    BOOL envoyUploadsFoundInGD = NO;
    
    //these will be arrays of files/folders that are in the top level withing Google drive and dropbox
    NSMutableArray* dropboxTopLevelItemsToNotDestroy = [[NSMutableArray alloc] init];
    NSMutableArray* googleDriveTopLevelItemsToNotDestroy = [[NSMutableArray alloc] init];
    
    //add all paths athat are subpaths of googledrive and dropbox
    for(File* fileObjectLoading in filesToNotClean){
        
        if ([[self fsInterface] filePath:fileObjectLoading.path isLocatedInsideDirectoryName:@"/GoogleDrive"]) {
            [googleDriveTopLevelItemsToNotDestroy addObject:fileObjectLoading.path];
             shouldWipeEnvoyUploadsGD = NO;
        }
        
        if ([[self fsInterface] filePath:fileObjectLoading.path isLocatedInsideDirectoryName:@"/Dropbox"]) {
            [dropboxTopLevelItemsToNotDestroy addObject:fileObjectLoading.path];
            shouldWipeEnvoyUploadsDB = YES;
        }
    }
    
    //if one of the paths in google drive is a subpath of one of the stored google drive paths
    for (NSString* topLevelPath in [[self fsInterface] getArrayFromEnumeratorForPath:@"/GoogleDrive" option:NSDirectoryEnumerationSkipsSubdirectoryDescendants]) {
        
        if ([[topLevelPath lastPathComponent] isEqualToString:@"Envoy Uploads"]) {
            envoyUploadsFoundInGD = YES;
        }
        //check each path in dropboxTopLevelItemsToNotDestroy
        //if those paths contain one of the paths from above then
        //we know to NOT delete that top level path from GoogleDrive
        //enumerate
        BOOL topLevelPathCanBeDeleted = YES;
        //for each path that is being loaded
        for (NSString* anyPath in dropboxTopLevelItemsToNotDestroy) {
            //if that loading path does not contains a top level paths from dropbox
            if ([anyPath rangeOfString:topLevelPath].location != NSNotFound) {
                topLevelPathCanBeDeleted = NO;
            }
        }
        // if we didn't match this top level path (it was loading something at a sub path), then destroy it.
        if (topLevelPathCanBeDeleted) {
            [[self fsInterface] deleteFileAtPath:topLevelPath];
        }
    }
    
    for (NSString* topLevelPath in [[self fsInterface] getArrayFromEnumeratorForPath:@"/Dropbox" option:NSDirectoryEnumerationSkipsSubdirectoryDescendants]) {
        
        if ([[topLevelPath lastPathComponent] isEqualToString:@"Envoy Uploads"]) {
            envoyUploadsFoundInDB = YES;
        }
        //check each path in dropboxTopLevelItemsToNotDestroy
        //if those paths contain one of the paths from above then
        //we know to NOT delete that top level path from GoogleDrive
        //enumerate
        BOOL topLevelPathCanBeDeleted = YES;
        //for each path that is being loaded
        for (NSString* anyPath in dropboxTopLevelItemsToNotDestroy) {
            //if that loading path does not contains a top level paths from dropbox
            if ([anyPath rangeOfString:topLevelPath].location != NSNotFound) {
                topLevelPathCanBeDeleted = NO;
            }
        }
        // if we didn't match this top level path (it was loading something at a sub path), then destroy it.
        if (topLevelPathCanBeDeleted) {
            [[self fsInterface] deleteFileAtPath:topLevelPath];
        }
    }
    
    //recreate the dropbox folder if it was wiped and was originaly
    //there, we need to check if it was originally there, because
    //we don't want it to be created if it was destroyed by the user.
    if (shouldWipeEnvoyUploadsDB && envoyUploadsFoundInDB){
        File* newEnvoyUploadsFolderDB = [[File alloc] initWithName:@"Envoy Uploads" andPath:[@"/Dropbox" stringByAppendingPathComponent:@"Envoy Uploads"] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newEnvoyUploadsFolderDB inDirectoryPath:@"/Dropbox"];
    }
    
    //recreate the googledrive folder if it was wiped and was originaly
    //there, we need to check if it was originally there, because
    //we don't want it to be created if it was destroyed by the user.
    
    if (shouldWipeEnvoyUploadsGD && envoyUploadsFoundInGD) {
        File* newEnvoyUploadsFolderGD = [[File alloc] initWithName:@"Envoy Uploads" andPath:[@"/GoogleDrive" stringByAppendingPathComponent:@"Envoy Uploads"] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newEnvoyUploadsFolderGD inDirectoryPath:@"/GoogleDrive"];
    }
}

// returns the current directory to the caller.

-(void) addFourRootFilesToCurrentDirectory{
    
    NSMutableArray* temporaryCurrentDir = [[NSMutableArray alloc]init];
    
    // add dropbox
    File *dropbox = [[File alloc] initWithName:@"Dropbox"
                                andPath:@"/Dropbox"
                                andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    [[self fsInterface] createDirectoryAtPath:@"/Dropbox" withIntermediateDirectories:NO attributes:nil];
    [temporaryCurrentDir  addObject:dropbox];
    
    //add google drive
    File *gDrive = [[File alloc] initWithName:@"GoogleDrive"
                            andPath:@"/GoogleDrive"
                            andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    [[self fsInterface] createDirectoryAtPath:@"/GoogleDrive" withIntermediateDirectories:NO attributes:nil];
    [temporaryCurrentDir  addObject:gDrive];

    //add tempholding and incoming and zippedFilePackages to hold our zip files before they get sent
    [[self fsInterface] createDirectoryAtPath:@"/Incoming" withIntermediateDirectories:NO attributes:nil];
//    [[self fsInterface] createDirectoryAtPath:@"/Tempholding" withIntermediateDirectories:NO attributes:nil];
    [[self fsInterface] createDirectoryAtPath:@"/ZippedFilePackages" withIntermediateDirectories:NO attributes:nil];
    
    //add Local
    File *local = [[File alloc] initWithName:@"Local"
                            andPath:@"/Local"
                            andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    [[self fsInterface] createDirectoryAtPath:@"/Local" withIntermediateDirectories:NO attributes:nil];
    [temporaryCurrentDir  addObject:local];
    
    //write all of these into the filesystem.
    [[self fsInterface] saveArrayToFileSystemJSON:temporaryCurrentDir  inDirectoryPath:@"/"];
    [temporaryCurrentDir  removeAllObjects];
    
    [[self fsAbstraction] pushOntoPathStack:local];
    
    //create sent to me
    File *sentToMe = [[File alloc] initWithName:@"sent to me"
                                andPath:[[[self fsAbstraction] reduceStackToPath] stringByAppendingPathComponent:@"sent to me"]
                                andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    [[self fsInterface] createDirectoryAtPath:[[[self fsAbstraction] reduceStackToPath] stringByAppendingPathComponent:@"sent to me"]
                        withIntermediateDirectories:NO attributes:nil];
    [temporaryCurrentDir  addObject:sentToMe];
    
    //create downloads
    File* downloadFolder = [[File alloc] initWithName:@"downloads" andPath:[[[self fsAbstraction] reduceStackToPath] stringByAppendingPathComponent:@"downloads"] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    [[self fsInterface] createDirectoryAtPath:[[[self fsAbstraction] reduceStackToPath] stringByAppendingPathComponent:@"downloads"] withIntermediateDirectories:NO attributes:nil];
    [temporaryCurrentDir addObject:downloadFolder];
    
    //save downloads and sent to me to json
    [[self fsInterface] saveArrayToFileSystemJSON:temporaryCurrentDir  inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
    [temporaryCurrentDir  removeAllObjects];
    
    [[self fsAbstraction] popDirectoryOffPathStack];
}


-(void) addThreeRootCloudFilesToCurrentDirectory {
    
    NSMutableArray* temporaryCurrentDir = [[NSMutableArray alloc]init];
    
    File *dropbox = [[File alloc] initWithName:@"Dropbox"
                                        andPath:@"/Dropbox"
                                       andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    [[self fsInterface] createDirectoryAtPath:@"/Dropbox" withIntermediateDirectories:NO attributes:nil];
    [temporaryCurrentDir  addObject:dropbox];
    
    File *gDrive = [[File alloc] initWithName:@"GoogleDrive"
                                       andPath:@"/GoogleDrive"
                                      andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    [[self fsInterface] createDirectoryAtPath:@"/GoogleDrive" withIntermediateDirectories:NO attributes:nil];
    [temporaryCurrentDir  addObject:gDrive];
    
    [[self fsInterface] saveArrayToFileSystemJSON:temporaryCurrentDir inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
}

// checks to see if the downloads folder
// is available locally and if it isn't
// it creates the folder and saves it
// in the JSON.
// since this only ever gets called from the
// cloud we don't need to worry about reloading
// the collectionviewi in real time to see the
// file appear, it will be there.

-(void) checkForAndAddDownloadsFolderInLocal {
    
    //first check for the downloads folder
    if(![[self fsInterface] isValidPath:[@"/Local" stringByAppendingPathComponent:@"downloads"]]){
        NSMutableArray* temporaryCurrentDir = [[NSMutableArray alloc]init];
        File* downloadFolder = [[File alloc] initWithName:@"downloads" andPath:[@"/Local" stringByAppendingPathComponent:@"downloads"] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
        [[self fsInterface] createDirectoryAtPath:[@"/Local" stringByAppendingPathComponent:@"downloads"] withIntermediateDirectories:NO attributes:nil];
        [temporaryCurrentDir addObject:downloadFolder];
        [[self fsInterface] saveArrayToFileSystemJSON:temporaryCurrentDir inDirectoryPath:@"/Local"];
    }
}

// enumerates a directory on the user's navivgate
// that cleans the file system

-(int) flatEnumerateAndCleanCorruptFilesOnNavigate:(NSString*)pathToEnumerate andCurrentDirectory:(NSArray*)currentDirectory{
    
    NSLog(@"TRIGGERS AT ALL");
    
    int corruptcount = 0;
    //create a dictionary that will map file paths to file objects
    NSMutableDictionary* currentDirectoryFiles = [[NSMutableDictionary alloc] init];
    for (File* file in currentDirectory) {
        [currentDirectoryFiles setObject:file forKey:file.path];
    }
    
    NSMutableDictionary* loadingFiles = [[NSMutableDictionary alloc] init];
    for (File* file in [[self fsAbstraction] arrayForLoadingFiles]) {
        [loadingFiles setObject:file forKey:file.path];
    }
    
    NSMutableDictionary* validPaths = [[NSMutableDictionary alloc] init];
    
    for (NSString* path in [[self fsInterface] getArrayFromEnumeratorForPath:pathToEnumerate option:NSDirectoryEnumerationSkipsSubdirectoryDescendants]) {
        
        if (![[path lastPathComponent ] isEqualToString:@".filesystem.json"]) {
            //if the dictionary does not contain one of the paths from a disk ([currentDirectoryFiles objectForKey:path] == nil), then destroy the thing on the disk.
            //that thing is on the disk but not in json, so it must be destroyed, don't worry about checking for loading files there
            if ([currentDirectoryFiles objectForKey:path] == nil){
                
//                NSLog(@"PATH ONE %@", [[self fsInterface] resolveFilePath:path excludingUpToDirectory:@"Documents"]);
                //incremenet the corruptcount
                //actually delete the file, and if it's successful increment the corruptcount
                if([[self fsInterface] deleteFileAtPath:path]){
                    corruptcount++;
                }
                
            //if the key is there then put it into a new dictionary, this seems redundnat on first glance
            //but it isn''t. If all the keys check out then currentDirectoryPaths and diskPaths
            //will contain the same keys, if they do not then they will have different keys
            //we will do a comparison later to get rid of stuff in JSON that is not on disk.
            //this gets the set of all keys we know are on disk and in JSON (valid files).
            }else{
                
//                NSLog(@"PATH TWO %@", [[self fsInterface] resolveFilePath:path excludingUpToDirectory:@"Documents"]);
                [validPaths setObject:[currentDirectoryFiles objectForKey:[[self fsInterface] resolveFilePath:path excludingUpToDirectory:@"Documents"]] forKey:[[self fsInterface] resolveFilePath:path excludingUpToDirectory:@"Documents"]];
            }
        }
    }
    
    NSMutableIndexSet* indiciesInCurrentToDestroy = [[NSMutableIndexSet alloc] init];
    
    //given that we know all the valid file path,
    //look for something in JSON that is not
    //considered a valid path.
    for (NSString* key in currentDirectoryFiles) {
        NSLog(@"PATH THREE %@", key);
        //the path is in json but not on disk then eliminate it from JSON
        if ([validPaths objectForKey:key] == nil) {
            //if it's not in loading files
            if ([loadingFiles objectForKey:key] == nil) {
                
                NSLog(@"FILE IS NOT IN LOADING FILES FOR KEY %@", key);
                //inrement corruptcount
                corruptcount++;
                //remove the file from JSON
                [[self fsInterface] removeSingleFileFromFileSystemJSON:[currentDirectoryFiles objectForKey:key] inDirectoryPath:((File*)[currentDirectoryFiles objectForKey:key]).parentURLPath];
                [indiciesInCurrentToDestroy addIndex:[[[self fsAbstraction] currentDirectory] indexOfObject:[currentDirectoryFiles objectForKey:key]]];
            }else{
                NSLog(@"FILE IS IN LOADING FILES %@", ((File*)[loadingFiles objectForKey:key]).name);
            }
        }
    }
    
    [[[self fsAbstraction] currentDirectory] removeObjectsAtIndexes:indiciesInCurrentToDestroy];
    return corruptcount;
}

@end
