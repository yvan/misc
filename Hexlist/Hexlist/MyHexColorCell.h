//
//  MyHexColorCell.h
//  Hexlist
//
//  Created by Roman Scher on 1/24/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyHexColorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *hexagon;
@property (weak, nonatomic) IBOutlet UIButton *helperButton;

@property (weak, nonatomic) IBOutlet UIView *bottomBorder;

@end
