//
//  LocalStorageManager.h
//  Airdoc
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.

//  This is a class created to store soft data (user preferences, friends, history, etc) locally

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface LocalStorageManager : NSObject

#pragma mark - Initializations

-(id)init;

#pragma mark - User NSUserDefaults

+(void)setUserFirstName:(NSString*)firstName;
+(void)setUserLastName:(NSString*)lastName;

+(NSString *)getUserFirstName;
+(NSString *)getUserLastName;
+(NSString *)getUserDisplayableFullName;

#pragma mark - Settings NSUserDefaults

//Settings

+(void)setReceivePushNotificationsSettingTo:(BOOL)notificationsSetting;
+(void)setKeepDeviceAwakeSettingTo:(BOOL)keepDeviceOnSetting;
+(BOOL)getReceivePushNotificationsSetting;
+(BOOL)getKeepDeviceAwakeSetting;

//Informative Alerts
+(void)setUserShownDropboxLinkSharingDialogueTo:(BOOL)shownSetting;
+(void)setUserShownGoogleDriveLinkSharingDialogueTo:(BOOL)shownSetting;
+(BOOL)userShownDropboxLinkSharingDialogue;
+(BOOL)userShownGoogleDriveLinkSharingDialogue;

//General
+(void)setSettingsDefaults;


#pragma mark - friends.json

-(void)createFriendsJsonFile;

-(void)addFriendWithName: (NSString*)newFriendName AndUUID: (NSString*)newFriendUUID;
-(void)deleteFriendWithUUID: (NSString*)friendUUID;
-(NSArray*)getFriends;
-(BOOL)FriendDoesExistWithUUID: (NSString*)UUID;
-(void)updateNameOfFriend: (NSString*)friendUUID IfNameChanged: (NSString*)newFriendName;

#pragma mark - .json File Management

-(BOOL)storeJSONData:(NSMutableDictionary*) data InJSONFilesWithFileIdentifier: (NSString*)fileIdentifier;
-(NSMutableDictionary *)readJSONFileWithFileIdenfifier: (NSString *)fileIdentifier;
-(void)printNamesOfAllJSONFilesInDocumentsDirectory;
-(void)printJsonStructureOfJsonFileWithFileIdentifier: (NSString*)jsonFileIdentifier;
-(BOOL)JSONFileExistsWithFileIdentifier: (NSString*)fileIdentifier;
-(BOOL)deleteJSONFileInDocumentsDirectoryWithFileIdentifier: (NSString*)fileIdentifier;

#pragma mark - PeerDisplayNameManipulation

+(NSString*)getPeerNameFromDisplayName: (NSString*)displayName;
+(NSString*)getUUIDFromDisplayName: (NSString*)displayName;

@end
