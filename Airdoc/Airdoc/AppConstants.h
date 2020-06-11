//
//  AppConstants.h
//  Envoy
//
//  Created by Roman Scher on 7/1/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Chameleon.h"

@interface AppConstants : NSObject

#pragma mark - General App Constants

+(NSString*)appName;
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

+(UIColor *)fadedWhiteColor;
+(UIColor *)addButtonPopupSelectionColor;
+(UIColor *)progressViewColor;
+(UIColor *)linkCellButtonColor;

+(UIColor *)niceRandomColor;

+(UIImage *)imageWithColor:(UIColor *)color;
+(UIImage *)imageWithView:(UIView *)view;
+(UIImage *)changeColorOfImage: (UIImage*)image ToColor: (UIColor*)color;
+(UIImage *) drawText:(NSString*) text inImage:(UIImage*)image withFont:(UIFont*)font;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
+(UIImage *)imageFromText:(NSString *)text withFont:(UIFont*)font;

#pragma mark - Presentable Strings

+(NSString*)dropboxPresentableString;
+(NSString*)googleDrivePresentableString;
+(NSString*)cameraRollPresentableString;

#pragma mark - Image Assets Identifiers

+(NSString*)appIconStringIdentifier;
+(NSString*)desertAStringIdentifier;
+(NSString*)desertBStringIdentifier;
+(NSString*)localStringIdentifier;
+(NSString*)boxStringIdentifier;
+(NSString*)dropboxStringIdentifier;
+(NSString*)googleDriveStringIdentifier;
+(NSString*)boxNavStringIdentifier;
+(NSString*)localNavStringIdentifier;
+(NSString*)dropboxNavStringIdentifier;
+(NSString*)googleDriveNavStringIdentifier;
+(NSString*)envoyNavStringIdentifier;
+(NSString*)cameraRollNavStringIdentifier;

//Toolbar popups
+(NSString*)dropboxToolbarPopupImageStringIdentifier;
+(NSString*)googleDriveToolbarPopupImageStringIdentifier;
+(NSString*)cameraRollToolbarPopupImageStringIdentifier;
+(NSString*)newFolderPopupImageStringIdentifier;
+(NSString*)addPhotosPopupImageStringIdentifier;
+(NSString*)renamePopupImageStringIdentifier;
+(NSString*)previewPopupImageStringIdentifier;

//Toolbar
+(NSString*)downloadImageStringIdentifier;
+(NSString*)cancelDownloadImageStringIdentifier;
+(NSString*)uploadImageStringIdentifier;
+(NSString*)moveImageStringIdentifier;
+(NSString*)deleteImageStringIdentifier;
+(NSString*)renameImageStringIdentifier;
+(NSString*)previewImageStringIdentifier;
+(NSString*)actionsImageStringIdentifier;
+(NSString*)sendLinkToolbarImageStringIdentifier;
+(NSString*)paperAirplaneToolbarImageStringIdentifier;

//Circle Button
+(NSString*)sendImageStringIdentifier;
+(NSString*)sendLinkImageStringIdentifier;

//Others

+(NSString*)addFriendStringIdentifier;
+(NSString*)removeFriendStringIdentifier;
+(NSString*)checkMarkOutlineStringIdentifier;
+(NSString*)checkMarkStringIdentifier;
+(NSString*)trashImageStringIdentifier;
+(NSString*)acceptImageStringIdentifier;
+(NSString*)acceptWhiteImageStringIdentifier;
+(NSString*)reloadStringIdentifier;
+(NSString*)resendBlackStringIdentifier;
+(NSString*)starOutlineStringIdentifier;
+(NSString*)yellowStarStringIdentifier;
+(NSString*)backArrowButtonStringIdentifier;
+(NSString*)backArrowButtonReversedStringIdentifier;
+(NSString*)moreFillStringIdentifier;
+(NSString*)requestsStringIdentifier;
+(NSString*)settingsStringIdentifier;
+(NSString*)unselectXStringIdentifier;
+(NSString*)cancelStringIdentifier;
+(NSString*)largeCircleOutlineStringIdentifier;
+(NSString*)largeCircleGreenStringIdentifier;
+(NSString*)filesSelectedStringIdentifier;
+(NSString*)filesUnselectedStringIdentifier;
+(NSString*)addImageStringIdentifier;
+(NSString*)folderImageStringIdentifier;
+(NSString*)folderDownloadsImageStringIdentifier;
+(NSString*)folderSendsImageStringIdentifier;
+(NSString*)folderEnvoyImageStringIdentifier;
+(NSString*)folderDownloadsSelectedImageStringIdentifier;
+(NSString*)folderSendsSelectedImageStringIdentifier;
+(NSString*)folderEnvoySelectedImageStringIdentifier;

#pragma mark - Custom Cell Identifiers

+(NSString*)friendCellStringIdentifier;
+(NSString*)strangerCellStringIdentifier;
+(NSString*)sendCellStringIdentifier;
+(NSString*)requestCellStringIdentifier;
+(NSString*)inboxCellStringIdentifier;
+(NSString*)incomingSendProgressCellStringIdentifier;
+(NSString*)linkPackageCellStringIdentifier;
+(NSString*)settingsCellStringIdentifier;
+(NSString*)settingsSwitchCellStringIdentifier;
+(NSString*)settingsCellSpecialStringIdentifier;
+(NSString*)nameCellStringIdentifier;
+(NSString*)changePasswordCellStringIdentifier;
+(NSString*)connectToolbarCellStringIdentifier;

#pragma mark - toolbar & Add Button Actions String Identifiers

+(NSString*)toolbarDownloadActionStringIdentifier;
+(NSString*)toolbarDownloadHereActionStringIdentifier;
+(NSString*)toolbarUploadActionStringIdentifier;
+(NSString*)toolbarUploadHereActionStringIdentifier;
+(NSString*)toolbarMoveActionStringIdentifier;
+(NSString*)toolbarDeleteActionStringIdentifier;
+(NSString*)toolbarRenameActionStringIdentifier;
+(NSString*)toolbarPreviewActionStringIdentifier;
+(NSString*)toolbarActionsActionStringIdentifier;
+(NSString*)toolbarSendActionStringIdentifier;
+(NSString*)toolbarCancelDownloadActionStringIdentifier;
+(NSString*)toolbarCancelUploadActionStringIdentifier;
+(NSString*)toolbarSendLinkActionStringIdentifier;
+(NSString*)AddButtonNewFolderActionStringIdentifier;

#pragma mark - Send Type String Identifiers

+(NSString*)SEND_TYPE_FILE;
+(NSString*)SEND_TYPE_LINK;

#pragma mark - sending & receiving String Identifiers

+(NSString*)peerIDStringIdentifier;
+(NSString*)zippedFilePathStringIdentifier;
+(NSString*)resourceNameStringIdentifier;
+(NSString*)sendingOrReceivingStringIdentifier;
+(NSString*)sendProgressStringIdentifier;
+(NSString*)observerStringIdentifier;

#pragma mark - NSUserDefaults 

//User & Settings
+(NSString*)firstNameStringIdentifier;
+(NSString*)lastNameStringIdentifier;
+(NSString*)receivePushNotificationsSettingStringIdentifier;
+(NSString*)keepDeviceAwakeStringSettingIdentifier;

//Informative Alerts
+(NSString*)userShownDropboxLinkSharingDialogueStringIdentifier;
+(NSString*)userShownGoogleDriveLinkSharingDialogueStringIdentifier;

//Inbox
+(NSString*)numberOfUncheckedFilePackagesStringIdentifier;
+(NSString*)numberOfUncheckedLinkPackagesStringIdentifier;
+(NSString*)totalNumberOfUncheckedPackagesStringIdentifier;

#pragma mark - friends.json String Identifiers

+(NSString*)friendNameStringIdentifier;
+(NSString*)friendsStringIdentifier;
+(NSString*)UUIDStringIdentifier;
+(NSString*)timestampStringIdentifier;

#pragma mark - inbox.json String Identifiers

+(NSString*)filePackagesStringIdentifier;
+(NSString*)receivedDateStringIdentifier;
+(NSString*)sentByStringIdentifier;
+(NSString*)sentByUUIDStringIdentifier;
+(NSString*)filePackageUUIDStringIdentifier;
+(NSString*)filesStringIdentifier;
+(NSString*)fileNameStringIdentifier;
+(NSString*)fileUrlStringIdentifier;
+(NSString*)createdStringIdentifier;
+(NSString*)revisionStringIdentifier;
+(NSString*)boxIdStringIdentifier;
+(NSString*)isDirectoryStringIdentifier;

#pragma mark - .json File String Identifiers

+(NSString*)friendsJSONFileIdentifier;
+(NSString*)incomingStringIdentifier;
+(NSString*)inboxJSONFileIdentifier;
+(NSString*)pathForRootDocumentsDirectory;
+(NSString*)pathForJSONFileWithIdentifier: (NSString*) fileIdentifier;
+(NSString*)pathForFilePackage: (NSDictionary*)filePackageUUID;

@end
