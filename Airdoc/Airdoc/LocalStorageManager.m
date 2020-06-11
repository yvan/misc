//
//  LocalStorageManager.m
//  Airdoc
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "LocalStorageManager.h"

@interface LocalStorageManager()

@end

@implementation LocalStorageManager

#pragma mark - Initializations

-(id)init {
    self = [super init];
    return self;
}

#pragma mark - User NSUserDefaults

/* - Sets user's first name for use in Multipeer interactions - */
+(void)setUserFirstName:(NSString*)firstName {
    [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:[AppConstants firstNameStringIdentifier]];
}

/* - Sets user's last name for use in Multipeer interactions - */
+(void)setUserLastName:(NSString*)lastName {
    [[NSUserDefaults standardUserDefaults] setObject:lastName forKey:[AppConstants lastNameStringIdentifier]];
}

+(NSString *)getUserFirstName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants firstNameStringIdentifier]];
}

+(NSString *)getUserLastName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants lastNameStringIdentifier]];
}

/* - Used for User's Multipeer displayName when a session is created - */
+(NSString *)getUserDisplayableFullName {
    return [[[[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants firstNameStringIdentifier]]
             stringByAppendingString:@" "]
            stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants lastNameStringIdentifier]]
            ];
}

#pragma mark - Settings NSUserDefaults

/* - Controls whether or not user receives out-of-app notifications on completed downloads/uploads, etc. - */
+(void)setReceivePushNotificationsSettingTo:(BOOL)notificationsSetting {
    [[NSUserDefaults standardUserDefaults] setBool:notificationsSetting forKey:[AppConstants receivePushNotificationsSettingStringIdentifier]];
}

/* - Controls whether or not device idle timer is disabled - */
+(void)setKeepDeviceAwakeSettingTo:(BOOL)keepDeviceOnSetting {
    [[NSUserDefaults standardUserDefaults] setBool:keepDeviceOnSetting forKey:[AppConstants keepDeviceAwakeStringSettingIdentifier]];
}

+(BOOL)getReceivePushNotificationsSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[AppConstants receivePushNotificationsSettingStringIdentifier]];
}

+(BOOL)getKeepDeviceAwakeSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[AppConstants keepDeviceAwakeStringSettingIdentifier]];
}

//Informative Alerts

+(void)setUserShownDropboxLinkSharingDialogueTo:(BOOL)shownSetting {
    [[NSUserDefaults standardUserDefaults] setBool:shownSetting forKey:[AppConstants userShownDropboxLinkSharingDialogueStringIdentifier]];
}

+(void)setUserShownGoogleDriveLinkSharingDialogueTo:(BOOL)shownSetting {
    [[NSUserDefaults standardUserDefaults] setBool:shownSetting forKey:[AppConstants userShownGoogleDriveLinkSharingDialogueStringIdentifier]];
}

/* - Whether or not user has seen alert for Dropbox link sharing - */

+(BOOL)userShownDropboxLinkSharingDialogue {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[AppConstants userShownDropboxLinkSharingDialogueStringIdentifier]];
}

/* - Whether or not user has seen alert for Google Drive link sharing - */

+(BOOL)userShownGoogleDriveLinkSharingDialogue {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[AppConstants userShownGoogleDriveLinkSharingDialogueStringIdentifier]];
}

//General

+(void)setSettingsDefaults {
    [[self class] setReceivePushNotificationsSettingTo:YES];
    [[self class] setKeepDeviceAwakeSettingTo:NO];
    [[self class] setUserShownDropboxLinkSharingDialogueTo:NO];
    [[self class] setUserShownGoogleDriveLinkSharingDialogueTo:NO];
}

#pragma mark - friends.json

/* - Creates empty friends.json file - */
-(void)createFriendsJsonFile {
    [self storeJSONData:[[NSMutableDictionary alloc] init] InJSONFilesWithFileIdentifier:[AppConstants friendsJSONFileIdentifier]];
}

//------- Friend Methods -------//

/* - Adds a friend from a stranger. Files received from friends will not display any warning as files received from strangers do - */

-(void)addFriendWithName: (NSString*)newFriendName AndUUID: (NSString*)newFriendUUID {
    
    NSMutableDictionary *existingFriendsJSONTop;
    
    //If friends.json exists, get existing friends.json, else start with new empty friends.json NSDictionary
    if ([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier:[AppConstants friendsJSONFileIdentifier]]]) {
        
        existingFriendsJSONTop = [self readJSONFileWithFileIdenfifier:[AppConstants friendsJSONFileIdentifier]];
    }
    else {
        existingFriendsJSONTop = [[NSMutableDictionary alloc] init];
    }
    
    NSDictionary *allFriends = [existingFriendsJSONTop objectForKey:[AppConstants friendsStringIdentifier]];
    NSMutableDictionary *allFriendsMutable = [[NSMutableDictionary alloc] init];
    [allFriendsMutable addEntriesFromDictionary:allFriends];
    
    NSDictionary *friend = [allFriendsMutable objectForKey:newFriendUUID];
    
    //Only add peer as a new friend if peer isn't already friend
    if (friend == nil) {
        // Add new friend to end of friend dictionary
        NSMutableDictionary *newFriend = [NSMutableDictionary dictionaryWithObjectsAndKeys: newFriendName, [AppConstants friendNameStringIdentifier], newFriendUUID, [AppConstants UUIDStringIdentifier], nil];
    
        [allFriendsMutable setObject:newFriend forKey:newFriendUUID];
        [existingFriendsJSONTop setObject:allFriendsMutable forKey:[AppConstants friendsStringIdentifier]];
        [self storeJSONData:existingFriendsJSONTop InJSONFilesWithFileIdentifier:[AppConstants friendsJSONFileIdentifier]];
    }
    else {
        NSLog(@"Did not add peer as a new friend, peer is already a friend.");
    }
}

/* - Deletes a Friend - */

-(void)deleteFriendWithUUID: (NSString*)friendUUID {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier:[AppConstants friendsJSONFileIdentifier]]]) {
        
        NSMutableDictionary *existingFriendsJSONTop = [self readJSONFileWithFileIdenfifier:[AppConstants friendsJSONFileIdentifier]];
        NSDictionary *allFriends = [existingFriendsJSONTop objectForKey:[AppConstants friendsStringIdentifier]];
        NSMutableDictionary *allFriendsMutable = [[NSMutableDictionary alloc] init];
        [allFriendsMutable addEntriesFromDictionary:allFriends];
        
        NSDictionary *friendToDelete = [allFriendsMutable objectForKey:friendUUID];
        
        if (friendToDelete != nil) {
            [allFriendsMutable removeObjectForKey:friendUUID];
            [existingFriendsJSONTop setObject:allFriendsMutable forKey:[AppConstants friendsStringIdentifier]];
            [self storeJSONData:existingFriendsJSONTop InJSONFilesWithFileIdentifier:[AppConstants friendsJSONFileIdentifier]];
        }
        else {
            NSLog(@"Unable to delete friend. Friend's name associated with %@%@", friendUUID, @" does not exist.");
        }
    }
    else {
        NSLog(@"Tried to delete friend with UUID %@%@%@%@", friendUUID, @", but ", [AppConstants friendsJSONFileIdentifier], @" does not exist.");
    }
}

/* - Returns an NSDictionary containing all friends whose keys are numbered "0" to the total number of friends - */

-(NSArray*)getFriends {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier:[AppConstants friendsJSONFileIdentifier]]]) {
        NSMutableDictionary *existingFriendsJSONTop = [self readJSONFileWithFileIdenfifier:[AppConstants friendsJSONFileIdentifier]];
        NSDictionary *existingFriendsJSONAllFriends = [existingFriendsJSONTop objectForKey:[AppConstants friendsStringIdentifier]];
        NSMutableDictionary *existingFriendsJSONAllFriendsMutable = [[NSMutableDictionary alloc] init];
        [existingFriendsJSONAllFriendsMutable addEntriesFromDictionary:existingFriendsJSONAllFriends];
        NSArray *friendsArray = [existingFriendsJSONAllFriendsMutable allValues];
        NSArray *friendsArraySorted = [self sortFriends:friendsArray];
        
        return friendsArraySorted;
    }
    else {
        NSLog(@"Tried to return friends, but %@%@", [AppConstants friendsJSONFileIdentifier], @" does not exist.");
        return nil;
    }
}

/* - Checks if a specified person is an friend in friends.json - */

-(BOOL)FriendDoesExistWithUUID: (NSString*)friendUUID {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier:[AppConstants friendsJSONFileIdentifier]]]) {
        
        NSMutableDictionary *existingFriendsJSONTop = [self readJSONFileWithFileIdenfifier:[AppConstants friendsJSONFileIdentifier]];
        NSDictionary *allFriends = [existingFriendsJSONTop objectForKey:[AppConstants friendsStringIdentifier]];
        NSDictionary *friend = [allFriends objectForKey:friendUUID];
        
        //Check that the friend actually exists
        if (friend != nil) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

/* - When multipeer connects to a peer that is a friend, this method updates their name if it has changed - */

-(void)updateNameOfFriend: (NSString*)friendUUID IfNameChanged: (NSString*)currentFriendName {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier:[AppConstants friendsJSONFileIdentifier]]]) {
        
        NSMutableDictionary *existingFriendsJSONTop = [self readJSONFileWithFileIdenfifier:[AppConstants friendsJSONFileIdentifier]];
        NSDictionary *allFriends = [existingFriendsJSONTop objectForKey:[AppConstants friendsStringIdentifier]];
        NSMutableDictionary *allFriendsMutable = [[NSMutableDictionary alloc] init];
        [allFriendsMutable addEntriesFromDictionary:allFriends];
        NSDictionary *friend = [allFriendsMutable objectForKey:friendUUID];
        
        //Check that the friend actually exists
        if (friend != nil) {
            NSMutableDictionary *friendMutable = [[NSMutableDictionary alloc] init];
            [friendMutable addEntriesFromDictionary:friend];
            if (!([((NSString*)[friendMutable objectForKey:[AppConstants friendNameStringIdentifier]]) isEqualToString:currentFriendName])) {
                [friendMutable setObject: currentFriendName forKey: [AppConstants friendNameStringIdentifier]];
                [allFriendsMutable setObject:friendMutable forKey:friendUUID];
                [existingFriendsJSONTop setObject:allFriendsMutable forKey:[AppConstants friendsStringIdentifier]];
                [self storeJSONData:existingFriendsJSONTop InJSONFilesWithFileIdentifier:[AppConstants friendsJSONFileIdentifier]];
            }
        }
    }
}

/* - Sorts Array of dictionaries by name key - */

-(NSArray*)sortFriends: (NSArray*)friendsArray {
    NSArray *friendsArraySorted = [friendsArray sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSString *name1 = [(NSDictionary *)obj1 objectForKey:[AppConstants friendNameStringIdentifier]];
        NSString *name2 = [(NSDictionary *)obj2 objectForKey:[AppConstants friendNameStringIdentifier]];
        return [name1 caseInsensitiveCompare:name2];
    }];
    
    return friendsArraySorted;
}



#pragma mark - .json File Management

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

/* - Prints name of all JSON Files currently in documents directory - */

-(void)printNamesOfAllJSONFilesInDocumentsDirectory {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryContents = [manager contentsOfDirectoryAtPath:[AppConstants pathForRootDocumentsDirectory] error:&error];
    
    if (error) {
        NSLog(@"%s COULD NOT FIND ITEMS ERROR: %@", __PRETTY_FUNCTION__, error);
    }
    else {
        
        for (NSString *item in directoryContents) {
            
            if ([item hasSuffix:@".json"] || [item hasSuffix:@".JSON"]) {
                NSLog(@"Found: %@",item);
            }
        }
    }
}

-(void)printJsonStructureOfJsonFileWithFileIdentifier: (NSString*)jsonFileIdentifier {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier: jsonFileIdentifier]]) {
        
        NSLog(@"json structure of %@%@%@", jsonFileIdentifier, @" is ", [self readJSONFileWithFileIdenfifier:jsonFileIdentifier]);
    }
    else {
        NSLog(@"File does not exist: %@", jsonFileIdentifier);
    }
}


-(BOOL)JSONFileExistsWithFileIdentifier: (NSString*) fileIdentifier {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[AppConstants pathForJSONFileWithIdentifier:fileIdentifier]]) {
        return YES;
    }
    else {
        return NO;
    }
}

/* - Deletes specific JSON file in documents directory - */

-(BOOL) deleteJSONFileInDocumentsDirectoryWithFileIdentifier: (NSString*)fileIdentifier {
    
    NSError *error = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // - get the path to .JSON file - //
    NSString *JSONPath = [AppConstants pathForJSONFileWithIdentifier:fileIdentifier];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:JSONPath]) {
        
        BOOL removeSuccess = [manager removeItemAtPath:JSONPath error:&error];
        
        if (!removeSuccess) {
            NSLog(@"%s COULD NOT DELETE JSON FILE ERROR: %@", __PRETTY_FUNCTION__, error);
            return NO;
        }
        else {
            NSLog(@"DELETED %@", fileIdentifier);
            return YES;
        }
    }
    else {
        NSLog(@"Tried to delete %@%@", fileIdentifier, @" but the file does not exist.");
        return NO;
    }
}

#pragma mark - PeerDisplayNameManipulation

+(NSString*)getPeerNameFromDisplayName: (NSString*)displayName {
    NSArray *strings = [displayName componentsSeparatedByString:@"|"];
    return [strings objectAtIndex:0];
}

+(NSString*)getUUIDFromDisplayName: (NSString*)displayName {
    NSArray *strings = [displayName componentsSeparatedByString:@"|"];
    return [strings objectAtIndex:1];
}

@end
