//
//  IntroViewController.h
//  Hexlist
//
//  Created by Roman Scher on 1/4/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "GiveNameViewController.h"
#import "TTTAttributedLabel.h"

@interface IntroViewController : UIViewController <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsOfServiceText;

@property (weak, nonatomic) IBOutlet UIButton *beginButton;

@property (nonatomic, assign) BOOL presentedFromSettings;

@end
