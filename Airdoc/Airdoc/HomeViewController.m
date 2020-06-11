//
// HomeViewController.m
// Airdoc
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
    _addButton.layer.cornerRadius = _addButton.frame.size.width/2;
    _addButton.backgroundColor = [AppConstants appSchemeColor];
    [_addButton setHighlightColor:[AppConstants addButtonPopupSelectionColor]];
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
    [_addButton setAlpha:0.0];
    [_addButton setExclusiveTouch:YES];
    
    //Draw the Selected Files Button
    UIView* whiteBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,23,23)];
    whiteBox.layer.cornerRadius = 7;
    whiteBox.layer.borderWidth = 1;
    whiteBox.layer.borderColor = [UIColor whiteColor].CGColor;
    whiteBox.backgroundColor = [UIColor clearColor];
    UIImage* whiteBoxImage = [AppConstants imageWithView:whiteBox];
    
    //Selected Files Button
    HighlightButton* selectedFilesButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [selectedFilesButton addTarget:self action:@selector(selectedFilesPress) forControlEvents:UIControlEventTouchUpInside];
    [selectedFilesButton setBackgroundImage:whiteBoxImage forState:UIControlStateNormal];
    [selectedFilesButton setExclusiveTouch:YES];
    _selectedFilesBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:selectedFilesButton];
    [self updateSelectedFilesButtonNumber];
    
    
    //Unselect button
    HighlightButton* unselectButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [unselectButton addTarget:self action:@selector(unselectButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [unselectButton setImage:[UIImage imageNamed:[AppConstants unselectXStringIdentifier]] forState:UIControlStateNormal];
    [unselectButton setExclusiveTouch:YES];
    _unselectBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:unselectButton];
    
    //Separator
    HighlightButton* separatorButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 6, unselectButton.frame.size.height*.75)];
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [AppConstants fadedWhiteColor].CGColor;
    sublayer.frame = CGRectMake((separatorButton.bounds.size.width - 1)/2, 0, 1, separatorButton.frame.size.height);
    [separatorButton.layer addSublayer:sublayer];
    [separatorButton setUserInteractionEnabled:NO];
    _separatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:separatorButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:_selectedFilesBarButtonItem, nil]];
    
    //Navigation bar setup - Right Bar Button Items
    [self setNavigationItemToImage:[AppConstants envoyNavStringIdentifier]];
    _collectionViewBackButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 20, 24)];
    [_collectionViewBackButton addTarget:self action:@selector(didPressCollectionViewBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants settingsStringIdentifier]] forState:UIControlStateNormal];
    [_collectionViewBackButton setExclusiveTouch:YES];
    _collectionViewBackBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_collectionViewBackButton];
    [self.navigationItem setLeftBarButtonItem:_collectionViewBackBarButtonItem];
    [self.navigationItem setRightBarButtonItem:_selectedFilesBarButtonItem];
    
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
    _addButtonIsCurrentlySendButton = NO;
    _transitioningToSendLinkButton = NO;
    
    //Make room for selectUnselectButton
    _homeFileCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 80 + _fileOptionsToolbar.frame.size.height, 0);
    
    // Filesystem initialization
    [_homeFileCollectionView setDelegate:self];
    [_homeFileCollectionView setDataSource:self];
    _homeFileCollectionView.allowsMultipleSelection = YES;
    
    _inboxManager = [InboxManager sharedInboxManager]; /*TEST*/
    _localStorageManager = [[LocalStorageManager alloc] init];
    
    // DBServiceManager initialization
    _dbServiceManager = [[DBServiceManager alloc] init];
    _gdServiceManager = [[GDServiceManager alloc] init];
    
    _dbServiceManager.dbServiceManagerDelegate = self;
    _gdServiceManager.gdServiceManagerDelegate = self;
    
    _arrayForFoldersToDisplay = [[NSMutableArray alloc]init];
    _arrayForNonFoldersToDisplay = [[NSMutableArray alloc]init];
    
    _dbServiceManager.reloadCollectionViewProgressDelegate = self;
    _gdServiceManager.reloadCollectionViewProgressDelegate = self;
    //_bxServiceManager.reloadCollectionViewProgressDelegate = self;
    //ALSO set teh delegate for bx service manager
    
    //Swipe Back button & swipe to send Gesture Recognizers
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didRightSwipe)];
    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [_homeFileCollectionView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    [_emptyMessageScrollView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    _rightSwipeGestureRecognizer = rightSwipeGestureRecognizer;
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectedFilesPress)];
    [leftSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [_emptyMessageScrollView.panGestureRecognizer requireGestureRecognizerToFail:leftSwipeGestureRecognizer];
    [_homeFileCollectionView.panGestureRecognizer requireGestureRecognizerToFail:leftSwipeGestureRecognizer];
    _leftSwipeGestureRecognizer = leftSwipeGestureRecognizer;

    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.minimumPressDuration = .35; //seconds
    longPressRecognizer.delegate = self;
    [_homeFileCollectionView addGestureRecognizer:longPressRecognizer];
    
    [[self fsInit] cleanFileSystem];
    
    if([[self fsInit] fileSystemRootExists]){
        [[self fsInit] addThreeRootCloudFilesToCurrentDirectory];
    } else {
        [[self fsInit] addFourRootFilesToCurrentDirectory];
    }
    
    // populate the colelction view after we init it
    [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
    
    //split the newly populated current directory into
    //folders and non folders arrays for ordering
    //during the display
    [self splitFoldersAndReloadCollectionView];
    
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
                                          selector:@selector(splitFoldersAndReloadCollectionView)
                                          name:@"reloadHomeCollectionViewNotification"
                                          object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(splitFoldersAndDontReloadCollectionView)
                                          name:@"splitFoldersAndDontReloadCollectionView"
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
                                          selector:@selector(showCollectionViewFromGDLoadCancel)
                                          name:@"showCollectionViewFromGDLoadCancel"
                                          object:nil];

    //reorganize the index paths after adding a folder/moving a file/folder
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reorganizeIndexPathsFromNotification)
                                                 name:@"reorganizeIndexPathsFromNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCollectionViewMessageForTimeout)
                                                 name:@"updateCollectionViewMessageForTimeout"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCollectionViewMessageForUnspecifiedError)
                                                 name:@"updateCollectionViewMessageForUnspecifiedError"
                                               object:nil];
    
//    NSData *data = [@"11. ザ･ミステリアス.mp3" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//    NSString *sanitizedText = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
//    NSLog(@"COOOKOOOLLLOOO%@",sanitizedText);
    
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

-(FileSystemFunctions*) fsFunctions{
    
    if(!_fsFunctions){
        _fsFunctions = [FileSystemFunctions sharedFileSystemFunctions];
    }
    return _fsFunctions;
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


//reorganize index paths after file name, folder creation, file move
-(void) reorganizeIndexPathsFromNotification {
    [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:[[NSMutableIndexSet alloc] init]];
}

#pragma mark DBServiceManagerDelegate

-(void) dbCreateFileLoadingObjectWithFile:(File *)file andReduceStack:(NSString*)reduceStackToPath{
        
    // basically build a dummy model of where the files are to preoperly grab the index path for that file loading object.
    NSMutableArray* foldersArray = [[NSMutableArray alloc] init];
    NSMutableArray* nonFoldersArray = [[NSMutableArray alloc] init];
    
    //populate dummy current directory
    NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
    [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy  inDirectoryPath:reduceStackToPath];
    
    for(File* file in currentDirProxy){
        if(file.isDirectory){
            [foldersArray addObject:file];
        }else{
            [nonFoldersArray addObject:file];
        }
    }
    
    foldersArray = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:foldersArray] copyItems:YES];
    nonFoldersArray = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:nonFoldersArray] copyItems:YES];
    
    //create the file loading object.
    NSIndexPath* indexPathForFile = [NSIndexPath indexPathForRow:([nonFoldersArray indexOfObject:file]+[foldersArray count]) inSection:0];
    FileLoadingObject* flobjtemp = [[FileLoadingObject alloc] initWithFile:file andProgress:0.0 andOldProgress:0.0 andIndexPath:indexPathForFile oldReduceStack:reduceStackToPath];
    dispatch_sync(_fileLoadingObjectsQueue, ^{
        [[[self fsAbstraction] arrayForLoadObjects] addObject:flobjtemp];
        [[[self fsAbstraction] arrayForLoadingFiles] addObject:file];
    });
    //We will need a more general verison of reorganize here. or not? because the index paths will auto fix on progress events?
}

//method triggered from the db service manager
//that perfroms upload once we've checked/created
//the necessary recipient folder up in teh cloud

-(void) uploadAfterCreatingUploadFolderDBWithOriginallySelectedFiles:(NSMutableArray *)originallySelectedFiles{
    // MASSIVE FUCKING NOTE TO SELF. DO NOT pass storedReduceStackToPath in like so:
    // DO NOT -> @"/Dropbox/Envoy Uploads" do this [@"/Dropbox" stringByAppendingPathComponent:@"Envoy Uploads"]
    [_dbServiceManager prepareToSaveFilesExportedFromOther:originallySelectedFiles calledFromInbox:NO storedReduceStackToPath:[@"/Dropbox" stringByAppendingPathComponent:@"/Envoy Uploads"] andMoveToDB:YES andMovedFromDB:NO];
}

-(void) dbUnselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath{
    
    HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
    [cell.cellImageSelected setHidden:YES];
    [cell.cellImage setHidden:NO];
}

#pragma mark GDServiceManagerDelegate

-(void) gdCreateFileLoadingObjectWithFile:(File *)file andReduceStack:(NSString*)reduceStackToPath{
    
    // basically build a dummy model of where the files are to preoperly grab the index path for that file loading object.
    NSMutableArray* foldersArray = [[NSMutableArray alloc] init];
    NSMutableArray* nonFoldersArray = [[NSMutableArray alloc] init];
    
    //populate dummy current directory
    NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
    [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy  inDirectoryPath:reduceStackToPath];
    
    for(File* file in currentDirProxy){
        if(file.isDirectory){
            [foldersArray addObject:file];
        }else{
            [nonFoldersArray addObject:file];
        }
    }
    
    foldersArray = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:foldersArray] copyItems:YES];
    nonFoldersArray = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:nonFoldersArray] copyItems:YES];
    
    //create the file loading object.
    NSIndexPath* indexPathForFile = [NSIndexPath indexPathForRow:([nonFoldersArray indexOfObject:file]+[foldersArray count]) inSection:0];
    FileLoadingObject* flobjtemp = [[FileLoadingObject alloc] initWithFile:file andProgress:0.0 andOldProgress:0.0 andIndexPath:indexPathForFile oldReduceStack:reduceStackToPath];
    dispatch_sync(_fileLoadingObjectsQueue, ^{
        [[[self fsAbstraction] arrayForLoadObjects] addObject:flobjtemp];
        [[[self fsAbstraction] arrayForLoadingFiles] addObject:file];
    });
    //We will need a more general verison of reorganize here. or not? because the index paths will auto fix on progress events?
}

//method triggered from the db service manager
//that perfroms upload once we've checked/created
//the necessary recipient folder up in teh cloud
-(void) uploadAfterCreatingUploadFolderGDWithOriginallySelectedFiles:(NSMutableArray *)originallySelectedFiles{
    [_gdServiceManager prepareToSaveFilesExportedFromOther:[[NSMutableArray alloc] initWithArray:originallySelectedFiles] calledFromInbox:NO storedReduceStackToPath:[@"/GoogleDrive" stringByAppendingPathComponent:@"/Envoy Uploads"] andMoveToGD:YES andMovedFromGD:NO];
}

-(void) gdUnselectHomeCollectionViewCellAtIndexPath:(NSIndexPath*)indexPath{
    HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
    [cell.cellImageSelected setHidden:YES];
    [cell.cellImage setHidden:NO];
}

#pragma mark IndexPathReOrganizationMethods

-(void) reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:(NSMutableIndexSet*)fileLoadingIndiciesToRemove{
    
    //I understand here we don't need to do a loop
    //for some of these but I did to keep the code consistent
    //with teh code for stopping the download on multiple files
    //at once !
    
    [self splitFoldersAndReloadCollectionView];
    
    //get the file loading object we're about to remove
    //so we can reset the alpha of its index path so that
    //the cell doesn't appear to be see through in other
    //directories when the cell gets re-used.
    NSArray* fileLoadingObjectsToRemove = [[[self fsAbstraction] arrayForLoadObjects] objectsAtIndexes:fileLoadingIndiciesToRemove];
    
    // send the things to be removed to the GD Service Manager and the DB Service Manager to be removed.
    // from the DBOperations / GDOperations queues
    
    [_gdServiceManager destroyGDOperationsWithFilePaths:fileLoadingObjectsToRemove];
    [_dbServiceManager destroyDBOperationsWithFilePaths:fileLoadingObjectsToRemove];
    
    //actually remove the fileLoadingObjects
    [[[self fsAbstraction] arrayForLoadObjects] removeObjectsAtIndexes:fileLoadingIndiciesToRemove];
    [[[self fsAbstraction] arrayForLoadingFiles] removeObjectsAtIndexes:fileLoadingIndiciesToRemove];
    
    for(FileLoadingObject* flObjToRemove in fileLoadingObjectsToRemove){
        HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:flObjToRemove.indexpath];
        [cell.cellImage setAlpha:1.0];
    }
    
    dispatch_sync(_fileLoadingObjectsQueue, ^{
        
        NSMutableIndexSet* indiciesToReplace = [[NSMutableIndexSet alloc] init];
        NSMutableArray* objectsToInsert = [[NSMutableArray alloc] init];
        
        for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
            
            NSIndexPath* indexPathForFile = [NSIndexPath indexPathForRow:([[self arrayForNonFoldersToDisplay] indexOfObject:fileLoadingObject.file]+[[self arrayForFoldersToDisplay] count]) inSection:0];

            //create a new file opject with updated percent download for the matching path
            //it has the index path of the old object
            FileLoadingObject* flobjtemp = [[FileLoadingObject alloc] initWithFile:[[[self fsAbstraction] arrayForLoadingFiles] objectAtIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]] andProgress:fileLoadingObject.progress andOldProgress:fileLoadingObject.oldProgress andIndexPath:indexPathForFile oldReduceStack:fileLoadingObject.originalReducedStack];
            [objectsToInsert addObject:flobjtemp];
            [indiciesToReplace addIndex: [[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]];
            
        }
        
        [[[self fsAbstraction] arrayForLoadObjects] replaceObjectsAtIndexes:indiciesToReplace withObjects:objectsToInsert];
    });
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - NSNotificationCenter

//reload the collectionview on a dispatch async queue
-(void) splitFoldersAndReloadCollectionView{
    //first split the folders, then reload the collectionview.
    dispatch_sync(_splitFoldersQueue, ^{
        [self splitFoldersAndNonFolders];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [_homeFileCollectionView reloadData];
    });
}

//for recreating the split folder objects after the
//currenty directory is updated on google drive upload
//to make sure boxid fields (google unique identifiers)
//are properly set
-(void) splitFoldersAndDontReloadCollectionView{
    dispatch_sync(_splitFoldersQueue, ^{
        [self splitFoldersAndNonFolders];
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

-(void) showCollectionViewFromGDLoadCancel{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants settingsStringIdentifier]] forState:UIControlStateNormal];
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

-(void) updateCollectionViewMessageForTimeout{
    [_collectionViewActivityIndicator stopAnimating];
//    _emptyCollectionMessage.text = @"There was an internet error!";
    _emptyCollectionMessage.text = @"Bah! Couldn't reach the service.";
}

-(void) updateCollectionViewMessageForUnspecifiedError{
    [_collectionViewActivityIndicator stopAnimating];
    _emptyCollectionMessage.text = @"There was some mystical unspecified error!";
}

//triggered after e return from a send operation,
//clears out all the selected files and reload collectionview.
-(void)emptyFilesAndDismissOnSend {
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    [[self fsAbstraction] removeAllObjectsFromFilesToSendArray];
    [self splitFoldersAndReloadCollectionView];
}

//will move to parent
//remove view from superview
//remvoe child controller from the parent.

-(void) returnToRootDirectory {
    
    //Fix for pressing add button or toolbar 
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];

    //set our nav identifier as the proper envoy logo.
    [self setNavigationItemToImage:[AppConstants envoyNavStringIdentifier]];
    
    //clean the file system when the user auto jumps back into the home directory
    dispatch_sync(_fileLoadingObjectsQueue, ^{
        [[self fsInit] cleanFileSystemExceptFiles:[[self fsAbstraction] arrayForLoadingFiles]];
    });
    
    while(![[[self fsAbstraction] reduceStackToPath] isEqualToString:@"/"]){
        [[self fsAbstraction] popDirectoryOffPathStack];
    }
    //Send a notification to update the toolbar once we've pushed.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
    
    [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
    //show the collection view again
    [self showCollectionView];
    //send a message to dropbox/googledrive/box to cancel their navigationary loads
    [_gdServiceManager cancelNavigationLoad];
    [_dbServiceManager cancelNavigationLoad];
    //split the newly populated current directory into
    //folders and non folders arrays for ordering
    //during the display
    [self splitFoldersAndReloadCollectionView];
}

#pragma mark - reloadCollectionViewProgressDelegate

// this is a delegate method that comes from services managers that tells the collection view to reload
// a cell with a certain load progress.

-(void) reloadCollectionViewFilePath:(NSString*)destinationPath withProgress:(CGFloat)percentDownloaded withReduceStack:(NSString*)oldReducedStack{
    
    // loop through the files in the current directory (foldersToDisplay and nonFoldersToDisplay)
    // and add a loading file object
    // for a file path that does not yet exist as a record in our arrayofLoadobjects
    // knowing whther a file is already in array of load objects is performed by a
    // second array which just stores a list fo the files we touched, I opted for
    // this over putting a loop inside, the loop.
    
    for(File* fileToReload in [self arrayForFoldersToDisplay]){
        
        NSIndexPath* indexPathForFile = [NSIndexPath indexPathForRow:[ [self arrayForNonFoldersToDisplay] indexOfObject:fileToReload] inSection:0];
        
        dispatch_sync(_fileLoadingObjectsQueue, ^{

            FileLoadingObject* flobj = [[FileLoadingObject alloc] initWithFile:fileToReload andProgress:percentDownloaded andOldProgress:percentDownloaded andIndexPath:indexPathForFile oldReduceStack:oldReducedStack];
            
            if ([fileToReload.path isEqualToString:[[self fsInterface]resolveFilePath:destinationPath excludingUpToDirectory:@"Documents"]] && ![[[self fsAbstraction] arrayForLoadingFiles] containsObject:fileToReload]){
                
                //array for load progress is needed because
                //we use it in if statements to avoid writing more loops
                //loops confusing, contains not.
                //do not delete the array for load progress you fool
                [[[self fsAbstraction] arrayForLoadingFiles] addObject:fileToReload];
                [[[self fsAbstraction] arrayForLoadObjects] addObject:flobj];
            }
        });
    }
    
    for(File* fileToReload in  [self arrayForNonFoldersToDisplay]){
        
        NSIndexPath* indexPathForFile = [NSIndexPath indexPathForRow:([[self arrayForNonFoldersToDisplay] indexOfObject:fileToReload]+[[self arrayForFoldersToDisplay] count]) inSection:0];
        
        dispatch_sync(_fileLoadingObjectsQueue, ^{

            FileLoadingObject* flobj = [[FileLoadingObject alloc] initWithFile:fileToReload andProgress:percentDownloaded andOldProgress:percentDownloaded andIndexPath:indexPathForFile oldReduceStack:oldReducedStack];
            
            if ([fileToReload.path isEqualToString:[[self fsInterface]resolveFilePath:destinationPath excludingUpToDirectory:@"Documents"]] && ![[[self fsAbstraction] arrayForLoadingFiles] containsObject:fileToReload]){
                
                //array for load progress is needed because
                //we use it in if statements to avoid writing more loops
                //loops confusing, contains not.
                //do not delete it you fool
                [[[self fsAbstraction] arrayForLoadingFiles] addObject:fileToReload];
                [[[self fsAbstraction] arrayForLoadObjects] addObject:flobj];
            }
        });
    }
    
    // This loop just goes through the old entries and updates their percentage
    // progress if it's the one we're updating right now.
    
    // iterate through a copy of the array.
    dispatch_sync(_fileLoadingObjectsQueue, ^{
        
        for(FileLoadingObject* flObj in [[NSMutableArray alloc]initWithArray:[[self fsAbstraction] arrayForLoadObjects]]){
            
            //this if statement should only trigger once on any one loop run.
            //this probably means we could do this without a loop...
            //yeah these arrays should just be dictionaries indexed by path?(maybe that's worse), that will
            //make this an O(1) operation from O(n)
            if([flObj.file.path isEqualToString:[[self fsInterface]resolveFilePath:destinationPath excludingUpToDirectory:@"Documents"]]){
                
                //get the new indexPath for the file represented by the fileLoadingObject being udated.
                NSIndexPath* indexPathForFile = [NSIndexPath indexPathForRow:([[self arrayForNonFoldersToDisplay] indexOfObject:flObj.file]+[[self arrayForFoldersToDisplay] count]) inSection:0];
                
                //create a new file opject with updated percent download for the matching path
                //it has the index path of the old object
                FileLoadingObject* flobjtemp = [[FileLoadingObject alloc] initWithFile:[[[self fsAbstraction] arrayForLoadingFiles] objectAtIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:flObj]] andProgress:percentDownloaded andOldProgress:flObj.progress andIndexPath:indexPathForFile oldReduceStack:flObj.originalReducedStack];

                // add this new object to the array where the old one was.
                [[[self fsAbstraction] arrayForLoadObjects] replaceObjectAtIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:flObj] withObject:flobjtemp];
               

                //if the index path exists, we're looking at the file (the current directory contains it)
                // and if either we're in the directory we pressed PASTE in or in a subdirectory of it
                // then we reload the index path of the thing we want to watch.
                
                if(flobjtemp.indexpath && [[[self fsAbstraction] currentDirectory] containsObject:flobjtemp.file] && (
        
                   [[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:flObj.originalReducedStack]
                    
                   ||
                   
                   [[[self fsAbstraction] reduceStackToPath] isEqualToString:flObj.originalReducedStack])){
            
                        //added this onto a async main queue to try
                        //to solve the issue where we had to renavigate
                        //to get the image changing animation to show
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:flobjtemp.indexpath];
                            
                            [cell.cellImage setImage:[self getUpdatedImageFromPercent:flobjtemp.progress andFile:flobjtemp.file]];
                            
                            if(flobjtemp.progress >= 1.0){
                                
                                // if we're looking at it and it's an image and its in local set the file icons to the images
                                if ([self isFileAnImage:flobjtemp.file.name] && [[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]) {
                                    
                                    //Animation for ALPHA values
                                    [UIView animateWithDuration:.25
                                                          delay:0
                                                        options:UIViewAnimationOptionCurveEaseInOut
                                                     animations:^(){
                                                         [cell.cellImage setAlpha:1.0];
                                                         [cell.cellImageSelected setAlpha:1.0];
                                                     }
                                                     completion:nil];
                                    
                                    //Animation for CELLIMAGE
                                    [UIView transitionWithView:cell.cellImage
                                                      duration:.25
                                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                                    animations:^{
                                                        cell.cellImage.image = [self getImageForCellFromPath:flobjtemp.file.path];
                                                    } completion:nil];
                                    
                                    //Animation for CELLIMAGESELECTED
                                    [UIView transitionWithView:cell.cellImageSelected
                                                      duration:.25
                                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                                    animations:^{
                                                        cell.cellImageSelected.image = [self getImageForCellFromPath:flobjtemp.file.path];
                                                        [cell.cellImageSelected.layer setBorderWidth:3.0];
                                                        cell.cellImageSelected.layer.borderColor = [UIColor colorWithRed:214.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0].CGColor;
                                                    } completion:nil];
                                } else {
                                    //if wer'e done downloading we want to
                                    //remove the file from the file loading objects array
                                    //and its analogous object in the loadprogress array
                                    //(the array w/ file objects)
                                    //and set the alpha to normal
                                    //and update the options toolbar
                                    [cell.cellImage setImage:[self assignIconForFileType:flobjtemp.file isSelected:NO]];
                                    
                                    //Animation for ALPHA values
                                    [UIView animateWithDuration:.25
                                                          delay:0
                                                        options:UIViewAnimationOptionCurveEaseInOut
                                                     animations:^(){
                                                         [cell.cellImage setAlpha:1.0];
                                                         [cell.cellImageSelected setAlpha:1.0];
                                                     }
                                                     completion:nil];
                                }

                                //update the toolbar when a file finishes downloading
                                //to switch from a cancel button to a normal toolbar
                                [self updateFileOptionsToolbar];
                            }
                        });
                }
                if(flobjtemp.progress >= 1.0){
                    [[[self fsAbstraction] arrayForLoadingFiles] removeObjectAtIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:flobjtemp]];
                    [[[self fsAbstraction] arrayForLoadObjects] removeObject:flobjtemp];
                }
            }
        }
        
    });
}

/* geta new image for a collectionview cell by cropping the fully loaded image
and the empty file image and combinging thme*/

-(UIImage*) getUpdatedImageFromPercent:(CGFloat)sliceImagePercent andFile:(File*) file{
    
    UIImage* redImage = [self assignIconForFileType:file isSelected:YES];;
    UIImage* whiteImage = [self assignIconForFileType:file isSelected:NO];
    //create a CG rect of the
    
    //this is the height from the bottom where we actually start to see color on our icon,
    //cna be checked in photoshop
    CGFloat cropceiling = 200;
    
    // in onyl want to crop a fraction of the pxiels from 65 down to 325down. or 260 pixels
    //for the white image our starting point is the top left corner.
    // so basically trying to describe this is hard, but:
    // the y height changes as a function of the 1-sliceImage percent, sliceimage percent is
    // just the % we've downloaded, so if we've downloaded 5% we will multiply our remaining
    // (picture hieight - the starting offset) (the bottom black bar) by the 0.95.
    // over time the 65px becomes more and more weighted (as sliceImagePercent grows), to the point where 65 px
    // from the top is our stopping point.
    // the amount we crop is the second two parameters, width is just the image width,
    // height changes as the slice image percent grows we crop more and more.
    CGRect clippedRectRed  = CGRectMake(0.0,//starting refence x
                                        ((redImage.size.height-cropceiling) * (1-sliceImagePercent))+(65*sliceImagePercent), //starting reference y
                                        redImage.size.width, //with of our crop section
                                        (redImage.size.height - (redImage.size.height * (1-sliceImagePercent)))+cropceiling); //height of our crop section.
    
    CGImageRef croppedRedImgRef = CGImageCreateWithImageInRect([redImage CGImage], clippedRectRed);
    UIImage *croppedRedImg  = [UIImage imageWithCGImage:croppedRedImgRef];
    CGImageRelease(croppedRedImgRef);
    
    CGSize size = CGSizeMake(redImage.size.width, redImage.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    [whiteImage drawInRect:CGRectMake(0, 0, whiteImage.size.width, whiteImage.size.height)];
    [croppedRedImg drawInRect:CGRectMake(0, redImage.size.height - croppedRedImg.size.height, croppedRedImg.size.width, croppedRedImg.size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

#pragma mark - Dropbox Registration/Auth Cancelled, need to reload

// when the user cancels their dropbox
// registration we need to pop dropbox off
// the stack, reload the collectionview, and
// make sure the collectionview is visible again
-(void) reloadAfterCloudCancel{
    [self setNavigationItemToImage:[AppConstants envoyNavStringIdentifier]];
    [self splitFoldersAndReloadCollectionView];
    [self showCollectionView];
}

#pragma mark - SelectedFilesViewControllerDelegate

// important interaction with the sendView controller delegate.
-(void) selectedFileViewPoppedOff {
    [self splitFoldersAndReloadCollectionView];
}

//#pragma mark ZipArchiveTestDelegate
//
//- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(unz_file_info)fileInfo
//{
//    NSLog(@"FILE INDEX: %ld", (long)fileIndex);
//    NSLog(@"TOTLAE FILES: %ld", totalFiles);
//    NSLog(@"ARCHIVE PATH: %@", archivePath);
//}
//
//- (void)zipArchiveWillUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(unz_file_info)fileInfo{
//    
//    NSLog(@"FILE INDEX: %ld", (long)fileIndex);
//    NSLog(@"TOTLAE FILES: %ld", totalFiles);
//    NSLog(@"ARCHIVE PATH: %@", archivePath);
//}

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
    if(![@"/" isEqualToString:[[self fsAbstraction] reduceStackToPath]] && [@"/" isEqualToString:[[[self fsAbstraction] reduceStackToPath] stringByDeletingLastPathComponent]] && !_currentlyLoadingCollectionViewAndHidden){
        
        dispatch_sync(_fileLoadingObjectsQueue, ^{
            
            [self setNavigationItemToImage:[AppConstants envoyNavStringIdentifier]];
            [[self fsInit] cleanFileSystemExceptFiles:[[self fsAbstraction] arrayForLoadingFiles]];
            
        });
    //else if we're in the root we just want to reset the nav
    //and not clean the filesystem.
    //this solved a bug where navigating to settings, then
    //and then navigating to home and then navigating to selected
    //and then home again wiped the currentDirectory and displayed nothing
    //in home.
    } else if([@"/" isEqualToString:[[self fsAbstraction] reduceStackToPath]] && _currentlyLoadingCollectionViewAndHidden){
        [self setNavigationItemToImage:[AppConstants envoyNavStringIdentifier]];
    }
    
    //if we're in the root and we're not currently loading the cloud, then go to settings.
    if([@"/" isEqualToString:[[self fsAbstraction] reduceStackToPath]] && !_currentlyLoadingCollectionViewAndHidden){
        [self performSegueWithIdentifier:@"home-to-settings" sender:self];
        
    // send notificaitons to reload and pop teh pushed directory.
    } else if([@"/" isEqualToString:[[self fsAbstraction] reduceStackToPath]] && _currentlyLoadingCollectionViewAndHidden){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxLoadCancelledByBackButtonPress" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"googledriveLoadCancelledByBackButtonPress" object:self];
        
    //otherwise go to the cloud and change the settings button
    } else {
        //solved a bug on the collectionview where if we pressed a back button while it was loading
        //things would break (like popping back up an extra level because we hadn't pushed yet for cloud navigation)
        if([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Dropbox"] && _currentlyLoadingCollectionViewAndHidden){
            
            [self setNavigationItemToImage:[AppConstants dropboxNavStringIdentifier]];
            [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxLoadCancelledByBackButtonPress" object:self];
            //reloads and splits files
            [self splitFoldersAndReloadCollectionView];
            [self showCollectionView];

        } else if([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"GoogleDrive"] && _currentlyLoadingCollectionViewAndHidden){
            
            [self setNavigationItemToImage:[AppConstants googleDriveNavStringIdentifier]];
            [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"googledriveLoadCancelledByBackButtonPress" object:self];
            //reloads and splits files
            [self splitFoldersAndReloadCollectionView];
            [self showCollectionView];

            
        } else {
            [[self fsAbstraction] popDirectoryOffPathStack];
            // send a notification to update the toolbar once we've pushed.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
            
            [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
            //reloads and splits files
            [self splitFoldersAndReloadCollectionView];
            [self showCollectionView];

        }
    }
}

-(void)didRightSwipe {
    if(![@"/" isEqualToString:[[self fsAbstraction] reduceStackToPath]] || _currentlyLoadingCollectionViewAndHidden)
        [self didPressCollectionViewBackButton:self];
}

-(void) selectedFilesPress {
    [KxMenu dismissMenu];
    [self performSegueWithIdentifier:@"home-to-selectedFiles" sender:self];
}

-(void)unselectButtonPress: (UIButton*)sender {
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    [self unselectAllCellImages];
}

//handles the long press event of a user.
-(void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    //Dismiss any popup menu if one currently shown
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:_homeFileCollectionView];
        NSIndexPath *indexPath = [_homeFileCollectionView indexPathForItemAtPoint:p];
        
        if (indexPath == nil){
            NSLog(@"%s COULDN'T FIND INDEX PATH IN handleLongPress", __PRETTY_FUNCTION__);
        }else{
            //in the future this long press event for a non-folder file
            //will open a viewer, it will not select the file.
            [self resolveSelectionOfFilesWithIndexPath:indexPath];
        }
    }
}

//get images / movies coming from the photo library and camera roll

- (void) elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    
    NSInteger numObjects = [info count];
    NSOperationQueue *imagePickerQueue = [[NSOperationQueue alloc] init];
    imagePickerQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    
    for(NSDictionary* infoobject in info){
        
        [imagePickerQueue addOperationWithBlock:^{
        
            // - UIImagePickerControllerMediaType not used - //
            NSString* fileInfo = [[infoobject objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
            NSString *uniqueFileCode = [fileInfo substringWithRange:NSMakeRange(36, 36)];
            NSString *fileExtension = [fileInfo substringWithRange:NSMakeRange(77,3)];
            
            NSString  *path = [[[self fsAbstraction] reduceStackToPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", uniqueFileCode, fileExtension]];
            
            // - as far as I know these are the only two image representations supported from the iOS photo library - //
            // - this performes the PHYSICAL WRITE to the disk for this image file. - //
            if([[fileExtension lowercaseString] isEqualToString:@"jpg"]){
                
                NSString* queryPath = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:
                                       
                                       [[[path stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       
                                       ];
                
                UIImage *image = [infoobject objectForKey:UIImagePickerControllerOriginalImage];
                [UIImageJPEGRepresentation(image, 1.0) writeToFile:queryPath atomically:YES];
            } else if([[fileExtension lowercaseString] isEqualToString:@"png"]){
                
                NSString* queryPath = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:
                                       
                                       [[[path stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       
                                       ];
                UIImage *image = [infoobject objectForKey:UIImagePickerControllerOriginalImage];
                [UIImagePNGRepresentation(image) writeToFile:queryPath atomically:YES];
            } else if ([[fileExtension lowercaseString] isEqualToString:@"mov"] || [[fileExtension lowercaseString] isEqualToString:@"mp4"] || [[fileExtension lowercaseString] isEqualToString:@"mpv"] || [[fileExtension lowercaseString] isEqualToString:@"3gp"]){
                NSString* queryPath = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:
                                       
                                       [[[path stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       
                                       ];
                
                ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
                [assetLibrary assetForURL:[infoobject objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(unsigned int)rep.size error:nil];
                    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
                    [data writeToFile:queryPath atomically:YES];//you can save image later
                } failureBlock:^(NSError *err) {
                    NSLog(@"Error: %@",[err localizedDescription]);
                }];
            }
            
            File* newPic = [[File alloc] initWithName:[NSString stringWithFormat:@"%@.%@", uniqueFileCode, fileExtension] andPath: [[[self fsAbstraction] reduceStackToPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", uniqueFileCode, fileExtension]] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:NO andBoxId:@"-1"];
            
            [[self fsInterface] saveSingleFileToFileSystemJSON:newPic inDirectoryPath:newPic.parentURLPath];
            
            // not 100% sure we will need this if statment, but I'll leave it here
            // jsut in case we decide on some weird implementation for adding
            // pictures we only want the user to relaod their collection view
            // if they are actually in that local directory.
            if( [[self fsInterface] filePath:newPic.path isLocatedInsideDirectoryName:newPic.parentURLPath]){
                
                [[[self fsAbstraction] currentDirectory] addObject:newPic];
            }
            
            if ([info indexOfObject:infoobject] == numObjects - 1) {
                // - for some reason we need to do this in dispatch, thesis is that somehow IO operations, and reloadData isn't working properly during these, putting it inside dispatch makes it thread safe.
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self splitFoldersAndReloadCollectionView];
                }];
            }
        }];
    }
}

- (void) elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

#pragma mark - PhotoAlbum methods

//basically a clone of the standard image picker in iOS,
//the only difference being that this one allows mutliple selection

-(void) summonPhotoLibrary{
    
    //create the album pciker and image picker
    //establish settings, set the delegates
    //for the elcpicker and the imagepicker
    //present the new view controller.
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
    elcPicker.returnsImage = YES;
    elcPicker.maximumImagesCount = 1000;
    elcPicker.imagePickerDelegate = self;
    elcPicker.delegate = self;
    elcPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, (NSString *) kUTTypeMovie, nil];
    [self presentViewController:elcPicker animated:YES completion:^(void){}];
}

//goes through our selected files and saves any
//that are on the disk to our phones camera roll/albums
-(void) saveSelectedPhotosToPhotoLibrary{
    NSArray* arrayToIterate = [[NSArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]];
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    [self unselectAllCellImages];
    for(File* potentialPhoto in arrayToIterate){
        if([self isFileAnImage:potentialPhoto.name]){
            UIImage* imageToSave = [self getImageForCellFromPath:potentialPhoto.path];
            [self savePictureToPhotoLibrary:imageToSave];
        }
    }
}

//wrapper to save a file to camera role

-(void) savePictureToPhotoLibrary:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [self alertUserToProblemUploadingToCamera:error];
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
    
    NSString* filename = file.name;
    NSString *fileExtension = [filename pathExtension];
    UIImage *image;
    fileExtension = [fileExtension lowercaseString];
    
    //if the file is selected
    if(selected){
        
        //if it's a directory
        if(file.isDirectory){
            
            //if it's a sepcial folder for downloads give it a special icon we made
            if([[self fsInterface] filePath:file.path  isLocatedInsideDirectoryName:@"Local"] && [file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"Local"]] && [filename isEqualToString:@"downloads"]){
                image = [UIImage imageNamed:[AppConstants folderDownloadsSelectedImageStringIdentifier]];
            //another special icon for sent to me
            } else if([[self fsInterface] filePath:file.path  isLocatedInsideDirectoryName:@"Local"] && [file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"Local"]] && [filename isEqualToString:@"sent to me"]){
                image = [UIImage imageNamed:[AppConstants folderSendsSelectedImageStringIdentifier]];
            
            //if we're in the cloud and we see the Envoy Uploads folder then set a special icon
            } else if (![[self fsInterface] filePath:file.path  isLocatedInsideDirectoryName:@"Local"] && ([file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"Dropbox"]]|| [file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"GoogleDrive"]]) && [filename isEqualToString:@"Envoy Uploads"]){
                image = [UIImage imageNamed:[AppConstants folderEnvoySelectedImageStringIdentifier]];
            //normal folder icon
            } else{
                image = [UIImage imageNamed:@"folder-sel"];
            }
        
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
            //if it's a special folder for downloads give it a specail icon
            if([[self fsInterface] filePath:file.path  isLocatedInsideDirectoryName:@"Local"] && [file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"Local"]] && [filename isEqualToString:@"downloads"]){
                image = [UIImage imageNamed:[AppConstants folderDownloadsImageStringIdentifier]];
            //another special
            } else if([[self fsInterface] filePath:file.path  isLocatedInsideDirectoryName:@"Local"] && [file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"Local"]] && [filename isEqualToString:@"sent to me"]){
                image = [UIImage imageNamed:[AppConstants folderSendsImageStringIdentifier]];
            //if we're in the cloud and we see the Envoy Uploads folder then set a special icon
            } else if(![[self fsInterface] filePath:file.path  isLocatedInsideDirectoryName:@"Local"] && ([file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"Dropbox"]]|| [file.parentURLPath isEqualToString:[@"/" stringByAppendingPathComponent:@"GoogleDrive"]]) && [filename isEqualToString:@"Envoy Uploads"]) {
                image = [UIImage imageNamed:[AppConstants folderEnvoyImageStringIdentifier]];
            //assign a normal file icon
            } else {
                image = [UIImage imageNamed:@"folder"];
            }
            
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

//gets an image for a cell.
//might have to do some resizing in future.

-(UIImage *) getImageForCellFromPath:(NSString*) filePath {
    
    //sanitize
    NSString* queryPath = [[[self fsInterface] getDocumentsDirectory] stringByAppendingPathComponent:
                           
                           [[[filePath stringByStandardizingPath] stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           
                           ];
    //make and return image
    return [AppConstants imageWithImage:[UIImage imageWithContentsOfFile:queryPath] scaledToFillSize:CGSizeMake(65.0, 64.0)];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    
    UINavigationController* navigationController = [self navigationController];
    //makes it so the name appears normally on the title of the preview
    controller.name = [controller.name stringByRemovingPercentEncoding];
    return navigationController;
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
    if([[[self fsAbstraction] reduceStackToPath] isEqualToString:@"/"]){
        
        //if were loading something, reload the collectionview to
        //have a back button, for when we navigate from home to
        //cloud and want to isntantly change the button
        if(_currentlyLoadingCollectionViewAndHidden){
            // Makes back button position consistent with other back buttons throughout app
            [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonStringIdentifier]] forState:UIControlStateNormal];
            CGRect buttonFrame = _collectionViewBackButton.frame;
            buttonFrame.size = CGSizeMake(20, 24);
            _collectionViewBackButton.frame = buttonFrame;
        } else {
            [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants settingsStringIdentifier]] forState:UIControlStateNormal];
            
            // Resets button size to accomodate settings icon
            CGRect buttonFrame = _collectionViewBackButton.frame;
            buttonFrame.size = CGSizeMake(24, 24);
            _collectionViewBackButton.frame = buttonFrame;
        }
        
        //check the order of the array, if it's
        //ordered problerly (all conditions met here)
        //then the array has been ordered based on the
        //system
        if(
           //if w'ere empty do nothing.
           ([_arrayForFoldersToDisplay count] != 0)
           &&
           [((File*)[_arrayForFoldersToDisplay objectAtIndex:0]).name isEqualToString:@"Local"]
           &&
           [((File*)[_arrayForFoldersToDisplay objectAtIndex:1]).name isEqualToString:@"GoogleDrive"]
           &&
           [((File*)[_arrayForFoldersToDisplay objectAtIndex:2]).name isEqualToString:@"Dropbox"]
           ){
            //swap google drive with dropbox to put dropbox in the middle
            [_arrayForFoldersToDisplay exchangeObjectAtIndex:1 withObjectAtIndex:2];
            
        } else if(
            //if w'ere empty do nothing.
            ([_arrayForFoldersToDisplay count] != 0)
            &&
            [((File*)[_arrayForFoldersToDisplay objectAtIndex:0]).name isEqualToString:@"Local"]
            &&
            [((File*)[_arrayForFoldersToDisplay objectAtIndex:1]).name isEqualToString:@"Dropbox"]
            &&
            [((File*)[_arrayForFoldersToDisplay objectAtIndex:2]).name isEqualToString:@"GoogleDrive"]
            ) {
            
            //do nothing WE ARE PROPERLY ORDERED WOOOOOO
            
        }else {// if the ordering is not right, reverse the ordering and then do the swap.
            NSArray* reversedArray = [[_arrayForFoldersToDisplay reverseObjectEnumerator] allObjects];
            [_arrayForFoldersToDisplay removeAllObjects];
            [_arrayForFoldersToDisplay addObjectsFromArray:reversedArray];
            [_arrayForFoldersToDisplay exchangeObjectAtIndex:1 withObjectAtIndex:2];
        }
        
    } else {
        [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonStringIdentifier]] forState:UIControlStateNormal];
        
        // Makes back button position consistent with other back buttons throughout app
        CGRect buttonFrame = _collectionViewBackButton.frame;
        buttonFrame.size = CGSizeMake(20, 24);
        _collectionViewBackButton.frame = buttonFrame;
        
        //get a file or folder to check the path
        File* lastFileOrFolder;
        if([_arrayForNonFoldersToDisplay count] > 0){
            lastFileOrFolder = [_arrayForNonFoldersToDisplay lastObject];
        }else{
            lastFileOrFolder = [_arrayForFoldersToDisplay lastObject];
        }
        
        //NEXT TWO IFS MAKE CERTAIN FOLDERS STICKY AT THE TOP
        
        //if we're in local and the adjust indexes of "sent to me" and "downloads" folders to always appear at the front
        //we don't just want to check for /Local at the base of the path (why we don't use the resvoleFilePath in the
        //fs interface methods) we want to check the direct parent of this thing to be /Local
        if([lastFileOrFolder.parentURLPath isEqualToString:@"/Local"]){
            
            File* downloadFolder = [[File alloc] init];
            File* sentToMeFolder = [[File alloc] init];
            
            //set the temporary file pointer if it exists in current directory.
            for (File* fileToGrab in [[self fsAbstraction] currentDirectory]) {
                if([fileToGrab.path isEqualToString:@"/Local/sent to me"] && ([[[self fsAbstraction] currentDirectory] count]>1)){
                    sentToMeFolder = fileToGrab;
                }
                if([fileToGrab.path isEqualToString:@"/Local/downloads"]){
                    downloadFolder = fileToGrab;
                }
            }
            
            //if we contain both set downloads to be at index 0 and sent to me at index 1
            //guaruanteed because if 2 things are in the array then elements 0 and 1 will be there.
            if ([_arrayForFoldersToDisplay containsObject:sentToMeFolder] && [_arrayForFoldersToDisplay containsObject:downloadFolder]) {
                
                [_arrayForFoldersToDisplay exchangeObjectAtIndex:[_arrayForFoldersToDisplay indexOfObject:sentToMeFolder] withObjectAtIndex:1];
                [_arrayForFoldersToDisplay exchangeObjectAtIndex:[_arrayForFoldersToDisplay indexOfObject:downloadFolder] withObjectAtIndex:0];
                
            //if only sent to me is there put sent to me first.
            //guaruanteed to work because if it's in the array we know for sure element 0 is there.
            } else  if ([_arrayForFoldersToDisplay containsObject:sentToMeFolder]){
                
                [_arrayForFoldersToDisplay exchangeObjectAtIndex:[_arrayForFoldersToDisplay indexOfObject:sentToMeFolder] withObjectAtIndex:0];
                
            //if only downloads is around put downloads first.
            //guaruanteed to work because if it's in the array we know for sure element 0 is there.
            } else if ([_arrayForFoldersToDisplay containsObject:downloadFolder]) {
                
                [_arrayForFoldersToDisplay exchangeObjectAtIndex:[_arrayForFoldersToDisplay indexOfObject:downloadFolder] withObjectAtIndex:0];

            }//else if neither exist do nothing.

        }
        
        //if we're in local and the adjust indexes of "sent to me" and "downloads" folders to always appear at the front
        //we don't just want to check for /Local at the base of the path (why we don't use the resvoleFilePath in the
        //fs interface methods) we want to check the direct parent of this thing to be the opposite of /Local (a cloud folder)
        if([lastFileOrFolder.parentURLPath isEqualToString:@"/Dropbox"] || [lastFileOrFolder.parentURLPath isEqualToString:@"/GoogleDrive"]){
            
            File* envoyUploadsFolder = [[File alloc] init];
            
            //set the temporary file pointer if it exists in current directory.
            for (File* fileToGrab in [[self fsAbstraction] currentDirectory]) {

                if([fileToGrab.name isEqualToString:@"Envoy Uploads"]){
                    envoyUploadsFolder = fileToGrab;
                }
            }
            
            //if we contain both set downloads to be at index 0 and sent to me at index 1
            //guaruanteed to work because if it's in the array we know for sure element 0 is there.
            if ([_arrayForFoldersToDisplay containsObject:envoyUploadsFolder]) {
                
                [_arrayForFoldersToDisplay exchangeObjectAtIndex:[_arrayForFoldersToDisplay indexOfObject:envoyUploadsFolder] withObjectAtIndex:0];
                
            }//if it isn't in the array do nothing.
        }
    }
    
    //Shows Message to user if There are no files in current directory
    if ([[[self fsAbstraction] currentDirectory] count] == 0) {
        [_homeFileCollectionView setAlpha:0.0];
        _emptyCollectionMessage.text = @"Nothing Here";
    }
    else {
        [_homeFileCollectionView setAlpha:1.0];
    }
    return [[[self fsAbstraction] currentDirectory] count];
}

-(HomeCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeCollectionViewCell* cell;
    File* file;
    
    // if there's a folder to display we want to display that.
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    
    BOOL fileIsSelected = [[[self fsAbstraction] selectedFiles] containsObject:file];
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //Set File Cell Image
    if([[[self fsAbstraction] reduceStackToPath] isEqualToString:@"/"]){
        cell = [_homeFileCollectionView dequeueReusableCellWithReuseIdentifier:@"nonRootFileCell" forIndexPath:indexPath];
        
        [cell.cellImageSelected setHidden:YES];
        [cell.cellImage setHidden:NO];
        
        //Special images for root directory
        if ([file.parentURLPath isEqualToString:@"/"]) {
            if([file.name isEqualToString:@"Dropbox"]) {
                cell.cellImage.image = [UIImage imageNamed:@"dropbox"];
                cell.cellLabel.text = @"Dropbox";
            } else if([file.name isEqualToString:@"Box"]) {
                cell.cellImage.image = [UIImage imageNamed:@"box"];
                cell.cellLabel.text = @"Box";
            } else if([file.name isEqualToString:@"GoogleDrive"]) {
                cell.cellImage.image = [UIImage imageNamed:@"googledrive"];
                cell.cellLabel.text = @"Google Drive";
            } else {
                cell.cellImage.image = [UIImage imageNamed:@"local"];
                cell.cellLabel.text = @"Local";
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
        
        //Get rid of border from reusing cell
        [cell.cellImageSelected.layer setBorderWidth:0.0];
        
        if([self isFileAnImage:file.name] && [[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]){
            
            //TEMPORARY IMAGES
            cell.cellImage.image = [self assignIconForFileType:file isSelected:NO];
            cell.cellImageSelected.image = [self assignIconForFileType:file isSelected:YES];

            //set the cell image as the image for that file scaled to fit
            //so theres no distortion
            cell.cellImage.clipsToBounds = YES;
            cell.cellImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.cellImageSelected.contentMode = UIViewContentModeScaleAspectFill;
            cell.cellImageSelected.clipsToBounds = YES;
            cell.cellImageSelected.layer.masksToBounds = YES;
            [cell.cellImageSelected.layer setBorderWidth:3.0];
            cell.cellImageSelected.layer.borderColor = [UIColor clearColor].CGColor;
            
            __block BOOL fileIsALoadingFile = NO;
            
            dispatch_sync(_fileLoadingObjectsQueue, ^{
                for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]) {
                    if([file.path isEqualToString:fileLoadingObject.file.path]) {
                        fileIsALoadingFile = YES;
                    }
                }
            });
            
            NSString *previousDirectory = [[self fsAbstraction] reduceStackToPath];
            
            if (!fileIsALoadingFile) {
                if(fileIsSelected){
                    [cell.cellImageSelected setHidden:NO];
                    [cell.cellImage setHidden:YES];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        UIImage* imageForCell = [self getImageForCellFromPath:file.path];
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            //Animation for CELLIMAGESELECTED
                            [UIView transitionWithView:cell.cellImageSelected
                                              duration:.25
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{
                                                HomeCollectionViewCell *cellNow = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
                                                
                                                //Only load image if we haven't changed directory
                                                if([previousDirectory isEqualToString:[[self fsAbstraction] reduceStackToPath]]) {
                                                        cellNow.cellImage.image = imageForCell;
                                                        cellNow.cellImageSelected.image = imageForCell;
                                                        cellNow.cellImageSelected.layer.borderColor = [UIColor colorWithRed:214.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0].CGColor;
                                                }
                                            } completion:nil];
                        });
                    });
                }
                else {
                    [cell.cellImageSelected setHidden:YES];
                    [cell.cellImage setHidden:NO];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        UIImage* imageForCell = [self getImageForCellFromPath:file.path];
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            //Animation for CELLIMAGE
                            [UIView transitionWithView:cell.cellImage
                                              duration:.25
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{
                                                HomeCollectionViewCell *cellNow = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
                                                
                                                //Only load image if we haven't changed directory
                                                if ([previousDirectory isEqualToString:[[self fsAbstraction] reduceStackToPath]]) {
                                                        cellNow.cellImage.image = imageForCell;
                                                        cellNow.cellImageSelected.image = imageForCell;
                                                        cellNow.cellImageSelected.layer.borderColor = [UIColor colorWithRed:214.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0].CGColor;
                                                }
                                            } completion:nil];
                        });
                    });
                }
            }
        } else {
            cell.cellImage.image = [self assignIconForFileType:file isSelected:NO];;
            cell.cellImageSelected.image = [self assignIconForFileType:file isSelected:YES];
            
            if([[[self fsAbstraction] selectedFiles] containsObject:file]){
                [cell.cellImageSelected setHidden:NO];
                [cell.cellImage setHidden:YES];
            } else {
                [cell.cellImageSelected setHidden:YES];
                [cell.cellImage setHidden:NO];
            }
        }
    }
    
    //Set File Cell Text
    cell.cellLabel.text = file.name;
    cell.cellLabel.numberOfLines = 2;
    cell.cellLabel.preferredMaxLayoutWidth = 97.0;
    
    // if we're downloading a file and want to display a special file animation.
    // we produce the animation by croppying a red backlit file with a white baclit
    // file by the percentage the file has downloaded.
    
    //check to see if the file we just selected is a loading file, if it is
    //then make sure its alpha is set properly and its progress is set properly
    
    dispatch_sync(_fileLoadingObjectsQueue, ^{

        BOOL noFilesIntheViewWereLoadingFiles = YES;
        for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
            if([file.path isEqualToString:fileLoadingObject.file.path]){
                
                //Always show unselected image whether cell is selected or not
                [cell.cellImage setAlpha:0.40];
                [cell.cellImageSelected setAlpha:0.40];
                [cell.cellImage setHidden:NO];
                if (fileIsSelected) {
                    [cell.cellImageSelected setHidden:NO];
                }
                else {
                    [cell.cellImageSelected setHidden:YES];
                }
                
                noFilesIntheViewWereLoadingFiles = NO;
                    //added this onto a async main queue to try
                    //to solve the issue where we had to renavigate
                    //to get the image changing animation to show
                dispatch_async(dispatch_get_main_queue(), ^{
                    HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:fileLoadingObject.indexpath];
                    
                    [cell.cellImage setImage:[self getUpdatedImageFromPercent:fileLoadingObject.progress andFile:fileLoadingObject.file]];
                });
            }
        }
        //Needed reset of alpha for non-loading cells due to reuse of cells
        if(noFilesIntheViewWereLoadingFiles){
            [cell.cellImage setAlpha:1.0];
            [cell.cellImageSelected setAlpha:1.0];
        }
    });
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //Dismiss any popup menu if one currently shown
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
    
    //create a reachibility manager
    InternetManager* internetManager = [InternetManager reachabilityForInternetConnection];
    
    File* file;
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    
    if (file.isDirectory) {//navigate into a directory
        
        // - THE "pressedXFolder" should be separate and test for an absolute path that proves
        // - it is the dropbox/googledrive/ or box folder, otherwise and path where the word "Box"
        // - or "Dropbox" or "GoogleDrive" is a substring will trigger the authentication process.
        // - if we pressed the dropbox cell/folder icon in the collectionview at the root directory - //
        if([[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"Dropbox"]){
            
            //if the internet is reachable
            if ([internetManager isReachable]){
                // - check to make sure out account is registered, if it is not present registration - //
                [self setNavigationItemToImage:[AppConstants dropboxNavStringIdentifier]];
                [_dbServiceManager pressedDropboxFolder:self withFile:file shouldReloadMainView:YES];
                [self hideCollectionView];
            } else {
                [self alertUserToInternetNotAvailable];
            }
            
        }else if([[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"GoogleDrive"]){
            
            if ([internetManager isReachable]){
                [self setNavigationItemToImage:[AppConstants googleDriveNavStringIdentifier]];
                [_gdServiceManager pressedGoogleDriveFolder:self withFile:(File*)file shouldReloadMainView:YES andMoveToGD:NO];
                [self hideCollectionView];
            } else {
                [self alertUserToInternetNotAvailable];
            }
            
        }else{
            
            // - push file onto the stack, this is meant to be used on folders - //
            [[self fsAbstraction] pushOntoPathStack:file];
            
            // send a notification to update the toolbar once we've pushed.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
            
            //populate the current directory with the right files
            [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction]reduceStackToPath]];
            
//            //flat enumerate and clean garbage
//            int numfilescleaned = [[self fsInit] flatEnumerateAndCleanCorruptFilesOnNavigate:[[self fsAbstraction] reduceStackToPath] andCurrentDirectory:[[self fsAbstraction] currentDirectory]];
//            if (numfilescleaned != 0) {
//                [self alertUserToCleaningCorruptFiles:numfilescleaned];
//            }
            
            //if the file we've clicked on is inside the /Local directory
            if([[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"Local"]){
                [self setNavigationItemToImage:[AppConstants localNavStringIdentifier]];
            }else{
                [self setNavigationItemToImage:[AppConstants envoyNavStringIdentifier]];
            }
        }
        
        [self splitFoldersAndReloadCollectionView];
        
    } else { //select a non directory if we're not navigating into a directory
        [self resolveSelectionOfFilesWithIndexPath:indexPath];
    }
}

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //Dismiss any popup menu if one currently shown
    [KxMenu dismissMenu];
    [self performSelector:@selector(dismissKxMenuPopup) withObject:nil afterDelay:.1];
    
    File* file;
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    if (file.isDirectory) {
        
        // - push file onto the stack, this is meant to be used on folders - //
        [[self fsAbstraction] pushOntoPathStack:file];
        // send a notification to update the toolbar once we've pushed.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateToolbar" object:self];
        
        [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction]reduceStackToPath]];
        
        if([[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"Local"]){
            [self setNavigationItemToImage:[AppConstants localNavStringIdentifier]];
        }else{
            [self setNavigationItemToImage:[AppConstants envoyNavStringIdentifier]];
        }
        [self splitFoldersAndReloadCollectionView];
    } else {
        [self resolveSelectionOfFilesWithIndexPath:indexPath];
    }
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
    File* file;
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    
    BOOL fileIsSelected = [[[self fsAbstraction] selectedFiles] containsObject:file];
    
    //if we contain the file in selected files and the file is not a cloud or inbox(incoming) folder
    if(fileIsSelected && ![FileSystemInterface fileIsRootDirectory:file]){
        //Remove unselected file
        [[self fsAbstraction] removeObjectFromSelectedFiles:file];
        
    }else if(![FileSystemInterface fileIsRootDirectory:file]){
        
        //Fixes a visual hiccup with addSend button transition from send button to sendLink button
        //Due to multiple selectedFilesChanged notifications being sent out
        
        if (![[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"Local"]) {
            if ([[[self fsAbstraction] selectedFiles] count] > 0) {
                File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
                if (![[self fsInterface] filePath:singleSelectedFile.path isLocatedInsideDirectoryName:[FileSystemInterface getRootDirectoryOfFilePath:file.path]]) {
                    _transitioningToSendLinkButton = YES;
                }
            }
        }
        
        //Remove any selected files located in other services
        [self removeSelectedFilesFromAllServicesExcept:[FileSystemInterface getRootDirectoryOfFilePath:file.path]];
        
        //Add selected file
        [[self fsAbstraction] addObjectToSelectedFiles:file];
    }
    
    //deal w/ showing selected files in the collectionview, no deselection or selection logic, these are the visual effects
    
    if(file.isDirectory && ![FileSystemInterface fileIsRootDirectory:file]){
        cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
        
        if(fileIsSelected){
            [cell.cellImageSelected setHidden:YES];
            [cell.cellImage setHidden:NO];
        }else{
            [cell.cellImageSelected setHidden:NO];
            [cell.cellImage setHidden:YES];
        }
    }else if (![FileSystemInterface fileIsRootDirectory:file]){
        cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
        
        __block BOOL fileIsLoading = NO;
        
        //check to see if the thing is loading, if it's not then set the border
        //if the file loading object is loading then DO NOT set the border
        dispatch_sync(_fileLoadingObjectsQueue, ^{
            //if there's something loading check if the thing
            //we pressed is loading and don't set the border if it is.
            if ([[[self fsAbstraction] arrayForLoadObjects] count] != 0) {
                
                for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                    if([file.path isEqualToString:fileLoadingObject.file.path]){
                        fileIsLoading = YES;
                    }
                }
            }
        });
        
        //an image in local that was just selected
        if([self isFileAnImage:file.name] &&  [[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath]  isLocatedInsideDirectoryName:@"Local"]){

            //When file is loading, only show and hide cellImageSelected
            //Otherwise show cellImageSelected/hide cellImage when file is not selected
            //And hide cellImageSelected/show cellImage when file is selected
            if (fileIsSelected) {
                if (!fileIsLoading) {
                    [cell.cellImageSelected setHidden:YES];
                    [cell.cellImage setHidden:NO];
                }
                else {
                    [cell.cellImageSelected setHidden:YES];
                }
            }
            else {
                if (!fileIsLoading) {
                    [cell.cellImageSelected setHidden:NO];
                    [cell.cellImage setHidden:YES];
                }
                else {
                    [cell.cellImageSelected setHidden:NO];
                }
            }
        //a non image in local that was just selected
        } else if(fileIsSelected){
            if (!fileIsLoading) {
                [cell.cellImageSelected setHidden:YES];
                [cell.cellImage setHidden:NO];
            }
            else {
                [cell.cellImageSelected setHidden:YES];
            }
            //a non image that was just unselected
        } else {
            if (!fileIsLoading) {
                [cell.cellImageSelected setHidden:NO];
                [cell.cellImage setHidden:YES];
            }
            else {
                [cell.cellImageSelected setHidden:NO];
            }
        }
    }
}



//unselects all cell images

-(void) unselectAllCellImages {
    for (int i = 0; i<[[[self fsAbstraction] currentDirectory] count]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_homeFileCollectionView cellForItemAtIndexPath:indexPath];
        [cell.cellImageSelected setHidden:YES];
        [cell.cellImage setHidden:NO];
    }
}

//method we call after we populate the current directory with the filesystem.json
//should also sort the folders/files by name alphabetically
-(void) splitFoldersAndNonFolders{
    [_arrayForFoldersToDisplay removeAllObjects];
    [_arrayForNonFoldersToDisplay removeAllObjects];
    for(File* file in [[self fsAbstraction] currentDirectory]){
        if(file.isDirectory){
            [_arrayForFoldersToDisplay addObject:file];
        }else{
            [_arrayForNonFoldersToDisplay addObject:file];
        }
    }
    _arrayForFoldersToDisplay = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:_arrayForFoldersToDisplay] copyItems:YES];
    _arrayForNonFoldersToDisplay = [[NSMutableArray alloc] initWithArray:[[self  fsFunctions] sortFoldersOrFiles:_arrayForNonFoldersToDisplay] copyItems:YES];
}

//removes selected files that are in one service when files
//get selected in a different service

-(void) removeSelectedFilesFromAllServicesExcept:(NSString*)serviceName{

    BOOL foundFilesInServiceToRemove = NO;
    NSString *serviceDirectoryOfRemovedFiles = @"";
    //remove files in other services that are not the same
    //as the service we are selecting in now
    NSMutableIndexSet* filesToRemove = [[NSMutableIndexSet alloc] init];
    for(File* fileToRemove in [[self fsAbstraction] selectedFiles]){
        if(![[self fsInterface] filePath:fileToRemove.path isLocatedInsideDirectoryName:serviceName]){
            [filesToRemove addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:fileToRemove]];
            serviceDirectoryOfRemovedFiles = [FileSystemInterface getRootDirectoryOfFilePath:fileToRemove.path];
            foundFilesInServiceToRemove = YES;
        }
    }
    [[self fsAbstraction] removeObjectsFromSelectedFilesAtIndexes:filesToRemove];
    
    if (foundFilesInServiceToRemove) {
        [self alertUserToUnselectingFilesInService: serviceDirectoryOfRemovedFiles];
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

-(void)alertUserToSharingFileLinksWithService:(NSString*)service {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sharing file links" message:[NSString stringWithFormat:@"You are about to share one or more file links from %@. Anyone with a link may view those files.", service] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              if ([service isEqualToString:[AppConstants dropboxPresentableString]]) {
                                                                  [LocalStorageManager setUserShownDropboxLinkSharingDialogueTo:YES];
                                                              }
                                                              else if ([service isEqualToString:[AppConstants googleDrivePresentableString]]) {
                                                                  [LocalStorageManager setUserShownGoogleDriveLinkSharingDialogueTo:YES];
                                                              }
                                                              [self generateLinks];
                                                          }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:noAction];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertUserToProblemUploadingToCamera: (NSError*)error {
    UIAlertController* alert;
    if ([error.domain isEqualToString:@"ALAssetsLibraryErrorDomain"] && error.code == -3310) {
        alert = [UIAlertController alertControllerWithTitle:@"Access Denied" message:@"This app does not have access to your photos or videos. You can enable access in Privacy Settings." preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:@"There was a problem uploading to your camera roll." preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertUserToUnselectingFilesInService: (NSString*)service {
    
    UIImage *serviceImage;
    if ([service isEqualToString:@"GoogleDrive"]) {
        serviceImage = [UIImage imageNamed:[AppConstants googleDriveNavStringIdentifier]];
    }
    else if ([service isEqualToString:@"Local"]) {
        serviceImage = [UIImage imageNamed:[AppConstants localNavStringIdentifier]];
    }
    else if ([service isEqualToString:@"Dropbox"]) {
        serviceImage = [UIImage imageNamed:[AppConstants dropboxNavStringIdentifier]];
    }
    
    UILabel* labelForTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 111, 20)]; //95 edge
    UILabel* labelForTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(151, 0, 54, 20)]; //34 edge
    UIImageView* imageView = [[UIImageView alloc] initWithImage:serviceImage]; //39 px
    UIView* viewForHUD = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 204, 20)];
    
    //        [labelForTitle setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.5]];
    //        [labelForTitle2 setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.5]];
    //        [imageView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.25]];
    //        [viewForHUD setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.75]];
    
    labelForTitle.text = @"Unselected";
    labelForTitle2.text = @"Files";
    labelForTitle.textColor = [UIColor whiteColor];
    labelForTitle2.textColor = [UIColor whiteColor];
    labelForTitle.textAlignment = NSTextAlignmentCenter;
    labelForTitle2.textAlignment = NSTextAlignmentCenter;
    [labelForTitle setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:18.0]];
    [labelForTitle2 setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:18.0]];
    
    CGRect frame = imageView.frame;
    frame.origin.x = 112;
    frame.origin.y = -12;
    imageView.frame = frame;
    
    [viewForHUD addSubview:labelForTitle];
    [viewForHUD addSubview:imageView];
    [viewForHUD addSubview:labelForTitle2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = viewForHUD;
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void)alertUserToDownloadingFilesToLocal {
    UILabel* labelForTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 144, 20)];
    UIImage *image = [UIImage imageNamed:[AppConstants localNavStringIdentifier]];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    UIView* viewForHUD = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 184, 20)];
    
    labelForTitle.text = @"Downloading to";
    labelForTitle.textColor = [UIColor whiteColor];
    labelForTitle.textAlignment = NSTextAlignmentCenter;
    [labelForTitle setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:18.0]];
    
    CGRect frame = imageView.frame;
    frame.origin.x = 145;
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

-(void)alertUserToUploadingFilesToService: (NSString*)service {
    UIImage *serviceImage;
    if ([service isEqualToString:[AppConstants googleDrivePresentableString]]) {
        serviceImage = [UIImage imageNamed:[AppConstants googleDriveNavStringIdentifier]];
    }
    else if ([service isEqualToString:[AppConstants cameraRollPresentableString]]) {
        serviceImage = [UIImage imageNamed:[AppConstants cameraRollNavStringIdentifier]];
    }
    else if ([service isEqualToString:[AppConstants dropboxPresentableString]]) {
        serviceImage = [UIImage imageNamed:[AppConstants dropboxNavStringIdentifier]];
    }
    
    UILabel* labelForTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 124, 20)];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:serviceImage];
    UIView* viewForHUD = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 164, 20)];
    
    labelForTitle.text = @"Uploading to";
    labelForTitle.textColor = [UIColor whiteColor];
    labelForTitle.textAlignment = NSTextAlignmentCenter;
    [labelForTitle setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:18.0]];
    
    CGRect frame = imageView.frame;
    frame.origin.x = 125;
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

-(void) alertUserToCleaningCorruptFiles:(int)numfilescleaned {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [NSString stringWithFormat:@"Cleaned %d files", numfilescleaned];
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

-(void) alertUserToInternetNotAvailable {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Bah! No internet.";
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

// this alert is actually in the db service manager delegate
-(void) alertUserToFileNotFound:(File*)fileNotFound{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [NSString stringWithFormat: @"%@ not found!", fileNotFound.name];
        hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:1.5];
    });
}

#pragma mark - NSNotificationCenter

// updates the selected files indicator and the tool bar
// when the user changes their file selection
-(void) updateSelectedFilesButtonNumberAndToolbar {
    [self updateSelectedFilesButtonNumber];
    [self updateUnselectButton];
    [self updateAddSendButton];
    [self updateFileOptionsToolbar];
    [self showOrHideFileOptionsToolbar];
}

-(void) updateToolbar {
    [self updateFileOptionsToolbar];
    [self showOrHideAddSendButton];
}

#pragma mark - File Options Toolbar & AddSend Button

/* - Called to visibly show or hide the addSendButton - */

-(void)showOrHideAddSendButton {
    if (!_addButtonIsCurrentlySendButton) {
        //Show AddSend Button
        if ([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]) {
            NSLog(@"Show add button");
            [_addButton setUserInteractionEnabled:YES];
            [_addButton addTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [_addButton setImage:[UIImage imageNamed:[AppConstants addImageStringIdentifier]] forState:UIControlStateNormal];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 [_addButton setAlpha:1.0];
                                 
                             }
                             completion:nil];
            
        //Hide
        } else {
            [_addButton setUserInteractionEnabled:NO];
            [_addButton removeTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 [_addButton setAlpha:0.0];
                             }
                             completion:nil];
        }
    }
}

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
                                 CGAffineTransform slideUpAddButton = CGAffineTransformMakeTranslation(0,-_fileOptionsToolbar.frame.size.height);
                                 [_fileOptionsToolbar setTransform: slideUpToolbar];
                                 [_addButton setTransform:slideUpAddButton];
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
                                 CGAffineTransform slideDownAddButton = CGAffineTransformMakeTranslation(0, 0);
                                 [_fileOptionsToolbar setTransform: slideDownToolbar];
                                 [_addButton setTransform:slideDownAddButton];
                             }
                             completion:nil
             ];
        }
    }
}

-(void)updateUnselectButton {
    if ([[[self fsAbstraction] selectedFiles] count] != 0) {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:_selectedFilesBarButtonItem, _separatorBarButtonItem, _unselectBarButtonItem, nil] animated:NO];
    }
    else {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:_selectedFilesBarButtonItem, nil] animated:NO];
    }
}

-(void)updateSelectedFilesButtonNumber {
    
    NSNumber *numFilesSelected = [NSNumber numberWithInteger:[[[self fsAbstraction] selectedFiles] count]];

    if (numFilesSelected.integerValue >= 0 && numFilesSelected.integerValue <= 9) {
        [((HighlightButton*)_selectedFilesBarButtonItem.customView).titleLabel setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:16]];
    }
    else if (numFilesSelected.integerValue >= 10 && numFilesSelected.integerValue <= 99) {
        [((HighlightButton*)_selectedFilesBarButtonItem.customView).titleLabel setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:14]];
    }
    else if (numFilesSelected.integerValue >= 100 && numFilesSelected.integerValue <= 999) {
        [((HighlightButton*)_selectedFilesBarButtonItem.customView).titleLabel setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:11]];
    }
    else {
         [((HighlightButton*)_selectedFilesBarButtonItem.customView).titleLabel setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:8]];
    }
      
    [((HighlightButton*)_selectedFilesBarButtonItem.customView) setTitle:[numFilesSelected stringValue] forState:UIControlStateNormal];
}

/* - Called to transition between button states for addSend button - */

-(void)updateAddSendButton {
    //In Local
    if ([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]) {
        //Transition to Add button
        if ([[[self fsAbstraction] selectedFiles] count] == 0) {
            _addButtonIsCurrentlySendButton = NO;
            [_addButton removeTarget:self action:@selector(toolbarSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [_addButton addTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [UIView transitionWithView:_addButton.imageView
                              duration:.13
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [_addButton setImage:[UIImage imageNamed:[AppConstants addImageStringIdentifier]] forState:UIControlStateNormal];
                            } completion:nil];
        }
        else if ([[[self fsAbstraction] selectedFiles] count] > 0) {
            File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
            //if our single selected file is in local then all our files are located in the Local folder
            
            //Transition to Send Button
            if ([[self fsInterface]filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]) {
                _addButtonIsCurrentlySendButton = YES;
                [_addButton removeTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [_addButton addTarget:self action:@selector(toolbarSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [_addButton setUserInteractionEnabled:YES];
                [UIView transitionWithView:_addButton.imageView
                                  duration:.13
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [_addButton setImage:[UIImage imageNamed:[AppConstants sendImageStringIdentifier]] forState:UIControlStateNormal];
                                } completion:nil];
            }
            //Show Send Link Button
            else {
                _addButtonIsCurrentlySendButton = YES;
                [_addButton removeTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [_addButton addTarget:self action:@selector(toolbarSendLinkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [_addButton setImage:[UIImage imageNamed:[AppConstants sendLinkImageStringIdentifier]] forState:UIControlStateNormal];
                [_addButton setUserInteractionEnabled:YES];
                [UIView animateWithDuration:.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(){
                                     [_addButton setAlpha:1.0];
                                 }
                                 completion:nil];
            }
        }
    }
    else { //Not in Local
        //Hide Send Button
        
        if ([[[self fsAbstraction] selectedFiles] count] == 0) {
            if (!_transitioningToSendLinkButton) {
                [_addButton setUserInteractionEnabled:NO];
                _addButtonIsCurrentlySendButton = NO;
                [_addButton removeTarget:self action:@selector(toolbarSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [_addButton removeTarget:self action:@selector(toolbarSendLinkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [UIView animateWithDuration:.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(){
                                     [_addButton setAlpha:0.0];
                                 }
                                 completion:nil];
            }
        }
        else if ([[[self fsAbstraction] selectedFiles] count] > 0) {
            File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
            //if our single selected file is in local then all our files are located in the Local folder
            
            //Show Send Button
            if([[self fsInterface]filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]){
                _addButtonIsCurrentlySendButton = YES;
                [_addButton removeTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [_addButton addTarget:self action:@selector(toolbarSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [_addButton setImage:[UIImage imageNamed:[AppConstants sendImageStringIdentifier]] forState:UIControlStateNormal];
                [_addButton setUserInteractionEnabled:YES];
                [UIView animateWithDuration:.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(){
                                     [_addButton setAlpha:1.0];
                                 }
                                 completion:nil];
            }
            //Show Send Link button
            else {
                NSLog(@"Transitioning to sendLinkButton?: %@", _transitioningToSendLinkButton? @"YES" : @"NO");
                if (_transitioningToSendLinkButton) {
                    _addButtonIsCurrentlySendButton = YES;
                    [_addButton removeTarget:self action:@selector(toolbarSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                    [_addButton addTarget:self action:@selector(toolbarSendLinkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                    [_addButton setUserInteractionEnabled:YES];
                    [UIView transitionWithView:_addButton.imageView
                                      duration:.13
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [_addButton setImage:[UIImage imageNamed:[AppConstants sendLinkImageStringIdentifier]] forState:UIControlStateNormal];
                                    } completion:nil];
                }
                else {
                    _addButtonIsCurrentlySendButton = YES;
                    [_addButton removeTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                    [_addButton addTarget:self action:@selector(toolbarSendLinkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                    [_addButton setImage:[UIImage imageNamed:[AppConstants sendLinkImageStringIdentifier]] forState:UIControlStateNormal];
                    [_addButton setUserInteractionEnabled:YES];
                    [UIView animateWithDuration:.25
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^(){
                                         [_addButton setAlpha:1.0];
                                     }
                                     completion:nil];

                }
                _transitioningToSendLinkButton = NO;
            }
        }
    }
}

- (IBAction)addButtonPress:(id)sender {
    
    CGRect rect=((UIButton*)sender).frame;
    rect.origin.y = rect.origin.y - 1 ;
    
    [KxMenu setTintColor:[AppConstants appSchemeColor]];
    [KxMenu setSelectedTintColor:[AppConstants addButtonPopupSelectionColor]];
    [KxMenu setTitleFont:[UIFont fontWithName:[AppConstants appFontNameB] size:16]];
    
    KxMenuItem *addFolderKxMenuItem = [KxMenuItem menuItem:@"New Folder"
                                                     image:[UIImage imageNamed:[AppConstants newFolderPopupImageStringIdentifier]]
                                                    target:self
                                                    action:@selector(newFolderPress:)];
    
    KxMenuItem *addPhotosKxMenuItem = [KxMenuItem menuItem:@"Add Photos"
                                                     image:[UIImage imageNamed:[AppConstants addPhotosPopupImageStringIdentifier]]
                                                    target:self
                                                    action:@selector(addPhotosPress:)];
    
    [KxMenu showMenuInView:self.view
                  fromRect:rect
                 menuItems:@[addFolderKxMenuItem, addPhotosKxMenuItem]];
}

//if we press to create a new folder tirgger the method below and set up buttons and stuff
-(void)newFolderPress: (UIButton*)sender {
    NSLog(@"New Folder Button Press");
    _nameFileViewControllerActionIdentifier = [AppConstants newFolderPopupImageStringIdentifier];
    [self presentNameFileViewController];
}

-(void)addPhotosPress: (UIButton*)sender {
    NSLog(@"Add Photos Button Press");
    [self summonPhotoLibrary];
}

/* - Presents the rename view controller - */


-(void)presentNameFileViewController{
    [self performSegueWithIdentifier:@"home-to-nameFile" sender:self];
}

/* - Shows Upload popup menu from upload toolbar button- */

-(void)showUploadPopupMenuFromSender: (id)sender {
    CGRect rect=((UIButton*)sender).frame;
    CGRect tRect=[((UIButton*)sender) convertRect:((UIButton*)sender).frame toView:self.view];
    tRect.origin.x=rect.origin.x;
    tRect.origin.y=tRect.origin.y - 1;
    
    [KxMenu setTintColor:[AppConstants appSchemeColorC]];
    [KxMenu setSelectedTintColor:[AppConstants fileOptionsToolbarSeparatorColor]];
    [KxMenu setTitleFont:[UIFont fontWithName:[AppConstants appFontNameB] size:16]];
    
    KxMenuItem *dropboxKxMenuItem = [KxMenuItem menuItem:[AppConstants dropboxPresentableString]
                                                   image:[UIImage imageNamed:[AppConstants dropboxToolbarPopupImageStringIdentifier]]
                                                  target:self
                                                  action:@selector(dropboxUploadPress:)];
    KxMenuItem *googleDriveKxMenuItem = [KxMenuItem menuItem:[AppConstants googleDrivePresentableString]
                                                       image:[UIImage imageNamed:[AppConstants googleDriveToolbarPopupImageStringIdentifier]]
                                                      target:self
                                                      action:@selector(googleDriveUploadPress:)];
    
    //check for upload to camera roll if we have no photos selected
    //gray it out.
    
    KxMenuItem *cameraRollKxMenuItem = [KxMenuItem menuItem:[AppConstants cameraRollPresentableString]
                                                      image:[UIImage imageNamed:[AppConstants cameraRollToolbarPopupImageStringIdentifier]]
                                                     target:self
                                                     action:@selector(cameraRollUploadPress:)];
    
    [KxMenu showMenuInView:self.view
                  fromRect:tRect
                 menuItems:@[dropboxKxMenuItem, googleDriveKxMenuItem, cameraRollKxMenuItem]];
}

/* - Shows Actions popup menu from upload toolbar button- */

-(void)showActionsPopupMenuFromSender: (UIButton*)sender {
    CGRect rect=((UIButton*)sender).frame;
    CGRect tRect=[((UIButton*)sender) convertRect:((UIButton*)sender).frame toView:self.view];
    tRect.origin.x=rect.origin.x;
    tRect.origin.y=tRect.origin.y - 1;
    
    [KxMenu setTintColor:[AppConstants appSchemeColorC]];
    [KxMenu setSelectedTintColor:[AppConstants fileOptionsToolbarSeparatorColor]];
    [KxMenu setTitleFont:[UIFont fontWithName:[AppConstants appFontNameB] size:16]];
    
    KxMenuItem *renameKxMenuItem = [KxMenuItem menuItem:@"Rename"
                                                       image:[UIImage imageNamed:[AppConstants renamePopupImageStringIdentifier]]
                                                      target:self
                                                      action:@selector(toolbarRenameButtonPress:)];
    
    KxMenuItem *previewKxMenuItem = [KxMenuItem menuItem:@"Preview"
                                                   image:[UIImage imageNamed:[AppConstants previewPopupImageStringIdentifier]]
                                                  target:self
                                                  action:@selector(toolbarPreviewButtonPress:)];
    
    [KxMenu showMenuInView:self.view
                  fromRect:tRect
                 menuItems:@[renameKxMenuItem, previewKxMenuItem]];
}


-(void)dropboxUploadPress: (UIButton*)sender {
    NSLog(@"Dropbox upload press");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        
        [self unselectAllCellImages];
        [self alertUserToUploadingFilesToService:[AppConstants dropboxPresentableString]];
        
        _dbServiceManager.canLoadAndNavigateAfterAuth = NO;//need this here or else dropbox tries to upload file on a regular click on thr dropbox folder authorixation
        [_dbServiceManager checkForAndCreateEnvoyUploadsFolderThenUpload:self];
    }
}

-(void)googleDriveUploadPress: (UIButton*)sender {
    NSLog(@"Google Drive upload press");
    
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        [self unselectAllCellImages];
        [self alertUserToUploadingFilesToService:[AppConstants googleDrivePresentableString]];
        [_gdServiceManager checkForAndCreateEnvoyUploadsFolderThenUpload:self];
    }
}

-(void)cameraRollUploadPress: (UIButton*)sender {
    NSLog(@"Camera Roll upload press");
    
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        
        [self alertUserToUploadingFilesToService:[AppConstants cameraRollPresentableString]];
        
        [self saveSelectedPhotosToPhotoLibrary];
    }
}

-(void)toolbarDownloadButtonPress: (UIButton*)sender {
    NSLog(@"Toolbar download Button Press");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        [self alertUserToDownloadingFilesToLocal];
        
        File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        
        if([[self fsInterface] filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"GoogleDrive"]){
            
            // create a special folder for containing
            // uploads to google drive if it doesn't
            // exist
            [[self fsInit] checkForAndAddDownloadsFolderInLocal];
            
            //actually perform the download
            [_gdServiceManager prepareForExportToOther:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] calledFromInbox:NO storedReduceStackToPath:[@"/Local" stringByAppendingPathComponent:@"downloads"] andMoveToGD:NO andMovedFromGD:YES];
            //remove objects from selected files immediately after download signal sent
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_homeFileCollectionView reloadData];
            });
        }
        
        if([[self fsInterface] filePath:singleSelectedFile.path  isLocatedInsideDirectoryName:@"Dropbox"]){
            
            // create a special folder for containing
            // uploads to google drive if it doesn't
            // exist
            [[self fsInit] checkForAndAddDownloadsFolderInLocal];
            
            //actually perform the download
            [_dbServiceManager prepareForExportToOther:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] calledFromInbox:NO storedReduceStackToPath:[@"/Local" stringByAppendingPathComponent:@"downloads"] andMoveToDB:NO andMovedFromDB:YES];
            //remove objects from selected files immediately after download signal sent
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_homeFileCollectionView reloadData];
            });
        }
    }
}

-(void)toolbarDownloadHereButtonPress: (UIButton*)sender {
    NSLog(@"Download Here Button Pressed");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        
        //if our selected files are in dropbox downloads from dropbox
        if([[self fsInterface]filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Dropbox"]){
            [_dbServiceManager prepareForExportToOther:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] calledFromInbox:NO storedReduceStackToPath:[[self fsAbstraction] reduceStackToPath] andMoveToDB:NO andMovedFromDB:NO];
            //remove objects from selected files immediately after download signal sent
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        }
        
        //if our selected files are in google drive download from google drive
        if([[self fsInterface]filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"GoogleDrive"]){
            [_gdServiceManager prepareForExportToOther:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] calledFromInbox:NO storedReduceStackToPath:[[self fsAbstraction] reduceStackToPath] andMoveToGD:NO andMovedFromGD:NO];
            //remove objects from selected files immediately after download signal sent
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        }
    }
}

//grab the selected Files which are currently downloading
//their paths are the ones that need to be cancelled.
//identify the client on which to cancel the specific path
//based on the storedReduceStackToPath in the query wrapper
//and the parent path of the selected file being deselected.
-(void)toolbarCancelDownloadButtonPress: (UIButton*)sender {
    NSLog(@"Cancel Download Button Press");
    
    if ([[[self fsAbstraction] selectedFiles] count] == 1) {
        
        NSMutableIndexSet* selectedIndicesToRemove = [[NSMutableIndexSet alloc]init];
        NSMutableIndexSet* fileLoadingIndiciesToRemove = [[NSMutableIndexSet alloc]init];
        
        //adding and removing indicies to avoid iterating over array while it changes
        //basically we check to see if the path we're downloading to is in one of the
        //dictionairies in one of the query wrappers in dropbox or google drive
        //we can be sure that ther won't be TWO query wrappers one in dropbox
        //and one in google drive that need to cancel the same file path
        //because file paths on our system are unique.
        File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        [_dbServiceManager cancelFileLoadWithFile:singleSelectedFile];
        [_gdServiceManager cancelFileLoadWithFile:singleSelectedFile];
        [selectedIndicesToRemove addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:singleSelectedFile]];

        dispatch_sync(_fileLoadingObjectsQueue, ^{
            for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                if([singleSelectedFile.path isEqualToString: fileLoadingObject.file.path]){
                    [fileLoadingIndiciesToRemove addIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]];
                }
            }
        });
        
        //order i chose here was explicit and shoule be kept.
        //gotta do a split BEFORE we reorganizefileloading paths
        //reorganize depends on the split function.
        [[self fsAbstraction] removeObjectsFromSelectedFilesAtIndexes:selectedIndicesToRemove];
        
        //removes selected file(s) from the JSON on the system that tracks it.
        //we can't just use the currentDirectory because we can cancel a file from loading
        //without being in the same directory
        if([[[self fsAbstraction] reduceStackToPath] isEqualToString:singleSelectedFile.parentURLPath]){
            
            [[[self fsAbstraction] currentDirectory] removeObject:singleSelectedFile];
            [[self fsInterface] removeSingleFileFromFileSystemJSON:singleSelectedFile inDirectoryPath:singleSelectedFile.parentURLPath];
            
        }else{
            
            NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
            [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy inDirectoryPath:singleSelectedFile.parentURLPath];
            for(File* fileToRepopulate in currentDirProxy){
                if ([fileToRepopulate.path isEqualToString:singleSelectedFile.path]) {
                    [[self fsInterface] removeSingleFileFromFileSystemJSON:fileToRepopulate inDirectoryPath:fileToRepopulate.parentURLPath];
                }
            }
        }
        
        //reload for collectionview and removal of the file loading object from arrayForLoadObjects happens here
        [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:fileLoadingIndiciesToRemove];
        
    } else if ([[[self fsAbstraction] selectedFiles] count] > 1) {
        
        NSMutableIndexSet* selectedIndicesToRemove = [[NSMutableIndexSet alloc]init];
        NSMutableIndexSet* fileLoadingIndiciesToRemove = [[NSMutableIndexSet alloc]init];
        
        for (File* potentialFileToRemove in [[self fsAbstraction] selectedFiles]){
            [_dbServiceManager cancelFileLoadWithFile:potentialFileToRemove];
            [_gdServiceManager cancelFileLoadWithFile:potentialFileToRemove];
        }
        
        dispatch_sync(_fileLoadingObjectsQueue, ^{

            for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                if([[[NSArray alloc]initWithArray:[[self fsAbstraction] selectedFiles]] containsObject:fileLoadingObject.file]){
                    [selectedIndicesToRemove addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:fileLoadingObject.file]];
                    [fileLoadingIndiciesToRemove addIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]];
                }
            }
            
        });
        
        //removes selected file(s) from the JSON on the system that tracks it.
        //we can't just use the currentDirectory because we can cancel a file from loading
        //without being in the same directory
        for(File* eachFile in [[self fsAbstraction] selectedFiles]){
            if([[[self fsAbstraction] reduceStackToPath] isEqualToString:eachFile.parentURLPath]){
                
                //if the file is in the rigth index set (it is a file loading object) and downaloding/uploading.
                //remove it from the current directory and remove it from the JSON
                if([selectedIndicesToRemove containsIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:eachFile]]){
                    
                    [[[self fsAbstraction] currentDirectory] removeObject:eachFile];
                    [[self fsInterface] removeSingleFileFromFileSystemJSON:eachFile inDirectoryPath:eachFile.parentURLPath];
                }
                
            }else{
                NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
                [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy inDirectoryPath:eachFile.parentURLPath];
                for(File* fileToRepopulate in currentDirProxy){
                    if ([fileToRepopulate.path isEqualToString:eachFile.path]) {
                        [[self fsInterface] removeSingleFileFromFileSystemJSON:fileToRepopulate inDirectoryPath:fileToRepopulate.parentURLPath];
                    }
                }
                
            }
        }
        
        //remove this object from the file loading array and the selected files array
        [[self fsAbstraction] removeObjectsFromSelectedFilesAtIndexes:selectedIndicesToRemove];

        //reload for collectionview and removal of the file loading object from arrayForLoadObjects happens here
        [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:fileLoadingIndiciesToRemove];
    }
}

-(void)toolbarCancelUploadButtonPress:(UIButton*)sender {
    
    if ([[[self fsAbstraction] selectedFiles] count] == 1) {
        
        NSMutableIndexSet* selectedIndicesToRemove = [[NSMutableIndexSet alloc]init];
        NSMutableIndexSet* fileLoadingIndiciesToRemove = [[NSMutableIndexSet alloc]init];
        
        //adding and removing indicies to avoid iterating over array while it changes
        //basically we check to see if the path we're downloading to is in one of the
        //dictionairies in one of the query wrappers in dropbox or google drive
        //we can be sure that ther won't be TWO query wrappers one in dropbox
        //and one in google drive that need to cancel the same file path
        //because file paths on our system are unique.
        File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        [_dbServiceManager cancelFileUploadWithFile:singleSelectedFile];
        [_gdServiceManager cancelFileUploadWithFile:singleSelectedFile];
        [selectedIndicesToRemove addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:singleSelectedFile]];
        
        dispatch_sync(_fileLoadingObjectsQueue, ^{
            
            for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                if([singleSelectedFile.path isEqualToString: fileLoadingObject.file.path]){
                    [fileLoadingIndiciesToRemove addIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]];
                }
            }
            
        });
        
        //order i chose here was explicit and shoule be kept.
        //gotta do a split BEFORE we reorganizefileloading paths
        //reorganize depends on the split function.
        [[self fsAbstraction] removeObjectsFromSelectedFilesAtIndexes:selectedIndicesToRemove];
        
        //removes selected file(s) from the JSON on the system that tracks it.
        //we can't just use the currentDirectory because we can cancel a file from loading
        //without being in the same directory
        if([[[self fsAbstraction] reduceStackToPath] isEqualToString:singleSelectedFile.parentURLPath]){
            
            [[[self fsAbstraction] currentDirectory] removeObject:singleSelectedFile];
            [[self fsInterface] removeSingleFileFromFileSystemJSON:singleSelectedFile inDirectoryPath:singleSelectedFile.parentURLPath];
            
        }else{
            
            NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
            [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy inDirectoryPath:singleSelectedFile.parentURLPath];
            for(File* fileToRepopulate in currentDirProxy){
                if ([fileToRepopulate.path isEqualToString:singleSelectedFile.path]) {
                    [[self fsInterface] removeSingleFileFromFileSystemJSON:fileToRepopulate inDirectoryPath:fileToRepopulate.parentURLPath];
                }
            }
        }
        
        //reload for collectionview and removal of the file loading object from arrayForLoadObjects happens here
        [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:fileLoadingIndiciesToRemove];
        
    } else if ([[[self fsAbstraction] selectedFiles] count] > 1) {
        
        NSMutableIndexSet* selectedIndicesToRemove = [[NSMutableIndexSet alloc]init];
        NSMutableIndexSet* fileLoadingIndiciesToRemove = [[NSMutableIndexSet alloc]init];
        
        for (File* potentialFileToRemove in [[self fsAbstraction] selectedFiles]){
            [_dbServiceManager cancelFileUploadWithFile:potentialFileToRemove];
            [_gdServiceManager cancelFileUploadWithFile:potentialFileToRemove];
        }
        
        dispatch_sync(_fileLoadingObjectsQueue, ^{
            
            for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                if([[[NSArray alloc]initWithArray:[[self fsAbstraction] selectedFiles]] containsObject:fileLoadingObject.file]){
                    [selectedIndicesToRemove addIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:fileLoadingObject.file]];
                    [fileLoadingIndiciesToRemove addIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]];
                }
            }
            
        });
        
        //removes selected file(s) from the JSON on the system that tracks it.
        //we can't just use the currentDirectory because we can cancel a file from loading
        //without being in the same directory
        for(File* eachFile in [[self fsAbstraction] selectedFiles]){
            
            if([[[self fsAbstraction] reduceStackToPath] isEqualToString:eachFile.parentURLPath]){
                
                //if the file is in the rigth index set (it is a file loading object) and downaloding/uploading.
                //remove it from the current directory and remove it from the JSON
                if([selectedIndicesToRemove containsIndex:[[[self fsAbstraction] selectedFiles] indexOfObject:eachFile]]){

                    [[[self fsAbstraction] currentDirectory] removeObject:eachFile];
                    [[self fsInterface] removeSingleFileFromFileSystemJSON:eachFile inDirectoryPath:eachFile.parentURLPath];
                }
                
            }else{
                NSMutableArray* currentDirProxy = [[NSMutableArray alloc] init];
                [[self fsInterface] populateArrayWithFileSystemJSON:currentDirProxy inDirectoryPath:eachFile.parentURLPath];
                for(File* fileToRepopulate in currentDirProxy){
                    if ([fileToRepopulate.path isEqualToString:eachFile.path]) {
                        [[self fsInterface] removeSingleFileFromFileSystemJSON:fileToRepopulate inDirectoryPath:fileToRepopulate.parentURLPath];
                    }
                }
            }
        }
        
        //remove this object from the file loading array and the selected files array
        [[self fsAbstraction] removeObjectsFromSelectedFilesAtIndexes:selectedIndicesToRemove];
        
        //reload for collectionview and removal of the file loading object from arrayForLoadObjects happens here
        [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:fileLoadingIndiciesToRemove];
    }
}

-(void)toolbarUploadButtonPress: (UIButton*)sender {
    NSLog(@"Toolbar upload Button Press");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        [self showUploadPopupMenuFromSender:sender];
    }
}

-(void)toolbarUploadHereButtonPress: (UIButton*)sender {
    NSLog(@"Toolbar upload here Button Press");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {

        if([[self fsInterface]filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Dropbox"]){
            [_dbServiceManager prepareToSaveFilesExportedFromOther:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] calledFromInbox:NO storedReduceStackToPath:[[self fsAbstraction] reduceStackToPath] andMoveToDB:NO andMovedFromDB:NO];
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        }
        
        if([[self fsInterface]filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"GoogleDrive"]){
            [_gdServiceManager prepareToSaveFilesExportedFromOther:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] calledFromInbox:NO storedReduceStackToPath:[[self fsAbstraction] reduceStackToPath] andMoveToGD:NO andMovedFromGD:NO];
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        }
    }
}

-(void)toolbarMoveButtonPress: (UIButton*)sender {
    NSLog(@"Toolbar Move Button Press");
    
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        
        //after we remove indicies if the selected files count is zero don't do the query.
        if([[[self fsAbstraction] selectedFiles] count] != 0){
            [[self fsFunctions] moveFilesLocal:[[NSMutableArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]] calledFromInbox:NO];
        }
        
        //remove all objects from selected files. NEED THIS to get rid
        //of selected files when user attempts to move a file/folder
        //into the same place as it already is (select ->press move)
        //which does nothing.
        [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        
        //reorganize the index paths post
        [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:[[NSMutableIndexSet alloc] init]];
        
        //refresh the collectionview
        [self splitFoldersAndReloadCollectionView];
    }
}

-(void)toolbarDeleteButtonpress: (UIButton*)sender {
    NSLog(@"Toolbar Delete Button Press");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
    
        UIAlertController *options = [UIAlertController alertControllerWithTitle:nil
                                                                         message:@"Are you sure you want to delete your selected files?"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive
          handler:^(UIAlertAction *action) {
              
              File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
              
              for (File* filetoDelete in [[self fsAbstraction] selectedFiles]) {
                  //if we've NOT selected files in a cloud folder (gdrive/dropbox) then we need to cancel downloads
                  if([[self fsInterface] filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]) {
                      
                      //delete the file if it's there
                      [[self fsInterface] deleteFileAtPath:filetoDelete.path];
                      //if a file is a directory
                      if(filetoDelete.isDirectory){
                          
                          NSMutableIndexSet* fileLoadingIndiciesToRemove = [[NSMutableIndexSet alloc] init];
                          //cycle through to see if any of the file loading objects
                          //have a file whose path is a child/subchilde of the deleted files*
                          dispatch_sync(_fileLoadingObjectsQueue, ^{
                              
                              for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                                  //if we check the path we're deleting and we find that a file loading object
                                  //has the deleted file path as its parent we need to remove that file loading object
                                  //and cancel the download operation on it.
                                  if([fileLoadingObject.file.path rangeOfString:filetoDelete.path].location != NSNotFound){
                                      File* fileToPass = [[File alloc] init];
                                      fileToPass = fileLoadingObject.file;
                                      [_dbServiceManager cancelFileLoadWithFile:fileToPass];
                                      [_gdServiceManager cancelFileLoadWithFile:fileToPass];
                                      [fileLoadingIndiciesToRemove addIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]];
                                  }
                              }
                          });
                          
                          //destory the operation wrappers on the service managers
                          NSArray* fileLoadingObjectsToRemove = [[[self fsAbstraction] arrayForLoadObjects] objectsAtIndexes:fileLoadingIndiciesToRemove];
                          [_gdServiceManager destroyGDOperationsWithFilePaths:fileLoadingObjectsToRemove];
                          [_dbServiceManager destroyDBOperationsWithFilePaths:fileLoadingObjectsToRemove];
                          //removes the thing we need to remove so we don't need to call remove on teh arrayForLoadObjects
                          //explicitly. DO NOT CALL [[[self fsAbstraction] arrayForLoadObjects] removeObjectsAtIndexes:fileLoadingIndiciesToRemove];
                          [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:fileLoadingIndiciesToRemove];
                          [fileLoadingIndiciesToRemove removeAllIndexes];
                      }
                      
                  //if we've selected files in a cloud folder like dropbox/google drive we want to cancel uploads
                  } else {
                      //delete the file in teh cloud.
                      //if we're in dropbox
                      if([[self fsInterface] filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Dropbox"]){
                          
                          [_dbServiceManager deleteFileFromDropbox:filetoDelete onDropboxPath:[[self fsInterface] resolveFilePath:filetoDelete.path excludingUpToDirectory:@"Dropbox"]];
                      //if we're in google drive
                      } else {
                
                          [_gdServiceManager deleteFileFromGoogleDrive:filetoDelete];
                      }
                      //if a file is a directory
                      if(filetoDelete.isDirectory){
                          
                          NSMutableIndexSet* fileLoadingIndiciesToRemove = [[NSMutableIndexSet alloc] init];
                          //cycle through to see if any of the file loading objects
                          //have a file whose path is a child/subchilde of the deleted files*
                          dispatch_sync(_fileLoadingObjectsQueue, ^{
                              
                              for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                                  //if we check the path we're deleting and we find that a file loading object
                                  //has the deleted file path as its parent we need to remove that file loading object
                                  //and cancel the download operation on it.
                                  if([fileLoadingObject.file.path rangeOfString:filetoDelete.path].location != NSNotFound){
                                      [_dbServiceManager cancelFileUploadWithFile:fileLoadingObject.file];
                                      [_gdServiceManager cancelFileUploadWithFile:fileLoadingObject.file];
                                      [fileLoadingIndiciesToRemove addIndex:[[[self fsAbstraction] arrayForLoadObjects] indexOfObject:fileLoadingObject]];
                                  }
                              }
                          });
                          
                          //destory the operation wrappers on the service managers
                          NSArray* fileLoadingObjectsToRemove = [[[self fsAbstraction] arrayForLoadObjects] objectsAtIndexes:fileLoadingIndiciesToRemove];
                          [_gdServiceManager destroyGDOperationsWithFilePaths:fileLoadingObjectsToRemove];
                          [_dbServiceManager destroyDBOperationsWithFilePaths:fileLoadingObjectsToRemove];
                          
                          //removes the thing we need to remove so we don't need to call remove on teh arrayForLoadObjects
                          //explicitly. DO NOT CALL [[[self fsAbstraction] arrayForLoadObjects] removeObjectsAtIndexes:fileLoadingIndiciesToRemove];
                          [self reorganizeIndexPathsForLoadingObjectsAfterArrayRebalance:fileLoadingIndiciesToRemove];
                          [fileLoadingIndiciesToRemove removeAllIndexes];
                      }
                  }
                  
                  //for each file cloud or no cloud remove from JSON
                  [[self fsInterface] removeSingleFileFromFileSystemJSON:filetoDelete inDirectoryPath:filetoDelete.parentURLPath];
              }
              
              // reload stuff and refactor the view
              
              [[self fsAbstraction]removeAllObjectsFromSelectedFilesArray];
              
              [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
              //split the newly populated current directory into
              //folders and non folders arrays for ordering
              //during the display
              [self splitFoldersAndReloadCollectionView];
          }];
        
          UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [options dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [options addAction:yesAction];
        [options addAction:noAction];
        [self presentViewController:options animated:YES completion:nil];
    }
}

-(void)toolbarRenameButtonPress: (UIButton*)sender {
    NSLog(@"Toolbar rename Button Press");
    
    /* CHECK FOR TOP LEVEL FOLDERS/FILES AND RENAME THOSE YO */
    
    NSNumber *numFilesSelected = [NSNumber numberWithInteger:[[[self fsAbstraction] selectedFiles] count]];
    
    if ([numFilesSelected intValue] == 1) {
        _nameFileViewControllerActionIdentifier = [AppConstants toolbarRenameActionStringIdentifier];
        [self presentNameFileViewController];
    }
}

-(void)toolbarPreviewButtonPress: (UIButton*)sender {
    NSLog(@"Toolbar preview Button Press");
    
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        File* selectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        
        NSURL* urlForFile = [[self fsInterface] getProperlyFormedNSURLFromPath:selectedFile.path];
        //create and present a UIDocumentinteractioncontroller controller that shows a file preview.
        // Initialize Document Interaction Controller
        UIDocumentInteractionController* documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:urlForFile];
        
        // Configure Document Interaction Controller
        [documentInteractionController setDelegate:self];
        
        // Preview PDF
        [documentInteractionController presentPreviewAnimated:YES];
    }
}

-(void)toolbarActionsButtonPress: (UIButton*)sender {
    NSLog(@"Actions Button Pressed");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        [self showActionsPopupMenuFromSender:sender];
    }
}

-(void)toolbarSendLinkButtonPress: (UIButton*)sender {
    
    //Check where the files are selected from
    File* selectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
    
    //If the files are in dropbox, check if we have shown the dropbox link sharing dialogue before
    if ([[self fsInterface] filePath:selectedFile.path isLocatedInsideDirectoryName:@"Dropbox"]) {
        if ([LocalStorageManager userShownDropboxLinkSharingDialogue]) {
            [self generateLinks];
        }
        else {
            [self alertUserToSharingFileLinksWithService:[AppConstants dropboxPresentableString]];
        }
    }
    else if ([[self fsInterface] filePath:selectedFile.path isLocatedInsideDirectoryName:@"GoogleDrive"]) {
        if ([LocalStorageManager userShownGoogleDriveLinkSharingDialogue]) {
            [self generateLinks];
        }
        else {
            [self alertUserToSharingFileLinksWithService:[AppConstants googleDrivePresentableString]];
        }
    }
}

-(void)generateLinks {
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        //dequeue one file.
        File* selectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        
        //if that file in dropbox look for links from dropbox.
        if ([[self fsInterface] filePath:selectedFile.path isLocatedInsideDirectoryName:@"Dropbox"]) {
            [_dbServiceManager getShareableLinksWithFiles:[[NSArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]]];
            
            //if that file is in google drive look for links in google drive.
        } else if ([[self fsInterface] filePath:selectedFile.path isLocatedInsideDirectoryName:@"GoogleDrive"]) {
            [_gdServiceManager getShareableLinksWithFiles:[[NSArray alloc] initWithArray:[[self fsAbstraction] selectedFiles]]];
        }
        
        _sendViewSendType = [AppConstants SEND_TYPE_LINK];
        [self performSegueWithIdentifier:@"home-to-send" sender:self];
    }
}

-(void)toolbarSendButtonPress: (UIButton*)sender {
    NSLog(@"Send Button Pressed");
    if ([[[self fsAbstraction] selectedFiles] count] > 0) {
        [[self fsAbstraction] addObjectsToFilesToSendFromArray:[[self fsAbstraction] selectedFiles]];
        
        _sendViewSendType = [AppConstants SEND_TYPE_FILE];
        [self performSegueWithIdentifier:@"home-to-send" sender:self];
    }
}

-(void) cancelPreviewButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* - Here is where the logic for deciding which buttons to add to the toolbar goes - */

-(void)updateFileOptionsToolbar {
    
    NSNumber *numFilesSelected = [NSNumber numberWithInteger:[[[self fsAbstraction] selectedFiles] count]];
    
    NSMutableArray *buttonActionIdentifiers = [[NSMutableArray alloc] init];
    
    //if we have a single item selected
    if([numFilesSelected intValue] == 1){
        File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        
        
        __block BOOL loadingObjIsSameAsSelected = NO;
        //if the single selected file a file we are currently loading from the
        //dropbox?

        dispatch_sync(_fileLoadingObjectsQueue, ^{

            for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                if([fileLoadingObject.file.path isEqualToString:singleSelectedFile.path]){
                    loadingObjIsSameAsSelected = YES;
                }
            }
        
        });
        
        //if the selected file is loading we add one thing to the toolbar.
        if(loadingObjIsSameAsSelected && [[self fsInterface] filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]){
            [buttonActionIdentifiers addObject:[AppConstants toolbarCancelDownloadActionStringIdentifier]];
        //if we're selected but we're not local and we're in the cloud.
        } else if (loadingObjIsSameAsSelected){
            [buttonActionIdentifiers addObject:[AppConstants toolbarCancelUploadActionStringIdentifier]];
        //if the selected file is not loading we add the normal stuff.
        } else {
            
            //FILES IN LOCAL
            //if our single selected file is in local then all our files are located in the Local folder
            if([[self fsInterface]filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]){
                
                //and we're in Local (the user is navgiated to the Local folder)
                if ([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]) {
                    //add the button to upload to various services (google drive,
                    
                    [buttonActionIdentifiers addObject:[AppConstants toolbarUploadActionStringIdentifier]];
                    [buttonActionIdentifiers addObject:[AppConstants toolbarMoveActionStringIdentifier]];
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];
                    
                    if(singleSelectedFile.isDirectory) {//if the file IS a directory we only show the rename button
                        [buttonActionIdentifiers addObject:[AppConstants toolbarRenameActionStringIdentifier]];
                    }else {//if the file IS NOT a direcotry display the combined button w/ both preview and rename
                        [buttonActionIdentifiers addObject:[AppConstants toolbarRenameActionStringIdentifier]];
                        [buttonActionIdentifiers addObject:[AppConstants toolbarPreviewActionStringIdentifier]];
                    }
                    
                    //the user is about to be in the home/root directory
                } else if([[[self fsAbstraction] reduceStackToPath] isEqualToString:@"/"]){
                    
                    [buttonActionIdentifiers addObject:[AppConstants toolbarUploadActionStringIdentifier]];
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];
                    
                    if(singleSelectedFile.isDirectory) {//if the file IS a directory we only show the rename button
                        [buttonActionIdentifiers addObject:[AppConstants toolbarRenameActionStringIdentifier]];
                    }else {//if the file IS NOT a direcotry display the combined button w/ both preview and rename
                        [buttonActionIdentifiers addObject:[AppConstants toolbarRenameActionStringIdentifier]];
                        [buttonActionIdentifiers addObject:[AppConstants toolbarPreviewActionStringIdentifier]];
                    }
                    
                    //the user is navigated in a cloud directory, and now we update the toolbar
                } else {
                    [buttonActionIdentifiers addObject:[AppConstants toolbarUploadHereActionStringIdentifier]]; // this one is different from else if above.
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];
                    
                    if(singleSelectedFile.isDirectory) {//if the file IS a directory we only show the rename button
                        [buttonActionIdentifiers addObject:[AppConstants toolbarRenameActionStringIdentifier]];
                    }else {//if the file IS NOT a direcotry display the combined button w/ both preview and rename
                        [buttonActionIdentifiers addObject:[AppConstants toolbarRenameActionStringIdentifier]];
                        [buttonActionIdentifiers addObject:[AppConstants toolbarPreviewActionStringIdentifier]];
                    }
                }
                
                //if our single selected file is not in local then our files are located in the cloud services
            } else {
                
                //if the user is navigated to the Local folder
                if ([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]) {
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDownloadHereActionStringIdentifier]];
                    //if the user is navigated to the Cloud
                } else {
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDownloadActionStringIdentifier]];
                }
                
                [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];
            }
        }
        
    //if we have more than one file selected
    } else if ([numFilesSelected intValue] > 1) {
        
        File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        
        __block BOOL loadingObjIsSameAsSelected = NO;

        dispatch_sync(_fileLoadingObjectsQueue, ^{

            for(FileLoadingObject* fileLoadingObject in [[self fsAbstraction] arrayForLoadObjects]){
                if([[[NSArray alloc]initWithArray:[[self fsAbstraction] selectedFiles]] containsObject:fileLoadingObject.file]){
                    loadingObjIsSameAsSelected = YES;
                }
            }
        
        });
        //if the selected file is loading we add one thing to the toolbar we show cancel download
        if(loadingObjIsSameAsSelected && [[self fsInterface] filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]){
            [buttonActionIdentifiers addObject:[AppConstants toolbarCancelDownloadActionStringIdentifier]];
        //if we're selected but we're not local and we're in the cloud we show cancel upload
        } else if(loadingObjIsSameAsSelected){
            [buttonActionIdentifiers addObject:[AppConstants toolbarCancelUploadActionStringIdentifier]];
        //if the selected file is not loading we add the normal stuff.
        } else {
        
            //if our single selected file is in local then all our files are located in the Local folder
            if([[self fsInterface]filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]){
                
                //and we're in Local (the user is navgiated to the Local folder)
                if ([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]) {
                    //add the button to upload to various services (google drive,
                    
                    [buttonActionIdentifiers addObject:[AppConstants toolbarUploadActionStringIdentifier]];
                    [buttonActionIdentifiers addObject:[AppConstants toolbarMoveActionStringIdentifier]];
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];

                    //the user is about to be in the home/root directory
                } else if([[[self fsAbstraction] reduceStackToPath] isEqualToString:@"/"]){
                    
                    [buttonActionIdentifiers addObject:[AppConstants toolbarUploadActionStringIdentifier]];
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];

                    
                    //the user is navigated in a cloud directory, and now we update the toolbar
                } else {
                    [buttonActionIdentifiers addObject:[AppConstants toolbarUploadHereActionStringIdentifier]];
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];
                }

            //if our single selected file is not in local then our files are located in the cloud services
            } else {
                //if the user is navigated to the Local folder
                if ([[self fsInterface] filePath:[[self fsAbstraction] reduceStackToPath] isLocatedInsideDirectoryName:@"Local"]) {
                    
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDownloadHereActionStringIdentifier]];
                    //if the user is navigated to the Cloud
                } else {
                    [buttonActionIdentifiers addObject:[AppConstants toolbarDownloadActionStringIdentifier]];
                }
                
                [buttonActionIdentifiers addObject:[AppConstants toolbarDeleteActionStringIdentifier]];
            }
        }
        
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
        if ([actionIdentifier isEqualToString:[AppConstants toolbarDownloadActionStringIdentifier]]) {
            UIBarButtonItem *downloadButton = [self createToolbarButtonWithText:@"Download" AndImage:[AppConstants downloadImageStringIdentifier] andActionIdentifier:[AppConstants toolbarDownloadActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:downloadButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarDownloadHereActionStringIdentifier]]) {
            UIBarButtonItem *downloadHereButton = [self createToolbarButtonWithText:@"Download Here" AndImage:[AppConstants downloadImageStringIdentifier] andActionIdentifier:[AppConstants toolbarDownloadHereActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:downloadHereButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarCancelDownloadActionStringIdentifier]]) {
            UIBarButtonItem *cancelDownloadButton = [self createToolbarButtonWithText:@"Cancel Download" AndImage:[AppConstants cancelDownloadImageStringIdentifier] andActionIdentifier:[AppConstants toolbarCancelDownloadActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:cancelDownloadButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarCancelUploadActionStringIdentifier]]) {
            //cancelDownloadImageStringIdentifier  this is jsut the image strign identifier
            // is the same as for cancelling downloads because the icon
            //for cancelling an upload is teh same for a download, it's jsut a cancel.
            UIBarButtonItem *cancelDownloadButton = [self createToolbarButtonWithText:@"Cancel Upload" AndImage:[AppConstants cancelDownloadImageStringIdentifier] andActionIdentifier:[AppConstants toolbarCancelUploadActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:cancelDownloadButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarUploadActionStringIdentifier]]) {
            UIBarButtonItem *uploadButton = [self createToolbarButtonWithText:@"Upload" AndImage:[AppConstants uploadImageStringIdentifier] andActionIdentifier:[AppConstants toolbarUploadActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:uploadButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarUploadHereActionStringIdentifier]]) {
            UIBarButtonItem *uploadButton = [self createToolbarButtonWithText:@"Upload Here" AndImage:[AppConstants uploadImageStringIdentifier] andActionIdentifier:[AppConstants toolbarUploadHereActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:uploadButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarMoveActionStringIdentifier]]) {
            UIBarButtonItem *moveButton = [self createToolbarButtonWithText:@"Move Here" AndImage:[AppConstants moveImageStringIdentifier] andActionIdentifier:[AppConstants toolbarMoveActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:moveButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarDeleteActionStringIdentifier]]) {
            UIBarButtonItem *deleteButton = [self createToolbarButtonWithText:@"Delete" AndImage:[AppConstants deleteImageStringIdentifier] andActionIdentifier:[AppConstants toolbarDeleteActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:deleteButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarRenameActionStringIdentifier]]) {
            UIBarButtonItem *renameButton = [self createToolbarButtonWithText:@"Rename" AndImage:[AppConstants renameImageStringIdentifier] andActionIdentifier:[AppConstants toolbarRenameActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:renameButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarPreviewActionStringIdentifier]]) {
            UIBarButtonItem *previewButton = [self createToolbarButtonWithText:@"Preview" AndImage:[AppConstants previewImageStringIdentifier] andActionIdentifier:[AppConstants toolbarPreviewActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
                [fileOptions addObject:previewButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarActionsActionStringIdentifier]]) {
            UIBarButtonItem *actionsButton = [self createToolbarButtonWithText:@"Actions" AndImage:[AppConstants actionsImageStringIdentifier] andActionIdentifier:[AppConstants toolbarActionsActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:actionsButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarSendLinkActionStringIdentifier]]) {
            UIBarButtonItem *sendLinkButton = [self createToolbarButtonWithText:@"Send Link" AndImage:[AppConstants sendLinkToolbarImageStringIdentifier] andActionIdentifier:[AppConstants toolbarSendLinkActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:sendLinkButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
        else if ([actionIdentifier isEqualToString:[AppConstants toolbarSendActionStringIdentifier]]) {
            UIBarButtonItem *sendButton = [self createToolbarButtonWithText:@"Send" AndImage:[AppConstants paperAirplaneToolbarImageStringIdentifier] andActionIdentifier:[AppConstants toolbarSendActionStringIdentifier] AndWithTotalNumberOfButtonsOnToolbar:totalNumberOfButtonsOnToolbar];
            
            [fileOptions addObject:sendButton];
            if ([buttonActionIdentifiers indexOfObject:actionIdentifier] != [totalNumberOfButtonsOnToolbar intValue] - 1) {
                [fileOptions addObject:centerNegativeSeparator];
            }
        }
    }
    
    [_fileOptionsToolbar setItems:fileOptions animated:NO];
}

-(UIBarButtonItem*)createToolbarButtonWithText: (NSString*)text AndImage: (NSString*)imageStringIdentifier andActionIdentifier: (NSString*)actionIdentifier AndWithTotalNumberOfButtonsOnToolbar: (NSNumber*)numberOfButtonsOnToolbar {
    
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
    
    if ([actionIdentifier isEqualToString:[AppConstants toolbarDownloadActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarDownloadButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarDownloadHereActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarDownloadHereButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarUploadActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarUploadButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarCancelDownloadActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarCancelDownloadButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarCancelUploadActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarCancelUploadButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarUploadHereActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarUploadHereButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarMoveActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarMoveButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarDeleteActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarDeleteButtonpress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarRenameActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarRenameButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarPreviewActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarPreviewButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarActionsActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarActionsButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarSendLinkActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarSendLinkButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([actionIdentifier isEqualToString:[AppConstants toolbarSendActionStringIdentifier]]) {
        [buttonForBarButtonItem addTarget:self action:@selector(toolbarSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
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

//-(void)addDummyFilePackagesToInboxJSONWithFilePackageUUID: (NSString*)UUID andFile:(File*)file {
//    
//    MCPeerID *peerA = [[MCPeerID alloc]initWithDisplayName:@"peerA|ace32-e3d2v3-we23df2fg3-2eg223r2"];
//    
//    [_inboxManager addNewlyReceivedFileToInboxJsonWithFilePackageUUID:UUID andFile:file fromPeer:peerA];
//}

#pragma mark - Navigation

/* - Set the sendViewController's delegate to the HomeViewController - */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[sendViewController class]]) {
        //set the sendViewController's delegate to the home view controller
        ((sendViewController*)[segue destinationViewController]).sendViewControllerDelegate = (id)self.tabBarController;
        //Set the sendViewController's type of send
        ((sendViewController*)[segue destinationViewController]).sendType = _sendViewSendType;
        
        //set the send link delegate from teh service manager equal to the sendview controller so it can recieve shareable links
        _dbServiceManager.sendLinksFromServiceManagerDelegate = ((sendViewController*)[segue destinationViewController]);
        _gdServiceManager.sendLinksFromServiceManagerDelegate = ((sendViewController*)[segue destinationViewController]);
        
    } else if ([[segue destinationViewController] isKindOfClass:[NameFileViewController class]]) {
        // set the name file view controller's actionstring identifier to controller
        ((NameFileViewController*)[segue destinationViewController]).actionStringIdentifier = _nameFileViewControllerActionIdentifier;
    }
}

@end
