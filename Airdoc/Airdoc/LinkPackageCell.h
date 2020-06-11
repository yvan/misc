//
//  LinkPackageCell.h
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import <UIKit/UIKit.h>
#import "HighlightButton.h"
#import "LinkPackage.h"

@interface LinkPackageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *userCircle;
@property (weak, nonatomic) IBOutlet UIButton *serviceIcon;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@property (weak, nonatomic) IBOutlet UIView *linksView;

@property (weak, nonatomic) IBOutlet UIView *actionsView;
@property (weak, nonatomic) IBOutlet UIView *downloadButtonView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIView *deleteButtonView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, assign) NSInteger numLinks;
@property (nonatomic, strong) LinkPackage *linkPackage;

+(NSInteger)cellHeightUnexpanded;
+(NSInteger)cellHeightExpandedStaticPortion;
+(NSInteger)mainViewHeight;
+(NSInteger)linkHeight;
+(NSInteger)actionsViewHeight;

@end
