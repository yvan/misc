//
//  FileSystemInit.m
//  Hexlist
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

-(SharedServiceManager*) sharedServiceManager {
    if (!_sharedServiceManager) {
        _sharedServiceManager = [SharedServiceManager sharedServiceManager];
    
    }
    return _sharedServiceManager;
}

#pragma mark FileSystemInitialization

// add dropbox, box, and google drive to realm.

-(File*) addFirstThreeContentSources {
    
    File* root = [[File alloc] init];
    root.serviceType = -1;
    root.displayName = @"/";
    root.displayPath = @"/";
    root.codedName = @"/";
    root.codedPath = @"/";
    root.parentFile = nil;
    root.isDirectory = YES;
    root.dateCreated = [NSDate date];
    root.idOnService = nil;
    
    NSString* newDropboxFileUUID = [[NSUUID UUID] UUIDString];
    File* dropbox = [[File alloc] init];
    dropbox.serviceType = [AppConstants serviceTypeForString:@"Dropbox"];
    dropbox.displayName = @"Dropbox";
    dropbox.displayPath = @"/Dropbox";
    dropbox.codedName = newDropboxFileUUID;
    dropbox.codedPath = [@"/" stringByAppendingPathComponent:newDropboxFileUUID];
    dropbox.parentFile = root;
    dropbox.isDirectory = YES;
    dropbox.dateCreated = [NSDate date];
    dropbox.idOnService = nil;
    
    NSString* newBoxFileUUID = [[NSUUID UUID] UUIDString];
    File* box = [[File alloc] init];
    box.serviceType = [AppConstants serviceTypeForString:@"Box"];
    box.displayName = @"Box";
    box.displayPath = @"/Box";
    box.codedName = newBoxFileUUID;
    box.codedPath = [@"/" stringByAppendingPathComponent:newBoxFileUUID];
    box.parentFile = root;
    box.isDirectory = YES;
    box.dateCreated = [NSDate date];
    box.idOnService = @"0";
    
    NSString* newGoogleDriveFileUUID = [[NSUUID UUID] UUIDString];
    File* googleDrive = [[File alloc] init];
    googleDrive.serviceType = [AppConstants serviceTypeForString:@"GoogleDrive"];
    googleDrive.displayName = @"GoogleDrive";
    googleDrive.displayPath = @"/GoogleDrive";
    googleDrive.codedName = newGoogleDriveFileUUID;
    googleDrive.codedPath = [@"/" stringByAppendingPathComponent:newGoogleDriveFileUUID];
    googleDrive.parentFile = root;
    googleDrive.isDirectory = YES;
    googleDrive.dateCreated = [NSDate date];
    googleDrive.idOnService = @"root";
    
    // do not refactor this to avoid querying for the root
    // we have to, we cannot just save a reference in fs abstraction
    // when the user returns to the intro screen it wipes the fsabstraction
    // and the saved reference to the file system root.
    RLMRealm* fileSystemRealm = [FileSystemInterface getFileSystemRealm];
    //if there is a root just return it
    File* fsRoot = [FileSystemInit getFileSystemRootIfExists];
    if (fsRoot) {
        return fsRoot;
    //if there is no root then add it and the content services
    } else {
        [fileSystemRealm beginWriteTransaction];
        [fileSystemRealm addObject:root];
        [root.children addObject:dropbox];
        [root.children addObject:box];
        [root.children addObject:googleDrive];
        [fileSystemRealm commitWriteTransaction];
        return root;
    }
}

+(File*) getFileSystemRootIfExists {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"codedName = %@",
                         @"/"];
    RLMResults* results = [File objectsInRealm:[FileSystemInterface getFileSystemRealm] withPredicate:pred];
    if ([results count] == 0) {
        return nil;
    } else {
        return [results lastObject];
    }
}


@end