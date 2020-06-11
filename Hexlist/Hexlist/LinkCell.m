//
//  LinkCell.m
//  Hexlist
//
//  Created by Roman Scher on 1/20/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "LinkCell.h"

@implementation LinkCell

- (void)awakeFromNib {
    // Initialization code
    [_linkLabel setText:nil];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *backgroundColor = _topBorder.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        // Recover backgroundColor of subviews.
        _topBorder.backgroundColor = backgroundColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *backgroundColor = _topBorder.backgroundColor;
    [super setSelected:selected animated:animated];
    if (selected) {
        // Recover backgroundColor of subviews.
        _topBorder.backgroundColor = backgroundColor;
    }
}

@end
