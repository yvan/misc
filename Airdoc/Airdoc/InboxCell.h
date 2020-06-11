//
//  InboxCell.h
//  Airdoc
//
//  Created by Roman Scher on 3/20/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"
#import "LocalStorageManager.h"

@interface InboxCell : MCSwipeTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userCircle;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@end
