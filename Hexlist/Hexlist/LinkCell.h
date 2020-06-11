//
//  LinkCell.h
//  Hexlist
//
//  Created by Roman Scher on 1/20/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkButton.h"
#import "MCSwipeTableViewCell.h"
#import "AppConstants.h"

@interface LinkCell : MCSwipeTableViewCell

@property (nonatomic, strong) Link *link;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *topBorder;

@property (weak, nonatomic) IBOutlet UIButton *serviceImageButton;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;

@end
