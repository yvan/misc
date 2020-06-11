//
//  SettingsManager.m
//  Hexlist
//
//  Created by Yvan Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "SettingsManager.h"

@interface SettingsManager()

@end

@implementation SettingsManager

#pragma mark - App version

+(NSString*)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
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

+(void)setMyHexColor:(NSString*)hexColorString {
    [[NSUserDefaults standardUserDefaults] setObject:hexColorString forKey:[AppConstants myHexColorStringIdentifier]];
}

+(void)setMyHexColorDefault {
    [[NSUserDefaults standardUserDefaults] setObject:[AppConstants hexStringFromColor:[AppConstants myHexColorDefault]] forKey:[AppConstants myHexColorStringIdentifier]];
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

+(NSString *)getMyHexColor {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants myHexColorStringIdentifier]];
}

#pragma mark - Settings NSUserDefaults

/* - Controls whether or not device idle timer is disabled - */
+(void)setKeepDeviceAwakeSettingTo:(BOOL)keepDeviceOnSetting {
    [[NSUserDefaults standardUserDefaults] setBool:keepDeviceOnSetting forKey:[AppConstants keepDeviceAwakeStringSettingIdentifier]];
}

+(BOOL)getKeepDeviceAwakeSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[AppConstants keepDeviceAwakeStringSettingIdentifier]];
}

//Informative Alerts

/* - Whether or not user has seen alert for link sharing from a Service- */

+(BOOL)userHasBeenShownLinkSharingDialogueForServiceType:(ServiceType)serviceType {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[AppConstants userHasBeenShownLinkSharingDialogueStringIdentifierForServiceType:serviceType]];
}

+(void)setUserHasBeenShownLinkSharingDialogueForServiceType:(ServiceType)serviceType To:(BOOL)shownSetting {
    [[NSUserDefaults standardUserDefaults] setBool:shownSetting forKey:[AppConstants userHasBeenShownLinkSharingDialogueStringIdentifierForServiceType:serviceType]];
}

+(void)setUserHasBeenShownLinkSharingDialogueToNoForAllServiceTypes {
    NSArray *serviceTypes = [AppConstants allServiceTypes];
    
    for (NSNumber *serviceType in serviceTypes) {
        [self setUserHasBeenShownLinkSharingDialogueForServiceType:[serviceType integerValue] To:NO];
    }
}

/* - Whether or not the user has been shown an HUD about pasting links into a Hex. - */

+(BOOL)userHasBeenShownLinkPasteHUD {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[AppConstants userHasBeenShownLinkPasteHUD]];
}

+(void)setUserHasBeenShownLinkPasteHUD:(BOOL)shownSetting {
    [[NSUserDefaults standardUserDefaults] setBool:shownSetting forKey:[AppConstants userHasBeenShownLinkPasteHUD]];
}

//Blocking Users
+(void)setEmptyBlockedUserUUIDsArray {
    [[NSUserDefaults standardUserDefaults] setObject:[[NSArray alloc] init] forKey:[AppConstants blockedUserUUIDsStringIdentifier]];
}

+(void)blockUserWithUUID:(NSString*)userUUID {
    NSMutableArray *blockedUserUUIDs = [[[NSUserDefaults standardUserDefaults] arrayForKey:[AppConstants blockedUserUUIDsStringIdentifier]] mutableCopy];
    [blockedUserUUIDs addObject:userUUID];
    [[NSUserDefaults standardUserDefaults] setObject:blockedUserUUIDs forKey:[AppConstants blockedUserUUIDsStringIdentifier]];
}

+(void)unblockUserWithUUID:(NSString*)userUUID {
    NSMutableArray *blockedUserUUIDs = [[[NSUserDefaults standardUserDefaults] arrayForKey:[AppConstants blockedUserUUIDsStringIdentifier]] mutableCopy];
    [blockedUserUUIDs removeObject:userUUID];
    [[NSUserDefaults standardUserDefaults] setObject:blockedUserUUIDs forKey:[AppConstants blockedUserUUIDsStringIdentifier]];
}

+(BOOL)userWithUUIDIsBlocked:(NSString*)userUUID {
    NSArray *blockedUserUUIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:[AppConstants blockedUserUUIDsStringIdentifier]];
    return  [blockedUserUUIDs containsObject:userUUID];
}

+(NSArray*)getBlockedUserUUIDs {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:[AppConstants blockedUserUUIDsStringIdentifier]];
}

//General

+(void)setSettingsDefaults {
    [self setKeepDeviceAwakeSettingTo:NO];
    [self setUserHasBeenShownLinkSharingDialogueToNoForAllServiceTypes];
    [self setMyHexColorDefault];
    [self setEmptyBlockedUserUUIDsArray];
}

@end
