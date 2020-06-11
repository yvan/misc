//
//  InboxViewController.m
//  Airdoc
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "InboxViewController.h"

@interface InboxViewController ()

@end

@implementation InboxViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Setup
    _inboxManager = [InboxManager sharedInboxManager];
    _connectedPeopleManager = [ConnectedPeopleManager sharedConnectedPeopleManager];
    _localStorageManager = [[LocalStorageManager alloc] init];
    if ([_connectedPeopleManager currentlyInTheProcessOfSending]) {
        [((ProgressNavigationViewController*)self.navigationController).sendProgress setProgress:[_connectedPeopleManager getProgressOfCurrentOutgoingSend] animated:NO];
        [((ProgressNavigationViewController*)self.navigationController).sendProgress setHidden:NO];
    }
    
    //Initialize data sources
    _selectedLinkPackageIndexes = [[NSMutableIndexSet alloc] init];
    _tempFilePackagesArray = [[_inboxManager getFilePackagesFromInboxJson] mutableCopy];
    _tempIncomingSendProgressesArray = [_connectedPeopleManager getAllIncomingSendProgresses];
    _linkPackages = [_inboxManager getAllLinkPackages];
    _tempLinkPackagesArray = [self getStaticLinkPackagesArray:_linkPackages];
    _filesTableOffset = 0.0f;
    _linksTableOffset = 0.0f;
    
    // Table view Setup ( & removing excess empty table view cells)
    [_inboxTableView setDelegate:self];
    [_inboxTableView setDataSource:self];
    _inboxTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
     _inboxTableView.separatorColor = [AppConstants tableViewSeparatorColor];
    
    //Set tableview background color
//    UIView* bview = [[UIView alloc] init];
//    bview.backgroundColor = [UIColor whiteColor];
//    [_inboxTableView setBackgroundView:bview];
    
    // In the future we will not be creating indivial service managers un each class
    // WE will be using single shared instance filemanagers, save memory.
    _gdServiceManager = [[GDServiceManager alloc] init];
    _dbServiceManager = [[DBServiceManager alloc] init];
    
    // Add this VC as a listener for notifications on peer connection states & receiving new files from peers (Posted from MultiPeerInitializerTabBarController)
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInboxTabSelected)
                                                 name:@"inboxTabSelectedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startedReceivingNewFilePackageFromPeer)
                                                 name:@"startedReceivingNewFilePackageFromPeer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedReceivingFilePackageFromPeer)
                                                 name:@"finishedReceivingFilePackageFromPeer"
                                               object:nil];
    
    //Notifications for Tab bar updates
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgesForNewFilePackage)
                                                 name:@"updateBadgesForNewFilePackage"
                                               object:nil];
    
    //Add links to LinkPackage and save linkpackage to disk
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    // Observe Realm Notifications
    _rlmNotificationToken = [realm addNotificationBlock:^(NSString *notification, RLMRealm * realm) {
        [self receivedLinkPackageFromPeer];
    }];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [self updateBadges];
}

-(FileSystemInterface*) fsInterface{
    
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}

-(FileSystemFunctions*) fsFunctions{
    if(!_fsFunctions){
        _fsFunctions = [FileSystemFunctions sharedFileSystemFunctions];
    }
    return _fsFunctions;
}

-(FileSystemAbstraction*) fsAbstraction {
    if(!_fsAbstraction){
        _fsAbstraction = [FileSystemAbstraction sharedFileSystemAbstraction];
    }
    return _fsAbstraction;
}

-(DBServiceManager*) dsServiceManager{
    if(!_dbServiceManager){
        _dbServiceManager = [[DBServiceManager alloc]init];
    }
    return _dbServiceManager;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        //Use Separator
        [_inboxTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        //Set tableview background color
        UIView* bview = [[UIView alloc] init];
        bview.backgroundColor = [UIColor whiteColor];
        [_inboxTableView setBackgroundView:bview];
        
        return 2;
    }
    //Links View
    else {
        //Remove separator
        [_inboxTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        //Set tableview background color
        UIView* bview = [[UIView alloc] init];
        bview.backgroundColor = [AppConstants grayTableViewBackgroundColor];
        [_inboxTableView setBackgroundView:bview];
        
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numRows = 0;
    
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        NSInteger countIncoming = [_tempIncomingSendProgressesArray count];
        NSInteger countFilePackages = [_tempFilePackagesArray count];
        
        if (section == 0) {
            numRows = countIncoming;
        }
        else {
            numRows = countFilePackages;
        }
        
        //Show table view or empty message
        if (countIncoming == 0 && countFilePackages == 0) {
            _emptyTableMessage.text = @"No Files Received Yet";
            _emptyMessageScrollView.scrollEnabled = YES;
            [_inboxTableView setAlpha:0.0];
        }
        else {
            _emptyMessageScrollView.scrollEnabled = NO;
            [_inboxTableView setAlpha:1.0];
        }
    }
    //Links View
    else {
        NSInteger countLinkPackages = [_tempLinkPackagesArray count];
        
        numRows = countLinkPackages;
        
        //Show table view or empty message
        if (countLinkPackages == 0) {
            _emptyTableMessage.text = @"No Links Received Yet";
            _emptyMessageScrollView.scrollEnabled = YES;
            [_inboxTableView setAlpha:0.0];
        }
        else {
            _emptyMessageScrollView.scrollEnabled = NO;
            [_inboxTableView setAlpha:1.0];
        }
    }
    
    return numRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {

        if (indexPath.section == 0) {
            //IncomingSendProgressCell
            return [self generateIncomingSendProgressCellForTableView:tableView AndIndexPath:indexPath];
        }
        else {
            //Inbox cell
            return [self generateInboxCellForTableView:tableView AndIndexPath:indexPath];
        }
    }
    //Links View
    else {
        //LinkPackageCell
        return [self generateLinkPackageCellForTableView:tableView AndIndexPath:indexPath];
    }
}

/* - Convenience method to generate an incomingSendProgressCell for an indexPath- */
-(IncomingSendProgressCell *)generateIncomingSendProgressCellForTableView:(UITableView *)tableView
                                                             AndIndexPath:(NSIndexPath *)indexPath {
    
    IncomingSendProgressCell *incomingSendProgressCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants incomingSendProgressCellStringIdentifier] forIndexPath:indexPath];
    incomingSendProgressCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *sendProgressDictionary = [_tempIncomingSendProgressesArray objectAtIndex:indexPath.row];
    NSString *senderName = [LocalStorageManager getPeerNameFromDisplayName:((MCPeerID*)[sendProgressDictionary objectForKey:[AppConstants peerIDStringIdentifier]]).displayName];
    
    //Draw First Letters of first & name in User Circle
    NSArray *firstAndLastName = [senderName componentsSeparatedByString:@" "];
    NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
    //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
    firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
    //    firstletterOfLastName = [firstletterOfLastName uppercaseString];
    
    //Draw the inbox user circle
    UIView* userCircle = [[UIView alloc] initWithFrame:CGRectMake(0,0,40,40)];
    userCircle.layer.cornerRadius = 20;
    userCircle.backgroundColor = [UIColor lightGrayColor];
    userCircle.alpha = .5;
    UIImage *userCircleImage = [AppConstants imageWithView:userCircle];
    [incomingSendProgressCell.userCircle setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
    [incomingSendProgressCell.userCircle setBackgroundImage:userCircleImage forState:UIControlStateNormal];
    incomingSendProgressCell.mainLabel.text = senderName;
    
    //Set UIProgressview properties
    [incomingSendProgressCell.sendProgress setProgressTintColor:[AppConstants appSchemeColorC]];
    [incomingSendProgressCell.sendProgress setTrackTintColor:[AppConstants tableViewSeparatorColor]];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    incomingSendProgressCell.sendProgress.transform = transform;
    [incomingSendProgressCell.sendProgress setProgress:[(NSProgress*)[sendProgressDictionary objectForKey: [AppConstants sendProgressStringIdentifier]] fractionCompleted] animated:NO];
    
    return incomingSendProgressCell;
}

/* - Convenience method to generate inboxCell for an indexPath- */
-(InboxCell *)generateInboxCellForTableView:(UITableView *)tableView
                               AndIndexPath:(NSIndexPath *)indexPath {
    
    InboxCell * inboxCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants inboxCellStringIdentifier] forIndexPath:indexPath];
    __weak InboxCell *weakInboxCell = inboxCell;
    
    // Configuring the views and colors for swipe to accept and swipe to delete.
    UIView *checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[AppConstants acceptWhiteImageStringIdentifier]]];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    
    UIView *crossView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[AppConstants trashImageStringIdentifier]]];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    // Setting the default inactive state color to the tableView background color.
    [inboxCell setDefaultColor:[UIColor lightGrayColor]];
    
    // Adding gestures per state basis.
    [inboxCell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self acceptButtonPress:weakInboxCell];
    }];
    inboxCell.firstTrigger = .24;
    
    [inboxCell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self declineButtonPress:weakInboxCell];
    }];
    
    inboxCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *filePackageUUID = [_tempFilePackagesArray objectAtIndex:indexPath.row];
    NSString *senderName = [filePackageUUID objectForKey:[AppConstants sentByStringIdentifier]];
    NSDictionary *files = [filePackageUUID objectForKey:[AppConstants filesStringIdentifier]];
    NSInteger numFiles = [files count];
    NSString *numFileString = [NSString stringWithFormat: @"%ld", (long)numFiles];
    
    NSString *sentDate = [filePackageUUID objectForKey:[AppConstants receivedDateStringIdentifier]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSDate *date1 = [dateFormatter dateFromString:sentDate];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    sentDate = [dateFormatter stringFromDate:date1];
    
    //Draw First Letters of first & name in User Circle
    NSArray *firstAndLastName = [senderName componentsSeparatedByString:@" "];
    NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
    //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
    firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
    //    firstletterOfLastName = [firstletterOfLastName uppercaseString];
    
    //Draw the inbox user circle
    UIView* userCircle = [[UIView alloc] initWithFrame:CGRectMake(0,0,40,40)];
    userCircle.layer.cornerRadius = 20;
    userCircle.backgroundColor = [AppConstants niceRandomColor];
    UIImage *userCircleImage = [AppConstants imageWithView:userCircle];
    [inboxCell.userCircle setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
    [inboxCell.userCircle setBackgroundImage:userCircleImage forState:UIControlStateNormal];
    inboxCell.mainLabel.text = senderName;
    __block NSString* subLabelText;
    if ([numFileString isEqualToString:@"1"]) {
        subLabelText = [numFileString stringByAppendingString:@" File "];
    }
    else {
        subLabelText = [numFileString stringByAppendingString:@" Files "];
    }
    
    
    inboxCell.subLabel.text = @"";
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSString* filePackagePath = [AppConstants pathForFilePackage:filePackageUUID];
        NSString* filePackageSize = [[self fsInterface] getFileSizeRecursive: filePackagePath];
        if (filePackageSize != nil) {
            subLabelText = [[[[subLabelText stringByAppendingString:@"- "] stringByAppendingString:filePackageSize] stringByAppendingString:@" - "]
                            stringByAppendingString:sentDate];
            
            inboxCell.subLabel.text = subLabelText;
        }
    });

    return inboxCell;
}

/* - Convenience method to generate an incomingSendProgressCell for an indexPath- */
-(LinkPackageCell *)generateLinkPackageCellForTableView:(UITableView *)tableView
                                           AndIndexPath:(NSIndexPath *)indexPath {
    
    LinkPackageCell *linkPackageCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants linkPackageCellStringIdentifier] forIndexPath:indexPath];
    
    LinkPackage *linkPackage = [_tempLinkPackagesArray objectAtIndex:indexPath.row];
    linkPackageCell.linkPackage = linkPackage;
    
    //Draw First Letters of first & name in User Circle
    NSArray *firstAndLastName = [linkPackage.senderName componentsSeparatedByString:@" "];
    NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
    //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
    firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
    
    //Draw the inbox user circle
    UIView* userCircle = [[UIView alloc] initWithFrame:CGRectMake(0,0,36,36)];
    userCircle.layer.cornerRadius = 18;
    userCircle.backgroundColor = [AppConstants niceRandomColor];
    UIImage *userCircleImage = [AppConstants imageWithView:userCircle];
    [linkPackageCell.userCircle setTitle:@"R" forState:UIControlStateNormal];
    [linkPackageCell.userCircle setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
    [linkPackageCell.userCircle setBackgroundImage:userCircleImage forState:UIControlStateNormal];
    linkPackageCell.mainLabel.text = linkPackage.senderName;
    [linkPackageCell.serviceIcon setImage:[self getServiceImage:linkPackage] forState:UIControlStateNormal];
    
    //    NSInteger numLinks = 1 + arc4random() % 4;
    NSInteger numLinks = [linkPackage.links count];
    linkPackageCell.numLinks = numLinks;
    
    NSString *numLinksString = [NSString stringWithFormat: @"%ld", (long)numLinks];
    __block NSString* subLabelText;
    if (numLinks == 1) {
        subLabelText = [numLinksString stringByAppendingString:@" Link - "];
    }
    else {
        subLabelText = [numLinksString stringByAppendingString:@" Links - "];
    }
    
    //Set date
    NSDate *sentDate = linkPackage.timestamp;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    subLabelText = [subLabelText stringByAppendingString:[dateFormatter stringFromDate:sentDate]];
    linkPackageCell.subLabel.text = subLabelText;
    
    NSUInteger linkPackageIndex = (NSUInteger)indexPath.row;
    if ([_selectedLinkPackageIndexes containsIndex:linkPackageIndex]) {
        [self generateLinksViewContent:linkPackageCell numLinks:numLinks];
        linkPackageCell.linksView.alpha = 1.0;
        linkPackageCell.actionsView.alpha = 1.0;
        [_inboxTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        linkPackageCell.linksView.alpha = 0.0;
        linkPackageCell.actionsView.alpha = 0.0;
    }
    
    return linkPackageCell;
}

-(void)generateLinksViewContent:(LinkPackageCell*)linkPackageCell numLinks:(NSInteger)numLinks {
    
    CGFloat linksViewHeight = [LinkPackageCell linkHeight] * numLinks;
    CGFloat linkHeight = linksViewHeight/numLinks;
    
    [[linkPackageCell.linksView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    LinkView *previousLinkView;
    
    NSArray *links = [self getSortedLinksArray:linkPackageCell.linkPackage.links];
    
    for (int i = 0; i < numLinks; i++) {
        
        LinkView *linkView = [[LinkView alloc] init];
        LinkButton *linkButton = linkView.linkButton;
        [linkView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        linkButton.link = [links objectAtIndex:i];
        [linkButton addTarget:self action:@selector(linkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//        [linkButton setTitle:linkButton.link.fileName forState:UIControlStateNormal];
        [linkButton setImage:[AppConstants imageFromText:linkButton.link.fileName withFont:linkButton.titleLabel.font] forState:UIControlStateNormal];
        [linkButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        
        //Add linkView to linkViews
        [linkPackageCell.linksView addSubview:linkView];
        
        //Set linkView constraints in linkViews
        
        NSLayoutConstraint *constraint;
        
        //LinkButtonViewConstraints
        constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                  attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:linkPackageCell.linksView
                                                  attribute:NSLayoutAttributeLeading
                                                 multiplier:1
                                                   constant:0];
        [linkPackageCell.linksView addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                  attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:linkPackageCell.linksView
                                                  attribute:NSLayoutAttributeTrailing
                                                 multiplier:1
                                                   constant:0];
        [linkPackageCell.linksView addConstraint:constraint];
        
        
        //First and Only cell
        if (i == 0 && i == numLinks - 1) {
            constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:linkPackageCell.linksView
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1
                                                       constant:0];
            [linkPackageCell.linksView addConstraint:constraint];
            
            constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:linkPackageCell.linksView
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1
                                                       constant:0];
            [linkPackageCell.linksView addConstraint:constraint];
        }
        //First cell + Multiple cells
        if (i == 0) {
            constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:linkPackageCell.linksView
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1
                                                       constant:0];
            [linkPackageCell.linksView addConstraint:constraint];
        }
        //Last Cell + Multiple cells
        else if (i == numLinks - 1) {
            constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:previousLinkView
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1
                                                       constant:0];
            [linkPackageCell.linksView addConstraint:constraint];
            
            constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:linkPackageCell.linksView
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1
                                                       constant:0];
            [linkPackageCell.linksView addConstraint:constraint];
        }
        //Middle Cells
        else {
            constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:previousLinkView
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1
                                                       constant:0];
            [linkPackageCell.linksView addConstraint:constraint];
        }
        
        constraint = [NSLayoutConstraint constraintWithItem:linkView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1
                                                   constant:linkHeight];
        constraint.priority = 999;
        [linkView addConstraint:constraint];
        
        previousLinkView = linkView;
    }
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        return 0.01f;
    }
    //Links View
    else {
        return 7;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        return 0.01f;
    }
    //Links View
    else {
        return 7;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        return 75;
    }
    //Links View
    else {
        NSUInteger linkPackageIndex = (NSUInteger)indexPath.row;
        if([_selectedLinkPackageIndexes containsIndex:linkPackageIndex]) {
            
            LinkPackage *linkPackage = [_tempLinkPackagesArray objectAtIndex:indexPath.row];
            NSInteger numLinks = [linkPackage.links count];

            return [LinkPackageCell cellHeightExpandedStaticPortion] + ([LinkPackageCell linkHeight] * numLinks);
        }
        else {
            return [LinkPackageCell cellHeightUnexpanded];
        }
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
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        // Explictly sets cell's inset to 0
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    //Links View
    else {
        LinkPackageCell *linkPackageCell = (LinkPackageCell*)cell;
        linkPackageCell.downloadButtonView.layer.cornerRadius = 5;
        linkPackageCell.deleteButtonView.layer.cornerRadius = 5;
        linkPackageCell.containerView.layer.cornerRadius = 5;
        linkPackageCell.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        linkPackageCell.containerView.layer.shadowOpacity = 0.10f;
        linkPackageCell.containerView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        linkPackageCell.containerView.layer.shadowRadius = 1.0f;
        [linkPackageCell.mainView.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:linkPackageCell.mainView.bounds cornerRadius:5.0f].CGPath];
        
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    }
}

/* - Used to set selection of file package - */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_inboxSegmentedControl selectedSegmentIndex] == 1) {
        
        NSUInteger linkPackageIndex = (NSUInteger)indexPath.row;
        LinkPackageCell *linkPackageCell = (LinkPackageCell*)[_inboxTableView cellForRowAtIndexPath:indexPath];
        
        if([_selectedLinkPackageIndexes containsIndex:linkPackageIndex]) {
            [_selectedLinkPackageIndexes removeIndex:linkPackageIndex];
            
            [_inboxTableView beginUpdates];
            [_inboxTableView endUpdates];
            
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [linkPackageCell.linksView setAlpha:0.0];
                                 [linkPackageCell.actionsView setAlpha:0.0];
                             }
                             completion:nil];
        }
        else {
            
            [self generateLinksViewContent:linkPackageCell numLinks:linkPackageCell.numLinks];
            
            [_selectedLinkPackageIndexes addIndex:linkPackageIndex];
            
            [_inboxTableView beginUpdates];
            [_inboxTableView endUpdates];
            
            [UIView animateWithDuration:.4
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [linkPackageCell.linksView setAlpha:1.0];
                                 [linkPackageCell.actionsView setAlpha:1.0];
                                 [_inboxTableView scrollToRowAtIndexPath:indexPath
                                                        atScrollPosition:UITableViewScrollPositionMiddle
                                                                animated:YES];
                             }
                             completion:nil];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_inboxSegmentedControl selectedSegmentIndex] == 1) {
        
        NSUInteger linkPackageIndex = (NSUInteger)indexPath.row;
        LinkPackageCell *linkPackageCell = (LinkPackageCell*)[_inboxTableView cellForRowAtIndexPath:indexPath];
        
        if([_selectedLinkPackageIndexes containsIndex:linkPackageIndex]) {
            [_selectedLinkPackageIndexes removeIndex:linkPackageIndex];
            
            [_inboxTableView beginUpdates];
            [_inboxTableView endUpdates];
            
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [linkPackageCell.linksView setAlpha:0.0];
                                 [linkPackageCell.actionsView setAlpha:0.0];
                             }
                             completion:nil];
        }
    }
}

#pragma mark - NSNotificationCenter

/* - For Color changes in Files Section :D - */

-(void)handleInboxTabSelected {
    
//    [_inboxTableView setContentOffset:CGPointZero animated:YES];
    
    [self changeColorOfAllCells];
}

-(void)updateBadgesForNewFilePackage {
    if ([_inboxSegmentedControl selectedSegmentIndex] == 1) {
        
        //Update badges if inbox tab is currently selected
        if (self.tabBarController.selectedIndex == 1) {
            UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
            
            [InboxManager incrementnumberOfUncheckedFilePackages];
            NSString *numUncheckedPackages = [InboxManager getTotalNumberOfUncheckedPackages];
            NSInteger numUncheckedFilePackages = [(NSString*)[InboxManager getNumberOfUncheckedFilePackages] intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                inboxTab.badgeValue = numUncheckedPackages;
                [_inboxSegmentedControl setBadgeNumber:numUncheckedFilePackages forSegmentAtIndex:0];
            });
        }
    }
}

-(void)updateBadgesForNewLinkPackage {
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        
        //Update badges if inbox tab is currently selected
        if (self.tabBarController.selectedIndex == 1) {
            UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
            
            [InboxManager incrementnumberOfUncheckedLinkPackages];
            NSString *numUncheckedPackages = [InboxManager getTotalNumberOfUncheckedPackages];
            NSInteger numUncheckedLinkPackages = [(NSString*)[InboxManager getNumberOfUncheckedLinkPackages] intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                inboxTab.badgeValue = numUncheckedPackages;
                [_inboxSegmentedControl setBadgeNumber:numUncheckedLinkPackages forSegmentAtIndex:1];
            });
        }
    }
}

/* This fires when we start receiving a new file package from a peer.
 * If there is zero new send progresses, don't do anything
 * If there is one or more new send progresses, insert every new send progress retrieved
 * Update the data source, and insert the new incomingSendProgressCell(s) into the tableView under the incomingSendProgresses section.
 */

-(void)startedReceivingNewFilePackageFromPeer {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger incomingSendProgressesCountBefore = [_tempIncomingSendProgressesArray count];
        _tempIncomingSendProgressesArray = [_connectedPeopleManager getAllIncomingSendProgresses];
        NSInteger incomingSendProgressesCountNow = [_tempIncomingSendProgressesArray count];
        NSInteger numNewSendProgresses = incomingSendProgressesCountNow - incomingSendProgressesCountBefore;
        
        //Files View
        if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
            //Show tableview if hidden
            [_inboxTableView setAlpha:1.0];
            
            //If there is indeed a new file package(s), do the insert. We need to do this check because a send can fail but multipeer still registers a successful didFinishReceivingResource
            if (numNewSendProgresses > 0) {
                NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                for (int i = 0; i < numNewSendProgresses; i++) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                [_inboxTableView beginUpdates];
                [_inboxTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView endUpdates];
            }
        }
    });
}

/* - This fires after we finish receiveing a new file package from a peer, with either a success or a failure
 * If success, we remove the corresponding incomingSendProgressCell from the incomingSendProgresses section, and add the new corresponding filePackageCell to
 * filePackages section
 * Success: # file packages returned from inboxManager is different from # file packages here
 * Failure: # file packages returned from inboxManager is the same as the # file packages here
 - */

-(void)finishedReceivingFilePackageFromPeer {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //UPDATE SEND PROGRESSES
        NSArray *oldIncomingSendProgressesArray = [[NSArray alloc] initWithArray:_tempIncomingSendProgressesArray copyItems:NO];
        _tempIncomingSendProgressesArray = [_connectedPeopleManager getAllIncomingSendProgresses];
        NSInteger incomingSendProgressesCountBefore = [oldIncomingSendProgressesArray count];
        NSInteger incomingSendProgressesCountNow = [_tempIncomingSendProgressesArray count];
        NSInteger numSendProgressesFinished = incomingSendProgressesCountBefore - incomingSendProgressesCountNow;
        
        //UPDATE FILE PACKAGES
        NSArray *oldFilePackagesArray = [[NSArray alloc] initWithArray:_tempFilePackagesArray copyItems:NO];
        _tempFilePackagesArray = [[_inboxManager getFilePackagesFromInboxJson] mutableCopy];
        NSInteger filePackagesCountBefore = [oldFilePackagesArray count];
        NSInteger filePackagesCountNow = [_tempFilePackagesArray count];
        NSInteger numNewFilePackages = filePackagesCountNow - filePackagesCountBefore;
        
        //Files View
        if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        
            //deleteIndexPaths declared here so we can bundle deletion & insertion of cells into case batch updates.
            NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
            
            if (numSendProgressesFinished > 0) {
            
                //FIX FOR CRASH WHERE WE EXPECT allIncomingSendProgresses TO HAVE ONE LESS ELEMENT, BUT IT HAS THE SAME NUMBER OF ELEMENTS, BECAUSE WE START RECEIVING A NEW FILE PACKAGE RIGHT AFTER WE FINISHED RECEIVING THE OLD FILE PACKAGE
                //Will hold only those items BOTH in oldIncomingSendProgressesArray and newIncomingSendProgressesArray (so as to isolate the element that finished)
                NSMutableArray *finishedIncomingSendProgresses = [[NSMutableArray alloc] init];
                for (NSDictionary *incomingSendProgressDictionary in oldIncomingSendProgressesArray) {
                    //Find any incomingSendProgresses that have finished
                    if (![_tempIncomingSendProgressesArray containsObject:incomingSendProgressDictionary]) {
                        [finishedIncomingSendProgresses addObject:incomingSendProgressDictionary];
                    }
                }
                
                
                for (NSDictionary *finishedIncomingSendProgress in finishedIncomingSendProgresses) {
                    [deleteIndexPaths addObject: [NSIndexPath indexPathForRow:[oldIncomingSendProgressesArray indexOfObject:finishedIncomingSendProgress] inSection:0]];
                }
                
                //Maintains fade animation for when there is only one cell in view
                if ([oldIncomingSendProgressesArray count] == 1 && [_tempFilePackagesArray count] == 0) {
                    
                    IncomingSendProgressCell *incomingSendProgressCell =
                    (IncomingSendProgressCell*)[_inboxTableView cellForRowAtIndexPath:deleteIndexPaths[0]];
                    
                    [UIView transitionWithView:incomingSendProgressCell
                                      duration:0.4
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:nil
                                    completion:^(BOOL success) {}];
                    [incomingSendProgressCell setHidden: YES];
                }
            }
            
            //insertIndexPaths declared here so we can bundle deletion & insertion of cells into case batch updates.
            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
            
            //If there is indeed a new file package, do the insert. We need to do this check because a send can fail but multipeer still registers a successful didFinishReceivingResource
            if (numNewFilePackages > 0) {
                for (int i = 0; i < numNewFilePackages; i++) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                }
            }
            
            //CASES FOR DELETION & INSERTION
            if (numSendProgressesFinished > 0 && numNewFilePackages > 0) {
                //Perform all deletion and insertion updates at once
                [_inboxTableView beginUpdates];
                [_inboxTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView endUpdates];
            }
            else if (numSendProgressesFinished > 0) {
                //Perform deletions
                [_inboxTableView beginUpdates];
                [_inboxTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView endUpdates];
            }
            else if (numNewFilePackages > 0) {
                //Perform insertions
                [_inboxTableView beginUpdates];
                [_inboxTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView endUpdates];
            }
        }
    });
}

-(void)receivedLinkPackageFromPeer {
    [self updateBadgesForNewLinkPackage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //UPDATE LINK PACKAGES
        NSArray *oldLinkPackagesArray = [[NSArray alloc] initWithArray:_tempLinkPackagesArray copyItems:NO];
        _tempLinkPackagesArray = [self getStaticLinkPackagesArray:_linkPackages];
        NSInteger linkPackagesCountBefore = [oldLinkPackagesArray count];
        NSInteger linkPackagesCountNow = [_tempLinkPackagesArray count];
        NSInteger numNewLinkPackages = linkPackagesCountNow - linkPackagesCountBefore;
        
        //Shift all selected indexes over by 1
        [_selectedLinkPackageIndexes shiftIndexesStartingAtIndex:0 by:numNewLinkPackages];
        
        //Links View
        if ([_inboxSegmentedControl selectedSegmentIndex] == 1) {
            //Show tableview if hidden
            [_inboxTableView setAlpha:1.0];
            
            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
            
            //If there is indeed a new link package, do the insert.
            if (numNewLinkPackages > 0) {
                for (int i = 0; i < numNewLinkPackages; i++) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                //Perform all deletion and insertion updates at once
                [_inboxTableView beginUpdates];
                [_inboxTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView endUpdates];
            }
        }
    });
}

/*- Reloads the table view when we reenter the app (used to clean up leftover incoming send progresses) - */

-(void)applicationWillEnterForeground {
    dispatch_async(dispatch_get_main_queue(), ^{
        _tempIncomingSendProgressesArray = [_connectedPeopleManager getAllIncomingSendProgresses];
        
        [_inboxTableView reloadData];
    });
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //Files View
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Find which incomingSendProgress this corresponds to
            NSInteger incomingSendProgressDictionaryIndex = -1;
            for (NSDictionary *sendProgressDictionary in _tempIncomingSendProgressesArray) {
                if ([[sendProgressDictionary objectForKey:[AppConstants sendProgressStringIdentifier]] isEqual:object]) {
                    incomingSendProgressDictionaryIndex = [_tempIncomingSendProgressesArray indexOfObject:sendProgressDictionary];
                }
            }
            
            if (incomingSendProgressDictionaryIndex >= 0) {
                UITableViewCell *cell = [_inboxTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:incomingSendProgressDictionaryIndex inSection:0]];
                IncomingSendProgressCell *incomingSendProgressCell = (IncomingSendProgressCell*)cell;

                //THIS CHECK OF THE CLASS IS NEEDED, BECAUSE SOMETIMES THE TABLE FOR SOME REASON RETURNS AN InboxCell INSTEAD OF THE IncomingSendProgressCELL
                if ([incomingSendProgressCell isKindOfClass:[IncomingSendProgressCell class]]) {
                    
                        [incomingSendProgressCell.sendProgress setProgress:[(NSProgress *)object fractionCompleted]];
                   
                }
            }
            
    //        if ([keyPath isEqualToString:@"fractionCompleted"]) {
    //            if ([_connectedPeopleManager progressIsAnIncomingSendProgress:(NSProgress*)object]) {
    //                NSLog(@"Sending File progress: %f", ([(NSProgress *)object fractionCompleted] * 100));
    //            }
    //        }
        });
    }
}

#pragma mark - IBAction

/* - Switches between files and links views - */
- (IBAction)segmentedControlPress:(id)sender {
    [self updateBadges];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
            _linksTableOffset = _inboxTableView.contentOffset.y;
            [_inboxTableView reloadData];
            [self setSavedScrollPosition:_filesTableOffset IsFilesView:YES];
        }
        else {
            _filesTableOffset = _inboxTableView.contentOffset.y;
            [_inboxTableView reloadData];
            [self setSavedScrollPosition:_linksTableOffset IsFilesView:NO];
        }
    });
}

//Links Section

/* - Handler method for link buttons -*/
-(void)linkButtonPress:(id)sender {
    LinkButton *linkButton = (LinkButton*)sender;
    NSURL *linkButtonURL = [[NSURL alloc] initWithString:linkButton.link.url];
    
//    linkButton.alpha = .25;
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[linkButtonURL]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                     }];
    NSLog(@"link name: %@", linkButton.link.fileName);
}

-(IBAction)downloadLinkPackageButtonPress {
    
}

-(IBAction)deleteLinkPackageButtonPress:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        LinkPackageCell *linkPackageCell = (LinkPackageCell*)[self GetCellFromTableView:_inboxTableView Sender:sender];
        NSIndexPath *indexPath = [_inboxTableView indexPathForRowAtPoint:linkPackageCell.center];
        LinkPackage *linkPackage = [_tempLinkPackagesArray objectAtIndex:indexPath.row];
        
        //Fixes fade out animation on last row
        if ([_tempLinkPackagesArray count] == 1) {
            
            //Fix fade animation by updating height first before deletion
            [_selectedLinkPackageIndexes removeIndex:indexPath.row];
            [_inboxTableView beginUpdates];
            [_inboxTableView endUpdates];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [linkPackageCell.linksView setAlpha:0.0];
                                 [linkPackageCell.actionsView setAlpha:0.0];
                             }
                             completion:nil];
            
            //Delete linkPackage
            [_inboxManager deleteLinkPackage:linkPackage];
            [_tempLinkPackagesArray removeObject:linkPackage];
            [_selectedLinkPackageIndexes shiftIndexesStartingAtIndex:indexPath.row by:-1];
            
            [UIView animateWithDuration:.4
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [linkPackageCell setAlpha:0.0];

                             }
                             completion:^(BOOL success) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [_inboxTableView reloadData];
                                 });
                             }];
        }
        else {
            
            //Fix fade animation by updating height first before deletion
            [_selectedLinkPackageIndexes removeIndex:indexPath.row];
            [_selectedLinkPackageIndexes shiftIndexesStartingAtIndex:indexPath.row by:1];
            if ([_inboxSegmentedControl selectedSegmentIndex] == 1) {
                //Change height of cell first
                [_inboxTableView beginUpdates];
                [_inboxTableView endUpdates];
            }
            
            //Delete linkPackage
            [_inboxManager deleteLinkPackage:linkPackage];
            [_tempLinkPackagesArray removeObject:linkPackage];
            
            //Only reload if in Links View
            if ([_inboxSegmentedControl selectedSegmentIndex] == 1) {
                
                NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                             [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],
                                             nil];
                
                [_inboxTableView beginUpdates];
                [_inboxTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView endUpdates];
            }
        }
    });
}

//Files Section

- (IBAction)acceptButtonPress:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        InboxCell *inboxCell = (InboxCell*)sender;
        NSIndexPath *indexPath = [_inboxTableView indexPathForRowAtPoint:inboxCell.center];
        NSDictionary *filePackageUUID = [_tempFilePackagesArray objectAtIndex:indexPath.row];

        //Fixes fade out animation on last row
        if ([_tempFilePackagesArray count] == 1) {
            [UIView transitionWithView:inboxCell
                              duration:0.4
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    //Move files & update json
                                    [self localSaveWithFilePackage:filePackageUUID];
                                    [_inboxManager removeFilePackageFromInboxJsonWithFilePackageUUID:[filePackageUUID objectForKey:[AppConstants filePackageUUIDStringIdentifier]]];
                                    [_tempFilePackagesArray removeObject:filePackageUUID];
                                    //Only reload if in Files View
                                    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
                                        [_inboxTableView reloadData];
                                    }
                                });
                            }];
            [inboxCell setHidden: YES];
        } else {
                
                //Move files & update json
                [self localSaveWithFilePackage:filePackageUUID];
                [_inboxManager removeFilePackageFromInboxJsonWithFilePackageUUID:[filePackageUUID objectForKey:[AppConstants filePackageUUIDStringIdentifier]]];
                [_tempFilePackagesArray removeObject:filePackageUUID];
                
                //Only reload if in Files View
                if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
                    
                    NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                                 [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],
                                                 nil];

                    [_inboxTableView beginUpdates];
                    [_inboxTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [_inboxTableView endUpdates];
                }
        }
    });
    
    
    //Show files moved alert
    UILabel* labelForTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 134, 20)];
    UIImage *image = [UIImage imageNamed:[AppConstants localNavStringIdentifier]];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    UIView* viewForHUD = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 174, 20)];
    
    labelForTitle.text = @"Files moved to";
    labelForTitle.textColor = [UIColor whiteColor];
    labelForTitle.textAlignment = NSTextAlignmentCenter;
    [labelForTitle setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:18.0]];
    
    CGRect frame = imageView.frame;
    frame.origin.x = 135;
    frame.origin.y = -12;
    imageView.frame = frame;
    
    [viewForHUD addSubview:labelForTitle];
    [viewForHUD addSubview:imageView];
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.customView = viewForHUD;
        hud.mode = MBProgressHUDModeCustomView;
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

- (IBAction)declineButtonPress:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        InboxCell *inboxCell = (InboxCell*)sender;
        
        //Fixes fade out animation on last row
        if ([_tempFilePackagesArray count] == 1) {
            [UIView transitionWithView:inboxCell
                              duration:0.4
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSIndexPath *indexPath = [_inboxTableView indexPathForRowAtPoint:inboxCell.center];
                                    NSDictionary *filePackageUUID = [_tempFilePackagesArray objectAtIndex:indexPath.row];
                                    
                                    //Move files & update json first
                                    [[self fsInterface] deleteFileAtPath:[AppConstants pathForFilePackage:filePackageUUID]];
                                    [_inboxManager removeFilePackageFromInboxJsonWithFilePackageUUID:[filePackageUUID objectForKey:[AppConstants filePackageUUIDStringIdentifier]]];
                                    
                                    [_tempFilePackagesArray removeObject:filePackageUUID];
                                    
                                    //Only reload if in Files View
                                    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
                                        [_inboxTableView reloadData];
                                    }
                                });
                            }];
            [inboxCell setHidden: YES];
        }
        else {
            NSIndexPath *indexPath = [_inboxTableView indexPathForRowAtPoint:inboxCell.center];
            NSDictionary *filePackageUUID = [_tempFilePackagesArray objectAtIndex:indexPath.row];
            
            //Move files & update json first
            [[self fsInterface] deleteFileAtPath:[AppConstants pathForFilePackage:filePackageUUID]];
            [_inboxManager removeFilePackageFromInboxJsonWithFilePackageUUID:[filePackageUUID objectForKey:[AppConstants filePackageUUIDStringIdentifier]]];
            
            [_tempFilePackagesArray removeObject:filePackageUUID];
            
            //Only reload if in Files View
            if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
                
                NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                             [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],
                                             nil];
                
                [_inboxTableView beginUpdates];
                [_inboxTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [_inboxTableView endUpdates];
            }
        }
    });
}

#pragma mark - Alerts

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

#pragma mark - Helper Methods

-(NSMutableArray*)getStaticLinkPackagesArray:(RLMResults*)linkPackages {
    NSMutableArray *staticLinkPackagesArray = [[NSMutableArray alloc] init];
    for (LinkPackage *linkPackage in linkPackages) {
        [staticLinkPackagesArray addObject:linkPackage];
    }
    
    return staticLinkPackagesArray;
}

-(NSArray*)getSortedLinksArray:(RLMArray*)links {
    NSMutableArray *linksArray = [[NSMutableArray alloc] init];
    for (Link *link in links) {
        [linksArray addObject:link];
    }
    
    NSArray *sortedLinksArray;
    sortedLinksArray = [linksArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *fileNameA = [(Link*)a fileName];
        NSString *fileNameB = [(Link*)b fileName];
        return [fileNameA length] > [fileNameB length] ;
    }];
    
    return sortedLinksArray;
}

//this method saves things from the inbox inside a container folder with the name of the sender
//the container folder is inside the sent to me folder.
//sent to me -> [yvanphone, yvancomp, romanphone] -> [ [yvanphone-1, yvanphone-2], [yvancomp-1, yvancomp-2], [romanphone-1, romanphone-2, romanphone-3] ]
-(void)localSaveWithFilePackage: (NSDictionary*)filePackageUUID {
    
    NSString* nameOfSender = [[filePackageUUID objectForKey:[AppConstants sentByStringIdentifier]] stringByRemovingPercentEncoding];
    
    //check for the sent to me directory, if it does not exist, create it.
    if(![[self fsInterface] isValidPath:[@"/Local" stringByAppendingPathComponent:@"sent to me"]]){
        File* sentToMeDir = [[File alloc] initWithName:@"sent to me" andPath:[@"/Local" stringByAppendingPathComponent:@"sent to me"] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
        [[self fsInterface] createDirectoryAtPath:sentToMeDir.path withIntermediateDirectories:NO attributes:nil];
        [[self fsInterface] saveSingleFileToFileSystemJSON:sentToMeDir inDirectoryPath:sentToMeDir.parentURLPath];
    }
    
    //if the container folder for that user does not exist inside the sent to me directory create it.
    if(![[self fsInterface] isValidPath:[[@"/Local" stringByAppendingPathComponent:@"sent to me"] stringByAppendingPathComponent:nameOfSender]]){
        File* containerFolder = [[File alloc] initWithName:nameOfSender andPath:[[@"/Local" stringByAppendingPathComponent:@"sent to me"] stringByAppendingPathComponent:nameOfSender] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
        [[self fsInterface] createDirectoryAtPath:containerFolder.path withIntermediateDirectories:NO attributes:nil];
        [[self fsInterface] saveSingleFileToFileSystemJSON:containerFolder inDirectoryPath:containerFolder.parentURLPath];
    }

    NSString *filePackageUUIDString = [filePackageUUID objectForKey:[AppConstants filePackageUUIDStringIdentifier]];
    
    File* dirToMoveLocal = [[File alloc] initWithName:filePackageUUIDString andPath:[@"/Incoming" stringByAppendingPathComponent:filePackageUUIDString] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
    
    //go through each file inside
    for (NSString* path in [[self fsInterface] getArrayFromEnumeratorForPath:dirToMoveLocal.path option:0]) {
        //if it's a directory we want to move it and all its contents.
        //get the filename and whether or not something is a directory
        //for each file
        BOOL isDirectory;
        NSString *filename = [[path lastPathComponent] stringByRemovingPercentEncoding];
        [[NSFileManager defaultManager] fileExistsAtPath:[[[[[self fsInterface] getDocumentsDirectory]stringByAppendingPathComponent:path] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isDirectory:&isDirectory];
        NSString* filePath = path;
        if(isDirectory){
            
            File* enumeratedDirectoryToMove = [[File alloc] initWithName:filename andPath:filePath andDate:[NSDate date] andRevision:@"1" andDirectoryFlag:YES andBoxId:@"-1"];
            
            [[self fsFunctions] moveFileAndSubChildrenByEnumeration:enumeratedDirectoryToMove fromPath:enumeratedDirectoryToMove.path toPath:[[[@"/Local" stringByAppendingPathComponent:@"sent to me"] stringByAppendingPathComponent:nameOfSender] stringByAppendingPathComponent:filename]];
            
        //if it's not we just move it.
        } else {
            //path here in this enumerateFileToMove is the new path, not the old one
            File* enumeratedFileToMove = [[File alloc] initWithName:filename andPath:[[[@"/Local" stringByAppendingPathComponent:@"sent to me"] stringByAppendingPathComponent:nameOfSender] stringByAppendingPathComponent:filename] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:NO andBoxId:@"-1"];

            [[self fsInterface] moveItemAtPath:filePath toPath:[[[@"/Local" stringByAppendingPathComponent:@"sent to me"] stringByAppendingPathComponent:nameOfSender] stringByAppendingPathComponent:filename]];
            
            [[self fsInterface] saveSingleFileToFileSystemJSON:enumeratedFileToMove inDirectoryPath:[[@"/Local" stringByAppendingPathComponent:@"sent to me"] stringByAppendingPathComponent:nameOfSender]];
        }
    }
    
    //repopulate the current directory and then reload the collectionview if we're in a subpath of "sent to me" folder
    if ([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:[@"Local" stringByAppendingPathComponent:@"sent to me"]]) {
        [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
        //reload the home view controller collection view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
    }
}

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    return [tableView cellForRowAtIndexPath:indexPath];
}

/* - Convenience method to set saved scroll position for filesView and linksView -*/

-(void)setSavedScrollPosition:(float)savedOffset IsFilesView:(BOOL)isFilesView {
    if (isFilesView) {
        //Set saved scroll position
        if (savedOffset < 0) {
            [_inboxTableView setContentOffset:CGPointMake(0, 0)];
        }
        else if (savedOffset + _inboxTableView.frame.size.height > _inboxTableView.contentSize.height) {
            if (_inboxTableView.contentSize.height >= _inboxTableView.frame.size.height) {
                [_inboxTableView setContentOffset:CGPointMake(0, _inboxTableView.contentSize.height - _inboxTableView.bounds.size.height)];
            }
        }
        else {
            [_inboxTableView setContentOffset:CGPointMake(0, savedOffset)];
        }
    }
    else {
        //Set saved scroll position
        if (savedOffset < 0) {
            [_inboxTableView setContentOffset:CGPointMake(0, 0)];
        }
        else if (savedOffset + _inboxTableView.frame.size.height > _inboxTableView.contentSize.height) {
            if (_inboxTableView.contentSize.height >= _inboxTableView.frame.size.height) {
                [_inboxTableView setContentOffset:CGPointMake(0, _inboxTableView.contentSize.height - _inboxTableView.bounds.size.height)];
            }
        }
        else {
            [_inboxTableView setContentOffset:CGPointMake(0, savedOffset)];
        }
    }
}

-(void)changeColorOfCellAtIndexPath:(NSIndexPath*)indexPath {
    if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
        InboxCell *inboxCell = (InboxCell*)[_inboxTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        
        //Draw the inbox user circle
        UIView* userCircle = [[UIView alloc] initWithFrame:CGRectMake(0,0,40,40)];
        userCircle.layer.cornerRadius = 20;
        userCircle.backgroundColor = [AppConstants niceRandomColor];
        UIImage *userCircleImage = [AppConstants imageWithView:userCircle];
        [inboxCell.userCircle setBackgroundImage:userCircleImage forState:UIControlStateNormal];
    }
    else {
        LinkPackageCell *linkPackageCell = (LinkPackageCell*)[_inboxTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        
        //Draw the inbox user circle
        UIView* userCircle = [[UIView alloc] initWithFrame:CGRectMake(0,0,36,36)];
        userCircle.layer.cornerRadius = 18;
        userCircle.backgroundColor = [AppConstants niceRandomColor];
        UIImage *userCircleImage = [AppConstants imageWithView:userCircle];
        [linkPackageCell.userCircle setBackgroundImage:userCircleImage forState:UIControlStateNormal];
    }
}

-(void)changeColorOfAllCells {
    
        if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
            //Change color of all visible filePackage cells
            NSArray *visibleCells = [_inboxTableView visibleCells];
            NSInteger numVisibleCells = [visibleCells count];
            for (NSInteger i = 0; i < numVisibleCells; ++i) {
                if ([(UITableViewCell*)visibleCells[i] isKindOfClass:[InboxCell class]]) {
                    InboxCell *inboxCell = (InboxCell*)visibleCells[i];

                    dispatch_async(dispatch_get_main_queue(), ^ {
                        //Draw the inbox user circle
                        UIView* userCircle = [[UIView alloc] initWithFrame:CGRectMake(0,0,40,40)];
                        userCircle.layer.cornerRadius = 20;
                        userCircle.backgroundColor = [AppConstants niceRandomColor];
                        UIImage *userCircleImage = [AppConstants imageWithView:userCircle];
                        [inboxCell.userCircle setBackgroundImage:userCircleImage forState:UIControlStateNormal];
                    });
                }
            }
        }
        else  {
            //Change color of all visible linkPackage cells
            NSArray *visibleCells = [_inboxTableView visibleCells];
            NSInteger numVisibleCells = [visibleCells count];
            for (NSInteger i = 0; i < numVisibleCells; ++i) {
                if ([(UITableViewCell*)visibleCells[i] isKindOfClass:[LinkPackageCell class]]) {
                    LinkPackageCell *inboxCell = (LinkPackageCell*)visibleCells[i];
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        //Draw the inbox user circle
                        UIView* userCircle = [[UIView alloc] initWithFrame:CGRectMake(0,0,36,36)];
                        userCircle.layer.cornerRadius = 18;
                        userCircle.backgroundColor = [AppConstants niceRandomColor];
                        UIImage *userCircleImage = [AppConstants imageWithView:userCircle];
                        [inboxCell.userCircle setBackgroundImage:userCircleImage forState:UIControlStateNormal];
                    });
                }
            }
        }
}

/* - Returns the service image associated with the link package link type - */

-(UIImage*)getServiceImage:(LinkPackage*)linkPackage {
    if ([((Link*)[linkPackage.links firstObject]).type isEqualToString:[Link LINK_TYPE_DROPBOX]]) {
        return [UIImage imageNamed:[AppConstants dropboxNavStringIdentifier]];
    }
    else {
        return [UIImage imageNamed:[AppConstants googleDriveNavStringIdentifier]];
    }
}

-(void)updateBadges {
    dispatch_async(dispatch_get_main_queue(), ^{
        UITabBarItem *inboxTab = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
        if ([_inboxSegmentedControl selectedSegmentIndex] == 0) {
            [InboxManager reduceNumberOfUncheckedFilePackagesToZero];
            [_inboxSegmentedControl setBadgeNumber:0 forSegmentAtIndex:0];
            [_inboxSegmentedControl setBadgeNumber:[(NSString*)[InboxManager getNumberOfUncheckedLinkPackages] intValue] forSegmentAtIndex:1];
        }
        else {
            [InboxManager reduceNumberOfUncheckedLinkPackagesToZero];
            [_inboxSegmentedControl setBadgeNumber:0 forSegmentAtIndex:1];
            [_inboxSegmentedControl setBadgeNumber:[(NSString*)[InboxManager getNumberOfUncheckedFilePackages] intValue] forSegmentAtIndex:0];
        }
        
        //Set tab bar badge value
        NSString *totalNumUncheckedPackages = [InboxManager getTotalNumberOfUncheckedPackages];
        if ([totalNumUncheckedPackages isEqualToString:@"0"]) {
            inboxTab.badgeValue = nil;
        }
        else {
            inboxTab.badgeValue = totalNumUncheckedPackages;
        }
    });
}

/*/Users/scherroman/Desktop/Xcode projects/Airdoc/Airdoc/InboxViewController.m
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
