//
//  AppConstants.m
//  Hexlist
//
//  Created by Roman Scher on 7/1/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "AppConstants.h"

@implementation AppConstants

+(NSString*) rootPathStringIdentifier {
    return @"/";
}

#pragma mark - General App Constants

+(NSString*)appName {
    return @"Hexlist";
}

+(NSURL*)appCallbackUrl {
    return [NSURL URLWithString:[[self appName] stringByAppendingString:@"://"]];
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
    return @"Avenir-Book";
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

+(UIColor *)tableViewSelectionColor {
    return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1];
}



+(UIColor *)grayTableViewBackgroundColor {
//    return [UIColor colorWithRed:230.0/255.0 green:231.0/255.0 blue:232.0/255.0 alpha:1];
    return [UIColor colorWithRed:242.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1];
}

+(UIColor *)fadedWhiteColor {
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:.25];
}

+(UIColor *)circleButtonSelectionColor; {
    return [UIColor colorWithRed:175.0/255.0 green:66.0/255.0 blue:87.0/255.0 alpha:1];
}

+(UIColor *)progressViewColor {
    return [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:255.0/255.0 alpha:1];
}

+(UIColor *)linkButtonColor {
    return [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1];
}

+(UIColor*)hexCellButtonColor {
    return [UIColor colorWithRed:170.0/255.0 green:184.0/255.0 blue:193.0/255.0 alpha:1.0];
}

+(UIColor *)myHexColorDefault {
    return [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0];
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

+(NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

+(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
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

#pragma mark - Image Assets Identifiers

+(NSString*)appIconImageStringIdentifier {
    return @"AppIcon";
}

+(NSString*)desertAImageStringIdentifier {
    return @"desertA";
}

+(NSString*)localImageStringIdentifier {
    return @"local";
}

+(NSString*)boxImageStringIdentifier {
    return @"box";
}

+(NSString*)dropboxImageStringIdentifier {
    return @"dropbox";
}

+(NSString*)googleDriveImageStringIdentifier {
    return @"googledrive";
}

+(NSString*)boxNavImageStringIdentifier {
    return @"boxNav";
}

+(NSString*)dropboxNavImageStringIdentifier {
    return @"dropboxNav";
}

+(NSString*)googleDriveNavImageStringIdentifier {
    return @"googleDriveNav";
}

+(NSString*)hexlistNavImageStringIdentifier {
    return @"hexlistNav";
}

//Toolbar

+(NSString*)linkToolbarImageStringIdentifier {
    return @"linkToolbar";
}

+(NSString*)hexOptionsToolbarImageStringIdentifier {
    return @"hexOptionsToolbar";
}

//Circle Buttons

+(NSString*)sendImageStringIdentifier {
    return @"send";
}

+(NSString*)sendLinkImageStringIdentifier {
    return @"sendLink";
}

//UIActivies

+(NSString*)copyLinkImageStringIdentifier {
    return @"copyLink";
}

+(NSString*)safariImageStringIdentifier {
    return @"safari";
}

+(NSString*)chromeImageStringIdentifier {
    return @"chrome";
}

//Cells

//Send Cell

+(NSString*)checkMarkOutlineImageStringIdentifier {
    return @"checkmark-outline";
}

+(NSString*)checkMarkImageStringIdentifier {
    return @"checkmark";
}

//HexCell
+(NSString*)sendHexImageStringIdentifier {
    return @"sendHex";
}

+(NSString*)addLinksImageStringIdentifier {
    return @"addLinks";
}

+(NSString*)hexActionsImageStringIdentifier {
    return @"hexActions";
}

+(NSString*)hexCheckmarkImageStringIdentifier {
    return @"hexCheckmark";
}

+(NSString*)dropboxLinkImageStringIdentifier {
    return @"dropboxLink";
}

+(NSString*)boxLinkImageStringIdentifier {
    return @"boxLink";
}

+(NSString*)googleDriveLinkImageStringIdentifier {
    return @"googleDriveLink";
}

+(NSString*)generalLinkImageStringIdentifier {
    return @"generalLink";
}

//General

+(NSString*)trashWhiteImageStringIdentifier {
    return @"trashWhite";
}

+(NSString*)acceptWhiteImageStringIdentifier {
    return @"acceptWhite";
}

+(NSString*)globeImageStringIdentifier {
    return @"globe";
}

//Create View

+(NSString*)linkEditImageStringIdentifier {
    return @"linkEdit";
}

//Others

+(NSString*)reloadImageStringIdentifier {
    return @"reload";
}

+(NSString*)backArrowButtonImageStringIdentifier {
    return @"back-arrow-button";
}

+(NSString*)settingsImageStringIdentifier {
    return @"settings";
}

+(NSString*)unselectXImageStringIdentifier {
    return @"unselectX";
}

+(NSString*)cancelImageStringIdentifier {
    return @"cancel";
}

+(NSString*)paintImageStringIdentifier {
    return @"paint";
}

+(NSString*)addImageStringIdentifier {
    return @"add";
}

+(NSString*)folderImageStringIdentifier {
    return @"folder";
}

#pragma mark - Custom Cell Identifiers

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

+(NSString*)hexCellReuseIdentifierStringIdentifier {
    return @"hexCell";
}

+(NSString*)hexCellTriReuseIdentifierStringIdentifier {
    return @"hexCellTri";
}

+(NSString*)linkCellStringIdentifier {
    return @"linkCell";
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

+(NSString*)settingsServiceCellStringIdentifier {
    return @"settingsServiceCell";
}

+(NSString*)myHexColorCellStringIdentifier {
    return @"myHexColorCell";
}

+(NSString*)nameCellStringIdentifier {
    return @"nameCell";
}

+(NSString*)connectToolbarCellStringIdentifier {
    return @"connectToolbarCell";
}

#pragma mark - NSUserDefaults

//User & Settings Identifiers

+(NSString*)firstNameStringIdentifier {
    return @"firstName";
}

+(NSString*)lastNameStringIdentifier {
    return @"lastName";
}

+(NSString*)myHexColorStringIdentifier {
    return @"myHexColor";
}

+(NSString*)keepDeviceAwakeStringSettingIdentifier {
    return @"keepDeviceAwake";
}

+(NSString*)blockedUserUUIDsStringIdentifier {
    return @"blockedUserUUIDs";
}

//Inbox

+(NSString*)numberOfUncheckedHexesStringIdentifier {
    return @"numberOfUncheckedHexes";
}

//Data Sends

#pragma mark - OperationTypes

+(NSString*)stringForOperationTypeStore {
    return @"Store";
}

+(NSString*)stringForOperationTypeAlert {
    return @"Alert";
}

+(NSString*)stringForOperationType:(OperationType)operationType {
    NSString *string = nil;
    
    switch(operationType) {
        case OperationTypeStore:
            string = [self stringForOperationTypeStore];
            break;
        case OperationTypeAlert:
            string = [self stringForOperationTypeAlert];
            break;
        default:
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [NSException raise:NSGenericException format:@"Unexpected OperationType: %ld", (long)operationType];
    }
    
    return string;
}

+(OperationType)operationTypeForString:(NSString*)string {
    OperationType operationType = -1;
    
    if ([string isEqualToString:[self stringForOperationTypeStore]]) {
        operationType = OperationTypeStore;
    }
    else if ([string isEqualToString:[self stringForOperationTypeAlert]]) {
        operationType = OperationTypeAlert;
    }
    else {
        //NSLog(@"%@", NSStringFromSelector(_cmd));
        [NSException raise:NSGenericException format:@"Unexpected OperationType String: %@", string];
    }
    
    return operationType;
}

#pragma mark - JMObjectTypes

+(NSString*)stringForJMObjectTypeHex {
    return @"Hex";
}

+(JMObjectType)jmObjectTypeForString:(NSString*)string {
    JMObjectType jmObjectType = -1;
    
    if ([string isEqualToString:[self stringForJMObjectTypeHex]]) {
        jmObjectType = JMObjectTypeHex;
    }
    else {
        //NSLog(@"%@", NSStringFromSelector(_cmd));
        [NSException raise:NSGenericException format:@"Unexpected JMObjectType String: %@", string];
    }
    
    return jmObjectType;
}

+(NSString*)stringForJMObjectType:(JMObjectType)objectType {
    NSString *string = nil;
    
    switch(objectType) {
        case JMObjectTypeHex:
            string = [self stringForJMObjectTypeHex];
            break;
        default:
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [NSException raise:NSGenericException format:@"Unexpected JMObjectType: %ld", (long)objectType];
    }
    
    return string;
}

#pragma mark - Hex Locations

+(NSArray*)allHexLocationTypes {
    NSMutableArray *hexLocationTypes = [[NSMutableArray alloc] init];
    
    [hexLocationTypes addObject:[NSNumber numberWithInteger:HexLocationTypeMyHexlist]];
    [hexLocationTypes addObject:[NSNumber numberWithInteger:HexLocationTypeInbox]];

    return [hexLocationTypes copy];
}

+(NSString*)stringForHexLocationTypeMyHexlist {
    return @"myHexlist";
}

+(NSString*)stringForHexLocationTypeInbox {
    return @"inbox";
}

+(NSString*)stringForHexLocationType:(HexLocationType)hexLocationType {
    NSString *string = nil;
    
    switch(hexLocationType) {
        case HexLocationTypeMyHexlist:
            string = [self stringForHexLocationTypeMyHexlist];
            break;
        case HexLocationTypeInbox:
            string = [self stringForHexLocationTypeInbox];
            break;
        default:
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [NSException raise:NSGenericException format:@"Unexpected HexLocationType: %ld", (long)hexLocationType];
    }
    
    return string;
}

+(HexLocationType)hexLocationTypeForString:(NSString*)string {
    HexLocationType hexLocationType = -1;
    
    if ([string isEqualToString:[self stringForHexLocationTypeMyHexlist]]) {
        hexLocationType = HexLocationTypeMyHexlist;
    }
    else if ([string isEqualToString:[self stringForHexLocationTypeInbox]]) {
        hexLocationType = HexLocationTypeInbox;
    }
    else {
        //NSLog(@"%@", NSStringFromSelector(_cmd));
        [NSException raise:NSGenericException format:@"Unexpected Hex Location Type String: %@", string];
    }
    
    return hexLocationType;
}

//Services

#pragma mark - ServiceTypes

+(NSArray*)allServiceTypes {
    
    NSMutableArray *serviceTypes = [[NSMutableArray alloc] init];
    
    [serviceTypes addObject:[NSNumber numberWithInteger:ServiceTypeUnknown]];
    [serviceTypes addObject:[NSNumber numberWithInteger:ServiceTypeDropbox]];
    [serviceTypes addObject:[NSNumber numberWithInteger:ServiceTypeBox]];
    [serviceTypes addObject:[NSNumber numberWithInteger:ServiceTypeGoogleDrive]];
    
    return [serviceTypes copy];
}

+(NSString*)stringForServiceTypeUnknown {
    return @"Unknown";
}

+(NSString*)stringForServiceTypeDropbox {
    return @"Dropbox";
}

+(NSString*)stringForServiceTypeBox {
    return @"Box";
}

+(NSString*)stringForServiceTypeGoogleDrive {
    return @"GoogleDrive";
}

+(NSString*)stringForServiceType:(ServiceType)serviceType {
    NSString *string = nil;
    
    switch(serviceType) {
        case ServiceTypeUnknown:
            string = [self stringForServiceTypeUnknown];
            break;
        case ServiceTypeDropbox:
            string = [self stringForServiceTypeDropbox];
            break;
        case ServiceTypeBox:
            string = [self stringForServiceTypeBox];
            break;
        case ServiceTypeGoogleDrive:
            string = [self stringForServiceTypeGoogleDrive];
            break;
        default:
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [NSException raise:NSGenericException format:@"Unexpected ServiceType: %ld", (long)serviceType];
    }
    
    return string;
}

+(ServiceType)serviceTypeForString:(NSString*)string {
    ServiceType serviceType = -1;
    
    if ([string isEqualToString:[self stringForServiceTypeUnknown]]) {
        serviceType = ServiceTypeUnknown;
    }
    else if ([string isEqualToString:[self stringForServiceTypeDropbox]]) {
        serviceType = ServiceTypeDropbox;
    }
    else if ([string isEqualToString:[self stringForServiceTypeBox]]) {
        serviceType = ServiceTypeBox;
    }
    else if ([string isEqualToString:[self stringForServiceTypeGoogleDrive]]) {
        serviceType = ServiceTypeGoogleDrive;
    }
    else {
        //NSLog(@"%@", NSStringFromSelector(_cmd));
        [NSException raise:NSGenericException format:@"Unexpected ServiceType String: %@", string];
    }
    
    return serviceType;
}

+(NSString*)presentableStringForServiceType:(ServiceType)serviceType {
    NSString *presentableServiceName = nil;
    
    switch(serviceType) {
        case ServiceTypeUnknown:
            presentableServiceName = @"Unknown";
            break;
        case ServiceTypeDropbox:
            presentableServiceName = @"Dropbox";
            break;
        case ServiceTypeBox:
            presentableServiceName = @"Box";
            break;
        case ServiceTypeGoogleDrive:
            presentableServiceName = @"Google Drive";
            break;
        default:
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [NSException raise:NSGenericException format:@"Unexpected Service Type: %ld", (long)serviceType
             ];
    }
    
    return presentableServiceName;
}

+(NSString*)userHasBeenShownLinkSharingDialogueStringIdentifierForServiceType:(ServiceType)serviceType {
    return [@"userShownLinkSharingDialogueFor" stringByAppendingString:[self stringForServiceType:serviceType]];
}

+(NSString*)userHasBeenShownLinkPasteHUD{
    return @"userHasBeenShownLinkPasteHUD";
}

+(UIImage*)serviceNavImageForServiceType:(ServiceType)serviceType {
    UIImage *image = nil;
    
    if (serviceType == ServiceTypeUnknown) {
        image = nil;
    }
    else if (serviceType == ServiceTypeDropbox) {
        image = [UIImage imageNamed:[AppConstants dropboxNavImageStringIdentifier]];
    }
    else if (serviceType == ServiceTypeGoogleDrive) {
        image = [UIImage imageNamed:[AppConstants googleDriveNavImageStringIdentifier]];
    }
    else if (serviceType == ServiceTypeBox) {
        image = [UIImage imageNamed:[AppConstants boxNavImageStringIdentifier]];
    }
    else {
        //NSLog(@"%@", NSStringFromSelector(_cmd));
        [NSException raise:NSGenericException format:@"Unexpected Service Type: %ld", (long)serviceType];
    }
    
    return image;
}

+(UIImage*)serviceLinkImageForServiceType:(ServiceType)serviceType {
    UIImage *image = nil;
    
    if (serviceType == ServiceTypeUnknown) {
        image = [UIImage imageNamed:[AppConstants generalLinkImageStringIdentifier]];
    }
    else if (serviceType == ServiceTypeDropbox) {
        image = [UIImage imageNamed:[AppConstants dropboxLinkImageStringIdentifier]];
    }
    else if (serviceType == ServiceTypeGoogleDrive) {
        image = [UIImage imageNamed:[AppConstants googleDriveLinkImageStringIdentifier]];
    }
    else if (serviceType == ServiceTypeBox) {
        image = [UIImage imageNamed:[AppConstants boxLinkImageStringIdentifier]];
    }
    else {
        //NSLog(@"%@", NSStringFromSelector(_cmd));
        [NSException raise:NSGenericException format:@"Unexpected Service Type: %ld", (long)serviceType
         ];
    }
    
    return image;
}

@end
