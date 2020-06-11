//
//  SendCell.h
//  Hexlist
//
//  Created by Roman Scher on 3/18/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *personName;
@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;
@property BOOL selectedCheckmark;

@end
