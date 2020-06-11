//
//  SettingsSwitchCell.h
//  Hexlist
//
//  Created by Roman Scher on 3/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bottomBorder;

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchObject;

@end
