//
//  ConnectViewController.m
//  Hexlist
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "ConnectViewController.h"

@interface ConnectViewController ()

@end

#define NEARBY_SECTION 0

@implementation ConnectViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Navigation Bar setup
    _currentlyReloading = NO;
    _rotationCount = 0;
    
//    //Draw view for emptyTableViewCellView
//    CALayer *border = [CALayer layer];
//    border.backgroundColor = [AppConstants tableViewSeparatorColor].CGColor;
//    border.frame = CGRectMake(0, _emptyTableViewCellView.frame.size.height - .5, _emptyTableViewCellView.frame.size.width, .5);
//    [_emptyTableViewCellView.layer addSublayer:border];
    
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
//    _emptyTableViewCellLabel.text = @"Keep device awake";
//    [_emptyTableViewCellSwitch setOn:[SettingsManager getKeepDeviceAwakeSetting]];
    [_peopleTableView setHidden:YES];
    
    // Setup
    _connectedPeopleManager = [ConnectedPeopleManager sharedConnectedPeopleManager];
    _staticConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
    
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
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCPeerDidChangeStateNotification"
                                               object:nil];
    
//    //Add listener for selectedFilesUpdated notification
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateKeepDeviceAwake)
//                                                 name:@"ChangedKeepDeviceAwake"
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
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

    if ([_staticConnectedStrangers count] == 0) {
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
            _emptyTableMessage.text = @"Nobody Around";
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
    
    
    NSUInteger numRows = 0;
    
//    //Keep device awake section
//    if (section == 0) {
//        numRows = 1;
//    }
    //Nearby section
    if (section == NEARBY_SECTION) {
        numRows = [_staticConnectedStrangers count];
    }
    
    return numRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == 0) { //ConnectToolbar
//        //ConnectToolbarCell
//        ConnectToolbarCell *connectToolbarCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants connectToolbarCellStringIdentifier] forIndexPath:indexPath];
//        connectToolbarCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        [connectToolbarCell.label setText:@"Keep device awake"];
//        [connectToolbarCell.switchButton setOn:[SettingsManager getKeepDeviceAwakeSetting]];
//        
//        CALayer *border = [CALayer layer];
//        border.backgroundColor = [AppConstants tableViewSeparatorColor].CGColor;
//        border.frame = CGRectMake(0, connectToolbarCell.frame.size.height - .5, connectToolbarCell.frame.size.width, .5);
//        [connectToolbarCell.layer addSublayer:border];
//        
//        return connectToolbarCell;
//    }
//    else { // Stranger
        // stranger cell
        StrangerCell *strangerCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants strangerCellStringIdentifier] forIndexPath:indexPath];
        [strangerCell.contentView setBackgroundColor:[UIColor whiteColor]];
        
        MCPeerID *stranger = [_staticConnectedStrangers objectAtIndex:indexPath.row];
        strangerCell.strangerName.text = [ConnectedPeopleManager getPeerNameFromDisplayName:stranger.displayName];
        
        return strangerCell;
//    }
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

/* - Sets header title for sections - */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *sectionName;

    // Which section is selected?
    switch (section) {
        case NEARBY_SECTION:
            sectionName = @" NEARBY";
            break;
        default:
            break;
    }

    return sectionName;
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
    if (section == NEARBY_SECTION) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MCPeerID *stranger = [_staticConnectedStrangers objectAtIndex:indexPath.row];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[ConnectedPeopleManager getPeerNameFromDisplayName:stranger.displayName] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* blockOrUnblock;
    
    NSLog(@"%@", [SettingsManager getBlockedUserUUIDs]);
    
    if ([SettingsManager userWithUUIDIsBlocked:[ConnectedPeopleManager getUUIDFromDisplayName:stranger.displayName]]) {
        blockOrUnblock = [UIAlertAction actionWithTitle:@"Unblock" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [SettingsManager unblockUserWithUUID:[ConnectedPeopleManager getUUIDFromDisplayName:stranger.displayName]];
                                                      }];
    }
    else {
        blockOrUnblock = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [SettingsManager blockUserWithUUID:[ConnectedPeopleManager getUUIDFromDisplayName:stranger.displayName]];
                                                      }];
    }
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:blockOrUnblock];
    [alert addAction:cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
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

//-(void)updateKeepDeviceAwake {
//    ConnectToolbarCell *connectToolbarCell = (ConnectToolbarCell*)[_peopleTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    [connectToolbarCell.switchButton setOn:[SettingsManager getKeepDeviceAwakeSetting]];
//    [_emptyTableViewCellSwitch setOn:[SettingsManager getKeepDeviceAwakeSetting]];
//}

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
        
        _staticConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
        [_peopleTableView reloadData];
    });
}

/*- Reloads the table view if a peer state changed - */

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"state"] isEqualToString:@"MCSessionStateConnected"]) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchingTimer invalidate];
            [_rotationTimer invalidate];
            _currentlyReloading = NO;
            _rotationCount = 0;
            [_reloadButton setUserInteractionEnabled:YES];
            
            _staticConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
            [_peopleTableView reloadData];
        });
    }
    else if ([[[notification userInfo] objectForKey:@"state"] isEqualToString:@"MCSessionStateNotConnected"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _staticConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
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

- (IBAction)reloadButtonTap:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerResetSession" object:self];
}

//- (IBAction)keepDeviceAwakeSwitchTap:(id)sender {
//    
//    if ([sender isEqual:_emptyTableViewCellSwitch]) {
//        [SettingsManager setKeepDeviceAwakeSettingTo: _emptyTableViewCellSwitch.on];
//        if ([SettingsManager getKeepDeviceAwakeSetting]) {
//            [UIApplication sharedApplication].idleTimerDisabled = YES;
//        }
//        else {
//            [UIApplication sharedApplication].idleTimerDisabled = NO;
//        }
//    }
//    else {
//        ConnectToolbarCell *connectToolbarCell = (ConnectToolbarCell*)[self GetCellFromTableView:_peopleTableView Sender:sender];
//        
//        [SettingsManager setKeepDeviceAwakeSettingTo: connectToolbarCell.switchButton.on];
//        _emptyTableViewCellSwitch.on = connectToolbarCell.switchButton.on;
//        if ([SettingsManager getKeepDeviceAwakeSetting]) {
//            [UIApplication sharedApplication].idleTimerDisabled = YES;
//        }
//        else {
//            [UIApplication sharedApplication].idleTimerDisabled = NO;
//        }
//    }
//}

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
    if (_rotationCount >= 12) {
        [_searchingTimer invalidate];
        [_rotationTimer invalidate];
        _currentlyReloading = NO;
        _rotationCount = 0;
        [_reloadButton setUserInteractionEnabled:YES];
        _emptyTableMessage.text = @"Nobody Around";
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

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    
    return [tableView cellForRowAtIndexPath:indexPath];
}

@end
