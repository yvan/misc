//
//  GeneratingLinksAlertView.h
//  Hexlist
//
//  Created by Roman Scher on 1/13/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneratingLinksAlertView : UIView

@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
