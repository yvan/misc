//
//  ConnectViewController.m
//  Airdoc
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "ConnectViewController.h"

@interface ConnectViewController ()

@end

@implementation ConnectViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Navigation Bar setup
    _savedLeftBarButtonItem = self.navigationItem.leftBarButtonItem;
    _currentlyReloading = NO;
    _rotationCount = 0;
    [_segmentedControl setHidden:YES];
    
    // Segmented Control styling
    [_segmentedControl setTitleTextAttributes:@{
                                        NSFontAttributeName: [UIFont fontWithName:[AppConstants appFontNameB] size:13.0]
                                        } forState:UIControlStateNormal];
    _segmentedControl.layer.shadowColor = nil;
    
    //Draw view for emptyTableViewCellView
    CALayer *border = [CALayer layer];
    border.backgroundColor = [AppConstants tableViewSeparatorColor].CGColor;
    border.frame = CGRectMake(0, _emptyTableViewCellView.frame.size.height - .5, _emptyTableViewCellView.frame.size.width, .5);
    [_emptyTableViewCellView.layer addSublayer:border];
    
    
    // Table view Setup ( & removing excess empty table view cells)
    [_peopleTableView setDelegate:self];
    [_peopleTableView setDataSource:self];
    _peopleTableView.separatorColor = [AppConstants tableViewSeparatorColor];
    _peopleTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView* backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [_peopleTableView setBackgroundView:backgroundView];
    _emptyTableMessage.text = nil;
    _emptyTableMessage2.text = nil;
    _emptyTableViewCellLabel.text = @"Keep device awake";
    [_emptyTableViewCellSwitch setOn:[LocalStorageManager getKeepDeviceAwakeSetting]];
    [_peopleTableView setHidden:YES];
    
    //Swipe to Friends
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftSegmentSwitch)];
    [leftSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [_peopleTableView.panGestureRecognizer requireGestureRecognizerToFail:leftSwipeGestureRecognizer];
    
    //Swipe back to nearby
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightSegmentSwitch)];
    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [_peopleTableView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    
    // Setup
    _localStorageManager = [[LocalStorageManager alloc] init];
    _connectedPeopleManager = [ConnectedPeopleManager sharedConnectedPeopleManager];
//    _tempConnectedFriends = [_connectedPeopleManager getConnectedFriends];
    _tempConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
    if ([_connectedPeopleManager currentlyInTheProcessOfSending]) {
        NSLog(@"Current outgoing send progress: %f", [_connectedPeopleManager getProgressOfCurrentOutgoingSend]);
        [((ProgressNavigationViewController*)self.navigationController).sendProgress setProgress:[_connectedPeopleManager getProgressOfCurrentOutgoingSend] animated:NO];
        [((ProgressNavigationViewController*)self.navigationController).sendProgress setHidden:NO];
    }
    
    //If we're currently in searching for peers state start rotation of reload button & show 'searching...' text
    if ([_connectedPeopleManager currentlySearchingForPeers]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _currentlyReloading = YES;
            [_reloadButton setUserInteractionEnabled:NO];
            [self performFirstHalfRotationOnReloadButton];
            [_rotationTimer invalidate];
            //Need to add the timer to the RunLoopCommonModes to stop tableView scroll interference
            _rotationTimer = [NSTimer timerWithTimeInterval:.5 target:self selector:@selector(performAnotherHalfRotationOnReloadButton) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_rotationTimer forMode:NSRunLoopCommonModes];
            _emptyTableMessage.text = @"Searching for nearby users      ";
            _emptyTableMessage2.text = nil;
            [_searchingTimer invalidate];
            _searchingTimer = [NSTimer timerWithTimeInterval:.4 target:self selector:@selector(animateSearchingText) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_searchingTimer forMode:NSRunLoopCommonModes];
        });
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNearbyTabSelected)
                                                 name:@"nearbyTabSelectedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCurrentlySearchingForPeersNotification)
                                                 name:@"currentlySearchingForPeersNotification"
                                               object:nil];
    
    // Add this VC as a listener for notifications on peer state changes (Posted from MultiPeerInitializerTabBarController)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(friendOrStrangerDidChangeStateWithNotification:)
                                                 name:@"MCPeerDidChangeStateNotification"
                                               object:nil];
    
    //Add listener for selectedFilesUpdated notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateKeepDeviceAwake)
                                                 name:@"ChangedKeepDeviceAwake"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    /*
    // Which segment tab is selected?
    if (_segmentedControl.selectedSegmentIndex == 0) {
        
        numSections = 2;
    }
    else if (_segmentedControl.selectedSegmentIndex == 1) {
        
        numSections = 1;
    }
    
    return numSections;
     */
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numRows = 0;
    
    if ([_tempConnectedStrangers count] == 0) {
        [_peopleTableView setHidden:YES];
        //Hide table view, display empty table message
        if (_currentlyReloading) {
            _emptyTableMessage.text = @"Searching for nearby users      ";
            _emptyTableMessage2.text = nil;
            [_searchingTimer invalidate];
            _searchingTimer = [NSTimer timerWithTimeInterval:.4 target:self selector:@selector(animateSearchingText) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_searchingTimer forMode:NSRunLoopCommonModes];
        }
        else {
            _emptyTableMessage.text = @"Nobody Around You";
            _emptyTableMessage2.text = @"Keep Wi-Fi enabled to connect\nwith nearby users";
        }
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             [_emptyTableMessage setAlpha:1.0];
                             [_emptyTableMessage2 setAlpha:1.0];
                         }
                         completion:nil
         ];
    }
    else {
        [_peopleTableView setHidden:NO];
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             [_emptyTableMessage setAlpha:0.0];
                             [_emptyTableMessage2 setAlpha:0.0];
                         }
                         completion:nil
         ];
    }
    
    if (section == 0) {
        numRows = 1;
    }
    // Which section? Friends or Strangers?
    else if (section == 1) {
        numRows = [_tempConnectedStrangers count];
        _numConnectedStrangers = numRows;
    }
    
    return numRows;

    
    /*
    // Which segment tab is selected?
    if (_segmentedControl.selectedSegmentIndex == 0) {
        
        if ([_tempConnectedFriends count] == 0 && [_tempConnectedStrangers count] == 0) {
            //Hide table view, display empty table message
            if (_currentyReloading) {
                _emptyTableMessage.text = @"Searching for peers...";
                _emptyTableMessage2.text = nil;
            }
            else {
                _emptyTableMessage.text = @"Nobody Around You";
                _emptyTableMessage2.text = @"Keep wifi enabled to see nearby users";
            }
            [_emptyTableMessage setHidden:NO];
            [_emptyTableMessage2 setHidden:NO];
        }
        else {
            [_emptyTableMessage setHidden:YES];
            [_emptyTableMessage2 setHidden:YES];
        }
        
        if (section == 0) {
            numRows = 1;
        }
        // Which section? Friends or Strangers?
        else if (section == 1) {
            numRows = [_tempConnectedFriends count];
            _numConnectedFriends = numRows;
        }
        else if (section == 2) {
            numRows = [_tempConnectedStrangers count];
            _numConnectedStrangers = numRows;
        }
    }
    else if (_segmentedControl.selectedSegmentIndex == 1) {
        numRows = [[_localStorageManager getFriends] count];
        
        if (numRows == 0) {
            _emptyTableMessage.text = @"No Friends Yet";
            _emptyTableMessage2.text = nil;
            [_emptyTableMessage setHidden:NO];
            [_emptyTableMessage2 setHidden:NO];
        }
        else {
            [_emptyTableMessage setHidden:YES];
            [_emptyTableMessage2 setHidden:YES];
        }
        _numFriends = numRows;
    }
    return numRows;
     */
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) { //ConnectToolbar
        //ConnectToolbarCell
        ConnectToolbarCell *connectToolbarCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants connectToolbarCellStringIdentifier] forIndexPath:indexPath];
        connectToolbarCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [connectToolbarCell.label setText:@"Keep device awake"];
        [connectToolbarCell.switchButton setOn:[LocalStorageManager getKeepDeviceAwakeSetting]];
        
        CALayer *border = [CALayer layer];
        border.backgroundColor = [AppConstants tableViewSeparatorColor].CGColor;
        border.frame = CGRectMake(0, connectToolbarCell.frame.size.height - .5, connectToolbarCell.frame.size.width, .5);
        [connectToolbarCell.layer addSublayer:border];
        
        return connectToolbarCell;
    }
    else { // Stranger
        // stranger cell
        FriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants friendCellStringIdentifier] forIndexPath:indexPath];
        friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [friendCell.contentView setBackgroundColor:[UIColor whiteColor]];
        
        MCPeerID *stranger = [_tempConnectedStrangers objectAtIndex:indexPath.row];
        friendCell.friendName.text = [LocalStorageManager getPeerNameFromDisplayName:stranger.displayName];
        
        return friendCell;
    }

    
    /*
    // Which segment tab is selected?
    if (_segmentedControl.selectedSegmentIndex == 0) { // Nearby section selected
     
        if (indexPath.section == 0) { //ConnectToolbar
            //ConnectToolbarCell
            ConnectToolbarCell *connectToolbarCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants connectToolbarCellStringIdentifier] forIndexPath:indexPath];
            connectToolbarCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [connectToolbarCell.label setText:@"Keep device awake"];
            [connectToolbarCell.switchButton setOn:[LocalStorageManager getKeepDeviceAwakeSetting]];
            
            CALayer *border = [CALayer layer];
            border.backgroundColor = [AppConstants tableViewSeparatorColor].CGColor;
            border.frame = CGRectMake(0, connectToolbarCell.frame.size.height - .5, connectToolbarCell.frame.size.width, .5);
            [connectToolbarCell.layer addSublayer:border];
            
            return connectToolbarCell;
        }
        // Which section is the cell in? Friend or Stranger?
        if (indexPath.section == 1) { // Friend
            //friend cell
            FriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants friendCellStringIdentifier] forIndexPath:indexPath];
            friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [friendCell.contentView setBackgroundColor:[UIColor whiteColor]];
            
            //Don't want remove friend button on nearby segment
            friendCell.rightUtilityButtons = nil;
            friendCell.delegate = nil;
            
            MCPeerID *friend = [_tempConnectedFriends objectAtIndex:indexPath.row];
            friendCell.friendName.text = [LocalStorageManager getPeerNameFromDisplayName:friend.displayName];
            
            return friendCell;
        }
        else { // Stranger
            // stranger cell
            StrangerCell *strangerCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants strangerCellStringIdentifier] forIndexPath:indexPath];
            strangerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [strangerCell.contentView setBackgroundColor:[UIColor whiteColor]];
            
            MCPeerID *stranger = [_tempConnectedStrangers objectAtIndex:indexPath.row];
            strangerCell.strangerName.text = [LocalStorageManager getPeerNameFromDisplayName:stranger.displayName];
            
            return strangerCell;
        }
    }
    else { // Friends section selected
        //Friend cell
        FriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants friendCellStringIdentifier] forIndexPath:indexPath];
        friendCell.selectionStyle = UITableViewCellSelectionStyleGray;
        [friendCell.contentView setBackgroundColor:[UIColor whiteColor]];
        
        friendCell.rightUtilityButtons = [self rightButtons];
        friendCell.delegate = self;
        
        NSDictionary *friend = [[_localStorageManager getFriends] objectAtIndex:indexPath.row];
        friendCell.friendName.text = [friend objectForKey:[AppConstants friendNameStringIdentifier]];
    
        return friendCell;
    }
     */
}

/* - Sets styling for section headers - */

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;

    //Font
    header.textLabel.font = [UIFont fontWithName:[AppConstants appFontNameB] size:15];
    
    // Background color
    header.tintColor = [UIColor whiteColor];
    header.contentView.backgroundColor = [UIColor whiteColor];
    
    // Text Color
    [header.textLabel setTextColor:[AppConstants appSchemeColor]];
}

/* - Sets header title for friends and strangers sections - */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    // Which segment tab is selected?
    if (_segmentedControl.selectedSegmentIndex == 0) {

        NSString *sectionName;
    
        // Which section is selected?
        switch (section)
        {
            case 1:
                sectionName = @" NEARBY";
                break;
            default:
                break;
                
            /*
            case 1:
                sectionName = @"FRIENDS";
                break;
            case 2:
                sectionName = @"STRANGERS";
                break;
            default:
                break;
             */
        }
    
        return sectionName;
    }
    else {
        return nil;
    }
}

/* - Specifically sets the line seperator insets of cells, seperate from Sections - */

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set tableviews's layout margins
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // Explictly set cell's layout margins
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
        
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDelegate

/* - Makes section headers dissapear if they don't have any cells - */

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (_segmentedControl.selectedSegmentIndex == 0) {
        
        if (section == 1 || section == 2) {
            if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
                return 0;
            } else {
                return 30;
            }
        }
        else {
            return 0;
        }
    }
    else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/* - Try to implement this method if using 'grouped' style table view - */

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UITableViewHeaderFooterView *sectionView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    [sectionView.contentView setBackgroundColor:[AppConstants appSchemeColorB]];
//    return sectionView;
//}

#pragma mark - NSNotificationCenter

-(void)handleNearbyTabSelected {
    [_peopleTableView setContentOffset:CGPointZero animated:YES];
}

/* - Updates the keep device awake setting whenever it is updated in settings - */

-(void)updateKeepDeviceAwake {
    ConnectToolbarCell *connectToolbarCell = (ConnectToolbarCell*)[_peopleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [connectToolbarCell.switchButton setOn:[LocalStorageManager getKeepDeviceAwakeSetting]];
    [_emptyTableViewCellSwitch setOn:[LocalStorageManager getKeepDeviceAwakeSetting]];
}

/* - We use this method to update the table view after the session has been reset and the connected people arrays purged - */

-(void)handleCurrentlySearchingForPeersNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        _currentlyReloading = YES;
        [_reloadButton setUserInteractionEnabled:NO];
        [self performFirstHalfRotationOnReloadButton];
        [_rotationTimer invalidate];
        //Need to add the timer to the RunLoopCommonModes to stop tableView scroll interference
        _rotationTimer = [NSTimer timerWithTimeInterval:.5 target:self selector:@selector(performAnotherHalfRotationOnReloadButton) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_rotationTimer forMode:NSRunLoopCommonModes];
//      _tempConnectedFriends = [_connectedPeopleManager getConnectedFriends];
        _tempConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
        [_peopleTableView reloadData];
    });
}

/*- Reloads the table view if a friend or stranger state changed - */

-(void)friendOrStrangerDidChangeStateWithNotification:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"state"] isEqualToString:@"MCSessionStateConnected"]) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchingTimer invalidate];
            [_rotationTimer invalidate];
            _currentlyReloading = NO;
            _rotationCount = 0;
            [_reloadButton setUserInteractionEnabled:YES];
    //        _tempConnectedFriends = [_connectedPeopleManager getConnectedFriends];
            _tempConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
            [_peopleTableView reloadData];
        });
    }
    else if ([[[notification userInfo] objectForKey:@"state"] isEqualToString:@"MCSessionStateNotConnected"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //        _tempConnectedFriends = [_connectedPeopleManager getConnectedFriends];
            _tempConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
            [_peopleTableView reloadData];
        });
    }
}

/* - Stops multiple timers from scheduling themsleves- */

-(void)applicationDidEnterBackground {
    [_searchingTimer invalidate];
    [_rotationTimer invalidate];
}

#pragma mark - IBActions

// Reloads the table view upon switching segment tabs
- (IBAction)segmentSwitch:(id)sender {
    
    //Remove refresh button when on Friends tab
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self.navigationItem setLeftBarButtonItem:_savedLeftBarButtonItem];
    }
    else {
        [self.navigationItem setLeftBarButtonItem:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        _tempConnectedFriends = [_connectedPeopleManager getConnectedFriends];
        _tempConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
        [_peopleTableView reloadData];
    });
}

/* - Left swipe gesture recognizer method to switch segments - */
-(void)swipeLeftSegmentSwitch {
    _segmentedControl.selectedSegmentIndex = 1;
    [self segmentSwitch:self];
}

/* - Right swipe gesture recognizer method to switch segments - */
-(void)swipeRightSegmentSwitch {
    _segmentedControl.selectedSegmentIndex = 0;
    [self segmentSwitch:self];
}

- (IBAction)reloadButtonTap:(id)sender {
    
    BOOL currentlyInTheProcessOfSending = [_connectedPeopleManager currentlyInTheProcessOfSending];
    BOOL currentlyInTheProcessOfZipping = [_connectedPeopleManager currentlyInTheProcessOfZipping];
    
    if (!currentlyInTheProcessOfSending && !currentlyInTheProcessOfZipping) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerResetSession" object:self];
    }
    else if (currentlyInTheProcessOfSending || currentlyInTheProcessOfZipping) {
        [self alertUserToResetSessionConnectionWarning];
    }
}

/* - Makes stranger a friend and relocates cell
   - from strangers section to friends section - */

- (IBAction)addFriendButtonTap:(id)sender {
    
    StrangerCell *strangerCell = (StrangerCell*)[self GetCellFromTableView:_peopleTableView Sender:sender];
    NSIndexPath *indexPath = [_peopleTableView indexPathForRowAtPoint:strangerCell.center];
    MCPeerID *stranger = [[_connectedPeopleManager getConnectedStrangers] objectAtIndex:indexPath.row];
    
    //Add stranger as friend, then remove peer from connected strangers and add them to connected friends
    [_connectedPeopleManager removeConnectedStranger:stranger];
    [_connectedPeopleManager addConnectedFriend:stranger];
     [_localStorageManager addFriendWithName:[LocalStorageManager getPeerNameFromDisplayName:stranger.displayName] AndUUID:[LocalStorageManager getUUIDFromDisplayName:stranger.displayName]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddedOrRemovedFriendNotification" object:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        _tempConnectedFriends = [_connectedPeopleManager getConnectedFriends];
        _tempConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
        [_peopleTableView reloadData];
    });
}

- (IBAction)keepDeviceAwakeSwitchTap:(id)sender {
    
    if ([sender isEqual:_emptyTableViewCellSwitch]) {
        [LocalStorageManager setKeepDeviceAwakeSettingTo: _emptyTableViewCellSwitch.on];
        if ([LocalStorageManager getKeepDeviceAwakeSetting]) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
        else {
            //If multipeer isn't active with a send/reception, turn device idle timer back on
            if (![_connectedPeopleManager currentlyInTheProcessOfSending] || [_connectedPeopleManager currentlyInTheProcessOfReceiving]) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }
        }
    }
    else {
        ConnectToolbarCell *connectToolbarCell = (ConnectToolbarCell*)[self GetCellFromTableView:_peopleTableView Sender:sender];
        
        [LocalStorageManager setKeepDeviceAwakeSettingTo: connectToolbarCell.switchButton.on];
        _emptyTableViewCellSwitch.on = connectToolbarCell.switchButton.on;
        if ([LocalStorageManager getKeepDeviceAwakeSetting]) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
        else {
            //If multipeer isn't active with a send/reception, turn device idle timer back on
            if (![_connectedPeopleManager currentlyInTheProcessOfSending] || [_connectedPeopleManager currentlyInTheProcessOfReceiving]) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }
        }
    }
}

#pragma mark - Helper Methods
     
/* - This appears to animate a change in message displayed while seaching for peers - */
-(void)animateSearchingText {
    if ([_emptyTableMessage.text isEqualToString:@"Searching for nearby users      "]) {
        _emptyTableMessage.text = @"Searching for nearby users .    ";
    }
    else if ([_emptyTableMessage.text isEqualToString:@"Searching for nearby users .    "]) {
        _emptyTableMessage.text = @"Searching for nearby users . .  ";
    }
    else if ([_emptyTableMessage.text isEqualToString:@"Searching for nearby users . .  "]) {
        _emptyTableMessage.text = @"Searching for nearby users . . .";
    }
    else if ([_emptyTableMessage.text isEqualToString:@"Searching for nearby users . . ."]) {
        _emptyTableMessage.text = @"Searching for nearby users      ";
    }
}

/* - This animation rotates the reload button once a total of 180 degrees - */
-(void)performAnotherHalfRotationOnReloadButton {
    if (_rotationCount >= 10) {
        [_searchingTimer invalidate];
        [_rotationTimer invalidate];
        _currentlyReloading = NO;
        _rotationCount = 0;
        [_reloadButton setUserInteractionEnabled:YES];
        _emptyTableMessage.text = @"Nobody Around You";
        _emptyTableMessage2.text = @"Keep Wi-Fi enabled to connect\nwith nearby users";
    }
    else {
        CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:((180*M_PI)/180)];
        fullRotation.duration = .5;
        fullRotation.repeatCount = 0;
        [_reloadButton.layer addAnimation:fullRotation forKey:@"180"];
        _rotationCount = _rotationCount + 1;
    }
}

-(void)performFirstHalfRotationOnReloadButton {
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((180*M_PI)/180)];
    fullRotation.duration = .5;
    fullRotation.repeatCount = 0;
    [_reloadButton.layer addAnimation:fullRotation forKey:@"180"];
    _rotationCount = 1;
}

-(void)alertUserToResetSessionConnectionWarning {
    UIAlertController *options = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                     message:@"Resetting your session connection will cancel any file sends currently in progress."
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerResetSession" object:self];
                                                      }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *action) {
                                                         [options dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    [options addAction:yesAction];
    [options addAction:noAction];
    [self presentViewController:options animated:YES completion:nil];
}

//-(void)alertUserToFileSendsCanceled {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = @"File sends canceled";
//        hud.userInteractionEnabled = NO;
//        hud.color = [AppConstants appSchemeColorC];
//        [hud hide:YES afterDelay:1.5];
//    });
//}

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    
    return [tableView cellForRowAtIndexPath:indexPath];
}

@end
