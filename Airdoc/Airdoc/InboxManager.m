//
//  InboxManager.m
//  Airdoc
//
//  Created by Roman Scher on 3/19/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "InboxManager.h"

@implementation InboxManager

#pragma mark - Singleton

+(id)sharedInboxManager {
    
    static dispatch_once_t pred;
    static InboxManager *sharedInboxManager = nil;
    
    dispatch_once(&pred, ^{
        if(sharedInboxManager == nil) {
            
            sharedInboxManager = [[self alloc] init];
            sharedInboxManager.inboxJsonUpdateQueue = dispatch_queue_create("Inbox Json Update queue", DISPATCH_QUEUE_SERIAL);

        }
    });
    
    return sharedInboxManager;
}

-(FileSystemInterface*) fsInterface{
    if (!_fsInterface) {
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}

#pragma mark - Inbox NSUserDefaults

+(void)incrementnumberOfUncheckedFilePackages {
    NSString *numUncheckedFilePackagesString = [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedFilePackagesStringIdentifier]];
    NSInteger numUncheckedFilePackagesIncrement = [numUncheckedFilePackagesString integerValue] + 1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat: @"%ld", (long)numUncheckedFilePackagesIncrement] forKey:[AppConstants numberOfUncheckedFilePackagesStringIdentifier]];
}

+(void)reduceNumberOfUncheckedFilePackagesToZero {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[AppConstants numberOfUncheckedFilePackagesStringIdentifier]];
}

+(NSString*)getNumberOfUncheckedFilePackages {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedFilePackagesStringIdentifier]];
}

//Link Packages
+(void)incrementnumberOfUncheckedLinkPackages {
    NSString *numUncheckedLinkPackagesString = [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedLinkPackagesStringIdentifier]];
    NSInteger numUncheckedLinkPackagesIncrement = [numUncheckedLinkPackagesString integerValue] + 1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat: @"%ld", (long)numUncheckedLinkPackagesIncrement] forKey:[AppConstants numberOfUncheckedLinkPackagesStringIdentifier]];
}

+(void)reduceNumberOfUncheckedLinkPackagesToZero {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[AppConstants numberOfUncheckedLinkPackagesStringIdentifier]];
}

+(NSString*)getNumberOfUncheckedLinkPackages {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedLinkPackagesStringIdentifier]];
}

//General
+(NSString*)getTotalNumberOfUncheckedPackages {
    NSString *numUncheckedFilePackagesString = [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedFilePackagesStringIdentifier]];
    NSString *numUncheckedLinkPackagesString = [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedLinkPackagesStringIdentifier]];
    
    NSInteger numUncheckedFilePackages = [numUncheckedFilePackagesString integerValue];
    NSInteger numUncheckedLinkPackages = [numUncheckedLinkPackagesString integerValue];
    
    NSInteger totalNumUncheckedPackages = numUncheckedFilePackages + numUncheckedLinkPackages;

    return [NSString stringWithFormat: @"%ld", (long)totalNumUncheckedPackages];
}

#pragma mark - LinkPackage methods

-(RLMResults*)getAllLinkPackages {
    return [[LinkPackage allObjects] sortedResultsUsingProperty:@"timestamp" ascending:NO];
}

/*- Takes a link jsonModel object, converts it to a realm link object, and saves it - */

-(void)saveLinkPackage:(LinkPackageJM *)linkPackageJM {
    LinkPackage *linkPackage = [[LinkPackage alloc] init];
    linkPackage.packageUUID = linkPackageJM.packageUUID;
    linkPackage.senderUUID = linkPackageJM.senderUUID;
    linkPackage.senderName = linkPackageJM.senderName;
    linkPackage.timestamp = [NSDate date];
    
    //Convert LinkJMs to Links
    NSMutableArray *linksJM = [LinkJM arrayOfModelsFromDictionaries:linkPackageJM.links];
    NSMutableArray *links = [[NSMutableArray alloc] init];
    for (LinkJM *linkJM in linksJM) {
        Link *link = [[Link alloc] init];
        link.url = linkJM.url;
        link.fileName = linkJM.fileName;
        link.type = linkJM.type;
        [links addObject:link];
    }
    
    //Add links to LinkPackage and save linkpackage to Realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [linkPackage.links addObjects:links];
    [realm addObject:linkPackage];
    [realm commitWriteTransaction];
}

-(void)deleteLinkPackage:(LinkPackage*)linkPackage {
    //Remove to linkPackage from Realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:linkPackage];
    [realm commitWriteTransaction];
}

#pragma mark - Inbox.json methods

/* - Creates empty inbox.json file - */
-(void)createInboxJsonFile {
    [self storeJSONData:[[NSMutableDictionary alloc] init] InJSONFilesWithFileIdentifier:[AppConstants inboxJSONFileIdentifier]];
}

/* - Creates inbox.json if it doesn't exist, and adds a SINGLE file to its appropriate UUID collection - */

-(void)addSingleFileToInboxJsonWithFilePackageUUID:(NSString*)filePackageUUID andFile:(File*)file fromPeer: (MCPeerID*)peer {
    
    dispatch_sync(_inboxJsonUpdateQueue, ^ {
        
        NSMutableDictionary *inboxJsonMutable;
        
        NSLog(@"Path we're checking: %@", [AppConstants pathForJSONFileWithIdentifier:[AppConstants inboxJSONFileIdentifier]]);
        
        //If inbox.json exists, get existing inbox.json, else start with new empty inbox.json NSDictionary
        if([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier:[AppConstants inboxJSONFileIdentifier]]]) {
            
            inboxJsonMutable = [self readJSONFileWithFileIdenfifier:[AppConstants inboxJSONFileIdentifier]];
            NSLog(@"INBOX.JSON EXISTS ALREADY");
        }
        else {
            inboxJsonMutable = [[NSMutableDictionary alloc] init];
            NSLog(@"INBOX.JSON DOES NOT EXIST ALREADY");
        }
        
        NSDictionary *filePackagesJson = [inboxJsonMutable objectForKey:[AppConstants filePackagesStringIdentifier]];
        NSMutableDictionary *filePackagesJsonMutable = [[NSMutableDictionary alloc] init];
        [filePackagesJsonMutable addEntriesFromDictionary:filePackagesJson];
        
        NSDictionary *filePackageUUIDJson = [filePackagesJson objectForKey:filePackageUUID];
        
        NSMutableDictionary *filePackageUUIDJsonMutable = [[NSMutableDictionary alloc] init];
        [filePackageUUIDJsonMutable addEntriesFromDictionary:filePackageUUIDJson];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
        
        // Set file package info
        [filePackageUUIDJsonMutable setObject:[formatter stringFromDate:[NSDate date]] forKey:[AppConstants receivedDateStringIdentifier]];
        [filePackageUUIDJsonMutable setObject:[LocalStorageManager getPeerNameFromDisplayName:peer.displayName] forKey:[AppConstants sentByStringIdentifier]];
        [filePackageUUIDJsonMutable setObject:[LocalStorageManager getUUIDFromDisplayName:peer.displayName] forKey:[AppConstants sentByUUIDStringIdentifier]];
        [filePackageUUIDJsonMutable setObject:filePackageUUID forKey:[AppConstants filePackageUUIDStringIdentifier]];
        
        //New file
        NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        file.name,[AppConstants fileNameStringIdentifier],
                                                        file.path,[AppConstants fileUrlStringIdentifier],
                                                        [formatter stringFromDate:file.dateCreated],[AppConstants createdStringIdentifier],
                                                        file.revision,[AppConstants revisionStringIdentifier],
                                                        file.boxid,[AppConstants boxIdStringIdentifier],
                                  [NSString stringWithFormat:@"%d",file.isDirectory],[AppConstants isDirectoryStringIdentifier], nil];
        
        //Add new file to files
        NSDictionary *filesJson = [filePackageUUIDJsonMutable objectForKey:[AppConstants filesStringIdentifier]];
        NSMutableDictionary *filesJsonMutable = [[NSMutableDictionary alloc] init];
        [filesJsonMutable addEntriesFromDictionary:filesJson];
        [filesJsonMutable setObject:fileDict forKey:file.name];
        
        [filePackageUUIDJsonMutable setObject:filesJsonMutable forKey:[AppConstants filesStringIdentifier]];
        [filePackagesJsonMutable setObject:filePackageUUIDJsonMutable forKey:filePackageUUID];
        [inboxJsonMutable setObject:filePackagesJsonMutable forKey:[AppConstants filePackagesStringIdentifier]];
        
//        NSLog(@"inbox.json has %lu%@", (unsigned long)[filePackagesJsonMutable count], @" packages after updating");
//        NSLog(@"filePackage with UUID %@%@%lu%@", filePackageUUID, @" has ", (unsigned long)[[[filePackagesJsonMutable objectForKey:filePackageUUID] objectForKey:[AppConstants filesStringIdentifier]] count], @" files");
        
        [self storeJSONData:inboxJsonMutable InJSONFilesWithFileIdentifier:[AppConstants inboxJSONFileIdentifier]];
    });
}

-(void)removeFilePackageFromInboxJsonWithFilePackageUUID: (NSString*)filePackageUUID {
    
    dispatch_sync(_inboxJsonUpdateQueue, ^ {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: [AppConstants pathForJSONFileWithIdentifier:[AppConstants inboxJSONFileIdentifier]]]) {
        
            NSMutableDictionary *inboxJsonMutable = [self readJSONFileWithFileIdenfifier:[AppConstants inboxJSONFileIdentifier]];
        
            NSDictionary *filePackagesJson = [inboxJsonMutable objectForKey:[AppConstants filePackagesStringIdentifier]];
            NSMutableDictionary *filePackagesJsonMutable = [[NSMutableDictionary alloc] init];
            [filePackagesJsonMutable addEntriesFromDictionary:filePackagesJson];
        
            [filePackagesJsonMutable removeObjectForKey:filePackageUUID];
            [inboxJsonMutable setObject:filePackagesJsonMutable forKey:[AppConstants filePackagesStringIdentifier]];
        
            [self storeJSONData:inboxJsonMutable InJSONFilesWithFileIdentifier:[AppConstants inboxJSONFileIdentifier]];
        }
        else {
            NSLog(@"Tried to delete a filesPackage, but InboxJSON does not exist");
        }
    });
}

/* - Returns an NSArray of NSDictionaries that will be used to populate the inbox view - */
-(NSArray*)getFilePackagesFromInboxJson {
    
    __block NSArray *filePackages;
    dispatch_sync(_inboxJsonUpdateQueue, ^ {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: [AppConstants pathForJSONFileWithIdentifier:[AppConstants inboxJSONFileIdentifier]]]) {
    
            NSDictionary *inboxJson = [self readJSONFileWithFileIdenfifier:[AppConstants inboxJSONFileIdentifier]];
            NSDictionary *filePackagesJson = [inboxJson objectForKey:[AppConstants filePackagesStringIdentifier]];
            filePackages = [[NSMutableArray alloc] initWithArray:[filePackagesJson allValues]];
            
            NSArray *filePackagesSorted = [[NSArray alloc] initWithArray:[self sortFilePackages:filePackages] copyItems:YES];
            filePackages = filePackagesSorted;
        }
        else {
            NSLog(@"Tried to return filesPackages, but InboxJSON does not exist");
            filePackages = nil;
        }
    });
    
    return filePackages;
}

/*  - Store given JSON into the specified .JSON file by overwriting existing JSON file or creating it. - */

-(BOOL) storeJSONData:(NSMutableDictionary*)JSONDict InJSONFilesWithFileIdentifier: (NSString*)fileIdentifier {
    
    // setup set date format and get path to specified .JSON file //
    NSError* error;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString *JSONPath = [AppConstants pathForJSONFileWithIdentifier:fileIdentifier];
    
    // - Add a timestamp, turn our JSON dictionary into NSData, then overwrite/create & write to the specified .JSON file with this data - //
    [JSONDict setObject:[formatter stringFromDate:[NSDate date]] forKey:[AppConstants timestampStringIdentifier]];

    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONDict options:0 error:&error];
    
    if(error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, [error description]);
        return NO;
    }
    else {
        [JSONData writeToFile:JSONPath atomically: YES];
        return YES;
    }
}

/* - Returns the requested JSON file from the userData JSON files in the documents directory - */

-(NSMutableDictionary *) readJSONFileWithFileIdenfifier: (NSString *)fileIdentifier {
    
    // - get the path to specified .JSON file - //
    NSString *JSONPath = [AppConstants pathForJSONFileWithIdentifier:fileIdentifier];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:JSONPath]) {
        
        NSError* error;
        NSData* filesystemdata = [NSData dataWithContentsOfFile:JSONPath];
        NSDictionary *JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
        
        // Put returned NSDictionary into an NSMutableDictionary so that it may be modified wherever it is returned to
        NSMutableDictionary *JSONDictMutable = [[NSMutableDictionary alloc] init];
        [JSONDictMutable addEntriesFromDictionary:JSONDict];
        
        if(error) {
            NSLog(@"Failed to return json file %s %@", __PRETTY_FUNCTION__, [error description]);
            return nil;
        }
        else {
            return JSONDictMutable;
        }
    }
    else {
        NSLog(@"Tried to return contents of %@%@", fileIdentifier, @" but the file does not exist.");
        return nil;
    }
}

#pragma mark - Helper methods

/* - Sorts array of peers by displayname - */

-(NSArray*)sortFilePackages: (NSArray*)filePackagesArray {
    
    NSArray *filePackagesArraySorted = [filePackagesArray sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
        
        NSDate *date1 = [dateFormatter dateFromString:[((NSDictionary*)obj1) objectForKey:[AppConstants receivedDateStringIdentifier]]];
        NSDate *date2 = [dateFormatter dateFromString:[((NSDictionary*)obj2) objectForKey:[AppConstants receivedDateStringIdentifier]]];
        return [date2 compare:date1];
    }];
    
    return filePackagesArraySorted;
}

@end
