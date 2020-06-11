//
//  SettingsServiceCell.h
//  Hexlist
//
//  Created by Roman Scher on 1/25/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsServiceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *serviceImage;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *switchObject;

@property (weak, nonatomic) IBOutlet UIView *bottomBorder;

@end
