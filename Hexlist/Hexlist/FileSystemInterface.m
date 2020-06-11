//
//  FileSystemInterface.m
//  Hexlist
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
        }
    });
    
    return sharedFileSystemInterface;
}

// see: https://realm.io/docs/objc/latest/#in-memory-realms

+(RLMRealm*) getFileSystemRealm {
    NSError* error = nil;
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.inMemoryIdentifier = @"FileSystemRealm";
    RLMRealm* fileSystemRealm = [RLMRealm realmWithConfiguration:config error:&error];
    // there was an issue with generated realm
    if (!fileSystemRealm) {
        //NSLog(@"Error in getFileSystemRealm %@", [error localizedDescription]);
    }
    return fileSystemRealm;
}

#pragma mark FileSystemRealmMethods

//thing that grabs the children and orders by multiple properties using realm
//http://stackoverflow.com/questions/27365809/order-by-multiple-properties-using-realm
-(void) populateArrayWithFileSystemRealm:(NSMutableArray*)arrayToPopulate forParentDirectory:(File*)parent {
    //clear whatever was in ths array before
    [arrayToPopulate removeAllObjects];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:[RLMSortDescriptor sortDescriptorWithProperty:@"isDirectory" ascending:NO],[RLMSortDescriptor sortDescriptorWithProperty:@"displayName" ascending:YES], nil];
    RLMResults* sortedFilesFolders = [parent.children sortedResultsUsingDescriptors:sortDescriptors];
    for (File* file in sortedFilesFolders) {
        [arrayToPopulate addObject:file];
    }
}

// NSArray<File*>* uses a generic to make sure everything in the array is a File object.

-(void) saveBatchOfFilesToFileSystemRealm:(NSArray<File*>*)arrayOfFilesToSave forParentDirectory:(File*)parent {
    
    //adding the children onto the paren'ts children array automatically adds them to realm, no need for separate query
    //clear the children on the parent, prevents double adding bugs.
    RLMRealm* fileSystemRealm = [FileSystemInterface getFileSystemRealm];
    [fileSystemRealm beginWriteTransaction];
    parent.children = nil;
    [parent.children addObjects:arrayOfFilesToSave];
    [fileSystemRealm commitWriteTransaction];
    
}

-(void) saveSingleFileToFileSystemRealm:(File*)fileToSave forParentDirectory:(File*)parent {
    //adding the children onto the paren'ts children array automatically adds them to realm, no need for separate query
    //clear the children on the parent, prevents double adding bugs.
    RLMRealm* fileSystemRealm = [FileSystemInterface getFileSystemRealm];
    [fileSystemRealm beginWriteTransaction];
    parent.children = nil;
    [parent.children addObject:fileToSave];
    [fileSystemRealm commitWriteTransaction];
}

-(void) removeBatchOfFilesToFileSystemRealm:(NSArray<File*>*)arrayOfFilesToRemove forParentDirectory:(File*)parent {
    //delete the array of objects on child array
    RLMRealm* fileSystemRealm = [FileSystemInterface getFileSystemRealm];
    [fileSystemRealm beginWriteTransaction];
    [fileSystemRealm deleteObjects:arrayOfFilesToRemove];
    [fileSystemRealm commitWriteTransaction];
}

-(void) removeSingleFileFromFileSystemRealm:(File*)fileToRemove forParentDirectory:(File*)parent {
    //delete the array of objects on child array
    RLMRealm* fileSystemRealm = [FileSystemInterface getFileSystemRealm];
    [fileSystemRealm beginWriteTransaction];
    [fileSystemRealm deleteObject:fileToRemove];
    [fileSystemRealm commitWriteTransaction];
}

@end