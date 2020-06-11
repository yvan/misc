//
//  ChangeNameViewController.h
//  Airdoc
//
//  Created by Roman Scher on 3/27/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "LocalStorageManager.h"
#import "NameCell.h"
#import "HighlightButton.h"

@interface ChangeNameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) LocalStorageManager *localStorageManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;

@property (weak, nonatomic) IBOutlet UITableView *nameTableView;

@end
