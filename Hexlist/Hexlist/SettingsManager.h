//
//  SettingsManager.h
//  Hexlist
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.

//This is a class created to persist soft data (user preferences)

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "Location.h"

@interface SettingsManager : NSObject

#pragma mark - App version

+(NSString*)getAppVersion;

#pragma mark - User NSUserDefaults

+(void)setUserFirstName:(NSString*)firstName;
+(void)setUserLastName:(NSString*)lastName;
+(void)setMyHexColor:(NSString*)hexColorString;

+(NSString *)getUserFirstName;
+(NSString *)getUserLastName;
+(NSString *)getUserDisplayableFullName;
+(NSString *)getMyHexColor;

#pragma mark - Settings NSUserDefaults

//Settings
+(void)setKeepDeviceAwakeSettingTo:(BOOL)keepDeviceOnSetting;
+(BOOL)getKeepDeviceAwakeSetting;

//Informative Alerts
+(BOOL)userHasBeenShownLinkSharingDialogueForServiceType:(ServiceType)serviceType;
+(void)setUserHasBeenShownLinkSharingDialogueForServiceType:(ServiceType)serviceType To:(BOOL)shownSetting;
+(BOOL)userHasBeenShownLinkPasteHUD;
+(void)setUserHasBeenShownLinkPasteHUD:(BOOL)shownSetting;

//Blocking Users
+(void)setEmptyBlockedUserUUIDsArray;
+(void)blockUserWithUUID:(NSString*)userUUID;
+(void)unblockUserWithUUID:(NSString*)userUUID;

+(BOOL)userWithUUIDIsBlocked:(NSString*)userUUID;
+(NSArray*)getBlockedUserUUIDs;

//General
+(void)setSettingsDefaults;

@end
