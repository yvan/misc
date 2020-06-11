//
//  SettingsCellSpecial.m
//  Hexlist
//
//  Created by Roman Scher on 3/24/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "SettingsCellSpecial.h"

@implementation SettingsCellSpecial

- (void)awakeFromNib {
    // Initialization code
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *backgroundColor = _bottomBorder.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        // Recover backgroundColor of subviews.
        _bottomBorder.backgroundColor = backgroundColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *backgroundColor = _bottomBorder.backgroundColor;
    [super setSelected:selected animated:animated];
    if (selected) {
        // Recover backgroundColor of subviews.
        _bottomBorder.backgroundColor = backgroundColor;
    }
}

@end
