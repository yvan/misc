//
//  MyHexlistViewController.h
//  Hexlist
//
//  Created by Roman Scher on 1/14/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HexManager.h"
#import "AlertManager.h"
#import "MBProgressHUD.h"
#import "sendViewController.h"
#import "CreateViewController.h"
#import "HexCell.h"
#import "CircleButton.h"
#import "FadeSegue.h"


@protocol MyHexlistViewControllerDelegate <NSObject>

-(void) addedToHexShowHUDWithNumAdded:(int)numHexesAdded;

@end

@interface MyHexlistViewController : UIViewController <UITableViewDelegate
                                                       ,UITableViewDataSource
                                                       ,CreateViewControllerDelegate
                                                       ,HexCellDelegate>

@property (nonatomic, strong) RLMArray *hexes;
@property (nonatomic, strong) RLMNotificationToken *rlmNotificationToken;
@property (nonatomic, strong) NSMutableArray *staticHexes;
@property (strong, nonatomic) NSMutableSet<Hex*> *selectedHexes;
@property (nonatomic, assign) BOOL currentlyPerformingFineGrainedUpdate;
@property (nonatomic, assign) BOOL allHexColorsAreMyHexColor;

@property (nonatomic, assign) NSInteger numLinksForMaxHexCellSize;

@property (weak, nonatomic) IBOutlet UIScrollView *emptyMessageScrollView;
@property (weak, nonatomic) IBOutlet UITableView *myHexlistTableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableMessage;

@property (weak, nonatomic) IBOutlet CircleButton *addButton;

@property (strong, nonatomic) UIBarButtonItem *leftBarButton;
@property (strong, nonatomic) UIBarButtonItem *rightBarButton;

//MyHexListAction
@property (nonatomic, assign) MyHexlistAction myHexlistAction;
@property (strong, nonatomic) NSArray<Link*> *linksToAddToHex;

@property (nonatomic, weak) id <MyHexlistViewControllerDelegate> myHexlistViewControllerDelegate;

//Send View Segue
@property (nonatomic, assign) SendType sendViewSendType;
@property Hex *hexToSend;

//Create View Segue
@property (nonatomic, assign) CreateViewAction createViewAction;
@property (strong, nonatomic) Hex *hexToEdit;
@property (strong, nonatomic) Link *linkToEdit;

@end
