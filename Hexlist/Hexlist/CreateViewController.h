//
//  CreateViewController.h
//  Hexlist
//
//  Created by Roman Scher on 8/22/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "SettingsManager.h"
#import "HexManager.h"
#import "FileSystemAbstraction.h"
#import "FileSystemInterface.h"
#import "HighlightButton.h"

@protocol CreateViewControllerDelegate <NSObject>

@optional

-(void)updateHex:(Hex*)hexEdited WithDescription:(NSString*)hexDescription AndColor:(UIColor*)hexColor;
-(void)addedToHexShowHUD;
-(void)hexJMPreparedForSend:(HexJM*)hexJM;

@end

@interface CreateViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id <CreateViewControllerDelegate> createViewControllerDelegate;

@property (weak, nonatomic) IBOutlet UIButton *hexagon;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *acceptButton;

//Passed in Parameters
@property (nonatomic, assign) CreateViewAction createViewAction;

//Cloud Send
@property (strong, nonatomic) NSArray<LinkJM*> *linksToSendWithHex;

//Create Hex
@property (strong, nonatomic) NSArray<Link*> *linksToSaveWithHex;

//Edit Hex
@property (strong, nonatomic) Hex *hexToEdit;

//Edit Link
@property (strong, nonatomic) Link *linkToEdit;

@end
