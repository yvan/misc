//
//  AlertManager.m
//  
//
//  Created by Roman Scher on 1/11/16.
//
//

#import "AlertManager.h"

@implementation AlertManager

+(UIActivityViewController*)generateActivityViewControllerWithURL:(NSURL*)url {
    //Add activities for share board
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    
    [activities addObject:[[CopyLinkActivity alloc] init]];
    [activities addObject:[[OpenInSafariActivity alloc] init]];
    if ([[OpenInChromeController sharedInstance] isChromeInstalled]) {
        [activities addObject:[[OpenInChromeActivity alloc] init]];
    }
    
    //Present activitiesVC
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                      applicationActivities:activities];
    activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList];
    
    //    UIView *activityContentView = (UIView*)[[activityVC.view subviews] objectAtIndex:0];
    //
    //    UIButton *urlDisplay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    //    urlDisplay.userInteractionEnabled = NO;
    //    urlDisplay.layer.masksToBounds = YES;
    //    urlDisplay.titleLabel.font = [UIFont fontWithName:[AppConstants appFontNameB] size:15.0];
    //    urlDisplay.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    //    urlDisplay.layer.cornerRadius = 4.0;
    //    [urlDisplay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [urlDisplay setTitle:linkButton.link.url forState:UIControlStateNormal];
    //    [urlDisplay.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    //    urlDisplay.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    
    //    [activityContentView addSubview:urlDisplay];
    
    //    NSLayoutConstraint *constraint;
    //    [urlDisplay setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //    //LinkButtonViewConstraints
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeBottom
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:activityContentView
    //                                              attribute:NSLayoutAttributeTop
    //                                             multiplier:1
    //                                               constant:-8];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeLeading
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:activityContentView
    //                                              attribute:NSLayoutAttributeLeading
    //                                             multiplier:1
    //                                               constant:0];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeTrailing
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:activityContentView
    //                                              attribute:NSLayoutAttributeTrailing
    //                                             multiplier:1
    //                                               constant:0];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeHeight
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:nil
    //                                              attribute:NSLayoutAttributeNotAnAttribute
    //                                             multiplier:1
    //                                               constant:40];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeWidth
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:nil
    //                                              attribute:NSLayoutAttributeNotAnAttribute
    //                                             multiplier:1
    //                                               constant:activityContentView.frame.size.width - 16];
    //    [urlDisplay addConstraint:constraint];
    
    return activityVC;
}

+(UIActivityViewController*)generateShareHexActivityViewControllerWithString:(NSString*)string {
    //Add activities for share board
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    
    [activities addObject:[[CopyAllLinksActivity alloc] init]];
    
    //Present activitiesVC
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:@[string]
                                      applicationActivities:activities];
    activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList];
    
    //    UIView *activityContentView = (UIView*)[[activityVC.view subviews] objectAtIndex:0];
    //
    //    UIButton *urlDisplay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    //    urlDisplay.userInteractionEnabled = NO;
    //    urlDisplay.layer.masksToBounds = YES;
    //    urlDisplay.titleLabel.font = [UIFont fontWithName:[AppConstants appFontNameB] size:15.0];
    //    urlDisplay.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    //    urlDisplay.layer.cornerRadius = 4.0;
    //    [urlDisplay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [urlDisplay setTitle:linkButton.link.url forState:UIControlStateNormal];
    //    [urlDisplay.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    //    urlDisplay.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    
    //    [activityContentView addSubview:urlDisplay];
    
    //    NSLayoutConstraint *constraint;
    //    [urlDisplay setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //    //LinkButtonViewConstraints
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeBottom
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:activityContentView
    //                                              attribute:NSLayoutAttributeTop
    //                                             multiplier:1
    //                                               constant:-8];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeLeading
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:activityContentView
    //                                              attribute:NSLayoutAttributeLeading
    //                                             multiplier:1
    //                                               constant:0];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeTrailing
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:activityContentView
    //                                              attribute:NSLayoutAttributeTrailing
    //                                             multiplier:1
    //                                               constant:0];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeHeight
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:nil
    //                                              attribute:NSLayoutAttributeNotAnAttribute
    //                                             multiplier:1
    //                                               constant:40];
    //    [activityContentView addConstraint:constraint];
    //
    //    constraint = [NSLayoutConstraint constraintWithItem:urlDisplay
    //                                              attribute:NSLayoutAttributeWidth
    //                                              relatedBy:NSLayoutRelationEqual
    //                                                 toItem:nil
    //                                              attribute:NSLayoutAttributeNotAnAttribute
    //                                             multiplier:1
    //                                               constant:activityContentView.frame.size.width - 16];
    //    [urlDisplay addConstraint:constraint];
    
    return activityVC;
}

//HexManager Alerts
+(void)alertUserToFailedToReadIncomingHex {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert;
        
        alert = [UIAlertController alertControllerWithTitle:@"Uh oh." message:[NSString stringWithFormat:@"Couldn't read an incoming hex. Your version of Hexlist may be incompatible with your peer's."] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [alert show];
    });
}

+(void)alertUserToFailedToReadIncomingData {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert;
        
        alert = [UIAlertController alertControllerWithTitle:@"Uh oh." message:[NSString stringWithFormat:@"Couldn't read an incoming data send. Your version of Hexlist may be incompatible with your peer's."] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [alert show];
    });
}

@end
