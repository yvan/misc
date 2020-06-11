//
//  OpenInSafariActivity.m
//  
//
//  Created by Roman Scher on 1/7/16.
//
//

#import "OpenInSafariActivity.h"

@interface OpenInSafariActivity ()

@property (nonatomic, strong) NSObject *linkToOpen;

@end

@implementation OpenInSafariActivity

- (NSString *)activityType {
    return @"Hexlist.Open.In.Safari";
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
    
}

- (NSString *)activityTitle {
    return @"Open in Safari";
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
    return [UIImage imageNamed:[AppConstants safariImageStringIdentifier]];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    _linkToOpen = [activityItems firstObject];
}

- (void)performActivity {
    if ([_linkToOpen isKindOfClass:[NSURL class]]) {
        [[UIApplication sharedApplication] openURL:(NSURL*)_linkToOpen];
    }
    else if ([_linkToOpen isKindOfClass:[NSString class]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
        [(NSString*)_linkToOpen stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
}

@end
