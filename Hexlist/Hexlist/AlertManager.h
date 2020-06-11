//
//  AlertManager.h
//  
//
//  Created by Roman Scher on 1/11/16.
//
//

#import <Foundation/Foundation.h>
#import "UIAlertController+Window.h"
#import "CopyLinkActivity.h"
#import "CopyAllLinksActivity.h"
#import "OpenInSafariActivity.h"
#import "OpenInChromeActivity.h"
#import "OpenInChromeController.h"

@interface AlertManager : NSObject

+(UIActivityViewController*)generateActivityViewControllerWithURL:(NSURL*)url;
+(UIActivityViewController*)generateShareHexActivityViewControllerWithString:(NSString*)string;

//HexManager Alerts
+(void)alertUserToFailedToReadIncomingHex;
+(void)alertUserToFailedToReadIncomingData;

@end
