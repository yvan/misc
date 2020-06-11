//
//  ResponsiveTableView.m
//  Hexlist
//
//  Created by Roman Scher on 1/19/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "ResponsiveTableView.h"

@implementation ResponsiveTableView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    // Because we set delaysContentTouches = NO, we return YES for UIButtons
    // so that scrolling works correctly when the scroll gesture
    // starts in the UIButtons.
    if ([view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
