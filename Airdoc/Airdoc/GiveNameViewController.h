//
//  GiveNameViewController.h
//  Airdoc
//
//  Created by Roman Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "LocalStorageManager.h"
#import "HomeViewController.h"

@interface GiveNameViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) LocalStorageManager *localStorageManager;

@end
