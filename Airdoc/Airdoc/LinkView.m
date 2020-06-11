//
//  LinkView.m
//  
//
//  Created by Roman Scher on 12/31/15.
//
//

#import "LinkView.h"

@implementation LinkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"LinkView" owner:self options:nil];
    
        self.bounds = self.containerView.bounds;
        
        [_linkButton setTitle:nil forState:UIControlStateNormal];
        _linkButton.tintColor = [AppConstants linkCellButtonColor];
        
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
