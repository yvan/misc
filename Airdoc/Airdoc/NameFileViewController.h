//
//  NameFileViewController.h
//  Envoy
//
//  Created by Roman Scher on 8/22/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "FileSystemAbstraction.h"
#import "FileSystemInterface.h"
#import "FileSystemFunctions.h"
#import "HighlightButton.h"

@interface NameFileViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) FileSystemInterface* fsInterface;
@property (nonatomic, strong) FileSystemAbstraction* fsAbstraction;
@property (nonatomic, strong) FileSystemFunctions* fsFunctions;

@property (strong, nonatomic) NSString *actionStringIdentifier;
@property (strong, nonatomic) File *originalFile;
@property (strong, nonatomic) UIView *nameFileView;
@property (strong, nonatomic) UIView *savedTitleView;
@property (strong, nonatomic) UITextField *fileNameTextField;
@property (strong, nonatomic) UIImage *navigationBarBackgroundImage;
@property (strong, nonatomic) UIImage *navigationBarShadowImage;
@property (strong, nonatomic) UIBarButtonItem *acceptNameButton;

@end
