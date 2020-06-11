//
//  MyHexlistViewController.m
//  Hexlist
//
//  Created by Roman Scher on 1/14/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "MyHexlistViewController.h"

@interface MyHexlistViewController ()

@property (nonatomic, assign) BOOL firstLoad;

@end

#define HEXES_SECTION 0

@implementation MyHexlistViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Draw the add Button & Shadow
    _addButton.layer.cornerRadius = _addButton.frame.size.width/2;
    _addButton.backgroundColor = [AppConstants appSchemeColor];
    [_addButton setHighlightColor:[AppConstants circleButtonSelectionColor]];
    [_addButton setNormalColor:_addButton.backgroundColor];
    [_addButton setImage:[UIImage imageNamed:[AppConstants addImageStringIdentifier]] forState:UIControlStateNormal];
    _addButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _addButton.layer.shadowOpacity = .5f;
    _addButton.layer.shadowOffset = CGSizeZero;
    _addButton.layer.shadowRadius = 1.5f;
    _addButton.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    //    _addButton.layer.masksToBounds = NO;
    //    _addButton.clipsToBounds = NO;
    _addButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_addButton.bounds cornerRadius:_addButton.frame.size.width/2].CGPath;
    [_addButton setExclusiveTouch:YES];
    
    //Navbar Buttons
    HighlightButton *paintButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [paintButton addTarget:self action:@selector(changeAllColorsToMyHexColor) forControlEvents:UIControlEventTouchUpInside];
    [paintButton setImage:[UIImage imageNamed:[AppConstants paintImageStringIdentifier]] forState:UIControlStateNormal];
    [paintButton setExclusiveTouch:YES];
    [paintButton setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *paintBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:paintButton];
    [self.navigationItem setRightBarButtonItem:paintBarButtonItem];
    _rightBarButton = paintBarButtonItem;
    [_rightBarButton.customView setAlpha:0.0];
    
    // Table view Setup ( & removing excess empty table view cells)
    [_myHexlistTableView setDelegate:self];
    [_myHexlistTableView setDataSource:self];
    [_myHexlistTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _myHexlistTableView.delaysContentTouches = NO;
    for (UIView *currentView in _myHexlistTableView.subviews) {
        if([currentView isKindOfClass:[UIScrollView class]]){
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
    
    //Putting data source setup on dispatch async on main
    //Improves performance on first open of myHexlist.
    [_emptyMessageScrollView setAlpha:0.0];
    _firstLoad = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //Initialize data sources
//        _selectedHexIndexes = [[NSMutableIndexSet alloc] init];
        _hexes = [HexManager getAllHexesInMyHexlist];
        _staticHexes = [self getStaticHexesArray:_hexes];
        _selectedHexes = [[NSMutableSet alloc] init];
        _allHexColorsAreMyHexColor = NO;
        
        _numLinksForMaxHexCellSize = ((_myHexlistTableView.bounds.size.height *.80) - [HexCell cellHeightExpandedStaticPortion])/[HexCell linkHeight];
        
        [_myHexlistTableView registerNib:[UINib nibWithNibName:@"HexCellTri" bundle:nil] forCellReuseIdentifier:[AppConstants hexCellTriReuseIdentifierStringIdentifier]];
        [_myHexlistTableView reloadData];
        
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
    
    if (_myHexlistAction != MyHexlistActionAddToHex) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadHexes)
                                                     name:@"userChangedNameNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMyHexlistTabSelected)
                                                     name:@"myHexlistTabSelectedNotification"
                                                   object:nil];
        
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(popBackToRootViewController)
                                                     name:@"popBackToRootViewController"
                                                   object:nil];
    }
    
    if (_myHexlistAction == MyHexlistActionAddToHex) {
        self.navigationItem.title = @"Add to Hex";
        
        _myHexlistTableView.allowsMultipleSelection = YES;
        
        [_addButton setHidden:YES];
        
        //Create navbar buttons
        HighlightButton *cancelButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setImage:[UIImage imageNamed:[AppConstants cancelImageStringIdentifier]] forState:UIControlStateNormal];
        [cancelButton setExclusiveTouch:YES];
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
        
        _leftBarButton = cancelBarButtonItem;
        
        HighlightButton *acceptButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 26, 21)];
        [acceptButton addTarget:self action:@selector(acceptAddToHexButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [acceptButton setImage:[UIImage imageNamed:[AppConstants acceptWhiteImageStringIdentifier]] forState:UIControlStateNormal];
        [acceptButton setExclusiveTouch:YES];
        UIBarButtonItem *acceptBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:acceptButton];
        [self.navigationItem setRightBarButtonItem:acceptBarButtonItem];
        
        _rightBarButton = acceptBarButtonItem;
        [_rightBarButton setEnabled:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Remove the saved notification token from Realm
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm removeNotification:_rlmNotificationToken];
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)popBackToRootViewController {
    //Add links to Hex and save hex to disk
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [CATransaction commit];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //Links View
    //Remove separator
    [_myHexlistTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //Set tableview background color
    UIView* bview = [[UIView alloc] init];
    bview.backgroundColor = [AppConstants grayTableViewBackgroundColor];
    [_myHexlistTableView setBackgroundView:bview];
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numRows = 0;
    
    NSInteger countHexes = [_staticHexes count];
    
    numRows = countHexes;
    
    
    //Show table view or empty message
    if (countHexes == 0) {
        _emptyMessageScrollView.scrollEnabled = YES;
        _emptyTableMessage.text = @"No Hexes Added Yet";
        if (_firstLoad) {
            [_myHexlistTableView setAlpha:0.0];
        }
        else {
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 if ([_staticHexes count] == 0) {
                                     [_rightBarButton.customView setAlpha:0.0];
                                 }
                                 [_myHexlistTableView setAlpha:0.0];
                             }
                             completion:nil];
        }
    }
    else {
        _emptyMessageScrollView.scrollEnabled = NO;
        if (_firstLoad) {
            [_myHexlistTableView setAlpha:1.0];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 if ([_staticHexes count] > 0) {
                                     [_rightBarButton.customView setAlpha:1.0];
                                 }
                             }
                             completion:nil];
        }
        else {
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 if ([_staticHexes count] > 0) {
                                     [_rightBarButton.customView setAlpha:1.0];
                                 }
                                 [_myHexlistTableView setAlpha:1.0];
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
    
    HexCell *hexCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants hexCellTriReuseIdentifierStringIdentifier] forIndexPath:indexPath];
    hexCell.hexCellType = HexCellTypeMyHexlist;
    
    [hexCell.lefthandButton addTarget:self action:@selector(hexLefthandButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [hexCell.middleButton addTarget:self action:@selector(hexMiddleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [hexCell.righthandButton addTarget:self action:@selector(hexRighthandButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
//    [hexCell.hexagon addTarget:self action:@selector(hexCellHexagonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [hexCell.helperButton addTarget:self action:@selector(hexCellHelperButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    hexCell.hex = hex;
    
    UIColor *hexColor = [AppConstants colorFromHexString:hex.hexColor];
    
    //Set tint color of buttons
    [hexCell.lefthandButton setTintColor:hexColor];
    [hexCell.middleButton setTintColor:hexColor];
    [hexCell.righthandButton setTintColor:hexColor];
    
    NSString *userName = [SettingsManager getUserDisplayableFullName];
    
    //Draw First Letters of first & name in hexagon
    NSArray *firstAndLastName = [userName componentsSeparatedByString:@" "];
    NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
    //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
    firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
    
    //Set color and text of hexagon
    [hexCell.hexagon setTintColor:hexColor];
  
    hexCell.mainLabel.text = hex.hexDescription;
    
    NSInteger numLinks = [hex.links count];
    
    NSString *numLinksString = [[NSString stringWithFormat: @"%ld", (long)numLinks] stringByAppendingString:(numLinks == 1)? @" Link" : @" Links"];
    
    hexCell.subLabel.text = numLinksString;
    
    //Set up linksTableView
    hexCell.hexCellDelegate = self;
    
    if (_myHexlistAction == MyHexlistActionAddToHex) {
        if ([_selectedHexes containsObject:hex]) {
            [hexCell.hexagon setImage:[UIImage imageNamed:[AppConstants hexCheckmarkImageStringIdentifier]] forState:UIControlStateNormal];
            [_myHexlistTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            [hexCell.hexagon setUserInteractionEnabled:NO];
            [hexCell.helperButton setUserInteractionEnabled:NO];
            [hexCell.hexagon setTitle:nil forState:UIControlStateNormal];
            [hexCell.hexagon setImage:nil forState:UIControlStateNormal];
        }
    }
    else {
        [hexCell.hexagon setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
        
        if ([_selectedHexes containsObject:hex]) {
            [hexCell updateLinksResetOffset:NO];
            hexCell.linksView.alpha = 1.0;
            hexCell.actionsView.alpha = 1.0;
            [_myHexlistTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            hexCell.linksView.alpha = 0.0;
            hexCell.actionsView.alpha = 0.0;
        }
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
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Links View
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    if(_myHexlistAction != MyHexlistActionAddToHex && [_selectedHexes containsObject:hex]) {
        NSInteger numLinks = [hex.links count];
        
        NSInteger expandedCellHeight = [HexCell cellHeightExpandedStaticPortion] + ([HexCell linkHeight] * numLinks);
        
        if (expandedCellHeight <= (.80 * _myHexlistTableView.bounds.size.height)) {
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
    //Fixes corner radius of HexCell and improves scroll performance with shadow path
    if ([cell isKindOfClass:[HexCell class]]) {
        HexCell *hexCell = (HexCell*)cell;
        hexCell.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        hexCell.containerView.layer.shadowOpacity = 0.10f;
        hexCell.containerView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        hexCell.containerView.layer.shadowRadius = 1.0f;
        [hexCell.mainView.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:hexCell.mainView.bounds cornerRadius:5.0f].CGPath];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

/* - Used to set selection of file package - */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HexCell *hexCell = (HexCell*)[_myHexlistTableView cellForRowAtIndexPath:indexPath];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    if([_selectedHexes containsObject:hex]) {
        [_selectedHexes removeObject:hex];
        
        if (_myHexlistAction == MyHexlistActionAddToHex) {
            [hexCell.hexagon setImage:nil forState:UIControlStateNormal];
            if ([_selectedHexes count] == 0) {
                 [_rightBarButton setEnabled:NO];
            }
        }
        else {
            [_myHexlistTableView beginUpdates];
            [_myHexlistTableView endUpdates];
            
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
    else {
        [_selectedHexes addObject:hex];
        
        if (_myHexlistAction == MyHexlistActionAddToHex) {
            [hexCell.hexagon setImage:[UIImage imageNamed:[AppConstants hexCheckmarkImageStringIdentifier]] forState:UIControlStateNormal];
            if ([_selectedHexes count] > 0) {
                [_rightBarButton setEnabled:YES];
            }
        }
        else {
            [hexCell updateLinksResetOffset:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_myHexlistTableView beginUpdates];
                [_myHexlistTableView endUpdates];
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                hexCell.linksTableView.scrollEnabled =  [hex.links count] * [HexCell linkHeight] > hexCell.linksTableView.frame.size.height;
                [_myHexlistTableView scrollToRowAtIndexPath:indexPath
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
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    HexCell *hexCell = (HexCell*)[_myHexlistTableView cellForRowAtIndexPath:indexPath];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    if([_selectedHexes containsObject:hex]) {
        [_selectedHexes removeObject:hex];
        
        if (_myHexlistAction == MyHexlistActionAddToHex) {
            [_selectedHexes removeObject:hex];
            [hexCell.hexagon setImage:nil forState:UIControlStateNormal];
            if ([_selectedHexes count] == 0) {
                [_rightBarButton setEnabled:NO];
            }
        }
        else {
            [_myHexlistTableView beginUpdates];
            [_myHexlistTableView endUpdates];
            
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
}

#pragma mark - Reordering

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"[can move row]");
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    if ([_selectedHexes containsObject:hex]){
        return NO;
    }
    else {
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_staticHexes exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    });
}

-(void)tableView:(UITableView *)tableView didBeginReorderingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self startedReorderingCells];
}

-(void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self finishedReorderingCells];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _currentlyPerformingFineGrainedUpdate = YES;
        
        //Get object to reorder from static hexes
        Hex *hexToReorder = [_staticHexes objectAtIndex:indexPath.row];
        
        Location *myHexlistLocation = [Location objectForPrimaryKey:[AppConstants stringForHexLocationType:HexLocationTypeMyHexlist]];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [myHexlistLocation.hexes moveObjectAtIndex:[myHexlistLocation.hexes indexOfObject:hexToReorder] toIndex:indexPath.row];
        [realm commitWriteTransaction];
    });
}

-(void)startedReorderingLinks {
    [self startedReorderingCells];
}

-(void)finishedReorderingLinks {
    [self finishedReorderingCells];
}

-(void)startedReorderingCells {
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    _myHexlistTableView.allowsSelection = NO;
}

-(void)finishedReorderingCells {
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    _myHexlistTableView.allowsSelection = YES;
    _currentlyPerformingFineGrainedUpdate = YES;
}

#pragma mark - NSNotificationCenter

/* - For Color changes of cells :D - */

-(void)handleMyHexlistTabSelected {
    if ([_selectedHexes count] > 0) {
        [self tableView:_myHexlistTableView didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:[_staticHexes indexOfObject:[_selectedHexes anyObject]] inSection:HEXES_SECTION]];
    }
    [_myHexlistTableView setContentOffset:CGPointZero animated:YES];
}

-(void)updateHexes {
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"[Update Hexes]");
        //Update Hexes
        NSArray *oldHexesArray = [[NSArray alloc] initWithArray:_staticHexes copyItems:NO];
        _staticHexes = [self getStaticHexesArray:_hexes];
        NSInteger hexesCountBefore = [oldHexesArray count];
        NSInteger hexesCountNow = [_staticHexes count];
        NSInteger numNewHexes = hexesCountNow - hexesCountBefore;
        
        //NSLog(@"Num new hexes: %ld", (long)numNewHexes);
        
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
            [_myHexlistTableView beginUpdates];
            [_myHexlistTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_myHexlistTableView endUpdates];
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
            
            if (_myHexlistAction == MyHexlistActionAddToHex) {
                if ([_selectedHexes count] == 0) {
                    [_rightBarButton setEnabled:NO];
                }
            }
            
            [_myHexlistTableView beginUpdates];
            [_myHexlistTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_myHexlistTableView endUpdates];
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
        [_myHexlistTableView reloadData];
    });
}

-(void)reloadSelectedHexLinks {
    //NSLog(@"Reload selected hex");
    Hex *selectedHex = [_selectedHexes anyObject];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_staticHexes indexOfObject:selectedHex] inSection:HEXES_SECTION];
    HexCell *hexCell = [_myHexlistTableView cellForRowAtIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hexCell updateLinksResetOffset:NO];
    });
}

-(void)applicationDidEnterBackground {
    [self reloadSelectedHexLinks];
}

#pragma mark - HexCellDelegate

/* - Handler method for link buttons -*/
-(void)linkButtonPressedWithLink:(Link*)link {
    [self showLinkOptionsWithLink:link];
}

-(void)deleteLink:(Link *)link FromHex:(Hex *)hex {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_staticHexes indexOfObject:hex] inSection:HEXES_SECTION];
    HexCell *hexCell = [_myHexlistTableView cellForRowAtIndexPath:indexPath];
    
    //Delete links from hex
    dispatch_async(dispatch_get_main_queue(), ^{
        _currentlyPerformingFineGrainedUpdate = YES;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:link];
        [realm commitWriteTransaction];
        
        //Animate change in height for tableview
        [_myHexlistTableView beginUpdates];
        [_myHexlistTableView endUpdates];
        [_myHexlistTableView scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:YES];
        
        [self updateHexCellForNewLinkCount:hexCell];
    });
}

#pragma mark - IBAction

//MyHexlistActionAddToHex

-(void)cancelButtonPressed {
    [self popBackToRootViewController];
}

-(void)acceptAddToHexButtonPress {
    //Add the links to each selected Hex
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (Hex *hex in _selectedHexes) {
       [hex.links addObjects:_linksToAddToHex];
    }
    [realm commitWriteTransaction];
    //send a message back to the home view controlelr (or anything implementing the delegate)
    //to show a hud
    id<MyHexlistViewControllerDelegate> strongDelegate = self.myHexlistViewControllerDelegate;
    if ([strongDelegate respondsToSelector:@selector(addedToHexShowHUDWithNumAdded:)]) {
        [strongDelegate addedToHexShowHUDWithNumAdded:(int)[_selectedHexes count]];
    }
    [self popBackToRootViewController];
}

- (IBAction)addButtonPressed:(id)sender {
    _createViewAction = CreateViewActionCreateHex;
    [self performSegueWithIdentifier:@"myHexlist-to-create" sender:self];
}

-(void)hexCellHexagonPressed:(id)sender {
    HexCell *hexCell = (HexCell*)[self GetCellFromTableView:_myHexlistTableView Sender:sender];
    [self changeColorOfCell:hexCell];
}

-(void)hexCellHelperButtonPressed:(id)sender {
    [self hexCellHexagonPressed:sender];
}

-(void)hexLefthandButtonPress:(id)sender {
    HexCell *hexCell = (HexCell*)[self GetCellFromTableView:_myHexlistTableView Sender:sender];
    NSIndexPath *indexPath = [_myHexlistTableView indexPathForRowAtPoint:hexCell.center];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    _sendViewSendType = SendTypeHex;
    _hexToSend = hex;
    [self performSegueWithIdentifier:@"myHexlist-to-send" sender:self];
}

// paste a thing into the hexlist hex object

-(void)hexMiddleButtonPress:(id)sender {
    HexCell *hexCell = (HexCell*)[self GetCellFromTableView:_myHexlistTableView Sender:sender];
    NSIndexPath *indexPath = [_myHexlistTableView indexPathForRowAtPoint:hexCell.center];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    NSArray<Link*> *linkArray;
    
    //First check for url in clipboard
    NSURL *pasteBoardUrl = [UIPasteboard generalPasteboard].URL;
    //NSLog(@"PasteBoardUrl: %@", [UIPasteboard generalPasteboard].URL);
    //NSLog(@"PasteBoardString: %@", [UIPasteboard generalPasteboard].string);
    if (pasteBoardUrl == nil || pasteBoardUrl.absoluteString.length == 0) {
        //If no url, check for string in clipboard
        NSString *pasteBoardString = [UIPasteboard generalPasteboard].string;
        
        if (pasteBoardString == nil || pasteBoardString.length == 0) {
            [self alertUserToUrlsNotFound];
            return;
        }
        else {
            //Parse the string for any urls
            linkArray = [self generateLinksFromUrlsInString:pasteBoardString];
            if (linkArray == nil || [linkArray count] == 0) {
                [self alertUserToUrlsNotFound];
                return;
            } else {
                //if the user has never performed this
                //paste to a hex tell them what it does.
                [self alertUserToLinkPasteFirstTimeHUD];
            }
        }
    }
    else {
        //if the user has never performed this
        //paste to a hex tell them what it does.
        [self alertUserToLinkPasteFirstTimeHUD];
        Link *link = [Link createLinkWithUUID:[[NSUUID UUID] UUIDString]
                                       AndURL:pasteBoardUrl.absoluteString
                           AndLinkDescription:pasteBoardUrl.host
                                   AndService:ServiceTypeUnknown];
        linkArray = [NSArray arrayWithObject:link];
    }
    
    //Add links to hex
    dispatch_async(dispatch_get_main_queue(), ^{
        _currentlyPerformingFineGrainedUpdate = YES;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [hex.links addObjects:linkArray];
        [realm commitWriteTransaction];
        
        //Animate change in height for tableview
        [_myHexlistTableView beginUpdates];
        [_myHexlistTableView endUpdates];
        [_myHexlistTableView scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:YES];
        
        [self updateHexCellForNewLinkCount:hexCell];
        
        [hexCell updateLinksAnimated];
    });
}

-(void)hexRighthandButtonPress:(id)sender {
    HexCell *hexCell = (HexCell*)[self GetCellFromTableView:_myHexlistTableView Sender:sender];
    NSIndexPath *indexPath = [_myHexlistTableView indexPathForRowAtPoint:hexCell.center];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    [self showHexOptionsWithHex:hex];
}

#pragma mark - Alerts

-(void)alertUserToUrlsNotFound {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"No links found in clipboard";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)alertUserToFailedToExtractLinks {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Couldn't read links from clipboard";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void) alertUserToLinkPasteFirstTimeHUD {
    //if the user hasn't been show the hud that describes the
    //paste then show that hud.
    if (![SettingsManager userHasBeenShownLinkPasteHUD]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Added links from clipboard";
            hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
            hud.userInteractionEnabled = NO;
            [hud hide:YES afterDelay:1.5];
        });
        [SettingsManager setUserHasBeenShownLinkPasteHUD:YES];
    }
}

-(void) alertUserToLinkCopied {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Link Copied";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)showLinkOptionsWithLink:(Link*)link {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:link.linkDescription message:link.url preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* shareLink = [UIAlertAction actionWithTitle:@"Use link" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self shareLink:link];
                                                      }];
    UIAlertAction* editLink = [UIAlertAction actionWithTitle:@"Edit description" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        _createViewAction = CreateViewActionEditLink;
                                                        _linkToEdit = link;
                                                        [self performSegueWithIdentifier:@"myHexlist-to-create" sender:self];
                                                    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:shareLink];
    [alert addAction:editLink];
    [alert addAction:cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
 
}

-(void)showHexOptionsWithHex:(Hex*)hex {
    NSInteger numLinks = [hex.links count];
    
    NSString *numLinksString = [[NSString stringWithFormat: @"%ld", (long)numLinks] stringByAppendingString:(numLinks == 1)? @" Link" : @" Links"];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:hex.hexDescription message:numLinksString preferredStyle:UIAlertControllerStyleActionSheet];

    
    UIAlertAction* editHex = [UIAlertAction actionWithTitle:@"Edit Description" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          _createViewAction = CreateViewActionEditHex;
                                                          _hexToEdit = hex;
                                                          [self performSegueWithIdentifier:@"myHexlist-to-create" sender:self];
                                                      }];
    UIAlertAction* shareHex = [UIAlertAction actionWithTitle:@"Export Hex" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        [self shareHex:hex];
                                                    }];
    
    UIAlertAction* deleteHex = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {
                                                          [self deleteHex:hex];
                                                      }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:shareHex];
    [alert addAction:editHex];
    [alert addAction:deleteHex];
    [alert addAction:cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
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
    NSString *hexLinksString = [hex.hexDescription stringByAppendingString:@"\n--------------------\n\n"];

    for (Link *link in hex.links) {
        if ([AppConstants serviceTypeForString:link.service] != ServiceTypeUnknown
                                                            && link.linkDescription
                                                            && !(link.linkDescription.length == 0)) {
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
        
        [_myHexlistTableView beginUpdates];
        [_myHexlistTableView endUpdates];
        
        [_staticHexes removeObject:hex];
        
        NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                     [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],
                                     nil];
        
        [_myHexlistTableView beginUpdates];
        [_myHexlistTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [_myHexlistTableView endUpdates];
        
        //Delete hex, wait for realm notification and do the rest of the animations/updates in updateHexes
        [HexManager deleteHexFromMyHexlist:hex];
    });
}

#pragma mark - Helper Methods

-(NSMutableArray*)getStaticHexesArray:(RLMArray*)hexes {
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
}

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    return [tableView cellForRowAtIndexPath:indexPath];
}

-(void)changeColorOfCell:(HexCell*)hexCell {
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSIndexPath *indexPath = [_myHexlistTableView indexPathForRowAtPoint:hexCell.center];
        Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
        
        _currentlyPerformingFineGrainedUpdate = YES;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        
        UIColor *niceRandomColor = [AppConstants niceRandomColor];
        //Persist change in hex color
        hex.hexColor = [AppConstants hexStringFromColor:niceRandomColor];
        
        //Set tint color of buttons
        [hexCell.lefthandButton setTintColor:niceRandomColor];
        [hexCell.middleButton setTintColor:niceRandomColor];
        [hexCell.righthandButton setTintColor:niceRandomColor];
        
        //Set the hexagon background color
        hexCell.hexagon.tintColor = niceRandomColor;
        
        [realm commitWriteTransaction];
    });
}

-(void)changeColorOfAllHexesTo:(UIColor*)color UseRandomColors:(BOOL)useRandomColors {
    
    
    _currentlyPerformingFineGrainedUpdate = YES;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    Location *myHexlistLocation = [Location objectForPrimaryKey:[AppConstants stringForHexLocationType:HexLocationTypeMyHexlist]];
    
    for (Hex *hex in myHexlistLocation.hexes) {
        if (useRandomColors) {
            color = [AppConstants niceRandomColor];
        }
        //Persist change in hex color
        hex.hexColor = [AppConstants hexStringFromColor:color];
    }
    
    [realm commitWriteTransaction];
    
    //Change color of all visible hex cells
    NSArray *visibleCells = [_myHexlistTableView visibleCells];
    
    for (UITableViewCell *cell in visibleCells) {
        if ([cell isKindOfClass:[HexCell class]]) {
            HexCell *hexCell = (HexCell*)cell;
            NSIndexPath *indexPath = [_myHexlistTableView indexPathForRowAtPoint:hexCell.center];
            Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
            
            //Set tint color of buttons
            [hexCell.lefthandButton setTintColor:[AppConstants colorFromHexString:hex.hexColor]];
            [hexCell.middleButton setTintColor:[AppConstants colorFromHexString:hex.hexColor]];
            [hexCell.righthandButton setTintColor:[AppConstants colorFromHexString:hex.hexColor]];
            
            //Set the hexagon background color
            hexCell.hexagon.tintColor = [AppConstants colorFromHexString:hex.hexColor];
        }
    }
}

-(void)changeAllColorsToMyHexColor {
    if (_allHexColorsAreMyHexColor) {
        _allHexColorsAreMyHexColor = NO;
        UIColor *myHexColor = [AppConstants colorFromHexString:[SettingsManager getMyHexColor]];
        if (![myHexColor isEqual:[AppConstants myHexColorDefault]]) {
            [self changeColorOfAllHexesTo:myHexColor
                          UseRandomColors:NO];
        }
        else {
            [self changeColorOfAllHexesTo:[AppConstants niceRandomColor]
                          UseRandomColors:YES];
        }
    }
    else {
        _allHexColorsAreMyHexColor = YES;
        [self changeColorOfAllHexesTo:[AppConstants niceRandomColor]
                      UseRandomColors:YES];
    }
}

//Users/scherroman/Desktop/Xcode projects/Hexlist/Hexlist/MyHexlistViewController.m
#pragma mark - Navigation

- (void)updateHex:(Hex*)hexEdited WithDescription:(NSString*)hexDescription AndColor:(UIColor*)hexColor {

}

-(void)updateHexCellForNewLinkCount:(HexCell*)hexCell {
    NSIndexPath *indexPath = [_myHexlistTableView indexPathForRowAtPoint:hexCell.center];
    Hex *hex = [_staticHexes objectAtIndex:indexPath.row];
    
    NSInteger numLinks = [hex.links count];
    
    [hexCell.subLabel setText:[[NSString stringWithFormat: @"%ld", (unsigned long)[hex.links count]] stringByAppendingString:(numLinks == 1)? @" Link" : @" Links"]];
     
    hexCell.linksTableView.scrollEnabled =  [hex.links count] * [HexCell linkHeight] > hexCell.linksTableView.frame.size.height;
}

-(NSArray<Link*>*)generateLinksFromUrlsInString:(NSString*)string {
    NSMutableArray<Link*> *linkArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    if (error) {
        [self alertUserToFailedToExtractLinks];
        return nil;
    }
    
    NSArray *matches = [linkDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            Link *link = [Link createLinkWithUUID:[[NSUUID UUID] UUIDString]
                                           AndURL:url.absoluteString
                               AndLinkDescription:url.host
                                       AndService:ServiceTypeUnknown];
            [linkArray addObject:link];
            //NSLog(@"Url found: %@", url);
        }
    }
    
    //NSLog(@"Matches count: %lu", (unsigned long)[matches count]);
    
    return  linkArray;
}

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
        if (_createViewAction == CreateViewActionEditHex) {
            ((CreateViewController*)[segue destinationViewController]).hexToEdit = _hexToEdit;
        }
        else if (_createViewAction == CreateViewActionEditLink) {
             ((CreateViewController*)[segue destinationViewController]).linkToEdit = _linkToEdit;
        }
    }
}


@end
