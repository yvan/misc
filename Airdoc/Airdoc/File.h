//
//  FileSystem.m
//  malamute
//
//  Created by Yvan Scher on 1/3/15.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//
/*  - isDirectory: tells us whether the file object is a folder/directory or a file with an extension
    - url is an NSURL that stores the file's location locally
    - name is the name of the file including the extension
    - parentURLPath is a URL path to the parent of the File.
    - sender will theoretically store some unique identifier of the original user who sent the file, if it is foreign
    - dateCreated is the date of the file object's creation, this get's stored in JSON and gets reloaded.
    - contents is an NSData object that stores the actual bytes of the file's data
    - revision is a concept used on GoogleDrive and Dropbox, it stores the file's version
    - isDummyFile is a flag that tells us The contents of the file are nil, basically this is a shell of a file that contains all information but the NSData contents to save space on the users local device, for example when we load in Googledribe/Box/Dropbox Files, they will be loaded in as dummy files at each level, only when the user goes to send to we go and fetch those files from the GoogleDrive/Box/Dropbox etc.
    - gdboxid is a unqiue identifier used by googeldrive and box, to unqiuely identify files.
    -*/
#import <Foundation/Foundation.h>

@interface File : NSObject <NSCopying>

@property (nonatomic) BOOL isDirectory;
@property (nonatomic) NSString* path;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* parentURLPath;
@property (nonatomic) NSString* sender;
@property (nonatomic) NSDate* dateCreated;
@property (nonatomic) NSString* revision;
@property (nonatomic) BOOL isDummyFile;
@property (nonatomic) NSString* boxid; // - set it to -1 for files not on box - //

-(instancetype)initWithName:(NSString*)name andPath:(NSString*)path andDate:(NSDate*)date andRevision:(NSString*)revision andDirectoryFlag:(BOOL)isDirectory andBoxId:(NSString*)boxID;
@end
