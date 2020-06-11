//
//  IncomingSendProgressCell.h
//  Envoy
//
//  Created by Roman Scher on 10/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncomingSendProgressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userCircle;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *sendProgress;

@end
