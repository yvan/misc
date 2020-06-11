//
//  LinkPackageCell.m
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import "LinkPackageCell.h"
#import "AppConstants.h"

@implementation LinkPackageCell

- (void)awakeFromNib {
    // Initialization code
    
    //General
    _numLinks = 0;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //Button Colors
    UIImage *image = [[_downloadButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_downloadButton setImage:image forState:UIControlStateNormal];
    _downloadButton.tintColor = [AppConstants linkCellButtonColor];
    [_downloadButton setExclusiveTouch:YES];
    [_deleteButton setExclusiveTouch:YES];
    
    image = [[_deleteButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_deleteButton setImage:image forState:UIControlStateNormal];
    _deleteButton.tintColor = [AppConstants linkCellButtonColor];
        
    //Hide expansion space views
    _linksView.alpha = 0.0;
    _actionsView.alpha = 0.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSInteger)verticalMargin {
    return 3;
}

+(NSInteger)cellHeightUnexpanded {
    return [self mainViewHeight] + (2 * [self verticalMargin]);
}

+(NSInteger)cellHeightExpandedStaticPortion {
    return [self mainViewHeight] + [self actionsViewHeight] + (2 * [self verticalMargin]);
}

+(NSInteger)mainViewHeight {
    return 54;
}

+(NSInteger)linkHeight {
    return 45;
}

+(NSInteger)actionsViewHeight {
    return 45;
}

@end
