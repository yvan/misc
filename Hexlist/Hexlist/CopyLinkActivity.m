//
//  CopyLinkActivity.m
//  
//
//  Created by Roman Scher on 1/7/16.
//
//

#import "CopyLinkActivity.h"

@interface CopyLinkActivity ()

@property (nonatomic, strong) NSObject *urlOrStringToCopy;

@end

@implementation CopyLinkActivity

- (NSString *)activityType {
    return @"Hexlist.Copy.Link";
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
    
}

- (NSString *)activityTitle {
    return @"Copy Link";
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
