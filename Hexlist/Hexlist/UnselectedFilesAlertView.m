//
//  UnselectedFilesAlertView.m
//  Hexlist
//
//  Created by Roman Scher on 1/13/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "UnselectedFilesAlertView.h"

@implementation UnselectedFilesAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"UnselectedFilesAlertView" owner:self options:nil];
        
        self.bounds = self.containerView.bounds;
        
        [self addSubview:self.containerView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
