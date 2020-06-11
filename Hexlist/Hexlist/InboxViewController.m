//
//  InboxViewController.m
//  Hexlist
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "InboxViewController.h"

@interface InboxViewController ()

@property (nonatomic, assign) BOOL firstLoad;

@end

#define HEXES_SECTION 0

@implementation InboxViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Table view Setup ( & removing excess empty table view cells)
    [_inboxTableView setDelegate:self];
    [_inboxTableView setDataSource:self];
    _inboxTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _inboxTableView.separatorColor = [AppConstants tableViewSeparatorColor];
    
    _inboxTableView.delaysContentTouches = NO;
    for (UIView *currentView in _inboxTableView.subviews) {
        if([currentView isKindOfClass:[UIScrollView class]]){
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
    
    //Putting data source setup on dispatch async on main
    //Improves performance on first open of inbox.
    [_emptyMessageScrollView setAlpha:0.0];
    _firstLoad = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //Initialize data sources
        _selectedHexes = [[NSMutableSet alloc] init];
        _hexes = [HexManager getAllHexesInInbox];
        _staticHexes = [self getStaticHexesArray:_hexes];
        
        _numLinksForMaxHexCellSize = ((_inboxTableView.bounds.size.height *.80) - [HexCell cellHeightExpandedStaticPortion])/[HexCell linkHeight];
        
        [_inboxTableView registerNib:[UINib nibWithNibName:@"HexCell" bundle:nil] forCellReuseIdentifier:[AppConstants hexCellReuseIdentifierStringIdentifier]];
        [_inboxTableView reloadData];
        
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(){
                             [_emptyMessageScrollView setAlpha:1.0];
                         }
                         completion:^(BOOL success) {
                             _firstLoad = NO;
                         }];
        
        //Add links to Hex and save hex to disk
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        // Observe Realm Notifications (for hexes changes)
        _rlmNotificationToken = [realm addNotificationBlock:^(NSString *notification, RLMRealm * realm) {
            [self updateHexes];
        }];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInboxTabSelected)
                                                 name:@"inboxTabSelectedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Do any additional setup after loading the view.
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //Links View
    //Remove separator
    [_inboxTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //Set tableview background color
    UIView* bview = [[UIView alloc] init];
    bview.backgroundColor = [AppConstants grayTableViewBackgroundColor];
    [_inboxTableView setBackgroundView:bview];
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numRows = 0;
    
    NSInteger countHexes = [_staticHexes count];
    
    numRows = countHexes;

    //Show table view or empty message
    if (countHexes == 0) {
        _emptyMessageScrollView.scrollEnabled = YES;
        _emptyTableMessage.text = @"No Hexes Received Yet";
        if (_firstLoad) {
             [_inboxTableView setAlpha:0.0];
        }
        else {
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [_inboxTableView setAlpha:0.0];
                             }
                             completion:nil];
        }
    }
    else {
        _emptyMessageScrollView.scrollEnabled = NO;
        if (_firstLoad) {
            [_inboxTableView setAlpha:1.0];
            
        }
        else {
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [_inboxTableView setAlpha:1.0];
                             }
                             completion:nil];
        }
    }
    
    return numRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //HexCell
    return [self generateHexCellForTableView:tableView AndIndexPath:indexPath];
}

/* - Convenience method to generate a hexCell for an indexPath- */
-(HexCell *)generateHexCellForTableView:(UITableView *)tableView
                                           AndIndexPath:(NSIndexPath *)indexPath {
    
    HexCell *hexCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants hexCellReuseIdentifierStringIdentifier] forIndexPath:indexPath];
    hexCell.hexCellType = HexCellTypeInbox;
    
    [hexCell.lefthandButton addTarget:self action:@selector(hexLefthandButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [hexCell.righthandButton addTarget:self action:@selector(hexRighthandButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [hexCell.hexagon addTarget:self action:@selector(hexCellHexagonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    hexCell.hex = hex;
    
    UIColor *hexColor = [AppConstants colorFromHexString:hex.hexColor];
    
    //Set tint color of buttons
    [hexCell.lefthandButton setTintColor:hexColor];
    [hexCell.righthandButton setTintColor:hexColor];
    
    //Draw First Letters of first & name in hexagon
    
    NSArray *firstAndLastName = [hex.senderName componentsSeparatedByString:@" "];
    NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
    //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
    firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
    
     //Set color and text of hexagon
    [hexCell.hexagon setTintColor:hexColor];
    [hexCell.hexagon setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
    [hexCell.hexagon setUserInteractionEnabled:NO];
    [hexCell.helperButton setUserInteractionEnabled:NO];
    
    NSInteger numLinks = [hex.links count];
    
    NSString *numLinksString = [[NSString stringWithFormat: @"%ld", (long)numLinks] stringByAppendingString:(numLinks == 1)? @" Link" : @" Links"];
    
    numLinksString = [numLinksString stringByAppendingString:[NSString stringWithFormat:@" - %@", hex.senderName]];
    
    hexCell.subLabel.text = numLinksString;
    
    //Display hex description in main label if present, else use sender's name.
    if (hex.hexDescription && ![hex.hexDescription isEqualToString:@""]) {
        [hexCell.mainLabel setHidden:NO];
        hexCell.mainLabel.text = hex.hexDescription;
    }
    else {
        [hexCell.mainLabel setHidden:YES];
    }
    
    //Set up linksTableView
    hexCell.hexCellDelegate = self;
    
    if ([_selectedHexes containsObject:hex]) {
        //Reload links tableview only when the hex cell is open
        [hexCell updateLinksResetOffset:NO];
        hexCell.linksView.alpha = 1.0;
        hexCell.actionsView.alpha = 1.0;
        [_inboxTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        hexCell.linksView.alpha = 0.0;
        hexCell.actionsView.alpha = 0.0;
    }
    
    return hexCell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Links View
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //Links View
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Links View
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    if([_selectedHexes containsObject:hex]) {
        NSInteger numLinks = [hex.links count];
        
        NSInteger expandedCellHeight = [HexCell cellHeightExpandedStaticPortion] + ([HexCell linkHeight] * numLinks);
        
        if (expandedCellHeight <= (.80 * _inboxTableView.bounds.size.height)) {
            return [HexCell cellHeightExpandedStaticPortion] + ([HexCell linkHeight] * numLinks);
        }
        else {
            return [HexCell cellHeightExpandedStaticPortion] + ([HexCell linkHeight] * _numLinksForMaxHexCellSize);
        }
    }
    else {
        return [HexCell cellHeightUnexpanded];
    }
}

/* - Sets styling for section headers - */

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    view.tintColor = [UIColor clearColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[AppConstants appSchemeColor]];
}

/* - Specifically sets the line seperator insets of cells, seperate from Sections - */

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Links View
    //Fixes corner radius of HexCell and improves scroll performance with shadow path
    HexCell *hexCell = (HexCell*)cell;
    hexCell.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    hexCell.containerView.layer.shadowOpacity = 0.10f;
    hexCell.containerView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    hexCell.containerView.layer.shadowRadius = 1.0f;
    [hexCell.mainView.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:hexCell.mainView.bounds cornerRadius:5.0f].CGPath];
    
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

/* - Used to set selection of file package - */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HexCell *hexCell = (HexCell*)[_inboxTableView cellForRowAtIndexPath:indexPath];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    if([_selectedHexes containsObject:hex]) {
        [_selectedHexes removeObject:hex];
        
        [_inboxTableView beginUpdates];
        [_inboxTableView endUpdates];
        
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(){
                             [hexCell.linksView setAlpha:0.0];
                             [hexCell.actionsView setAlpha:0.0];
                         }
                         completion:nil];
    }
    else {
        [_selectedHexes addObject:hex];
        
        //Reload links tableview only when the hex cell is opened
        [hexCell updateLinksResetOffset:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_inboxTableView beginUpdates];
            [_inboxTableView endUpdates];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            hexCell.linksTableView.scrollEnabled =  [hex.links count] * [HexCell linkHeight] > hexCell.linksTableView.frame.size.height;
            [_inboxTableView scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:YES];
            
            [UIView animateWithDuration:.4
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [hexCell.linksView setAlpha:1.0];
                                 [hexCell.actionsView setAlpha:1.0];
                             }
                             completion:nil];
        });
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    HexCell *hexCell = (HexCell*)[_inboxTableView cellForRowAtIndexPath:indexPath];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    if([_selectedHexes containsObject:hex]) {
        [_selectedHexes removeObject:hex];
        
        [_inboxTableView beginUpdates];
        [_inboxTableView endUpdates];
        
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(){
                             [hexCell.linksView setAlpha:0.0];
                             [hexCell.actionsView setAlpha:0.0];
                         }
                         completion:nil];
    }
}

#pragma mark - NSNotificationCenter

/* - For Color changes of cells :D - */

-(void)handleInboxTabSelected {
    if ([_selectedHexes count] > 0) {
        [self tableView:_inboxTableView didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:[_staticHexes indexOfObject:[_selectedHexes anyObject]] inSection:HEXES_SECTION]];
    }
    [_inboxTableView setContentOffset:CGPointZero animated:YES];
}

-(void)updateHexes {
    dispatch_async(dispatch_get_main_queue(), ^{
        //Update Hexes
        NSArray *oldHexesArray = [[NSArray alloc] initWithArray:_staticHexes copyItems:NO];
        _staticHexes = [self getStaticHexesArray:_hexes];
        NSInteger hexesCountBefore = [oldHexesArray count];
        NSInteger hexesCountNow = [_staticHexes count];
        NSInteger numNewHexes = hexesCountNow - hexesCountBefore;
        
        //If there is indeed a new hex, do the insert.
        if (numNewHexes > 0) {
            
            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];

            //Find indexes of objects that were inserted
            NSSet *oldHexesSet = [NSSet setWithArray:oldHexesArray];
            NSIndexSet *matchingIndexes = [_staticHexes indexesOfObjectsPassingTest:^BOOL(Hex *hex, NSUInteger idx, BOOL *stop) {
                return ![oldHexesSet containsObject:hex];
            }];
            
            [matchingIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:HEXES_SECTION]];
            }];
            
            //Perform all deletion and insertion updates at once
            [_inboxTableView beginUpdates];
            [_inboxTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_inboxTableView endUpdates];
        }
        else if (numNewHexes < 0) {
            NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
            
            NSIndexSet *matchingIndexes = [oldHexesArray indexesOfObjectsPassingTest:^BOOL(Hex *hex, NSUInteger idx, BOOL *stop) {
                return hex.invalidated;
            }];
            
            [matchingIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:HEXES_SECTION]];
            }];
            
            //Make a new array with the valid objects
            NSMutableSet *validHexes = [[NSMutableSet alloc] init];
            for (Hex *hex in _selectedHexes) {
                if (!hex.invalidated) {
                    [validHexes addObject:hex];
                }
            }
            _selectedHexes = validHexes;
            
            [_inboxTableView beginUpdates];
            [_inboxTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_inboxTableView endUpdates];
        }
        else {
            if (!_currentlyPerformingFineGrainedUpdate) {
                //NSLog(@"Reloading hexes");
                [self reloadHexes];
            }
            else {
                _currentlyPerformingFineGrainedUpdate = NO;
            }
        }
    });
}

/* - Resets all hexes - */

-(void)reloadHexes {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_inboxTableView reloadData];
    });
}

-(void)reloadSelectedHexLinks {
    //NSLog(@"Reload selected hex");
    Hex *selectedHex = [_selectedHexes anyObject];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_staticHexes indexOfObject:selectedHex] inSection:HEXES_SECTION];
    HexCell *hexCell = [_inboxTableView cellForRowAtIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hexCell updateLinksResetOffset:NO];
    });
}

-(void)applicationDidEnterBackground {
    [self reloadSelectedHexLinks];
}

#pragma mark - IBAction

-(void)hexCellHexagonPressed:(id)sender {
}

-(IBAction)hexLefthandButtonPress:(id)sender {
    
    HexCell *hexCell = (HexCell*)[self GetCellFromTableView:_inboxTableView Sender:sender];
    NSIndexPath *indexPath = [_inboxTableView indexPathForRowAtPoint:hexCell.center];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    _sendViewSendType = SendTypeHex;
    _hexToSend = hex;
    [self performSegueWithIdentifier:@"inbox-to-send" sender:self];
}

-(IBAction)hexRighthandButtonPress:(id)sender {
    HexCell *hexCell = (HexCell*)[self GetCellFromTableView:_inboxTableView Sender:sender];
    NSIndexPath *indexPath = [_inboxTableView indexPathForRowAtPoint:hexCell.center];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    [self showHexOptionsWithHex:hex];
}

#pragma mark - HexCellDelegate

/* - Handler method for link buttons -*/
-(void)linkButtonPressedWithLink:(Link*)link {
    [self showLinkOptionsWithLink:link];
}

-(void)deleteLink:(Link *)link FromHex:(Hex *)hex {}

-(void)startedReorderingLinks {
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    _inboxTableView.allowsSelection = NO;
}

-(void)finishedReorderingLinks {
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    _inboxTableView.allowsSelection = YES;
}

#pragma mark - Alerts

-(void)alertUserToLinkCopied {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Link Copied";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)alertUserToUserReported {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"User Reported";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)showLinkOptionsWithLink:(Link*)link {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:link.linkDescription message:link.url preferredStyle:UIAlertControllerStyleActionSheet];
    
//    UIAlertAction* linkInfo = [UIAlertAction actionWithTitle:@"Link info" style:UIAlertActionStyleDefault
//                                                            handler:^(UIAlertAction * action) {
//                                                                _createViewAction = CreateViewActionViewLink;
//                                                                _linkToView = link;
//                                                                [self performSegueWithIdentifier:@"inbox-to-create" sender:self];
//                                                            }];
    UIAlertAction* shareLink = [UIAlertAction actionWithTitle:@"Use link" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self shareLink:link];
                                                      }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:shareLink];
    [alert addAction:cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

-(void)showHexOptionsWithHex:(Hex*)hex {
    
    NSInteger numLinks = [hex.links count];
    
    NSString *numLinksString = [[NSString stringWithFormat: @"%ld", (long)numLinks] stringByAppendingString:(numLinks == 1)? @" Link" : @" Links"];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:hex.hexDescription message:numLinksString preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* saveToMyHexlist = [UIAlertAction actionWithTitle:@"Save to My Hexlist" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self saveHexToMyHexlist:hex];
                                                          }];
    UIAlertAction* shareHex = [UIAlertAction actionWithTitle:@"Export Hex" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [self shareHex:hex];
                                                     }];
    UIAlertAction* reportAndBlock = [UIAlertAction actionWithTitle:@"Report and Block" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [SettingsManager blockUserWithUUID:hex.senderUUID];
                                                         [self alertUserToUserReported];
                                                     }];
    UIAlertAction* deleteHex = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction * action) {
                                                                [self deleteHex:hex];
                                                            }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:shareHex];
    [alert addAction:saveToMyHexlist];
    [alert addAction:reportAndBlock];
    [alert addAction:deleteHex];
    [alert addAction:cancel];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

-(void)saveHexToMyHexlist:(Hex*)hex {
    NSMutableArray *linkCopiesArray = [[NSMutableArray alloc] init];
    for (Link *link in hex.links) {
        Link *linkCopy = [Link createLinkWithUUID:[[NSUUID UUID] UUIDString]
                                           AndURL:link.url
                               AndLinkDescription:link.linkDescription
                                       AndService:[AppConstants serviceTypeForString:link.service]];
        
        [linkCopiesArray addObject:linkCopy];
    }
    
    Hex *hexCopy = [Hex createHexWithUUID:[[NSUUID UUID] UUIDString]
                           AndSenderUUID:hex.senderUUID
                           AndSenderName:hex.senderName
                       AndHexDescription:hex.hexDescription
                             AndHexColor:hex.hexColor];
    
    [HexManager saveNewHexToMyHexlist:hexCopy WithLinks:linkCopiesArray];
}

-(void)shareLink:(Link*)link {
    NSURL *linkURL = [[NSURL alloc] initWithString:link.url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityVC = [AlertManager generateActivityViewControllerWithURL:linkURL];
        
        activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *items, NSError *error) {
        };
        
        [self presentViewController:activityVC
                           animated:YES
                         completion:^() {}];
    });
}

-(void)shareHex:(Hex*)hex {
    NSString *hexLinksString = [[[hex.hexDescription stringByAppendingString:@" - " ]
                                stringByAppendingString:hex.senderName]
                                stringByAppendingString:@"\n\n"];
    
    for (Link *link in hex.links) {
        if (link.linkDescription && ![link.linkDescription isEqualToString:@""]) {
            hexLinksString = [[hexLinksString stringByAppendingString:link.linkDescription] stringByAppendingString:@"\n"];
        }
        hexLinksString = [[hexLinksString stringByAppendingString:link.url] stringByAppendingString:@"\n\n"];
    }
    
    UIActivityViewController *activityVC = [AlertManager generateShareHexActivityViewControllerWithString:hexLinksString];
    
    //    activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *items, NSError *error) {};
    
    [self presentViewController:activityVC
                       animated:YES
                     completion:^() {}];
}

-(void)deleteHex:(Hex*)hex {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_staticHexes indexOfObject:hex] inSection:HEXES_SECTION];
        
        _currentlyPerformingFineGrainedUpdate = YES;
        
        [_selectedHexes removeObject:hex];
        
        [_inboxTableView beginUpdates];
        [_inboxTableView endUpdates];
        
        [_staticHexes removeObject:hex];
        
        NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                     [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],
                                     nil];
        
        [_inboxTableView beginUpdates];
        [_inboxTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [_inboxTableView endUpdates];
        
        //Delete hex, wait for realm notification and do the rest of the animations/updates in updateHexes
        [HexManager deleteHexFromInbox:hex];
    });
}

#pragma mark - Helper Methods

-(NSMutableArray*)getStaticHexesArray:(RLMResults*)hexes {
    NSMutableArray *staticHexesArray = [[NSMutableArray alloc] init];
    for (Hex *hex in hexes) {
        [staticHexesArray addObject:hex];
    }
    
    return staticHexesArray;
}

-(NSArray*)getSortedLinksArray:(RLMArray*)links {
    NSMutableArray *linksArray = [[NSMutableArray alloc] init];
    for (Link *link in links) {
        [linksArray addObject:link];
    }
    
    return linksArray;
    
//    NSArray *sortedLinksArray;
//    sortedLinksArray = [linksArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        NSString *fileNameA = ((Link*)a).linkDescription;
//        NSString *fileNameB = ((Link*)b).linkDescription;
//        return [fileNameA length] > [fileNameB length] ;
//    }];
//    return sortedLinksArray;
}

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    return [tableView cellForRowAtIndexPath:indexPath];
}

//Users/scherroman/Desktop/Xcode projects/Hexlist/Hexlist/InboxViewController.m
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[sendViewController class]]) {
        //set the sendViewController's delegate to the home view controller
        ((sendViewController*)[segue destinationViewController]).sendViewControllerDelegate = (id)self.tabBarController;
        //Set the sendViewController's type of send
        ((sendViewController*)[segue destinationViewController]).sendType = _sendViewSendType;
        ((sendViewController*)[segue destinationViewController]).hexToSend = _hexToSend;
    }
    else if ([[segue destinationViewController] isKindOfClass:[CreateViewController class]]) {
        ((CreateViewController*)[segue destinationViewController]).createViewControllerDelegate = self;
        ((CreateViewController*)[segue destinationViewController]).createViewAction = _createViewAction;
        if (_createViewAction == CreateViewActionViewLink) {
            ((CreateViewController*)[segue destinationViewController]).linkToEdit = _linkToView;
        }
    }
}

@end
