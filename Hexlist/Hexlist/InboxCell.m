//
//  InboxCell.m
//  Hexlist
//
//  Created by Roman Scher on 3/20/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "InboxCell.h"

@implementation InboxCell

//- (void)setFrame:(CGRect)frame {
//    frame.origin.y += 4;
//    frame.size.height -= 2 * 4;
//    [super setFrame:frame];
//}

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
//    [self.contentView.layer setBorderColor:[[AppConstants appSchemeColor] CGColor]];
//    [self.contentView.layer setBorderWidth:0.5f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
