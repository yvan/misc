//
//  GiveNameViewController.h
//  Hexlist
//
//  Created by Roman Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "SettingsManager.h"
#import "HighlightButton.h"

@interface GiveNameViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) NameViewType nameViewType;

@property (weak, nonatomic) IBOutlet UILabel *prompt;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end
