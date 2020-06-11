//
//  sendViewController.m
//  Hexlist
//
//  Created by Roman Scher on 7/17/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "sendViewController.h"

@interface sendViewController ()

@end

@implementation sendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navigation Bar Setup
    _cancelButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setImage:[UIImage imageNamed:[AppConstants cancelImageStringIdentifier]] forState:UIControlStateNormal];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    _reloadButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_reloadButton addTarget:self action:@selector(reloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_reloadButton setImage:[UIImage imageNamed:[AppConstants reloadImageStringIdentifier]] forState:UIControlStateNormal];
    UIBarButtonItem *reloadBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_reloadButton];
    self.navigationItem.rightBarButtonItem = reloadBarButtonItem;
    _currentlyReloading = NO;
    _rotationCount = 0;
    
    //Table view Setup ( & removing excess empty table view cells)
    [_peopleTableView setDelegate:self];
    [_peopleTableView setDataSource:self];
    _peopleTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _peopleTableView.separatorColor = [AppConstants tableViewSeparatorColor];
    UIView* backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [_peopleTableView setBackgroundView:backgroundView];
    _emptyTableMessage.text = nil;
    _emptyTableMessage2.text = nil;
    [_peopleTableView setHidden:YES];
    
    //Setup
    _connectedPeopleManager = [ConnectedPeopleManager sharedConnectedPeopleManager];
    _staticConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
    _selectedLocalPeople = [[NSMutableArray alloc] init];
    CGAffineTransform slideDown = CGAffineTransformMakeTranslation(0, 49);
    [_sendButton setTransform: slideDown];
    _sendButtonIsActive = NO;
    _retrieveLinksDelegateMethodAlreadyCalled = NO;
    
    //If Sending Links
    //Hide TableView and show generating links alert message
    //Do not block UI and allow the user to back out of the send VC
    if (_sendType == SendTypeCloudHex) {
        [self hideContent];
        
        if ([[[self fsAbstraction] selectedFiles] count] == 1) {
            [self alertUserToGeneratingLinksIsPlurral:NO];
        }
        else {
            [self alertUserToGeneratingLinksIsPlurral:YES];
        }
        
        self.navigationItem.title = @"Send Hex";
    }
    else if (_sendType == SendTypeHex) {
        self.navigationItem.title = @"Send Hex";
    }
    
    //If we're currently in searching for peers state
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
                                             selector:@selector(handleCurrentlySearchingForPeersNotification)
                                                 name:@"currentlySearchingForPeersNotification"
                                               object:nil];
    
    //NOTIFICATIONS: Listen for notifications on peer state changes & invitations/accepting invitations (Posted from MultiPeerInitializerTabBarController)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCPeerDidChangeStateNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popBackToRootViewController)
                                                 name:@"popBackToRootViewController"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


-(void)popBackToRootViewController {
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

-(void)dismissThisViewController {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController popViewControllerAnimated:NO];
    [CATransaction commit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(FileSystemAbstraction*) fsAbstraction{
    
    if(!_fsAbstraction){
        _fsAbstraction = [FileSystemAbstraction sharedFileSystemAbstraction];
    }
    return _fsAbstraction;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
//    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numRows;
    
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
            _emptyTableMessage2.text = @"Keep Wi-Fi enabled to send\nto nearby users";
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
    
    numRows = [_staticConnectedStrangers count];
    
    return numRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SendCell *sendCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants sendCellStringIdentifier] forIndexPath:indexPath];
    sendCell.selectionStyle = UITableViewCellSelectionStyleGray;
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [AppConstants tableViewSeparatorColor];
    [sendCell setSelectedBackgroundView:backgroundView];
    
    MCPeerID *stranger = [_staticConnectedStrangers objectAtIndex:indexPath.row];
    sendCell.personName.text = [ConnectedPeopleManager getPeerNameFromDisplayName:stranger.displayName];
    
    if (!([_selectedLocalPeople containsObject:stranger])) { //Unselected
        [sendCell.checkmarkButton setImage:[UIImage imageNamed:[AppConstants checkMarkOutlineImageStringIdentifier]] forState:UIControlStateNormal];
        [sendCell setSelected:NO];
        sendCell.selectedCheckmark = NO;
        [sendCell.personName setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:17.0]];
        
    }
    else { //Selected
        [sendCell.checkmarkButton setImage:[UIImage imageNamed:[AppConstants checkMarkImageStringIdentifier]] forState:UIControlStateNormal];
        [sendCell setSelected:YES];
        sendCell.selectedCheckmark = YES;
        [_peopleTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [sendCell.personName setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:17.0]];
    }
    
    return sendCell;
}

/* - Sets styling for section headers - */

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
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
        case 0:
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

/* - Used to set selection of a file package - */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SendCell *sendCell = (SendCell*)[_peopleTableView cellForRowAtIndexPath:indexPath];
    
    MCPeerID *peerStranger = [_staticConnectedStrangers objectAtIndex:indexPath.row];
    [_selectedLocalPeople addObject:peerStranger];
    
    [sendCell.checkmarkButton setImage:[UIImage imageNamed:[AppConstants checkMarkImageStringIdentifier]] forState:UIControlStateNormal];
    sendCell.selectedCheckmark = YES;
    
    [self showOrHideSendButton];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SendCell *sendCell = (SendCell*)[_peopleTableView cellForRowAtIndexPath:indexPath];
    
    MCPeerID *peerStranger = [_staticConnectedStrangers objectAtIndex:indexPath.row];
    [_selectedLocalPeople removeObject:peerStranger];
    
    [sendCell.checkmarkButton setImage:[UIImage imageNamed:[AppConstants checkMarkOutlineImageStringIdentifier]] forState:UIControlStateNormal];
    sendCell.selectedCheckmark = NO;
    
    [self showOrHideSendButton];
}

/* - Makes section headers dissapear if they don't have any cells - */

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 30;
    }
}

#pragma mark - UINavigationBarDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - IBActions

- (IBAction)cancelButtonPressed {
    [self dismissThisViewController];
}

- (IBAction)reloadButtonPressed {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerResetSession" object:self];
}

- (IBAction)sendButtonPressed:(id)sender {
    if (_sendType == SendTypeCloudHex) {
        //send a message to the select files view to cleanup, unselect
        [[NSNotificationCenter defaultCenter] postNotificationName:@"emptyFilesAndDismissOnSend" object:self];
        
        id<SendViewControllerDelegate> strongDelegate = self.sendViewControllerDelegate;
        
        if ([strongDelegate respondsToSelector:@selector(sendHexJMs:ToPeers:)]) {
            [strongDelegate sendHexJMs:[NSArray arrayWithObject:_hexJMToSend] ToPeers:_selectedLocalPeople];
        }
        
        [self dismissThisViewController];
    }
    else if (_sendType == SendTypeHex) {
        
        id<SendViewControllerDelegate> strongDelegate = self.sendViewControllerDelegate;
        
        if ([strongDelegate respondsToSelector:@selector(sendHexes:ToPeers:)]) {
            [strongDelegate sendHexes:[NSArray arrayWithObject:_hexToSend] ToPeers:_selectedLocalPeople];
        }
        
        [self dismissThisViewController];
    }
}

/* - Used to set selection of a file package - */

- (IBAction)checkmarkButtonPressed:(id)sender {
    
    SendCell *sendCell = (SendCell*)[self GetCellFromTableView:_peopleTableView Sender:sender];
    NSIndexPath *indexPath = [_peopleTableView indexPathForRowAtPoint:sendCell.center];
    
    if (!sendCell.selectedCheckmark) {
        [(UIButton*)sender setImage:[UIImage imageNamed:[AppConstants checkMarkImageStringIdentifier]] forState:UIControlStateNormal];
        [_peopleTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        sendCell.selectedCheckmark = YES;
    
        MCPeerID *peerStranger = [_staticConnectedStrangers objectAtIndex:indexPath.row];
        [_selectedLocalPeople addObject:peerStranger];
    }
    else {
        [(UIButton*)sender setImage:[UIImage imageNamed:[AppConstants checkMarkOutlineImageStringIdentifier]] forState:UIControlStateNormal];
        [sendCell setSelected:NO];
        [_peopleTableView deselectRowAtIndexPath:indexPath animated:NO];
        sendCell.selectedCheckmark = NO;
        
        MCPeerID *peerStranger = [_staticConnectedStrangers objectAtIndex:indexPath.row];
        [_selectedLocalPeople removeObject:peerStranger];
    }
    
    [self showOrHideSendButton];
}

#pragma mark RetrieveLinksFromServiceManagerDelegate

-(void)finishedPreparingLinks:(NSArray<LinkJM*>*)links withLinkGenerationUUID:(NSString *)uuidString{
    //NSLog(@"[finishedPreparingAllLinks]");
    
    if ([uuidString isEqualToString:_linkGenerationUUID]) {
        if (!_retrieveLinksDelegateMethodAlreadyCalled) {
            _retrieveLinksDelegateMethodAlreadyCalled = YES;
            
//            for (LinkJM* link in links) {
//                //NSLog(@"link url: %@ | name: %@", link.url, link.linkDescription);
//            }
            
            _linksToSendWithHex = links;
            if (_sendType == SendTypeCloudHex) {
                _createViewAction = CreateViewActionCloudSend;
                [self performSegueWithIdentifier:@"send-to-Create" sender:self];
            }
            else if (_sendType == SendTypeHex) {
                //Dismiss alert and show table view
                [self dismissGeneratingLinksAlert];
                [self revealContent];
            }
        }
    }
}

-(void)failedToRetrieveAllLinks:(NSString*)errorMessageToDisplay withLinkGenerationUUID:(NSString*)uuidString{
    //NSLog(@"[failedToRetrieveAllLinks]");
    
    if ([uuidString isEqualToString:_linkGenerationUUID]) {
        if (!_retrieveLinksDelegateMethodAlreadyCalled) {
            _retrieveLinksDelegateMethodAlreadyCalled = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                    //Dismiss alert
                    [self dismissGeneratingLinksAlert];
                    
                    //Hide cancel button
                    [UIView animateWithDuration:.25
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^(){
                                         [_cancelButton setAlpha:0.0];
                                     }
                                     completion:nil];
                    
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ouch!" message:errorMessageToDisplay preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              [_cancelButton setEnabled:NO];
                                                                              [self cancelButtonPressed];
                                                                          }];
                    
                    [alert addAction:defaultAction];
                    
                    [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }
}

#pragma mark - CreateViewControllerDelegate

-(void)hexJMPreparedForSend:(HexJM*)hexJM {
    _hexJMToSend = hexJM;
    //Dismiss alert and show table view
    [self dismissGeneratingLinksAlert];
    [self revealContent];
}

#pragma mark - NSNotificationCenter

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
        [self showOrHideSendButton];
    });
}

/*- Reloads the table view if a peer's state changed - */

-(void)peerDidChangeStateWithNotification: (NSNotification *)notification {
    
    MCPeerID *peer = [notification.userInfo objectForKey:@"peerID"];
    
    // Makes sure peer gets removed from selected local people if they disconnected
    if ([[notification.userInfo objectForKey:@"state"] isEqualToString:@"MCSessionStateNotConnected"]) {
        [_selectedLocalPeople removeObject:peer];
    }
    
    if ([[[notification userInfo] objectForKey:@"state"] isEqualToString:@"MCSessionStateConnected"]) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchingTimer invalidate];
            [_rotationTimer invalidate];
            _currentlyReloading = NO;
            _rotationCount = 0;
            [_reloadButton setUserInteractionEnabled:YES];
            
            _staticConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
            [_peopleTableView reloadData];
            [self showOrHideSendButton];
        });
    }
    else if ([[[notification userInfo] objectForKey:@"state"] isEqualToString:@"MCSessionStateNotConnected"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _staticConnectedStrangers = [_connectedPeopleManager getConnectedStrangers];
            [_peopleTableView reloadData];
            [self showOrHideSendButton];
        });
    }
}

/* - Stops multiple timers from scheduling themsleves- */

-(void)applicationDidEnterBackground {
    [_searchingTimer invalidate];
    [_rotationTimer invalidate];
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
    if (_rotationCount >= 12) {
        [_searchingTimer invalidate];
        [_rotationTimer invalidate];
        _currentlyReloading = NO;
        _rotationCount = 0;
        [_reloadButton setUserInteractionEnabled:YES];
        _emptyTableMessage.text = @"Nobody Around";
        _emptyTableMessage2.text = @"Keep Wi-Fi enabled to send\nto nearby users";
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

-(void)alertUserToGeneratingLinksIsPlurral:(BOOL)isPlurral {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        _generatingLinksAlert = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _generatingLinksAlert.mode = MBProgressHUDModeIndeterminate;
        if (isPlurral) {
            _generatingLinksAlert.labelText = @"Generating Links";
        }
        else {
            _generatingLinksAlert.labelText = @"Generating Link";
        }
        _generatingLinksAlert.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        _generatingLinksAlert.userInteractionEnabled = NO;
    });
}

-(void)dismissGeneratingLinksAlert {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_generatingLinksAlert hide:YES];
    });
}

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    return [tableView cellForRowAtIndexPath:indexPath];
}

-(void)showOrHideSendButton {
    if ([_selectedLocalPeople count] != 0) {
        if (!_sendButtonIsActive) {
            _sendButtonIsActive = YES;
            [UIView animateWithDuration:.25
                    delay:0
                    options:UIViewAnimationOptionCurveEaseOut
                    animations:^(){
                        //Shifts Table View Up to give room for button on long lists
                        _peopleTableView.frame = CGRectMake(_peopleTableView.frame.origin.x, _peopleTableView.frame.origin.y, _peopleTableView.frame.size.width, _peopleTableView.frame.size.height -49);
                        CGAffineTransform slideUp = CGAffineTransformMakeTranslation(0,0);
                        [_sendButton setTransform: slideUp];
                    }
                    completion:nil
             ];
        }
    }
    else {
        if (_sendButtonIsActive) {
            _sendButtonIsActive = NO;
            [UIView animateWithDuration:.25
                    delay:0
                    options:UIViewAnimationOptionCurveEaseOut
                    animations:^(){
                        //Shifts Table View Up to give room for button on long lists
                        _peopleTableView.frame = CGRectMake(_peopleTableView.frame.origin.x, _peopleTableView.frame.origin.y, _peopleTableView.frame.size.width, _peopleTableView.frame.size.height + 49);
                        CGAffineTransform slideDown = CGAffineTransformMakeTranslation(0, 49);
                        [_sendButton setTransform: slideDown];
                    }
                    completion:nil
             ];
        }
    }
}

/* - Convenience method to hide content for this view - */
-(void)hideContent {
    [_reloadButton setAlpha:0.0];
    
    // Create a mask layer and the frame to determine what will be visible in the view.
    _contentCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    _contentCover.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contentCover];
    [self.view bringSubviewToFront:_contentCover];
}

/* - Convenience method to reveal content for this view - */
-(void)revealContent {
    [UIView animateWithDuration:.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         [_contentCover setAlpha:0.0];
                         [_reloadButton setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         [_contentCover removeFromSuperview];
                         _contentCover = nil;
                     }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[CreateViewController class]]) {
        ((CreateViewController*)[segue destinationViewController]).createViewControllerDelegate = self;
        ((CreateViewController*)[segue destinationViewController]).createViewAction = _createViewAction;
        ((CreateViewController*)[segue destinationViewController]).linksToSendWithHex = _linksToSendWithHex;
    }
}


@end
