//
//  AppConstants.h
//  Hexlist
//
//  Created by Roman Scher on 7/1/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Chameleon.h"

@interface AppConstants : NSObject

+(NSString*)rootPathStringIdentifier;

#pragma mark - General App Constants

+(NSString*)appName;
+(NSURL*)appCallbackUrl;
+(UIColor*)appSchemeColor;
+(UIColor *)appSchemeColorB;
+(UIColor *)appSchemeColorC;
+(NSString *)appFontNameA;
+(NSString *)appFontNameB;

+(UIColor *)settingsTableViewSeparatorColor;
+(UIColor *)tableViewSeparatorColor;
+(UIColor *)inboxtableViewSeparatorColor;
+(UIColor *)fileOptionsToolbarSeparatorColor;
+(UIColor *)grayTableViewBackgroundColor;
+(UIColor *)tableViewSelectionColor;

+(UIColor *)fadedWhiteColor;
+(UIColor *)circleButtonSelectionColor;
+(UIColor *)progressViewColor;
+(UIColor *)linkButtonColor;
+(UIColor*)hexCellButtonColor;
+(UIColor *)myHexColorDefault;

+(UIColor *)niceRandomColor;
+(NSString *)hexStringFromColor:(UIColor *)color;
+(UIColor *)colorFromHexString:(NSString *)hexString;

+(UIImage *)imageWithColor:(UIColor *)color;
+(UIImage *)imageWithView:(UIView *)view;
+(UIImage *)changeColorOfImage: (UIImage*)image ToColor: (UIColor*)color;
+(UIImage *) drawText:(NSString*) text inImage:(UIImage*)image withFont:(UIFont*)font;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
+(UIImage *)imageFromText:(NSString *)text withFont:(UIFont*)font;

#pragma mark - Image Assets Identifiers

+(NSString*)appIconImageStringIdentifier;
+(NSString*)desertAImageStringIdentifier;
+(NSString*)localImageStringIdentifier;
+(NSString*)boxImageStringIdentifier;
+(NSString*)dropboxImageStringIdentifier;
+(NSString*)googleDriveImageStringIdentifier;
+(NSString*)boxNavImageStringIdentifier;
+(NSString*)dropboxNavImageStringIdentifier;
+(NSString*)googleDriveNavImageStringIdentifier;
+(NSString*)hexlistNavImageStringIdentifier;

//Toolbar
+(NSString*)linkToolbarImageStringIdentifier;
+(NSString*)hexOptionsToolbarImageStringIdentifier;

//Circle Button
+(NSString*)sendImageStringIdentifier;
+(NSString*)sendLinkImageStringIdentifier;

//UIActivies
+(NSString*)copyLinkImageStringIdentifier;
+(NSString*)safariImageStringIdentifier;
+(NSString*)chromeImageStringIdentifier;

//General

+(NSString*)trashWhiteImageStringIdentifier;
+(NSString*)acceptWhiteImageStringIdentifier;
+(NSString*)globeImageStringIdentifier;

#pragma mark Cell Members

//Send Cell
+(NSString*)checkMarkOutlineImageStringIdentifier;
+(NSString*)checkMarkImageStringIdentifier;

//HexCell
+(NSString*)sendHexImageStringIdentifier;
+(NSString*)addLinksImageStringIdentifier;
+(NSString*)hexActionsImageStringIdentifier;
+(NSString*)hexCheckmarkImageStringIdentifier;
+(NSString*)dropboxLinkImageStringIdentifier;
+(NSString*)boxLinkImageStringIdentifier;
+(NSString*)googleDriveLinkImageStringIdentifier;
+(NSString*)generalLinkImageStringIdentifier;

//Create View
+(NSString*)linkEditImageStringIdentifier;

//Others
+(NSString*)reloadImageStringIdentifier;
+(NSString*)backArrowButtonImageStringIdentifier;
+(NSString*)settingsImageStringIdentifier;
+(NSString*)unselectXImageStringIdentifier;
+(NSString*)cancelImageStringIdentifier;
+(NSString*)paintImageStringIdentifier;
+(NSString*)addImageStringIdentifier;
+(NSString*)folderImageStringIdentifier;

#pragma mark - Custom Cell Identifiers

+(NSString*)strangerCellStringIdentifier;
+(NSString*)sendCellStringIdentifier;
+(NSString*)requestCellStringIdentifier;
+(NSString*)inboxCellStringIdentifier;
+(NSString*)incomingSendProgressCellStringIdentifier;
+(NSString*)hexCellReuseIdentifierStringIdentifier;
+(NSString*)hexCellTriReuseIdentifierStringIdentifier;
+(NSString*)linkCellStringIdentifier;
+(NSString*)settingsCellStringIdentifier;
+(NSString*)settingsSwitchCellStringIdentifier;
+(NSString*)settingsCellSpecialStringIdentifier;
+(NSString*)settingsServiceCellStringIdentifier;
+(NSString*)myHexColorCellStringIdentifier;
+(NSString*)nameCellStringIdentifier;
+(NSString*)connectToolbarCellStringIdentifier;

#pragma mark - NSUserDefaults

//User & Settings
+(NSString*)firstNameStringIdentifier;
+(NSString*)lastNameStringIdentifier;
+(NSString*)myHexColorStringIdentifier;
+(NSString*)keepDeviceAwakeStringSettingIdentifier;
+(NSString*)blockedUserUUIDsStringIdentifier;

//Inbox
+(NSString*)numberOfUncheckedHexesStringIdentifier;

#pragma mark - Toolbar Actions

typedef NS_ENUM(NSInteger, ToolbarAction) {
    ToolbarActionGrabLink,
    ToolbarActionGrabLinks,
    ToolbarActionStoreLink,
    ToolbarActionStoreLinks
};

#pragma mark - Link Actions

typedef NS_ENUM(NSInteger, LinkAction) {
    LinkActionCreateLink,
    LinkActionStoreLink,
    LinkActionSendLink
};

#pragma mark - CreateView Actions

typedef NS_ENUM(NSInteger, CreateViewAction) {
    CreateViewActionCreateHex,
    CreateViewActionEditHex,
    CreateViewActionCloudSend,
    CreateViewActionEditLink,
    CreateViewActionViewLink
};

#pragma mark - MyHexList Actions

typedef NS_ENUM(NSInteger, MyHexlistAction) {
    MyHexlistActionDefault,
    MyHexlistActionAddToHex
};

#pragma mark - Send Types

typedef NS_ENUM(NSInteger, SendType) {
    SendTypeHex,
    SendTypeCloudHex
};

#pragma mark - Hex Cell Types

typedef NS_ENUM(NSInteger, HexCellType) {
    HexCellTypeMyHexlist,
    HexCellTypeInbox
};

#pragma mark - Legal Type

typedef NS_ENUM(NSInteger, LegalType) {
    LegalTypePrivacyPolicy,
    LegalTypeEndUserLicenseAgreement,
    LegalTypeAttribution
};

#pragma mark - Settings Content Type

typedef NS_ENUM(NSInteger, SettingsContentType) {
    SettingsContentTypeRoot,
    SettingsContentTypeLegal
};

#pragma mark - Name View Types

typedef NS_ENUM(NSInteger, NameViewType) {
    NameViewTypeGiveName,
    NameViewTypeChangeName
};

//Data Sends

#pragma mark - OperationTypes

//OperationTypeStore: Used to store an object on the receiver's end

typedef NS_ENUM(NSInteger, OperationType) {
    OperationTypeStore,
    OperationTypeAlert
};

+(NSString*)stringForOperationType:(OperationType)operationType;
+(OperationType)operationTypeForString:(NSString*)string;

#pragma mark - JMObjectTypes

typedef NS_ENUM(NSInteger, JMObjectType) {
    JMObjectTypeNone,
    JMObjectTypeHex
};

+(NSString*)stringForJMObjectType:(JMObjectType)objectType;
+(JMObjectType)jmObjectTypeForString:(NSString*)string;

#pragma mark - Hex Locations

typedef NS_ENUM(NSInteger, HexLocationType) {
    HexLocationTypeMyHexlist,
    HexLocationTypeInbox
};

+(NSArray*)allHexLocationTypes;
+(NSString*)stringForHexLocationType:(HexLocationType)hexLocationType;
+(HexLocationType)hexLocationTypeForString:(NSString*)string;

//Services

#pragma mark - ServiceTypes

//Always add new service types to the end of the list

typedef NS_ENUM(NSInteger, ServiceType) {
    ServiceTypeUnknown,
    ServiceTypeDropbox,
    ServiceTypeBox,
    ServiceTypeGoogleDrive
};

+(NSArray*)allServiceTypes;
+(NSString*)stringForServiceType:(ServiceType)serviceType;
+(ServiceType)serviceTypeForString:(NSString*)string;

+(NSString*)presentableStringForServiceType:(ServiceType)serviceType;
+(NSString*)userHasBeenShownLinkSharingDialogueStringIdentifierForServiceType:(ServiceType)serviceType;
+(NSString*)userHasBeenShownLinkPasteHUD;
+(UIImage*)serviceNavImageForServiceType:(ServiceType)serviceType;
+(UIImage*)serviceLinkImageForServiceType:(ServiceType)serviceType;


@end
