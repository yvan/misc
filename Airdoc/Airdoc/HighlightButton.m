//
//  HighlightButton.m
//  Envoy
//
//  Created by Roman Scher on 9/21/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "HighlightButton.h"

@implementation HighlightButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}


- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (_highlightColor) {
            self.backgroundColor = _highlightColor;
        }
        else {
            self.alpha = 0.25;
        }
    }
    else {
        if (_normalColor) {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 self.backgroundColor = _normalColor;
                             }
                             completion:nil];
        }
        else {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                    self.alpha = 1.0;
                             }
                             completion:nil];
        }
    }
}

@end
