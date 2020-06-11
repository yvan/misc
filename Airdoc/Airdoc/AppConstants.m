//
//  AppConstants.m
//  Envoy
//
//  Created by Roman Scher on 7/1/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "AppConstants.h"

@implementation AppConstants

#pragma mark - General App Constants

+(NSString*)appName {
    return @"Envoy";
}

+(UIColor *) appSchemeColor {
    return [UIColor colorWithRed:163.0/255.0 green:30.0/255.0 blue:57.0/255.0 alpha:1]; //Lively Reddish
}

+(UIColor *) appSchemeColorB {
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]; //White
}

+(UIColor *) appSchemeColorC {
    return [UIColor colorWithRed:10.0/255.0 green:73.0/255.0 blue:88.0/255.0 alpha:1]; //Bluish Green
}

+(NSString *) appFontNameA {
    return @"Avenir-Heavy";
}
+(NSString *) appFontNameB {
    return @"Avenir-Heavy";
}



+(UIColor *)settingsTableViewSeparatorColor {
    return [UIColor colorWithRed:223.0/255.0 green:225.0/255.0 blue:227.0/255.0 alpha:1];
}

+(UIColor *) tableViewSeparatorColor {
    return [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1]; //Light Grey;
}

+(UIColor *) inboxtableViewSeparatorColor {
    return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1]; //Light Grey;
}

+(UIColor *)fileOptionsToolbarSeparatorColor {
//    return [UIColor colorWithRed:55.0/255.0 green:90.0/255.0 blue:98.0/255.0 alpha:1.0]; // current
    return [UIColor colorWithRed:37.0/255.0 green:90.0/255.0 blue:102.0/255.0 alpha:1];
}



+(UIColor *)grayTableViewBackgroundColor {
//    return [UIColor colorWithRed:230.0/255.0 green:231.0/255.0 blue:232.0/255.0 alpha:1];
    return [UIColor colorWithRed:242.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1];
}

+(UIColor *)fadedWhiteColor {
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:.25];
}

+(UIColor *)addButtonPopupSelectionColor {
    return [UIColor colorWithRed:175.0/255.0 green:66.0/255.0 blue:87.0/255.0 alpha:1];
}

+(UIColor *)progressViewColor {
    return [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:255.0/255.0 alpha:1];
}

+(UIColor *)linkCellButtonColor {
    return [UIColor colorWithRed:67.0/255.0 green:68.0/255.0 blue:69.0/255.0 alpha:1];
}



+(UIColor *)niceRandomColor {
//    // This method returns a random color in a range of nice ones,
//    // using HSB coordinates.
//    
//    // Random hue from 0 to 359 degrees.
//    
//    CGFloat hue = (arc4random() % 360) / 359.0f;
//    
//    // Random saturation from 0.0 to 1.0
//    
//    CGFloat saturation = (float)arc4random() / UINT32_MAX;
//    
//    // Random brightness from 0.0 to 1.0
//    
//    CGFloat brightness = (float)arc4random() / UINT32_MAX;
//    
//    // Limit saturation and brightness to get a nice colors palette.
//    // Remove the following 2 lines to generate a color from the full range.
//    
//    saturation = saturation < 0.5 ? 0.5 : saturation;
//    brightness = brightness < 0.9 ? 0.9 : brightness;
//    
//    // Return a random UIColor.
//    
//    return [UIColor colorWithHue:hue
//                      saturation:saturation
//                      brightness:brightness
//                           alpha:1];
    
    UIColor *randomColor;
    do {
        randomColor = [UIColor randomFlatColor];
    }while ([randomColor isEqual:[UIColor flatBlackColor]] || [randomColor isEqual:[UIColor flatBlackColorDark]] ||
            [randomColor isEqual:[UIColor flatGrayColor]]  || [randomColor isEqual:[UIColor flatGrayColorDark]]  ||
            [randomColor isEqual:[UIColor flatWhiteColor]] || [randomColor isEqual:[UIColor flatWhiteColorDark]] ||
            [randomColor isEqual:[UIColor flatPinkColor]]  || [randomColor isEqual:[UIColor flatPinkColorDark]]);
    
    return randomColor;
    
}


+(UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage *)changeColorOfImage: (UIImage*)image ToColor: (UIColor*)color {
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return flippedImage;
}

/* - Creates and returns an image from a view - */

+(UIImage *) imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+(UIImage *) drawText:(NSString*)text inImage:(UIImage*)image withFont:(UIFont*)font {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    CGRect rect = CGRectMake(12.0, 7.0, image.size.width, image.size.height);
    
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withAttributes:[[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil]];
//    [UIColor whiteColor], NSForegroundColorAttributeName,
    
    //    size_t width =  CGImageGetWidth(image.CGImage)/2.0;
    //    size_t height = CGImageGetHeight(image.CGImage)/2.0;
    //    size_t bitsPerComponent = CGImageGetBitsPerComponent(image.CGImage);
    //    size_t bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
    //    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    //    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(image.CGImage);
    //
    //    CGContextRef context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    //
    //    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size {
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/* - Gets an image from an NSString's text - */

+(UIImage *)imageFromText:(NSString *)text withFont:(UIFont*)font {
    //Size of text with font
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName: font}];
    
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    
    [text drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:@{NSFontAttributeName: font}];
    
    //Get image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Presentable Strings

+(NSString*)dropboxPresentableString {
    return @"Dropbox";
}

+(NSString*)googleDrivePresentableString {
    return @"Google Drive";
}

+(NSString*)cameraRollPresentableString {
    return @"Camera Roll";
}

#pragma mark - Image Assets Identifiers

+(NSString*)appIconStringIdentifier {
    return @"AppIcon";
}

+(NSString*)desertAStringIdentifier {
    return @"desertA";
}

+(NSString*)desertBStringIdentifier {
    return @"desertB";
}

+(NSString*)localStringIdentifier {
    return @"local";
}

+(NSString*)boxStringIdentifier {
    return @"box";
}

+(NSString*)dropboxStringIdentifier {
    return @"dropbox";
}

+(NSString*)googleDriveStringIdentifier {
    return @"googledrive";
}

+(NSString*)localNavStringIdentifier {
    return @"localNav";
}

+(NSString*)boxNavStringIdentifier {
    return @"boxNav";
}

+(NSString*)dropboxNavStringIdentifier {
    return @"dropboxNav";
}

+(NSString*)googleDriveNavStringIdentifier {
    return @"googleDriveNav";
}

+(NSString*)envoyNavStringIdentifier {
    return @"envoyNav";
}

+(NSString*)cameraRollNavStringIdentifier {
    return @"cameraRollNav";
}

//Toolbar popups

+(NSString*)dropboxToolbarPopupImageStringIdentifier {
    return @"dropboxToolbarPopup";
}

+(NSString*)googleDriveToolbarPopupImageStringIdentifier {
    return @"googleDriveToolbarPopup";
}

+(NSString*)cameraRollToolbarPopupImageStringIdentifier {
    return @"cameraRollToolbarPopup";
}

+(NSString*)newFolderPopupImageStringIdentifier {
    return @"newFolderPopup";
}

+(NSString*)addPhotosPopupImageStringIdentifier {
    return @"addPhotosPopup";
}

+(NSString*)renamePopupImageStringIdentifier {
    return @"renamePopup";
}

+(NSString*)previewPopupImageStringIdentifier {
    return @"previewPopup";
}

//Toolbar

+(NSString*)downloadImageStringIdentifier {
    return @"download";
}

+(NSString*)cancelDownloadImageStringIdentifier {
    return @"cancelDownload";
}

+(NSString*)uploadImageStringIdentifier {
    return @"upload";
}

+(NSString*)moveImageStringIdentifier {
    return @"move";
}

+(NSString*)deleteImageStringIdentifier {
    return @"delete";
}

+(NSString*)renameImageStringIdentifier {
    return @"rename";
}

+(NSString*)previewImageStringIdentifier {
    return @"preview";
}

+(NSString*)actionsImageStringIdentifier {
    return @"actions";
}

+(NSString*)sendLinkToolbarImageStringIdentifier {
    return @"sendLinkToolbar";
}

+(NSString*)paperAirplaneToolbarImageStringIdentifier {
    return @"paperAirplaneToolbar";
}

//Circle Buttons

+(NSString*)sendImageStringIdentifier {
    return @"send";
}

+(NSString*)sendLinkImageStringIdentifier {
    return @"sendLink";
}

//Others

+(NSString*)addFriendStringIdentifier {
    return @"add-friend";
}

+(NSString*)removeFriendStringIdentifier {
    return @"remove-friend";
}

+(NSString*)checkMarkOutlineStringIdentifier {
    return @"checkmark-outline";
}

+(NSString*)checkMarkStringIdentifier {
    return @"checkmark";
}

+(NSString*)trashImageStringIdentifier {
    return @"trash";
}

+(NSString*)acceptImageStringIdentifier {
    return @"accept";
}

+(NSString*)acceptWhiteImageStringIdentifier {
    return @"acceptWhite";
}

+(NSString*)reloadStringIdentifier {
    return @"reload";
}

+(NSString*)resendBlackStringIdentifier {
    return  @"resend-black";
}

+(NSString*)starOutlineStringIdentifier {
    return @"star-outline";
}

+(NSString*)yellowStarStringIdentifier {
    return @"yellow-star";
}

+(NSString*)backArrowButtonStringIdentifier {
    return @"back-arrow-button";
}

+(NSString*)backArrowButtonReversedStringIdentifier {
    return @"back-arrow-reversed";
}

+(NSString*)moreFillStringIdentifier {
    return @"more-fill";
}

+(NSString*)requestsStringIdentifier {
    return @"requests";
}

+(NSString*)settingsStringIdentifier {
    return @"settings";
}

+(NSString*)unselectXStringIdentifier {
    return @"unselectX";
}

+(NSString*)cancelStringIdentifier {
    return @"cancel";
}

+(NSString*)largeCircleOutlineStringIdentifier {
    return @"large-circle-outline";
}

+(NSString*)largeCircleGreenStringIdentifier {
    return @"large-circle-green";
}

+(NSString*)filesSelectedStringIdentifier {
    return @"filesSelected";
}

+(NSString*)filesUnselectedStringIdentifier {
    return @"filesUnselected";
}

+(NSString*)addImageStringIdentifier {
    return @"add";
}

+(NSString*)folderImageStringIdentifier {
    return @"folder";
}

+(NSString*)folderDownloadsImageStringIdentifier {
    return @"folder-downloads";
}

+(NSString*)folderSendsImageStringIdentifier {
    return @"folder-sends";
}

+(NSString*)folderEnvoyImageStringIdentifier {
    return @"folder-envoy";
}

+(NSString*)folderDownloadsSelectedImageStringIdentifier {
    return @"folder-downloads-selected";
}

+(NSString*)folderSendsSelectedImageStringIdentifier {
    return @"folder-sends-selected";
}

+(NSString*)folderEnvoySelectedImageStringIdentifier {
    return @"folder-envoy-selected";
}

#pragma mark - Custom Cell Identifiers

+(NSString*)friendCellStringIdentifier {
    return @"friendCell";
}

+(NSString*)strangerCellStringIdentifier {
    return @"strangerCell";
}

+(NSString*)requestCellStringIdentifier {
    return @"requestCell";
}

+(NSString*)sendCellStringIdentifier {
    return @"sendCell";
}

+(NSString*)inboxCellStringIdentifier {
    return @"inboxCell";
}

+(NSString*)incomingSendProgressCellStringIdentifier {
    return @"incomingSendProgressCell";
}

+(NSString*)linkPackageCellStringIdentifier {
    return @"linkPackageCell";
}

+(NSString*)settingsCellStringIdentifier {
    return @"settingsCell";
}

+(NSString*)settingsSwitchCellStringIdentifier {
    return @"settingsSwitchCell";
}

+(NSString*)settingsCellSpecialStringIdentifier {
    return @"settingsCellSpecial";
}

+(NSString*)nameCellStringIdentifier {
    return @"nameCell";
}

+(NSString*)changePasswordCellStringIdentifier {
    return @"changePasswordCell";
}

+(NSString*)connectToolbarCellStringIdentifier {
    return @"connectToolbarCell";
}

#pragma mark - toolbarActionsStringIdentifiers

+(NSString*)toolbarDownloadActionStringIdentifier {
    return @"downloadAction";
}

+(NSString*)toolbarDownloadHereActionStringIdentifier {
    return @"downloadHereAction";
}

+(NSString*)toolbarUploadActionStringIdentifier {
    return @"uploadAction";
}

+(NSString*)toolbarUploadHereActionStringIdentifier {
    return @"uploadHere";
}

+(NSString*)toolbarMoveActionStringIdentifier {
    return @"moveAction";
}

+(NSString*)toolbarDeleteActionStringIdentifier {
    return @"deleteAction";
}

+(NSString*)toolbarRenameActionStringIdentifier {
    return @"renameAction";
}

+(NSString*)toolbarPreviewActionStringIdentifier {
    return @"previewAction";
}

+(NSString*)toolbarActionsActionStringIdentifier {
    return @"actionsAction";
}

+(NSString*)toolbarSendActionStringIdentifier {
    return @"sendAction";
}

+(NSString*)toolbarCancelDownloadActionStringIdentifier; {
    return @"cancelDownload";
}

+(NSString*)toolbarCancelUploadActionStringIdentifier; {
    return @"cancelUpload";
}

+(NSString*)toolbarSendLinkActionStringIdentifier {
    return @"sendLinkAction";
}

+(NSString*)AddButtonNewFolderActionStringIdentifier {
    return @"newFolder";
}

#pragma mark - Send Type String Identifiers

+(NSString*)SEND_TYPE_FILE {
    return @"file_send";
}

+(NSString*)SEND_TYPE_LINK {
    return @"link_send";
}

#pragma mark - NSUserDefaults 

//User & Settings Identifiers

+(NSString*)firstNameStringIdentifier {
    return @"firstName";
}

+(NSString*)lastNameStringIdentifier {
    return @"lastName";
}

+(NSString*)receivePushNotificationsSettingStringIdentifier {
    return @"receivePushNotifications";
}

+(NSString*)keepDeviceAwakeStringSettingIdentifier {
    return @"keepDeviceAwake";
}

//Informative Alerts
+(NSString*)userShownDropboxLinkSharingDialogueStringIdentifier {
    return @"userShownDropboxLinkSharingDialogue";
}

+(NSString*)userShownGoogleDriveLinkSharingDialogueStringIdentifier {
    return @"userShownGoogleDriveLinkSharingDialogue";
}

//Inbox
+(NSString*)numberOfUncheckedFilePackagesStringIdentifier {
    return @"numberOfUncheckedFilePackages";
}

+(NSString*)numberOfUncheckedLinkPackagesStringIdentifier {
    return @"numberOfUncheckedLinkPackages";
}

+(NSString*)totalNumberOfUncheckedPackagesStringIdentifier {
    return @"totalNumberOfUncheckedPackages";
}

#pragma mark - sending & receiving String Identifiers

+(NSString*)peerIDStringIdentifier; {
    return @"peerID";
}

+(NSString*)zippedFilePathStringIdentifier {
    return @"zippedFilePath";
}

+(NSString*)resourceNameStringIdentifier {
    return @"resourceName";
}

+(NSString*)sendingOrReceivingStringIdentifier {
    return @"sendingOrReceiving";
}

+(NSString*)sendProgressStringIdentifier {
    return @"sendProgress";
}

+(NSString*)observerStringIdentifier {
    return @"observer";
}

#pragma mark - friends.json String Identifiers

+(NSString*)friendNameStringIdentifier {
    return @"friendName";
}

+(NSString*)friendsStringIdentifier {
    return @"friends";
}

+(NSString*)UUIDStringIdentifier {
    return @"UUID";
}

+(NSString*)timestampStringIdentifier {
    return @"timestamp";
}

#pragma mark - inbox.json String Identifiers

+(NSString*)filePackagesStringIdentifier {
    return @"filePackages";
}

+(NSString*)receivedDateStringIdentifier {
    return @"receivedDate";
}

+(NSString*)sentByStringIdentifier {
    return @"sentBy";
}

+(NSString*)sentByUUIDStringIdentifier {
    return @"sentByUUID";
}

+(NSString*)filePackageUUIDStringIdentifier {
    return @"filePackageUUID";
}

+(NSString*)filesStringIdentifier {
    return @"files";
}

+(NSString*)fileNameStringIdentifier {
    return @"name";
}

+(NSString*)fileUrlStringIdentifier {
    return @"url";
}

+(NSString*)createdStringIdentifier {
    return @"created";
}

+(NSString*)revisionStringIdentifier {
    return @"revision";
}

+(NSString*)boxIdStringIdentifier {
    return @"boxId";
}

+(NSString*)isDirectoryStringIdentifier {
    return @"isDirectory";
}

#pragma mark - .json File String Identifiers

+(NSString*)friendsJSONFileIdentifier {
    return @"friends.json";
}

+(NSString*)incomingStringIdentifier {
    return @"Incoming";
}

+(NSString*)inboxJSONFileIdentifier {
    return @"inbox.json";
}

/* - Returns documents directory path in app sand box - */

+(NSString*)pathForRootDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}

/* - Returns specified JSON file path in documents directory - */

+(NSString*)pathForJSONFileWithIdentifier: (NSString*) fileIdentifier {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *fileIdentifierPath;
    
    if ([fileIdentifier isEqualToString: [self inboxJSONFileIdentifier]]) {
        fileIdentifierPath = [documentsDirectory stringByAppendingPathComponent:[[self class] incomingStringIdentifier]];
        fileIdentifierPath = [fileIdentifierPath stringByAppendingPathComponent:fileIdentifier];
    } else {
        fileIdentifierPath = [documentsDirectory stringByAppendingPathComponent:fileIdentifier];
    }
    
    return fileIdentifierPath;
}

+(NSString*)pathForFilePackage: (NSDictionary*)filePackageUUID {
    return [[self incomingStringIdentifier] stringByAppendingPathComponent:[filePackageUUID objectForKey:[self filePackageUUIDStringIdentifier]]];
}

@end
