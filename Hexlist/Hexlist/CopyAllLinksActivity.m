//
//  CopyAllLinksActivity.m
//  Hexlist
//
//  Created by Roman Scher on 1/18/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "CopyAllLinksActivity.h"

@interface CopyAllLinksActivity ()

@property (nonatomic, strong) NSObject *urlOrStringToCopy;

@end

@implementation CopyAllLinksActivity

- (NSString *)activityType {
    return @"Hexlist.Copy.All.Links";
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
    
}

- (NSString *)activityTitle {
    return @"Copy All Links";
}

- (UIImage *)activityImage {
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //        return [UIImage imageNamed:@"iPadShare.png"];
    //    }
    //    else {
    //        return [UIImage imageNamed:@"iPhoneShare.png"];
    //    }
    return [UIImage imageNamed:[AppConstants copyLinkImageStringIdentifier]];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    _urlOrStringToCopy = [activityItems firstObject];
}

- (void)performActivity {
    if ([_urlOrStringToCopy isKindOfClass:[NSURL class]]) {
        [UIPasteboard generalPasteboard].URL = (NSURL*)_urlOrStringToCopy;
    }
    else if ([_urlOrStringToCopy isKindOfClass:[NSString class]]) {
        [UIPasteboard generalPasteboard].string = (NSString*)_urlOrStringToCopy;
    }
}

@end
