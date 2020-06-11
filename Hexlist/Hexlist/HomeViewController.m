//
// HomeViewController.m
// Hexlist
//
//
//  Created by Roman Scher on 01/04/2014.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "HomeViewController.h"
#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

/* - initialize the session,
 - start advertising yourself,
 - then search for other peers.
 - */

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    _fileLoadingObjectsQueue = dispatch_queue_create("File Loading Objects Queue", DISPATCH_QUEUE_SERIAL);
    _splitFoldersQueue = dispatch_queue_create("Split Folders Queue", DISPATCH_QUEUE_SERIAL);
    
    //Draw the add Button & Shadow
    _sendButton.layer.cornerRadius = _sendButton.frame.size.width/2;
    _sendButton.backgroundColor = [AppConstants appSchemeColor];
    [_sendButton setHighlightColor:[AppConstants circleButtonSelectionColor]];
    [_sendButton setNormalColor:_sendButton.backgroundColor];
    [_sendButton setImage:[UIImage imageNamed:[AppConstants addImageStringIdentifier]] forState:UIControlStateNormal];
    _sendButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _sendButton.layer.shadowOpacity = .5f;
    _sendButton.layer.shadowOffset = CGSizeZero;
    _sendButton.layer.shadowRadius = 1.5f;
    _sendButton.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    //    _sendButton.layer.masksToBounds = NO;
    //    _sendButton.clipsToBounds = NO;
    _sendButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_sendButton.bounds cornerRadius:_sendButton.frame.size.width/2].CGPath;
    [_sendButton setAlpha:0.0];
    [_sendButton setExclusiveTouch:YES];
    
    //Selected Files Button
    HighlightButton* selectedFilesButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 23, self.navigationController.navigationBar.bounds.size.height)];
    [selectedFilesButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
    [selectedFilesButton setUserInteractionEnabled:NO];
    [selectedFilesButton.titleLabel setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:21]];
    selectedFilesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //    [selectedFilesButton setBackgroundColor:[UIColor blueColor]];
    _selectedFilesBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:selectedFilesButton];
    [self updateSelectedFilesButtonNumber];
    
    //Unselect button
    HighlightButton* unselectButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
    [unselectButton addTarget:self action:@selector(unselectButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [unselectButton setImage:[UIImage imageNamed:[AppConstants unselectXImageStringIdentifier]] forState:UIControlStateNormal];
    [unselectButton setExclusiveTouch:YES];
    //    [unselectButton setBackgroundColor:[UIColor greenColor]];
    _unselectBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:unselectButton];
    
    //Separator
    HighlightButton* separatorButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 13, 20)];
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [AppConstants fadedWhiteColor].CGColor;
    //Leave 7 empty space on left side, 5 empty space on right side
    sublayer.frame = CGRectMake(7, -.5, 1, separatorButton.frame.size.height);
    [separatorButton.layer addSublayer:sublayer];
    [separatorButton setUserInteractionEnabled:NO];
    //    [separatorButton setBackgroundColor:[UIColor grayColor]];
    _separatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:separatorButton];
    
    //Navigation bar setup - Right Bar Button Items
    [self setNavigationItemToImage:[AppConstants hexlistNavImageStringIdentifier]];
    _collectionViewBackButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 20, 24)];
    [_collectionViewBackButton addTarget:self action:@selector(didPressCollectionViewBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants settingsImageStringIdentifier]] forState:UIControlStateNormal];
    [_collectionViewBackButton setExclusiveTouch:YES];
    _collectionViewBackBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_collectionViewBackButton];
    [self.navigationItem setLeftBarButtonItem:_collectionViewBackBarButtonItem];
    
    //Tab bar setup
    // Make unselected tab bar images orriginal color
    for(UITabBarItem *item in self.tabBarController.tabBar.items) {
        // use the UIImage category code for the imageWithColor: method
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    //Setup
    //Hide toolbar on startup
    CGAffineTransform slideDown = CGAffineTransformMakeTranslation(0, _fileOptionsToolbar.frame.size.height);
    [_fileOptionsToolbar setTransform: slideDown];
    _fileOptionsToolbarIsActive = NO;
    
    //Make room for selectUnselectButton
    _homeFileCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 80 + _fileOptionsToolbar.frame.size.height, 0);
    
    // Filesystem initialization
    [_homeFileCollectionView setDelegate:self];
    [_homeFileCollectionView setDataSource:self];
    _homeFileCollectionView.allowsMultipleSelection = YES;
    
    //make shared manager
    _sharedManager = [SharedServiceManager sharedServiceManager];
    
    // DBServiceManager initialization
    _sharedManager.dbServiceManager = [[DBServiceManager alloc] init];
    _sharedManager.gdServiceManager = [[GDServiceManager alloc] init];
    _sharedManager.bxServiceManager = [[BXServiceManager alloc] init];
    
    _sharedManager.dbServiceManager.dbServiceManagerDelegate = self;
    _sharedManager.gdServiceManager.gdServiceManagerDelegate = self;
    _sharedManager.bxServiceManager.bxServiceManagerDelegate = self;
    
    //_bxServiceManager.reloadCollectionViewProgressDelegate = self;
    //ALSO set teh delegate for bx service manager
    
    //Swipe Back button & swipe to send Gesture Recognizers
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didRightSwipe)];
    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [_homeFileCollectionView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    [_emptyMessageScrollView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    _rightSwipeGestureRecognizer = rightSwipeGestureRecognizer;
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.minimumPressDuration = .25; //seconds
    longPressRecognizer.delegate = self;
    [_homeFileCollectionView addGestureRecognizer:longPressRecognizer];
    
    // creates the in memory realm and adds first content source file representations to it
    File* rootParent = [[self fsInit] addFirstThreeContentSources];
    [[self fsAbstraction] setRoot:rootParent];
    //push the root onto stack
    [[self fsAbstraction] pushOntoPathStack:[[self fsAbstraction] getRootRealmFile]];
    // populate the colelction view after we init it
    [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:[[self fsAbstraction] getRootRealmFile]];
    
    // split the newly populated current directory into
    // folders and non folders arrays for ordering
    // during the display
    [self reloadCollectionView];
    
    //Add listener for selectedFilesUpdated notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSelectedFilesButtonNumberAndToolbar)
                                                 name:@"selectedFilesUpdated"
                                               object:nil];
    
    //empties out and cleans up after we send.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emptyFilesAndDismissOnSend)
                                                 name:@"emptyFilesAndDismissOnSend"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateToolbar)
                                                 name:@"updateToolbar"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCollectionView)
                                                 name:@"reloadHomeCollectionViewNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCollectionView)
                                                 name:@"showCollectionView"
                                               object:nil];
    
    //Add home view controller as a listener for double taps on the home tab bar item
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnToRootDirectory)
                                                 name:@"returnHomeViewControllerToRootDirectoryNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAfterCloudCancel)
                                                 name:@"reloadAfterDropboxCancel"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAfterCloudCancel)
                                                 name:@"reloadAfterGoogleCancel"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAfterCloudCancel)
                                                 name:@"reloadAfterBoxCancel"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCollectionViewFromGDLoadCancel)
                                                 name:@"showCollectionViewFromGDLoadCancel"
                                               object:nil];
    
    //    [self detectBluetooth];
}

-(FileSystemAbstraction*) fsAbstraction{
    
    if(!_fsAbstraction){
        _fsAbstraction = [FileSystemAbstraction sharedFileSystemAbstraction];
    }
    return _fsAbstraction;
}

-(FileSystemInterface*) fsInterface{
    
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}

-(FileSystemInit*) fsInit{
    
    if(!_fsInit){
        _fsInit = [[FileSystemInit alloc]init];
    }
    return _fsInit;
}

//- (void)detectBluetooth
//{
//    if(!_bluetoothManager)
//    {
//        // Put on main queue so we can call UIAlertView from delegate callbacks.
//        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
//    }
//    [self centralManagerDidUpdateState:_bluetoothManager]; // Show initial state
//}
//
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//    NSString *stateString = nil;
//    switch(_bluetoothManager.state)
//    {
//        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
//        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
//        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
//        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
//        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use."; break;
//        default: stateString = @"State unknown, update imminent."; break;
//    }
//
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth state" message:stateString delegate:nil cancelButtonTitle:@"K" otherButtonTitles:nil];
//    [alert show];
//}

#pragma mark ServiceManagerDelegates

// all three delegate methods map to this one method

-(void) unselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath{
    
    HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
    [cell.cellImageSelected setHidden:YES];
    [cell.cellImage setHidden:NO];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - NSNotificationCenter

//reload the collectionview on a dispatch async queue
-(void) reloadCollectionView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_homeFileCollectionView reloadData];
    });
}

//hides the collection view
//when we are waiting for the cloud
//to load
-(void) hideCollectionView{
    dispatch_async(dispatch_get_main_queue(), ^{
        _currentlyLoadingCollectionViewAndHidden = YES;
        _homeFileCollectionView.hidden = YES;
        _homeFileCollectionView.userInteractionEnabled = NO;
        _emptyCollectionMessage.text = @"";
        [_collectionViewActivityIndicator startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
}

//re-shows the collection view when
//the cloud files are ready do do stuff.
-(void) showCollectionView{
    dispatch_async(dispatch_get_main_queue(), ^{
        _currentlyLoadingCollectionViewAndHidden = NO;
        _homeFileCollectionView.hidden = NO;
        _homeFileCollectionView.userInteractionEnabled = YES;
        [_collectionViewActivityIndicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

// google needs a special one for some reason i guess.
-(void) showCollectionViewFromGDLoadCancel{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants settingsImageStringIdentifier]] forState:UIControlStateNormal];
        // Resets button size to accomodate settings icon
        CGRect buttonFrame = _collectionViewBackButton.frame;
        buttonFrame.size = CGSizeMake(24, 24);
        _collectionViewBackButton.frame = buttonFrame;
        _currentlyLoadingCollectionViewAndHidden = NO;
        _homeFileCollectionView.hidden = NO;
        _homeFileCollectionView.userInteractionEnabled = YES;
        _emptyCollectionMessage.text = @"";
    });
}

//triggered after e return from a send operation,
//clears out all the selected files and reload collectionview.
-(void)emptyFilesAndDismissOnSend {
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    [self reloadCollectionView];
}

//will move to parent
//remove view from superview
//remvoe child controller from the parent.

-(void) returnToRootDirectory {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_currentlyGeneratingLinks) {
            
            //Fix for pressing add button or toolbar
            [KxMenu dismissMenu];
            [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
            
            //set our nav identifier as the proper Hexlist logo.
            [self setNavigationItemToImage:[AppConstants hexlistNavImageStringIdentifier]];
            
            //while we're not looking at root pop until we get to root.
            //delete the children of each parent at each level as we move
            //up from realm, didn't use fsinterface method
            //because it would rquire a realm query or a for loop
            //this is cleaner.
            while(![ ((File*)[[[self fsAbstraction] currentDirectoryFilesStack] lastObject]).displayName isEqualToString:[AppConstants rootPathStringIdentifier]]){
                File* parentFile = [[[self fsAbstraction] currentDirectoryFilesStack] lastObject];
                RLMRealm* fileSystemRealm = [FileSystemInterface getFileSystemRealm];
                [fileSystemRealm beginWriteTransaction];
                [fileSystemRealm deleteObjects:parentFile.children];
                [fileSystemRealm commitWriteTransaction];
                [[self fsAbstraction] popDirectoryOffFileStack];
            }
            
            //Send a notification to update the toolbar once we've pushed.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];

            //get the new files for the root directory (probably content services.)
            [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:[[self fsAbstraction] getRootRealmFile]];
            
            //show the collection view again
            [self showCollectionView];
            
            //send a message to dropbox/googledrive/box to cancel their navigationary loads
            [_sharedManager.gdServiceManager cancelNavigationLoad];
            [_sharedManager.dbServiceManager cancelNavigationLoad];
            [_sharedManager.bxServiceManager cancelNavigationLoad];
            //split the newly populated current directory into
            //folders and non folders arrays for ordering
            //during the display
            
            [self reloadCollectionView];
        }
    });
}

#pragma mark - Dropbox Registration/Auth Cancelled, need to reload

// when the user cancels their dropbox
// registration we need to pop dropbox off
// the stack, reload the collectionview, and
// make sure the collectionview is visible again
-(void) reloadAfterCloudCancel{
    [self setNavigationItemToImage:[AppConstants hexlistNavImageStringIdentifier]];
    //RLM QUERY
    [self reloadCollectionView];
    [self showCollectionView];
}

#pragma mark - IBActions and View Methods

/* - Back button OR settings button for navigating directories - */

-(IBAction) didPressCollectionViewBackButton:(id)sender{
    
    //Dismiss any popup menu if one currently shown
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
    
    //if we're NOT in the root and going TO the root and we're not in the process of loading into a folder on google drive or dropbox
    //had to put the && !_currentlyLoadingCollectionViewAndHidden or else the sometimes it would wipe the /GoogleDrive/.filesystem.json
    //and then the user would press the back button on dropbox or google drive and see a "Nothing here" written on the screen
    //because the .filesystem.json had been emptied (not deleted from teh disk).
    //we want to both set the nav title AND clean the filesystem
    if(![[AppConstants rootPathStringIdentifier] isEqualToString:[[self fsAbstraction] getCurrentDirectoryPath]] && [[AppConstants rootPathStringIdentifier] isEqualToString:[[[self fsAbstraction] getCurrentDirectoryPath] stringByDeletingLastPathComponent]] && !_currentlyLoadingCollectionViewAndHidden){
        [self setNavigationItemToImage:[AppConstants hexlistNavImageStringIdentifier]];
 
        //else if we're in the root we just want to reset the nav
        //and not clean the filesystem.
        //this solved a bug where navigating to settings, then
        //and then navigating to home and then navigating to selected
        //and then home again wiped the currentDirectory and displayed nothing
        //in home.
    } else if([[AppConstants rootPathStringIdentifier] isEqualToString:[[self fsAbstraction] getCurrentDirectoryPath]] && _currentlyLoadingCollectionViewAndHidden){
        [self setNavigationItemToImage:[AppConstants hexlistNavImageStringIdentifier]];
    }
    
    //if we're in the root and we're not currently loading the cloud, then go to settings.
    if([[AppConstants rootPathStringIdentifier] isEqualToString:[[self fsAbstraction] getCurrentDirectoryPath]] && !_currentlyLoadingCollectionViewAndHidden){
        [self performSegueWithIdentifier:@"home-to-settings" sender:self];
        
        // send notificaitons to reload and pop teh pushed directory.
    } else if([[AppConstants rootPathStringIdentifier] isEqualToString:[[self fsAbstraction] getCurrentDirectoryPath]] && _currentlyLoadingCollectionViewAndHidden){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxLoadCancelledByBackButtonPress" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"googledriveLoadCancelledByBackButtonPress" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"boxLoadCancelledByBackButtonPress" object:self];
        
        //otherwise go to the cloud and change the settings button
    } else {
        //solved a bug on the collectionview where if we pressed a back button while it was loading
        //things would break (like popping back up an extra level because we hadn't pushed yet for cloud navigation)
        // this DOES NOT deal with cases where we press a back button and nothing else / loading is happening
        // only deals with the loading case. That last else statement below deals with the case where we are just sitting on a page and press back button.
        if( (((File*)[[[self fsAbstraction] currentDirectoryFilesStack] lastObject]).serviceType == ServiceTypeDropbox) && _currentlyLoadingCollectionViewAndHidden){
            //NSLog(@"did fire off dropbox");
            [self setNavigationItemToImage:[AppConstants dropboxNavImageStringIdentifier]];
            
            //NSLog(@"current directory path %@", [[self fsAbstraction] getCurrentDirectoryPath]);
        
            //get the parent file we're currently peeking inside
            File* parentFile = [[[self fsAbstraction] currentDirectoryFilesStack] lastObject];
            
            //NSLog(@"parent %@", parentFile.displayPath);
            
            //if the current directory we're looking at
            //is empty and we can't get a parent from one of the
            //children  then grab the parent from here and
            //do stuff with it.
            if ([[[self fsAbstraction] currentDirectoryChildren] count] > 0) {
                //don't remove or repopulate currenct directory children, we already have what we need in the currencdirectory children.
                //reloads collectionview
                [self reloadCollectionView];
                [self showCollectionView];
                //if we can get the children from a parent. then...
            } else {
                //there's nothing to remove from realm (empty currentDrectory)
                //get the parent of the parent of the old stuff we were watching and load into that.
                [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:parentFile.parentFile];
                
                //reloads and splits files
                [self reloadCollectionView];
                [self showCollectionView];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxLoadCancelledByBackButtonPress" object:self];
            
        } else if( (((File*)[[[self fsAbstraction] currentDirectoryFilesStack] lastObject]).serviceType == ServiceTypeGoogleDrive) && _currentlyLoadingCollectionViewAndHidden){
            //NSLog(@"did fire off google drive");
            [self setNavigationItemToImage:[AppConstants googleDriveNavImageStringIdentifier]];
            
            //get the parent file we're currently peeking inside
            File* parentFile = [[[self fsAbstraction] currentDirectoryFilesStack] lastObject];
            
            //if the current directory we're looking at
            //is empty and we can't get a parent from one of the
            //children  then grab the parent from here and
            //do stuff with it.
            if ([[[self fsAbstraction] currentDirectoryChildren] count] > 0) {
                //don't remove or repopulate currenct directory children, we already have what we need in the currencdirectory children.
                //reloads collectionview
                [self reloadCollectionView];
                [self showCollectionView];
                //if we can get the children from a parent. then...
            } else {
                //there's nothing to remove from realm (empty currentDrectory)
                //get the parent of the parent of the old stuff we were watching and load into that.
                [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:parentFile.parentFile];
                
                //reloads and splits files
                [self reloadCollectionView];
                [self showCollectionView];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"googledriveLoadCancelledByBackButtonPress" object:self];
            
        // only sitting on a page, nothing else, no loading happening, this is the back button press for
        // that scenario
        } else if( (((File*)[[[self fsAbstraction] currentDirectoryFilesStack] lastObject]).serviceType == ServiceTypeBox) && _currentlyLoadingCollectionViewAndHidden){
            //NSLog(@"did fire off box");
            [self setNavigationItemToImage:[AppConstants boxNavImageStringIdentifier]];
            
            //get the parent file we're currently peeking inside
            File* parentFile = [[[self fsAbstraction] currentDirectoryFilesStack] lastObject];
            
            //if the current directory we're looking at
            //is empty and we can't get a parent from one of the
            //children  then grab the parent from here and
            //do stuff with it.
            if ([[[self fsAbstraction] currentDirectoryChildren] count] > 0) {
                //don't remove or repopulate currenct directory children, we already have what we need in the currencdirectory children
                //reloads and splits files
                [self reloadCollectionView];
                [self showCollectionView];
                //if we can get the children from a parent. then...
            } else {
                //there's nothing to remove from realm (empty currentDrectory)
                //get the parent of the parent of the old stuff we were watching and load into that.
                [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:parentFile.parentFile];
                
                //reloads and splits files
                [self reloadCollectionView];
                [self showCollectionView];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"boxLoadCancelledByBackButtonPress" object:self];
            
            // only sitting on a page, nothing else, no loading happening, this is the back button press for
            // that scenario
        } else {
            // send a notification to update the toolbar once we've pushed.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
            
//            //NSLog(@"current directory path %@", [[self fsAbstraction] getCurrentDirectoryPath]);
            
            //get the parent file we're currently peeking inside
            File* parentFile = [[[self fsAbstraction] currentDirectoryFilesStack] lastObject];
            
//            //NSLog(@"parent %@", parentFile.displayPath);

            //if the current directory we're looking at
            //is empty and we can't get a parent from one of the
            //children  then grab the parent from here and
            //do stuff with it.
            if ([[[self fsAbstraction] currentDirectoryChildren] count] > 0) {
                //wipe the old metadata files from realm if they happen to exist
                [[self fsInterface] removeBatchOfFilesToFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:parentFile];
                //get the parent of the parent of the old stuff we were watching and load into that.
                [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:parentFile.parentFile];
                
                //reloads and splits files
                [self reloadCollectionView];
                [self showCollectionView];
            //if we can get the children from a parent. then...
            } else {
                //there's nothing to remove from realm (empty currentDrectory)
                //get the parent of the parent of the old stuff we were watching and load into that.
                [[self fsInterface] populateArrayWithFileSystemRealm:[[self fsAbstraction] currentDirectoryChildren] forParentDirectory:parentFile.parentFile];
                
                //reloads and splits files
                [self reloadCollectionView];
                [self showCollectionView];
            }
            
            //leave pop after everything
            //pop the currentdiectory off the stack
            [[self fsAbstraction] popDirectoryOffFileStack];
        }
    }
}

-(void)didRightSwipe {
    if(![[AppConstants rootPathStringIdentifier] isEqualToString:[[self fsAbstraction] getCurrentDirectoryPath]] || _currentlyLoadingCollectionViewAndHidden)
        [self didPressCollectionViewBackButton:self];
}

-(void)unselectButtonPress:(id)sender {
    [self unselectAllSelectedFiles];
}

//handles the long press event of a user.
-(void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    //Dismiss any popup menu if one currently shown
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:_homeFileCollectionView];
        NSIndexPath *indexPath = [_homeFileCollectionView indexPathForItemAtPoint:p];
        File* file = [[[self fsAbstraction] currentDirectoryChildren] objectAtIndex:indexPath.row];
        
        if (indexPath == nil){
            //NSLog(@"%s COULDN'T FIND INDEX PATH IN handleLongPress", __PRETTY_FUNCTION__);
        }else{
            //in the future this long press event for a non-folder file
            //will open a viewer, it will not select the file.
            if (![file.parentFile.displayName isEqualToString:[AppConstants rootPathStringIdentifier]]) {
                [self resolveSelectionOfFilesWithIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - Image Functions

//For assinging collection view icons and cropping reload icons

/* - didn't use NSRange bec. it's non obvious
 - NOTE: this function will break
 - on files with more than one extension
 - it needs to be updated for that.
 - */

-(UIImage *) assignIconForFileType:(File*)file isSelected:(BOOL)selected{
    
    NSString* filename = file.displayName;
    NSString *fileExtension = [filename pathExtension];
    UIImage *image;
    fileExtension = [fileExtension lowercaseString];
    
    //if the file is selected
    if(selected){
        
        //if it's a directory
        if(file.isDirectory){
            image = [UIImage imageNamed:@"folder-sel"];
        //if it's not a directory set it normally
        }else{
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-sel", fileExtension]];
        }
        if(image == nil){//we don't have a proper image file for this type of file yet then put a generic placeholder
            image = [UIImage imageNamed:@"unidentified-sel"];
        }
        //if it's not selected
    }else{
        
        //if it is a directory
        if(file.isDirectory){
            image = [UIImage imageNamed:@"folder"];
        //if it's not a directory
        } else {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", fileExtension]];
        }
        if(image == nil){//we don't have a proper image file for this type of file yet then put a generic placeholder
            image = [UIImage imageNamed:@"unidentified"];
        }
    }
    return image;
}

-(BOOL) isFileAnImage:(NSString*)filename {
    
    NSString* fileExtension = [filename pathExtension];
    fileExtension = [fileExtension lowercaseString];
    if([fileExtension isEqualToString:@"png"]){
        return YES;
    } else if([fileExtension isEqualToString:@"jpg"]) {
        return YES;
    }
    return NO;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    // - this makes the back button and options appear and disappear, it's in this method because this method
    // - always gets called for sure, cellForItemAtIndexPath might not get called if this
    // - method returns 0 (i.e. current directory has no objects in it, this happens when
    // - a direcotry is emtpy.
    if([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[AppConstants rootPathStringIdentifier]]){
        
        //if were loading something, reload the collectionview to
        //have a back button, for when we navigate from home to
        //cloud and want to isntantly change the button
        if(_currentlyLoadingCollectionViewAndHidden){
            // Makes back button position consistent with other back buttons throughout app
            [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonImageStringIdentifier]] forState:UIControlStateNormal];
            CGRect buttonFrame = _collectionViewBackButton.frame;
            buttonFrame.size = CGSizeMake(20, 24);
            _collectionViewBackButton.frame = buttonFrame;
        } else {
            [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants settingsImageStringIdentifier]] forState:UIControlStateNormal];
            
            // Resets button size to accomodate settings icon
            CGRect buttonFrame = _collectionViewBackButton.frame;
            buttonFrame.size = CGSizeMake(24, 24);
            _collectionViewBackButton.frame = buttonFrame;
        }
        
        // order the folders on the content source home view to be dropbox, box ,google
        
        int dbindex = -1;
        //increment until we find the thing
        for (File* rootFolder in [[self fsAbstraction] currentDirectoryChildren]) {
            if (![rootFolder.displayName isEqualToString:@"Dropbox"]) {
                dbindex++;
            }
        }
        
        // if dropbox is not at 0 put it as zero ans swap wtr else was there.
        if (![((File*)[[[self fsAbstraction] currentDirectoryChildren] objectAtIndex:0]).displayName isEqualToString:@"Dropbox"]) {
            [[[self fsAbstraction] currentDirectoryChildren] exchangeObjectAtIndex:0 withObjectAtIndex:dbindex];
        }
        
        
        int bxindex = -1;
        //increment until we find the thing
        for (File* rootFolder in [[self fsAbstraction] currentDirectoryChildren]) {
            if (![rootFolder.displayName isEqualToString:@"Dropbox"]) {
                bxindex++;
            }
        }
        
        // if dropbox is not at 0 put it as zero ans swap wtr else was there.
        if (![((File*)[[[self fsAbstraction] currentDirectoryChildren] objectAtIndex:1]).displayName isEqualToString:@"Box"]) {
            [[[self fsAbstraction] currentDirectoryChildren] exchangeObjectAtIndex:1 withObjectAtIndex:bxindex];
        }
        
    } else {
        [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonImageStringIdentifier]] forState:UIControlStateNormal];
        
        // Makes back button position consistent with other back buttons throughout app
        CGRect buttonFrame = _collectionViewBackButton.frame;
        buttonFrame.size = CGSizeMake(20, 24);
        _collectionViewBackButton.frame = buttonFrame;
        
        //get a file or folder to check the path
        File* lastFileOrFolder;
        if([[[self fsAbstraction] currentDirectoryChildren] count] > 0){
            lastFileOrFolder = [[[self fsAbstraction] currentDirectoryChildren] lastObject];
        }else{
            lastFileOrFolder = [[[self fsAbstraction] currentDirectoryChildren] lastObject];
        }
    }
    
    //Shows Message to user if There are no files in current directory
    if ([[[self fsAbstraction] currentDirectoryChildren] count] == 0) {
        [_homeFileCollectionView setAlpha:0.0];
        _emptyCollectionMessage.text = @"Nothing Here";
    }
    else {
        [_homeFileCollectionView setAlpha:1.0];
    }
    return [[[self fsAbstraction] currentDirectoryChildren] count];
}

-(HomeCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeCollectionViewCell* cell;
    File* file = [[[self fsAbstraction] currentDirectoryChildren] objectAtIndex:indexPath.row];
    BOOL fileIsSelected = NO;
    
    //use a for loop. do not use contains,
    //we're testing for equality of the unique id
    //not the address in memory because on a backwards
    //navigate the realm object gets purged
    
    for (File* selectedFile in [[self fsAbstraction] selectedFiles]) {
        //need to upgrade to swift before we can
        //check unique ids on dropbox.
        if (selectedFile.serviceType == ServiceTypeDropbox) {
            if ([selectedFile.displayPath isEqualToString:file.displayPath]) {
                fileIsSelected = YES;
            }
        } else {
            if ([selectedFile.idOnService isEqualToString:file.idOnService]) {
                fileIsSelected = YES;
            }
        }
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //Set File Cell Image
    if([[[self fsAbstraction] getCurrentDirectoryPath] isEqualToString:[AppConstants rootPathStringIdentifier]]){
        cell = [_homeFileCollectionView dequeueReusableCellWithReuseIdentifier:@"nonRootFileCell" forIndexPath:indexPath];
        
        [cell.cellImageSelected setHidden:YES];
        [cell.cellImage setHidden:NO];
        
        //Special images for root directory
        if ([file.parentFile.displayName isEqualToString:[AppConstants rootPathStringIdentifier]]) {
            if([file.displayName isEqualToString:@"Dropbox"]) {
                cell.cellImage.image = [UIImage imageNamed:@"dropbox"];
                cell.cellLabel.text = @"Dropbox";
            } else if([file.displayName isEqualToString:@"Box"]) {
                cell.cellImage.image = [UIImage imageNamed:@"box"];
                cell.cellLabel.text = @"Box";
            } else if([file.displayName isEqualToString:@"GoogleDrive"]) {
                cell.cellImage.image = [UIImage imageNamed:@"googledrive"];
                cell.cellLabel.text = @"Google Drive";
            }
        }
        
        return cell;
    }else if(file.isDirectory){
        cell = [_homeFileCollectionView dequeueReusableCellWithReuseIdentifier:@"nonRootFileCell" forIndexPath:indexPath];
        
        //Get rid of border from reusing cell
        [cell.cellImageSelected.layer setBorderWidth:0.0];
        
        cell.cellImage.image = [self assignIconForFileType:file isSelected:NO];
        cell.cellImageSelected.image = [self assignIconForFileType:file isSelected:YES];
        
        if(fileIsSelected){
            [cell.cellImageSelected setHidden:NO];
            [cell.cellImage setHidden:YES];
        }else{
            [cell.cellImageSelected setHidden:YES];
            [cell.cellImage setHidden:NO];
        }
    }else{
        cell = [_homeFileCollectionView dequeueReusableCellWithReuseIdentifier:@"nonRootFileCell" forIndexPath:indexPath];
        
        cell.cellImage.image = [self assignIconForFileType:file isSelected:NO];;
        cell.cellImageSelected.image = [self assignIconForFileType:file isSelected:YES];
        
        if(fileIsSelected){
            [cell.cellImageSelected setHidden:NO];
            [cell.cellImage setHidden:YES];
        } else {
            [cell.cellImageSelected setHidden:YES];
            [cell.cellImage setHidden:NO];
        }
    }
    
    //Set File Cell Text
    cell.cellLabel.text = file.displayName;
    cell.cellLabel.numberOfLines = 2;
    cell.cellLabel.preferredMaxLayoutWidth = 97.0;
    
    // if we're downloading a file and want to display a special file animation.
    // we produce the animation by croppying a red backlit file with a white baclit
    // file by the percentage the file has downloaded.
    
    //check to see if the file we just selected is a loading file, if it is
    //then make sure its alpha is set properly and its progress is set properly
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //Dismiss any popup menu if one currently shown
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
    
    //create a reachibility manager
    InternetManager* internetManager = [InternetManager reachabilityForInternetConnection];
    File* file = [[[self fsAbstraction] currentDirectoryChildren] objectAtIndex:indexPath.row];
    
    if (file.isDirectory) {//navigate into a directory
        
        // - THE "pressedXFolder" should be separate and test for an absolute path that proves
        // - it is the dropbox/googledrive/ or box folder, otherwise and path where the word "Box"
        // - or "Dropbox" or "GoogleDrive" is a substring will trigger the authentication process.
        // - if we pressed the dropbox cell/folder icon in the collectionview at the root directory - //
        if(file.serviceType == ServiceTypeDropbox){
            
            //if the internet is reachable
            if ([internetManager isReachable]){
                // - check to make sure out account is registered, if it is not present registration - //
                [self setNavigationItemToImage:[AppConstants dropboxNavImageStringIdentifier]];
                [_sharedManager.dbServiceManager pressedDropboxFolder:self withFile:file];
                [self hideCollectionView];
            } else {
                [self alertUserToInternetNotAvailable];
            }
            
        }else if(file.serviceType == ServiceTypeGoogleDrive){
            
            if ([internetManager isReachable]){
                [self setNavigationItemToImage:[AppConstants googleDriveNavImageStringIdentifier]];
                [_sharedManager.gdServiceManager pressedGoogleDriveFolder:self withFile:(File*)file];
                [self hideCollectionView];
            } else {
                [self alertUserToInternetNotAvailable];
            }
            
        }else if(file.serviceType == ServiceTypeBox){
            
            if ([internetManager isReachable]){
                [self setNavigationItemToImage:[AppConstants boxNavImageStringIdentifier]];
                [_sharedManager.bxServiceManager pressedBoxFolder:self withFile:file];
                [self hideCollectionView];
            } else {
                [self alertUserToInternetNotAvailable];
            }
        }
        
        [self reloadCollectionView];
        
    } else { //select a non directory if we're not navigating into a directory
        [self resolveSelectionOfFilesWithIndexPath:indexPath];
    }
}

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //Dismiss any popup menu if one currently shown
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
    [self resolveSelectionOfFilesWithIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize fileIconSize;
    fileIconSize.height = 121;
    fileIconSize.width = 100;
    return fileIconSize;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

//function to resolve the selection of files/folders
//called in the longpress handler and file select
//to make sure that selection occurs in a consistent
//manner

-(void) resolveSelectionOfFilesWithIndexPath: (NSIndexPath*)indexPath {
    
    HomeCollectionViewCell* cell;
    File* file = [[[self fsAbstraction] currentDirectoryChildren] objectAtIndex:indexPath.row];
    
    BOOL fileIsSelected = NO;
    NSMutableIndexSet* indexOfSelectedFile = [[NSMutableIndexSet alloc] init];
    //use a for loop. do not use contains,
    //we're testing for equality of the unique id
    //not the address in memory because on a backwards
    //navigate the realm object gets purged
    
    for (File* selectedFile in [[self fsAbstraction] selectedFiles]) {
        //need to upgrade to swift before we can
        //check unique ids on dropbox.
        if (selectedFile.serviceType == ServiceTypeDropbox) {
            if ([selectedFile.displayPath isEqualToString:file.displayPath]) {
                fileIsSelected = YES;
                [indexOfSelectedFile addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:selectedFile]];
            }
        } else {
            if ([selectedFile.idOnService isEqualToString:file.idOnService]) {
                fileIsSelected = YES;
                [indexOfSelectedFile addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:selectedFile]];
            }
        }
    }
    //if we contain the file in selected files and the file is not a cloud or inbox(incoming) folder
    if(fileIsSelected && ![file.displayName isEqualToString:[AppConstants rootPathStringIdentifier]]){
        //Remove unselected file
        [[self fsAbstraction] removeObjectsFromSelectedFilesAtIndexes:indexOfSelectedFile];
        
    }else if(![file.displayName isEqualToString:[AppConstants rootPathStringIdentifier]]){
        
        //Fixes a visual hiccup with addSend button transition from send button to sendLink button
        //Due to multiple selectedFilesChanged notifications being sent out
        if ([[[self fsAbstraction] selectedFiles] count] > 0) {
            File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
            if (singleSelectedFile.serviceType != file.serviceType) {
                _switchingServices = YES;
            }
        }
        
        if (_switchingServices) {
            [self removeSelectedFilesFromAllServicesExcept:file.serviceType];
        }

        //Add clone of the selected file
        //we can't add the origina because when we navigate
        //we purge
        
        File* newFile = [[File alloc] init];
        newFile.serviceType = file.serviceType;
        newFile.displayName = file.displayName;
        newFile.displayPath = file.displayPath;
        newFile.codedName = file.codedName;
        newFile.codedPath = file.codedPath;
        newFile.parentFile = file.parentFile;
        newFile.isDirectory = file.isDirectory;
        newFile.dateCreated = file.dateCreated;
        newFile.idOnService = file.idOnService;// when upgrade to swift change to metadata.fileID
        
        [[self fsAbstraction] addObjectToSelectedFiles:newFile];
    }
    
    //deal w/ showing selected files in the collectionview, no deselection or selection logic, these are the visual effects
    
    if(file.isDirectory && ![file.displayName isEqualToString:[AppConstants rootPathStringIdentifier]]){
        cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
        
        if(fileIsSelected){
            [cell.cellImageSelected setHidden:YES];
            [cell.cellImage setHidden:NO];
        }else{
            [cell.cellImageSelected setHidden:NO];
            [cell.cellImage setHidden:YES];
        }
    }else if (![file.displayName isEqualToString:[AppConstants rootPathStringIdentifier]]){
        cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
        
        if(fileIsSelected){
                [cell.cellImageSelected setHidden:YES];
                [cell.cellImage setHidden:NO];
            //a non image that was just unselected
        } else {
                [cell.cellImageSelected setHidden:NO];
                [cell.cellImage setHidden:YES];
        }
    }
}

-(void)unselectAllSelectedFiles {
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    [self unselectAllCellImages];
}

//unselects all cell images

-(void) unselectAllCellImages {
    for (int i = 0; i<[[[self fsAbstraction] currentDirectoryChildren] count]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
        [cell.cellImageSelected setHidden:YES];
        [cell.cellImage setHidden:NO];
    }
}

//removes selected files that are in one service when files
//get selected in a different service

-(void) removeSelectedFilesFromAllServicesExcept:(ServiceType)serviceType{
    
    BOOL foundFilesInServiceToRemove = NO;
    ServiceType serviceTypeOfUnselectedFiles = -1;
    //remove files in other services that are not the same
    //as the service we are selecting in now
    NSMutableIndexSet* filesToRemove = [[NSMutableIndexSet alloc] init];
    for(File* fileToRemove in [[self fsAbstraction] selectedFiles]){
        if(fileToRemove.serviceType != serviceType){
            [filesToRemove addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:fileToRemove]];
            serviceTypeOfUnselectedFiles = fileToRemove.serviceType;
            foundFilesInServiceToRemove = YES;
        }
    }
    [[self fsAbstraction] removeObjectsFromSelectedFilesAtIndexes:filesToRemove];
    
    if (foundFilesInServiceToRemove) {
        [self alertUserToUnselectingFilesInService: serviceTypeOfUnselectedFiles];
    }
}

#pragma mark - Helper methods

-(void)setNavigationItemToImage: (NSString*)imageStringIdentifier {
    UIImage *titleImage = [UIImage imageNamed:imageStringIdentifier];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:titleImage];
    self.navigationItem.titleView = imageView;
}

//-(void)setNavigationItemToImageTest: (NSString*)imageStringIdentifier {
//    UIImage *titleImage = [UIImage imageNamed:imageStringIdentifier];
//    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 36)];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [imageView setImage:titleImage];
//    self.navigationItem.titleView = imageView;
//}

-(void)showLinkOptionsWithLinks:(NSArray<LinkJM*>*)links {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* saveToMyHexlist = [UIAlertAction actionWithTitle:@"Create new Hex" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                [self createNewHexWithLinks:links];
                                                            }];
    UIAlertAction* deleteHex = [UIAlertAction actionWithTitle:@"Choose existing" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self addLinksToHex:links];
                                                      }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:saveToMyHexlist];
    [alert addAction:deleteHex];
    [alert addAction:cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

-(void)createNewHexWithLinks:(NSArray<LinkJM*>*)linkJMArray {
    NSArray *links = [HexManager generateArrayOfLinksFromLinksJM:linkJMArray];
    
    _generatedLinks = links;
    _createViewAction = CreateViewActionCreateHex;
    [self performSegueWithIdentifier:@"home-to-create" sender:self];
}

-(void)addLinksToHex:(NSArray<LinkJM*>*)linkJMArray {
    _linksToAddToHex = [HexManager generateArrayOfLinksFromLinksJM:linkJMArray];
    
    _myHexlistAction = MyHexlistActionAddToHex;
    [self performSegueWithIdentifier:@"home-to-AddToHex" sender:self];
}

-(void) addedToHexShowHUDWithNumAdded:(int)numHexesAdded {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        if (numHexesAdded > 1) {
            hud.labelText = @"Added to Hexes!";
        } else {
            hud.labelText = @"Added to Hex!";
        }
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void) addedToHexShowHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Created Hex!";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)alertUserToUsingFileLinksWithServiceType:(ServiceType)serviceType forLinkAction:(LinkAction)linkAction {
    
    UIAlertController* alert;
    
    if (linkAction == LinkActionSendLink) {
        alert = [UIAlertController alertControllerWithTitle:@"Sharing file links" message:[NSString stringWithFormat:@"You are about to share one or more file links from %@. Anyone with a link may view those files.", [AppConstants presentableStringForServiceType:serviceType]] preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        alert = [UIAlertController alertControllerWithTitle:@"Creating file links" message:[NSString stringWithFormat:@"You are about to create one or more file links from %@. Anyone with a link may view those files.", [AppConstants presentableStringForServiceType:serviceType]] preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [SettingsManager setUserHasBeenShownLinkSharingDialogueForServiceType:serviceType To:YES];
                                                              
                                                              [self generateLinksForLinkAction:linkAction];
                                                          }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:noAction];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertUserToUnselectingFilesInService:(ServiceType)serviceType {
    UnselectedFilesAlertView* unselectedFilesAlertView = [[UnselectedFilesAlertView alloc] init];
    unselectedFilesAlertView.serviceImage.image = [AppConstants serviceNavImageForServiceType:serviceType];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showCustomHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = unselectedFilesAlertView;
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void) alertUserToInternetNotAvailable {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"No internets. Meh.";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void) alertUserToRateLimitFromService:(ServiceType)serviceType {
    NSString* serviceString = [AppConstants presentableStringForServiceType:serviceType];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Rate Limit" message:[NSString stringWithFormat: @"%@ is rate limiting you.", serviceString] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// this alert is actually in the db service manager delegate
-(void) alertUserToFileNotFound:(File*)fileNotFound{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"File Not Found" message:[NSString stringWithFormat: @"%@ not found on \n %@!", fileNotFound.displayName, [AppConstants presentableStringForServiceType:fileNotFound.serviceType]] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) alertUserToInsufficientPermission:(File*)fileNotPermitted {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Not Allowed" message:[NSString stringWithFormat: @"You don't have permission to mess with %@ on %@", fileNotPermitted.displayName, [AppConstants presentableStringForServiceType:fileNotPermitted.serviceType]] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) alerUserToCouldntReachService:(ServiceType)serviceType {
    [_collectionViewActivityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _emptyCollectionMessage.text = [NSString stringWithFormat:@"Bah! Couldn't reach %@.", [AppConstants presentableStringForServiceType:serviceType]];
}

-(void) alertUserToUnspecifiedErrorOnService:(ServiceType)serviceType {
    [_collectionViewActivityIndicator stopAnimating];
    _emptyCollectionMessage.text = [NSString stringWithFormat:@"Bah! %@ mystery error.", [AppConstants presentableStringForServiceType:serviceType]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)alertUserToGeneratingLinksIsPlurral:(BOOL)isPlurral {
     dispatch_async(dispatch_get_main_queue(), ^{
        //Lock HomeVc UI
        _currentlyGeneratingLinks = YES;
        [self disableNavigation];
        
        GeneratingLinksAlertView* generatingLinksAlertView = [[GeneratingLinksAlertView alloc] init];
        [generatingLinksAlertView.cancelButton addTarget:self action:@selector(cancelLinksGeneration:) forControlEvents:UIControlEventTouchUpInside];
        if (isPlurral) {
             generatingLinksAlertView.label.text = @"Generating Links";
        }
        else {
            generatingLinksAlertView.label.text = @"Generating Link";
        }
        [generatingLinksAlertView.activityIndicator startAnimating];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        _generatingLinksAlert = [MBProgressHUD showCustomHUDAddedTo:self.view animated:YES];
        _generatingLinksAlert.mode = MBProgressHUDModeCustomView;
        _generatingLinksAlert.customView = generatingLinksAlertView;
        _generatingLinksAlert.userInteractionEnabled = YES;
    });
}

-(void)dismissGeneratingLinksAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        //Unlock HomeVC UI
        _currentlyGeneratingLinks = NO;
        [self enableNavigation];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
        [_generatingLinksAlert hide:YES];
    });
}

-(void)cancelLinksGeneration:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        _canceledLinksGeneration = YES;
        [self dismissGeneratingLinksAlert];
    });
}

-(void)disableNavigation {
    [_collectionViewBackButton setEnabled:NO];
    [_rightSwipeGestureRecognizer setEnabled:NO];
}

-(void)enableNavigation {
    [_collectionViewBackButton setEnabled:YES];
    [_rightSwipeGestureRecognizer setEnabled:YES];
}

#pragma mark - NSNotificationCenter

// updates the selected files indicator and the tool bar
// when the user changes their file selection
-(void)updateSelectedFilesButtonNumberAndToolbar {
    [self updateSelectedFilesButtonNumber];
    [self updateUnselectButton];
    [self updateSendButton];
    [self updateFileOptionsToolbar];
    [self showOrHideFileOptionsToolbar];
}

-(void) updateToolbar {
    [self updateFileOptionsToolbar];
}

#pragma mark RetrieveLinksFromServiceManagerDelegate

-(void)finishedPreparingLinks:(NSArray<LinkJM*>*)links withLinkGenerationUUID:(NSString *)uuidString{
    //NSLog(@"[finishedPreparingAllLinks]");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([uuidString isEqualToString:_linkGenerationUUID]) {
            if (!_canceledLinksGeneration && !_retrieveLinksDelegateMethodAlreadyCalled) {
                _retrieveLinksDelegateMethodAlreadyCalled = YES;
                
                //Dismiss alert and show table view
                [self dismissGeneratingLinksAlert];
                
//                for (LinkJM* link in links) {
//                    //NSLog(@"link url: %@ | name: %@", link.url, link.linkDescription);
//                }
                
                if (_linkAction == LinkActionCreateLink) {
                    if ([links count] == 1) {
                        LinkJM *linkToPresent = (LinkJM*)[links firstObject];
                        NSURL *linkURL = [[NSURL alloc] initWithString:linkToPresent.url];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIActivityViewController *activityVC = [AlertManager generateActivityViewControllerWithURL:linkURL];
                            
                            //                activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *items, NSError *error) {};
                            
                            [self presentViewController:activityVC
                                               animated:YES
                                             completion:^() {}];
                        });
                    }
                    else {
                        NSString *linksString = [[NSString alloc] init];
                        
                        for (LinkJM *linkJM in links) {
                            linksString = [[linksString stringByAppendingString:linkJM.url] stringByAppendingString:@"\n"];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIActivityViewController *activityVC = [AlertManager generateShareHexActivityViewControllerWithString:linksString];
                            
                            //                activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *items, NSError *error) {};
                            
                            [self presentViewController:activityVC
                                               animated:YES
                                             completion:^() {}];
                        });
                    }
                }
                else if (_linkAction == LinkActionStoreLink) {
                    [self showLinkOptionsWithLinks:links];
                }
            }
        }
    });
}

-(void)failedToRetrieveAllLinks:(NSString*)errorMessageToDisplay withLinkGenerationUUID:(NSString *)uuidString {
    //NSLog(@"[failedToRetrieveAllLinks]");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([uuidString isEqualToString:_linkGenerationUUID]) {
            if (!_canceledLinksGeneration && !_retrieveLinksDelegateMethodAlreadyCalled) {
                _retrieveLinksDelegateMethodAlreadyCalled = YES;
                
                //Dismiss alert
                [self dismissGeneratingLinksAlert];
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ouch!" message:errorMessageToDisplay preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                                      handler:nil];
                
                [alert addAction:defaultAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
        }
    });
}

#pragma mark - File Options Toolbar & AddSend Button

/* - Called to visibly show or hide the toolbar - */

-(void)showOrHideFileOptionsToolbar {
    if ([[[self fsAbstraction] selectedFiles] count] != 0) {
        if (!_fileOptionsToolbarIsActive) {
            [_fileOptionsToolbar setUserInteractionEnabled:YES];
            _fileOptionsToolbarIsActive = YES;
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 CGAffineTransform slideUpToolbar = CGAffineTransformMakeTranslation(0,0);
                                 CGAffineTransform slideUpsendButton = CGAffineTransformMakeTranslation(0,-_fileOptionsToolbar.frame.size.height);
                                 [_fileOptionsToolbar setTransform: slideUpToolbar];
                                 [_sendButton setTransform:slideUpsendButton];
                             }
                             completion:nil
             ];
        }
    }
    else {
        if (_fileOptionsToolbarIsActive) {
            [_fileOptionsToolbar setUserInteractionEnabled:NO];
            _fileOptionsToolbarIsActive = NO;
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 CGAffineTransform slideDownToolbar = CGAffineTransformMakeTranslation(0, _fileOptionsToolbar.frame.size.height);
                                 CGAffineTransform slideDownsendButton = CGAffineTransformMakeTranslation(0, 0);
                                 [_fileOptionsToolbar setTransform: slideDownToolbar];
                                 [_sendButton setTransform:slideDownsendButton];
                             }
                             completion:nil
             ];
        }
    }
}

-(void)updateUnselectButton {
    if ([[[self fsAbstraction] selectedFiles] count] != 0) {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:_unselectBarButtonItem, _separatorBarButtonItem, _selectedFilesBarButtonItem, nil] animated:NO];
    }
    else {
        [self.navigationItem setRightBarButtonItems:nil animated:NO];
    }
}

-(void)updateSelectedFilesButtonNumber {
    NSNumber *numFilesSelected = [NSNumber numberWithInteger:[[[self fsAbstraction] selectedFiles] count]];
    [((HighlightButton*)_selectedFilesBarButtonItem.customView) setTitle:[numFilesSelected stringValue] forState:UIControlStateNormal];
    [((HighlightButton*)_selectedFilesBarButtonItem.customView) sizeToFit];
}

/* - Called to transition between button states for addSend button - */

-(void)updateSendButton {
        //Hide Send Button
        
    if ([[[self fsAbstraction] selectedFiles] count] == 0) {
        
        if (!_switchingServices) {
            [_sendButton setUserInteractionEnabled:NO];
            [_sendButton removeTarget:self action:@selector(toolbarSendLinkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 [_sendButton setAlpha:0.0];
                             }
                             completion:nil];
        }
    }
    else if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        //if our single selected file is in local then all our files are located in the Local folder
        
        [_sendButton addTarget:self action:@selector(toolbarSendLinkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton setImage:[UIImage imageNamed:[AppConstants sendLinkImageStringIdentifier]] forState:UIControlStateNormal];
        [_sendButton setUserInteractionEnabled:YES];
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             [_sendButton setAlpha:1.0];
                         }
                         completion:nil];
        _switchingServices = NO;
    }
}

-(void)toolbarGrabLinksButtonPress: (id)sender {
    _linkAction = LinkActionCreateLink;
    [self requestToGenerateLinksForLinkAction:_linkAction];
}

-(void)toolbarStoreLinksButtonPress:(id)sender {
    _linkAction = LinkActionStoreLink;
    [self requestToGenerateLinksForLinkAction:_linkAction];
}

-(void)toolbarSendLinkButtonPress:(id)sender {
    _linkAction = LinkActionSendLink;
    [self requestToGenerateLinksForLinkAction:_linkAction];
}

-(void)requestToGenerateLinksForLinkAction:(LinkAction)linkAction {
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        //Check where the files are selected from
        File* selectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        ServiceType serviceType = selectedFile.serviceType;
        
        //Conditionally present link creation/sharing alerts for services
        if ([SettingsManager userHasBeenShownLinkSharingDialogueForServiceType:serviceType]) {
            [self generateLinksForLinkAction:linkAction];
        }
        else {
            [self alertUserToUsingFileLinksWithServiceType:serviceType forLinkAction:linkAction];
        }
    }
}

-(void)generateLinksForLinkAction:(LinkAction)linkAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        _linkGenerationUUID = [[NSUUID UUID] UUIDString];
        _canceledLinksGeneration = NO;
        _retrieveLinksDelegateMethodAlreadyCalled = NO;
        
        //dequeue one file.
        File* selectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        
        if (selectedFile.serviceType == ServiceTypeDropbox) {
            [_sharedManager.dbServiceManager getShareableLinksWithFiles:[[NSArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] andParentFile:[[[self fsAbstraction] currentDirectoryFilesStack] lastObject] andUUID:[NSString stringWithString:_linkGenerationUUID]];
        } else if (selectedFile.serviceType == ServiceTypeBox) {
            [_sharedManager.bxServiceManager getShareableLinksWithFiles:[[NSArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] andParentFile:[[[self fsAbstraction] currentDirectoryFilesStack] lastObject] andUUID:[NSString stringWithString:_linkGenerationUUID]];
        } else if (selectedFile.serviceType == ServiceTypeGoogleDrive) {
            [_sharedManager.gdServiceManager getShareableLinksWithFiles:[[NSArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] andParentFile:[[[self fsAbstraction] currentDirectoryFilesStack] lastObject] andUUID:[NSString stringWithString:_linkGenerationUUID]];
        }
        
        if (linkAction == LinkActionCreateLink) {
            [self prepareLinksFromServiceManagerDelegateWithViewController:self];
            [self alertUserToGeneratingLinksIsPlurral:NO];
            [self unselectAllSelectedFiles];
        }
        else if (linkAction == LinkActionStoreLink) {
            [self prepareLinksFromServiceManagerDelegateWithViewController:self];
            if ([[[self fsAbstraction] selectedFiles] count] == 1) {
                [self alertUserToGeneratingLinksIsPlurral:NO];
            }
            else {
                [self alertUserToGeneratingLinksIsPlurral:YES];
            }
            [self unselectAllSelectedFiles];
        }
        else if (linkAction == LinkActionSendLink) {
            _sendViewSendType = SendTypeCloudHex;
            [self performSegueWithIdentifier:@"home-to-send" sender:self];
        }
    });
}

/* - Here is where the logic for deciding which buttons to add to the toolbar goes - */

-(void)updateFileOptionsToolbar {
    
    NSNumber *numFilesSelected = [NSNumber numberWithInteger:[[[self fsAbstraction] selectedFiles] count]];
    
    NSMutableArray *buttonActionIdentifiers = [[NSMutableArray alloc] init];
    
    if([numFilesSelected intValue] == 1){
        [buttonActionIdentifiers addObject:[NSNumber numberWithInteger:ToolbarActionGrabLink]];
        [buttonActionIdentifiers addObject:[NSNumber numberWithInteger:ToolbarActionStoreLink]];
    } else if ([numFilesSelected intValue] > 1) {
        [buttonActionIdentifiers addObject:[NSNumber numberWithInteger:ToolbarActionGrabLinks]];
        [buttonActionIdentifiers addObject:[NSNumber numberWithInteger:ToolbarActionStoreLinks]];
    }
    
    //Prevents bug where toolbar will update/wipe/show different file options after deselecting files
    if ([numFilesSelected intValue] != 0) {
        [self setFileOptionsToolbarButtons: buttonActionIdentifiers];
    }
}

/* - Here is where we actually set the toolbar buttons - */

-(void)setFileOptionsToolbarButtons: (NSMutableArray*)buttonActionIdentifiers  {
    NSMutableArray *fileOptions = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *leftNegativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftNegativeSeparator.width = -16;
    [fileOptions addObject:leftNegativeSeparator];
    
    UIBarButtonItem *centerNegativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    centerNegativeSeparator.width = -10;
    
    NSNumber *totalNumberOfButtonsOnToolbar = [[NSNumber alloc] initWithInt:(int)[buttonActionIdentifiers count]];
    
    for (NSString* actionIdentifier in buttonActionIdentifiers) {

        if ([actionIdentifier integerValue] == ToolbarActionGrabLink) {
            UIBarButtonItem *sendLinkButton = [self createToolbarButtonWithText:@"Grab Link" AndImage:[AppConstants linkToolbarImageStringIdentifier] andToolbarAction: ToolbarActionGrabLink AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:sendLinkButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier integerValue] == ToolbarActionGrabLinks) {
            UIBarButtonItem *sendLinkButton = [self createToolbarButtonWithText:@"Grab Links" AndImage:[AppConstants linkToolbarImageStringIdentifier] andToolbarAction: ToolbarActionGrabLink AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:sendLinkButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier integerValue] == ToolbarActionStoreLink) {
            UIBarButtonItem *sendLinkButton = [self createToolbarButtonWithText:@"Add Link to Hex" AndImage:[AppConstants hexOptionsToolbarImageStringIdentifier] andToolbarAction:ToolbarActionStoreLink AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:sendLinkButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier integerValue] == ToolbarActionStoreLinks) {
            UIBarButtonItem *sendLinkButton = [self createToolbarButtonWithText:@"Add Links to Hex" AndImage:[AppConstants hexOptionsToolbarImageStringIdentifier] andToolbarAction:ToolbarActionStoreLinks AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:sendLinkButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
    }
    
    [_fileOptionsToolbar setItems:fileOptions animated:NO];
}

-(UIBarButtonItem*)createToolbarButtonWithText: (NSString*)text AndImage: (NSString*)imageStringIdentifier andToolbarAction: (ToolbarAction)toolbarAction AndWithTotalNumberOfButtonsOnToolbar: (NSNumber*)numberOfButtonsOnToolbar {
    
    CGFloat toolbarButtonWidth = (_fileOptionsToolbar.frame.size.width)/numberOfButtonsOnToolbar.intValue;
    CGFloat toolbarHeight = _fileOptionsToolbar.frame.size.height;
    CGFloat labelHeight = 20;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, toolbarHeight - labelHeight, toolbarButtonWidth, labelHeight)];
    UIImage *image = [UIImage imageNamed:imageStringIdentifier];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    UIView* viewForToolbarButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, toolbarButtonWidth, toolbarHeight)];
    UIButton *buttonForBarButtonItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, toolbarButtonWidth, toolbarHeight)];
    [buttonForBarButtonItem setBackgroundImage:[AppConstants imageWithColor:[AppConstants fileOptionsToolbarSeparatorColor]] forState:UIControlStateHighlighted];
    [buttonForBarButtonItem setExclusiveTouch:YES];
    buttonForBarButtonItem.tintColor = [UIColor whiteColor];
    
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:11.0]];
    
    CGRect frame = imageView.frame;
    frame.size.width = 20;
    frame.size.height = 20;
    frame.origin.y = 6;
    imageView.frame = frame;
    imageView.center = CGPointMake(CGRectGetMidX(viewForToolbarButton.bounds), imageView.center.y);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [viewForToolbarButton addSubview:label];
    [viewForToolbarButton addSubview:imageView];
    
    //    Add right side border
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(viewForToolbarButton.frame.size.width, 6, .5, viewForToolbarButton.frame.size.height - 12)];
    lineView.backgroundColor = [AppConstants fileOptionsToolbarSeparatorColor];
    [viewForToolbarButton addSubview:lineView];

    if (toolbarAction == ToolbarActionGrabLink || toolbarAction == ToolbarActionGrabLinks) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarGrabLinksButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (toolbarAction == ToolbarActionStoreLink || toolbarAction == ToolbarActionStoreLinks) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarStoreLinksButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    viewForToolbarButton.userInteractionEnabled = NO;
    viewForToolbarButton.exclusiveTouch = NO;
    [buttonForBarButtonItem addSubview:viewForToolbarButton];
    
    //    [viewForToolbarButton setBackgroundColor:[UIColor redColor]];
    //    [label setBackgroundColor:[UIColor blueColor]];
    //    [imageView setBackgroundColor:[UIColor orangeColor]];
    
    //DO NOT USE addsubview here
    return [[UIBarButtonItem alloc] initWithCustomView:buttonForBarButtonItem];
}

-(void)dismissKxMenuPopup {
    [KxMenu dismissMenu];
}

-(void)prepareLinksFromServiceManagerDelegateWithViewController:(UIViewController*)viewController {
    _sharedManager.dbServiceManager.retrieveLinksFromServiceManagerDelegate = (id)viewController;
    _sharedManager.gdServiceManager.retrieveLinksFromServiceManagerDelegate = (id)viewController;
    _sharedManager.bxServiceManager.retrieveLinksFromServiceManagerDelegate = (id)viewController;
}

#pragma mark - Navigation

/* - Set the sendViewController's delegate to the HomeViewController - */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[sendViewController class]]) {
        //set the sendViewController's delegate to the home view controller
        ((sendViewController*)[segue destinationViewController]).sendViewControllerDelegate = (id)self.tabBarController;
        //Set the sendViewController's type of send
        ((sendViewController*)[segue destinationViewController]).sendType = _sendViewSendType;
        ((sendViewController*)[segue destinationViewController]).linkGenerationUUID = _linkGenerationUUID;
        
        //set the send link delegate from the service manager equal to the sendview controller so it can recieve shareable links
        [self prepareLinksFromServiceManagerDelegateWithViewController:((sendViewController*)[segue destinationViewController])];
    }
    else if ([[segue destinationViewController] isKindOfClass:[CreateViewController class]]) {
        ((CreateViewController*)[segue destinationViewController]).createViewAction = _createViewAction;
        ((CreateViewController*)[segue destinationViewController]).linksToSaveWithHex = _generatedLinks;
        ((CreateViewController*)[segue destinationViewController]).createViewControllerDelegate = self;
    }
    else if ([[segue destinationViewController] isKindOfClass:[MyHexlistViewController class]]) {
        ((MyHexlistViewController*)[segue destinationViewController]).myHexlistAction = _myHexlistAction;
        ((MyHexlistViewController*)[segue destinationViewController]).linksToAddToHex = _linksToAddToHex;
        ((MyHexlistViewController*)[segue destinationViewController]).myHexlistViewControllerDelegate = self;

    }
    else if ([[segue destinationViewController] isKindOfClass:[SettingsViewController class]]) {
        ((SettingsViewController*)[segue destinationViewController]).settingsContentType = SettingsContentTypeRoot;
    }
}

@end