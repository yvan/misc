//
//  IntroViewController.h
//  Airdoc
//
//  Created by Roman Scher on 1/4/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "LocalStorageManager.h"

@interface IntroViewController : UIViewController

@property (nonatomic, strong) LocalStorageManager *localStorageManager;

@property (weak, nonatomic) IBOutlet UIButton *beginButton;

@end
