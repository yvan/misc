//
//  HexCell.h
//  Hexlist
//
//  Created by Roman Scher on 1/20/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hex.h"
#import "LinkCell.h"
#import "AlertManager.h"
#import "HPReorderTableView.h"

@protocol HexCellDelegate <NSObject>

@required

-(void)linkButtonPressedWithLink:(Link*)link;
-(void)deleteLink:(Link*)link FromHex:(Hex*)hex;
-(void)startedReorderingLinks;
-(void)finishedReorderingLinks;

@end

@interface HexCell : UITableViewCell <UITableViewDelegate
                                      ,UITableViewDataSource
                                      ,HPReorderTableViewDelegate>

@property (weak, nonatomic) id <HexCellDelegate> hexCellDelegate;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *hexagon;
@property (weak, nonatomic) IBOutlet UIButton *helperButton;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@property (weak, nonatomic) IBOutlet UIView *linksView;
@property (weak, nonatomic) IBOutlet UITableView *linksTableView;

@property (weak, nonatomic) IBOutlet UIView *actionsView;
@property (weak, nonatomic) IBOutlet UIButton *lefthandButton;
@property (weak, nonatomic) IBOutlet UIButton *righthandButton;

//HexCell Types

@property (nonatomic, assign) HexCellType hexCellType;

//HexCellTri
@property (weak, nonatomic) IBOutlet UIButton *middleButton;

@property (nonatomic, strong) Hex *hex;
@property (nonatomic, strong) NSMutableArray *staticLinksArray;

-(void)updateLinksResetOffset:(BOOL)resetOffset;
-(void)updateLinksAnimated;

+(NSInteger)verticalMargin;
+(NSInteger)horizontalMargin;
+(NSInteger)cellHeightUnexpanded;
+(NSInteger)cellHeightExpandedStaticPortion;
+(NSInteger)mainViewHeight;
+(NSInteger)linkHeight;
+(NSInteger)actionsViewHeight;

@end
