//
//  FileSystemFunctions.h
//  Airdoc
//
//  Created by Yvan Scher on 3/25/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "FileSystemAbstraction.h"
#import "FileSystemInterface.h"
#import "FileLoadingObject.h"

@interface FileSystemFunctions : NSObject


+(id) sharedFileSystemFunctions;

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;

-(void) moveFilesLocal:(NSMutableArray*) files calledFromInbox:(BOOL)calledFromInbox;
-(NSMutableArray*) convertFileLoadingObjectsIntoFileObjects:(NSMutableArray*)fileLoadingObjects;
-(void) moveFileAndSubChildrenByEnumeration:(File*)file fromPath:(NSString*)oldPath toPath:(NSString*)newPath;
-(NSArray*) sortFoldersOrFiles: (NSMutableArray*)folderOrFilesArray;

@end
