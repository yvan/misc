//
//  RequestViewCell.h
//  Airdoc
//
//  Created by Roman Scher on 1/23/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *requestName;
@property (weak, nonatomic) IBOutlet UIButton *acceptRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *declineRequestButton;

@end
