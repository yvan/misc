//
//  FileSystemInterface.m
//  Airdoc
//
//  Created by Yvan Scher on 3/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

/*  - this class is intended to be a low level 
    - interface for dealing with the filesystem
    - abstractions should be kept to a minimal
    - also all methods should take input over
    - using a property of this class, these
    - inputs will come from the other classes
    - like the filesystemabstraction class
    - in practice.
 
    This is part of the new FileSystem,
    the guiding principles were:
 
    1. Wrappers for the vast majority of 
    iOS filesystem methods. 
    2. Methods expect one kind of input,
    string paths with teh Documents
    directory portion cut off. So basically
    just the important section of path.
    3.All abstractions moved into their own class.
    4.Use NSURLs internally wherever possible.
    5.Parse out dogshit like "private" from the paths
    via sanitization.
 
    */

#import "FileSystemInterface.h"

@implementation FileSystemInterface

#pragma mark FilSystemInterfaceInit

+(id) sharedFileSystemInterface {
    
    static dispatch_once_t pred;
    static FileSystemInterface* sharedFileSystemInterface = nil;
    
    dispatch_once(&pred, ^{
        if(sharedFileSystemInterface == nil){
            sharedFileSystemInterface = [[self alloc] init];
            sharedFileSystemInterface.sharedFSInterfaceAsync = dispatch_queue_create("queue.fs.interface", DISPATCH_QUEUE_SERIAL);
        }
    });
    
    return sharedFileSystemInterface;
}

#pragma mark DocumentsDirectoryMethods

-(NSString*) getDocumentsDirectory{
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}

#pragma mark FileSystemStateMethods

/* PATH RESOLUTION METHODS */

/*  - tests to see if a path is valid/exists
 - should conitnue to take a path string
 - and not an NSURL because its sole purpose
 - is to resolve valid paths
 - */

-(BOOL) isValidPath:(NSString*)rawPath{
    
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           
                           ];
    
    BOOL isValid = [[NSFileManager defaultManager] fileExistsAtPath:queryPath];
//    NSLog(@"%s ISVALIDPATH %d PATH: %@", __PRETTY_FUNCTION__,isValid, rawPath);
    return isValid;
}

/*  - gets the path leading up to a file but does not include the file itself.
 - basically gets rid of everything after the last slash.
 - */

-(NSString *) resolveFilePathForPath:(NSString*)rawPath withName:(NSString*)fileName{
    
    NSString* queryPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSInteger finalSlash = 0;
    NSString *finalPath = @"";
    for (NSInteger index=0; index<queryPath.length;index++){
        if([queryPath characterAtIndex:index] == '/'){ finalSlash = index; } //find the last or second to last slash
        if(index == queryPath.length-1){ finalPath = [queryPath substringWithRange:NSMakeRange(0, finalSlash+1)]; }//right before the end return the path.
    }
//    NSLog(@"%s FINALPATH: %@", __PRETTY_FUNCTION__, finalPath);
    return [finalPath stringByRemovingPercentEncoding];
}

/*  - this method takes a file path and the name of a directory
 - it returns a string with the directorys leading up to and
 - inclusding the provided directory name discarded.
 - inputs filesystem/yvan/roman/ios/ and yvan would return
 - "roman/ios/", it SHOULd find the first occurrence because
 - that's what range does.
 */

-(NSString*) resolveFilePath:(NSString*)rawPath excludingUpToDirectory:(NSString*)directoryName{
    
    NSString *finalPath = @"";
    directoryName = [[directoryName stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* fullPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
    NSRange range = [fullPath rangeOfString:[@"/" stringByAppendingPathComponent:directoryName]];
    if((range.location > fullPath.length-1) || (range.location == NSNotFound)){ finalPath = fullPath; }
    else{
        finalPath = [fullPath substringFromIndex:range.location+(directoryName.length+1)]; }
//    NSLog(@"%s FINALPATH in RESOLVE PATH EXCLUDING: %@", __PRETTY_FUNCTION__, finalPath);
    return [finalPath stringByRemovingPercentEncoding];
}

/*  - tests whether a filePath is a child or sub child of a directory
    - by testing if that directory's name is in the path and that it 
    - is the first element of the path, this may sounds restrictive
    - but it's mainly for testing inclusion in "Local" "Dropbox"
    - and the thing is any subfolder could also have the name 
    - "Dropbox" which would cause conflicts in a flexible method.
 */

-(BOOL) filePath:(NSString*)filePath isLocatedInsideDirectoryName:(NSString*)directoryName{
    
    // a string of /GoogleDrive will be located inside the special GoogleDrive directory
    // if the range of the string starts at a range.location of 1 or 0.
    NSRange range = [filePath rangeOfString: directoryName];
//    NSLog(@"%s RANGE LOCATION: %lu FOR FILE PATH: %@", __PRETTY_FUNCTION__, (unsigned long)range.location, filePath);
    if((range.location == 0) || (range.location == 1)){return YES;}else{return NO;}
}

/* - This method returns the first component of a path
     (i.e. path of '/Dropbox/summer2015/pics' will return 'Dropbox') - */

+(NSString*) getRootDirectoryOfFilePath:(NSString*)filePath {
    NSString* fullPath = [[[filePath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
    
    NSArray *pathComponents = [fullPath pathComponents];
    
    if ([pathComponents count] >= 2) {
        return [fullPath pathComponents][1];
    }
    else {
        return @"";
    }
}

/* - Convenience method to check if file path corresponds to a service directory
 (i.e. Dropbox directory) - */

+(BOOL) fileIsRootDirectory:(File*)file {
    return [file.path isEqualToString:@"/Dropbox"]
    || [file.path isEqualToString:@"/Box"]
    || [file.path isEqualToString:@"/GoogleDrive"]
    || [file.path isEqualToString:@"/Local"]
    || [file.path isEqualToString:@"/Incoming"];
}

#pragma mark FileOperationsMethods

/* expects an unencoded path that does NOT include the current documents directory. Will create a directory at that path */

-(BOOL) createDirectoryAtPath:(NSString*)rawPath withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes{
    
        NSError* error;
        NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                               [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                               ];
    
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:queryPath] withIntermediateDirectories:createIntermediates attributes:attributes error:&error];
        if(error){NSLog(@"%s THERE WAS AN ERROR IN DIRECTORY CREATION:  %@", __PRETTY_FUNCTION__, [error description]); return NO;}
        else{return YES;}
}

// calls should always be accompanied by a call to saveSingleFileToJson
-(BOOL) createFileAtPath:(NSString*)rawPath contents:(NSData *)data attributes:(NSDictionary *)attr{
    
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    BOOL createdFile = [[NSFileManager defaultManager] createFileAtPath:queryPath contents:data attributes:attr];
    if(!createdFile){NSLog(@"%s THERE WAS AN ERROR IN FILE CREATION AT PATH: %@", __PRETTY_FUNCTION__, queryPath); return NO;}
    else{return YES;}
}

//moveItem can be used to move an item or just rename it.
-(BOOL) moveItemAtPath:(NSString*)rawPath toPath:(NSString *)rawDestinationPath{
    
    NSError* error;
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    NSString* destinationPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                                 
                                 [[[rawDestinationPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                            ];

    [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:queryPath] toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    if(error){NSLog(@"%s THERE WAS AN ERROR :%@: IN MOVING FILE AT PATH: %@ TO PATH: %@", __PRETTY_FUNCTION__,error, queryPath, destinationPath); return NO;}
    else{return YES;}
}

//moveItem can be used to move an item or just rename it.
-(BOOL) copyItemAtPath:(NSString*)rawPath toPath:(NSString *)rawDestinationPath{
    
    NSError* error;
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    NSString* destinationPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                                 
                                 [[[rawDestinationPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                 ];
    
    [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:queryPath] toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    if(error){NSLog(@"%s THERE WAS AN ERROR :%@: IN MOVING FILE AT PATH: %@ TO PATH: %@", __PRETTY_FUNCTION__,error, queryPath, destinationPath); return NO;}
    else{return YES;}
}

// recursive directory enumeration 
-(NSDirectoryEnumerator*) getEnumeratorForPath:(NSString*)rawPath option:(NSDirectoryEnumerationOptions)option{
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    return [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:queryPath] includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:option errorHandler:^BOOL(NSURL *url, NSError *error){
        NSLog(@"%s THERE WAS AN ERROR %@ IN ENUMERATING FILE FOR NORMAL ENUMERATOR AT PATH: %@", __PRETTY_FUNCTION__, error, queryPath);;
        return NO;
    }];
}

-(NSArray*) getArrayFromEnumeratorForPath:(NSString*)rawPath option:(NSDirectoryEnumerationOptions)option{
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    NSDirectoryEnumerator* enumeratorForRawPath = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:queryPath] includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey] options:option errorHandler:^BOOL(NSURL *url, NSError *error){
        NSLog(@"%s THERE WAS AN ERROR %@ IN ENUMERATING FILE FOR ARRAY OF PATHS ENUMERATOR AT PATH: %@", __PRETTY_FUNCTION__, error, queryPath);;
        return NO;
    }];
    
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    for (NSURL* url in enumeratorForRawPath) {
        NSString* pathFromUrl = [self resolveFilePath:[[[url path] stringByStandardizingPath] stringByRemovingPercentEncoding] excludingUpToDirectory:@"Documents"];
        [returnArray addObject:pathFromUrl];
    }
    return returnArray;
}

-(NSData*) getDataForfilePath:(NSString*)rawPath {
    
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    
    return [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:queryPath]];
}


-(NSURL*) getProperlyFormedNSURLFromPath:(NSString*)rawPath {
    
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
    
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    return [NSURL fileURLWithPath:queryPath];
}

//gets the file size of a file and returns it as a string
-(NSString*) getFileSizeRecursive:(NSString*)rawPath{

    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           ];
    
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:queryPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long int folderSize = 0;
    
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[queryPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    
    //This line will give you formatted size from bytes ....
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

// calls should always be accompanied by a call to removeSingleFileFromJson, unless hadling corrpupt files
// returns YES if the file is successfully deleted.
// returns NO if the file was not successfully deleted.
-(BOOL) deleteFileAtPath:(NSString*)rawPath{
    
    NSError* error;
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           
                           ];
    
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:queryPath] error:&error];
    if(error){NSLog(@"%s THERE WAS AN ERROR IN FILE DELETION AT PATH: %@ WITH ERROR: %@", __PRETTY_FUNCTION__, queryPath, error); return NO;}
    else{return YES;}
}



#pragma mark FileSystemJSONMethods

// this method populates an NSMutablearray with the cotents of a filesystem.json at a particular
// path, returns an emtpy array with all objects removed if the filesystem.json was created
// from this method call. returns NO (false) if there's nothing there.
// returns YES if there is something

-(NSMutableArray*) populateArrayWithFileSystemJSON:(NSMutableArray*)arrayToPopulate inDirectoryPath:(NSString*)rawPath {
    
    NSError* error;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    
    NSString* sanitizedRawPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:sanitizedRawPath];
    
    // gets te filepath from the santizied input string path
    NSString *filePath = [queryPath stringByAppendingPathComponent:@".filesystem.json"];
    
    //check the original sanitized path for validity
    //this works because isValid Path adds a documents
    //directory operation, may make sense to substitute
    //this with a file exists at path in future instead
    //of a call to our own method MORE SILO-ING ALL THE SILOS
    if(![self isValidPath:sanitizedRawPath]){
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//        NSLog(@"WAS INVALID, MADE NEW PATH");
    }
    
    NSData* filesystemdata = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary* JSONDict = [[NSMutableDictionary alloc] init];
    
    if([filesystemdata length] == 0){
        [arrayToPopulate removeAllObjects];
    }else{
        JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
        if(error){NSLog(@"%s THERE WAS AN ERROR IN JSON POPULATION AT PATH: %@", __PRETTY_FUNCTION__, filePath);}
    }
    
//    NSLog(@"%s CURRENT JSON DICT IN: %@ AT PATH: %@", __PRETTY_FUNCTION__, JSONDict, filePath);
    
    NSMutableArray* currentDirectoryTemp = [[NSMutableArray alloc] init];
    
    for(NSString* fileName in JSONDict){ // - iterates through all the names in the current directory - //
        if(![fileName isEqual:@"timestamp"]){ // - check all fields except the timestamp field - //
            NSDictionary* individualFile = [JSONDict objectForKey:fileName];
            NSString* name = [individualFile objectForKey:@"name"];
            NSString* path = [individualFile objectForKey:@"url"];
            NSDate* created = [formatter dateFromString:[individualFile objectForKey:@"created"]];
            NSString* revision = [individualFile objectForKey:@"revision"];
            BOOL isDirectory = [[individualFile objectForKey:@"isDirectory"] boolValue];
            NSString* boxId = [individualFile objectForKey:@"boxId"];
            //add encodings here because if we don't files with % in their name get set to null inside the file class
            //i took the encodings out but I leaving comments here just in case we need to come abck
            File* file = [[File alloc] initWithName:name andPath:path andDate:created andRevision:revision andDirectoryFlag:isDirectory andBoxId:boxId];
            [currentDirectoryTemp addObject:file];
        }
    }
    
    [arrayToPopulate removeAllObjects];
    [arrayToPopulate addObjectsFromArray:currentDirectoryTemp];
    
    return arrayToPopulate;
}

// saves a given array into the filesystem.json of a containing directory path

-(BOOL) saveArrayToFileSystemJSON:(NSMutableArray*)arrayToSave inDirectoryPath:(NSString*)rawPath{
    
    // - atomically write to filesystem.json to overwrite the file. - //
    NSError *error;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString* sanitizedRawPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:sanitizedRawPath];
    
    // check if the .filesystem.json file exists. if it doesnt exist then create
    // it, if it exists then get it's data and turn it into a dictionary that we
    // use later
    NSString *filePath = [queryPath stringByAppendingPathComponent:@".filesystem.json"];
    NSData* filesystemdata;
    NSMutableDictionary* JSONDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *currentDirectoryTemp = [[NSMutableDictionary alloc] init];
    
    if([self isValidPath:sanitizedRawPath]){
        filesystemdata = [NSData dataWithContentsOfFile:filePath];
        if(![filesystemdata length] == 0){
            JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
            if(error){/*NSLog(@"%s THERE WAS AN ERROR IN JSON POPULATION AT PATH: %@", __PRETTY_FUNCTION__, filePath);*/ return NO;}
        }
    }else{
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    //loop through each file in the array and add it to a temporary dictionary
    for(File* file in arrayToSave){
        NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:file.name,@"name", file.path,@"url",[formatter stringFromDate:file.dateCreated],@"created",@"a",@"revision",file.boxid,@"boxId",[NSString stringWithFormat:@"%d",file.isDirectory],@"isDirectory", nil];
        [currentDirectoryTemp setValue:fileDict forKey:file.name];
    }
    
    //setup a final dictionary that combines entries from the new files
    //and old pre-existing json. also add a timestamp. Turn this finaldictionary
    //into JSON and save it.
    NSMutableDictionary* finalDictionary = [[NSMutableDictionary alloc] init];
    [finalDictionary setValue:[formatter stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [finalDictionary addEntriesFromDictionary:JSONDict];
    [finalDictionary addEntriesFromDictionary:currentDirectoryTemp];
    
//    NSLog(@"%s SAVING THIS STRUCTURE TO FILESYSTEM: %@ SAVE ARRAY OF FILES TO FILESYSTEM IN :%@", __PRETTY_FUNCTION__, finalDictionary ,filePath);
    
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:finalDictionary options:0 error:&error];
    if(error){/*NSLog(@"%s ERROR IN SETTING JSONdata FROM TEMPORARY DIRECTORY %@", __PRETTY_FUNCTION__, error);*/ return NO;}
    
    [JSONdata writeToFile:filePath atomically:YES];
    
    return YES;
}

-(BOOL) saveSingleFileToFileSystemJSON:(File*)fileToSave inDirectoryPath:(NSString*)rawPath{
    
    NSError *error;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    
    NSString* sanitizedRawPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:sanitizedRawPath];
    
    // check if the .filesystem.json file exists. if it doesnt exist then create
    // it, if it exists then get it's data and turn it into a dictionary that we
    // use later
    NSData* filesystemdata;
    NSString *filePath = [queryPath stringByAppendingPathComponent:@".filesystem.json"];
    NSMutableDictionary* JSONDict = [[NSMutableDictionary alloc] init];
    
    //check the original sanitized path for validity
    //this works because isValid Path adds a documents
    //directory operation, may make sense to substitute
    //this with a file exists at path in future instead
    //of a call to our own method MORE SILO-ING ALL THE SILOS
    if([self isValidPath:sanitizedRawPath]){
        filesystemdata = [NSData dataWithContentsOfFile:filePath];
        if(![filesystemdata length] == 0){
            JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
            if(error){NSLog(@"%s THERE WAS AN ERROR IN JSON POPULATION AT PATH: %@", __PRETTY_FUNCTION__, filePath); return NO;}
        }
    }else{
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
//    NSLog(@"%s OLD JSON FILE: %@ IN SAVESINGLEFILE TO FILESYSTEM AT PATH: %@", __PRETTY_FUNCTION__, JSONDict, filePath);

    //add the file to a temporary dictionary
    NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:fileToSave.name,@"name", fileToSave.path,@"url",[formatter stringFromDate:fileToSave.dateCreated],@"created",@"a",@"revision",fileToSave.boxid,@"boxId",[NSString stringWithFormat:@"%d",fileToSave.isDirectory],@"isDirectory", nil];
    
    //setup a final dictionary that combines entries from the new files
    //and old pre-existing json. also add a timestamp. Turn this finaldictionary
    //into JSON and save it.
    NSMutableDictionary* finalDictionary = [[NSMutableDictionary alloc] init];
    [finalDictionary setValue:[formatter stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [finalDictionary addEntriesFromDictionary:JSONDict];
    [finalDictionary setObject:fileDict forKey:fileToSave.name];
    
//    NSLog(@"%s SAVING THIS STRUCTURE TO FILESYSTEM: %@ IN SAVESINGLEFILE TO FILESYSTEM AT PATH: %@", __PRETTY_FUNCTION__, finalDictionary, filePath);
    
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:finalDictionary options:0 error:&error];
    if(error){NSLog(@"%s ERROR IN SETTING JSONdata FROM TEMPORARY DIRECTORY %@", __PRETTY_FUNCTION__, error); return NO;}
    
    [JSONdata writeToFile:filePath atomically:YES];
    return YES;
}

-(BOOL) removeSingleFileFromFileSystemJSON:(File*)fileToRemove inDirectoryPath:(NSString*)rawPath{
    
    NSError* error;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    
    NSString* sanitizedRawPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:sanitizedRawPath];
    
    // - gets the path to filesystem.json by reducing the current stack and adding filesystem.json - //
    NSData* filesystemdata;
    NSString *filePath = [queryPath stringByAppendingPathComponent:@".filesystem.json"];
    NSMutableDictionary* JSONDict = [[NSMutableDictionary alloc] init];
    
    //check the original sanitized path for validity
    //this works because isValid Path adds a documents
    //directory operation, may make sense to substitute
    //this with a file exists at path in future instead
    //of a call to our own method MORE SILO-ING ALL THE SILOS
    if([self isValidPath:sanitizedRawPath]){
        filesystemdata = [NSData dataWithContentsOfFile:filePath];
        if([filesystemdata length] == 0){
            return NO; // - filesystem data is empty there is nothing to remove. removal failes
        }else{//we get the currently existing JSON data stored in .filesystem.json
            JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
            if(error){NSLog(@"JSON DICTIONARY ERROR: %d - message: %s", errno, strerror(errno));return NO;}
        }
    }else{// if the file does not exist then return NO
          // NSLog(@"%s .filesystem.json DOES NOT EXIST AT PATH: %@", __PRETTY_FUNCTION__, filePath);
        return NO;
    }
    
    //make sure the key to remove is actually in the dictionary
    NSString* keyToRemove = @"";
    for(NSString* fileName in JSONDict){ // - iterates through all the names in the directory looking for the key- //
        if([fileName isEqualToString:fileToRemove.name]){keyToRemove = fileName;}
    }
    
    //if the key isn't there then return NO, key was not removed (because it didn't exist)
    if ([keyToRemove isEqualToString:@""]) {
        return NO;
    }else{//else remove the key and save the new json structure to the filesystem
        JSONDict = [JSONDict mutableCopy];
        [JSONDict removeObjectForKey:fileToRemove.name];
        NSData* finalData = [NSJSONSerialization dataWithJSONObject:JSONDict options:0 error:&error];
        if(error){/*NSLog(@"%s ERROR GETTING DATA FROM JSONDict: %@ FOR KEY: %@", __PRETTY_FUNCTION__, [error description], fileToRemove.name);*/return NO;}
        [finalData writeToFile:filePath atomically:YES];
        return YES;
    }
}

-(BOOL) saveBatchOfFilesToFileSystemJSON:(NSArray*)arrayOfFilesToSave inDirectoryPath:(NSString*)rawPath{
    NSError *error;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    
    NSString* sanitizedRawPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:sanitizedRawPath];
    
    // check if the .filesystem.json file exists. if it doesnt exist then create
    // it, if it exists then get it's data and turn it into a dictionary that we
    // use later
    NSData* filesystemdata;
    NSString *filePath = [queryPath stringByAppendingPathComponent:@".filesystem.json"];
    NSMutableDictionary* JSONDict = [[NSMutableDictionary alloc] init];
    
    //check the original sanitized path for validity
    //this works because isValid Path adds a documents
    //directory operation, may make sense to substitute
    //this with a file exists at path in future instead
    //of a call to our own method MORE SILO-ING ALL THE SILOS
    if([self isValidPath:sanitizedRawPath]){
        filesystemdata = [NSData dataWithContentsOfFile:filePath];
        if(![filesystemdata length] == 0){
            JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
            if(error){NSLog(@"%s THERE WAS AN ERROR IN JSON POPULATION AT PATH: %@", __PRETTY_FUNCTION__, filePath); return NO;}
        }
    }else{
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSMutableDictionary* finalDictionary = [[NSMutableDictionary alloc] init];
    [finalDictionary setValue:[formatter stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [finalDictionary addEntriesFromDictionary:JSONDict];

//        NSLog(@"%s OLD JSON FILE: %@ IN SAVESINGLEFILE TO FILESYSTEM AT PATH: %@", __PRETTY_FUNCTION__, JSONDict, filePath);
    for (File* fileToSave in arrayOfFilesToSave) {
        //add the file to a temporary dictionary
        NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:fileToSave.name,@"name",fileToSave.path,@"url",[formatter stringFromDate:fileToSave.dateCreated],@"created",@"a",@"revision",fileToSave.boxid,@"boxId",[NSString stringWithFormat:@"%d",fileToSave.isDirectory],@"isDirectory",nil];
        
        //setup a final dictionary that combines entries from the new files
        //and old pre-existing json. also add a timestamp. Turn this finaldictionary
        //into JSON and save it.
        [finalDictionary setObject:fileDict forKey:fileToSave.name];
        
//            NSLog(@"%s SAVING THIS STRUCTURE TO FILESYSTEM: %@ IN SAVESINGLEFILE TO FILESYSTEM AT PATH: %@", __PRETTY_FUNCTION__, finalDictionary, filePath);
    }

    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:finalDictionary options:0 error:&error];
    if(error){NSLog(@"%s ERROR IN SETTING JSONdata FROM TEMPORARY DIRECTORY %@", __PRETTY_FUNCTION__, error); return NO;}
    
    [JSONdata writeToFile:filePath atomically:YES];

    return YES;
}

-(BOOL) removeBatchOfFilesFromFileSystemJSON:(NSArray*)arrayOfFilesToSave inDirectoryPath:(NSString*)rawPath{
    
    NSError* error;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    
    NSString* sanitizedRawPath = [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:sanitizedRawPath];
    
    // - gets the path to filesystem.json by reducing the current stack and adding filesystem.json - //
    NSData* filesystemdata;
    NSString *filePath = [queryPath stringByAppendingPathComponent:@".filesystem.json"];
    NSMutableDictionary* JSONDict = [[NSMutableDictionary alloc] init];
    
    //check the original sanitized path for validity
    //this works because isValid Path adds a documents
    //directory operation, may make sense to substitute
    //this with a file exists at path in future instead
    //of a call to our own method MORE SILO-ING ALL THE SILOS
    if([self isValidPath:sanitizedRawPath]){
        filesystemdata = [NSData dataWithContentsOfFile:filePath];
        if([filesystemdata length] == 0){
            return NO; // - filesystem data is empty there is nothing to remove. removal failes
        }else{//we get the currently existing JSON data stored in .filesystem.json
            JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
            if(error){NSLog(@"JSON DICTIONARY ERROR: %d - message: %s", errno, strerror(errno));return NO;}
        }
    }else{// if the file does not exist then return NO
        // NSLog(@"%s .filesystem.json DOES NOT EXIST AT PATH: %@", __PRETTY_FUNCTION__, filePath);
        return NO;
    }
    
    for (File* fileToRemove in arrayOfFilesToSave) {
        //make sure the key to remove is actually in the dictionary
        NSString* keyToRemove = @"";
        //this will get the first one, but in a filesystem where names are unique that
        //should be the only one.
        for(NSString* fileName in JSONDict){ // - iterates through all the names in the directory looking for the key- //
            if([fileName isEqualToString:fileToRemove.name]){
                keyToRemove = fileName;
            }
        }
        //if the key isn't there then return NO, key was not removed (because it didn't exist)
        if (![keyToRemove isEqualToString:@""]) {
            JSONDict = [JSONDict mutableCopy];
            [JSONDict removeObjectForKey:fileToRemove.name];        }
    }
    
    NSData* finalData = [NSJSONSerialization dataWithJSONObject:JSONDict options:0 error:&error];
    
    if(error){
        /*NSLog(@"%s ERROR GETTING DATA FROM JSONDict: %@ FOR KEY: %@", __PRETTY_FUNCTION__, [error description], fileToRemove.name);*/
        return NO;
    }
    
    if([finalData writeToFile:filePath atomically:YES]){
        return YES;
    } else {
        return NO;
    }
}

// This method should prevent the user from writing into
// the route '/' and then breaks out of whatever is happening
// by throwing an error. The idea is to call this function
// internally inside fsInterface and fsFunctions whenever we
// need to make a file write to prevent the file from being written
// in the root directory.

//-(void) preventWritingToRoot:(NSString*)rawPath {
//    
//    //standardize our path
//    NSString* queryPath = [[self getDocumentsDirectory] stringByAppendingPathComponent:
//                                                     
//                            [[[rawPath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
//                           
//                          ];
//    
//    //if anything other than 'Local' 'Incoming' 'GoogleDrive' or 'Dropbox'
//    //appears at the base of the path then we throw an error
//    //if the right things appear (those thigns listed above) appear
//    //at the root of the path then we're in teh clear and the path is ok
//    if ([self filePath:queryPath isLocatedInsideDirectoryName:@"GoogleDrive"] || [self filePath:queryPath isLocatedInsideDirectoryName:@"Dropbox"] || [self filePath:queryPath isLocatedInsideDirectoryName:@"Local"] || [self filePath:queryPath isLocatedInsideDirectoryName:@"Incoming"]) {
//        
//    } else {
//        
//    }
//}

@end
