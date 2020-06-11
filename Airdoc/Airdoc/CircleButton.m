//
//  CircleButton.m
//  Envoy
//
//  Created by Roman Scher on 9/22/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "CircleButton.h"

@implementation CircleButton

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
            [self setBackgroundColor:_highlightColor];
        }
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    }
    else {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             if (_normalColor) {
                                 [self setBackgroundColor:_normalColor];
                             }
                         }
                         completion:nil];
        self.layer.shadowRadius = 1.5f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    }
}

@end
