//
//  SelectedFilesViewController.m
//  Airdoc
//
//  Created by Roman Scher on 3/17/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "SelectedFilesViewController.h"

@interface SelectedFilesViewController ()

@end

@implementation SelectedFilesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _splitFoldersQueue = dispatch_queue_create("Split Folders Queue", DISPATCH_QUEUE_SERIAL);
    
    //Draw the sendButton & Shadow
    _sendButton.layer.cornerRadius = _sendButton.frame.size.width/2;
    _sendButton.backgroundColor = [AppConstants appSchemeColor];
    [_sendButton setHighlightColor:[AppConstants addButtonPopupSelectionColor]];
    [_sendButton setNormalColor:_sendButton.backgroundColor];
    [_sendButton setImage:[UIImage imageNamed:[AppConstants sendImageStringIdentifier]] forState:UIControlStateNormal];
    _sendButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _sendButton.layer.shadowOpacity = .5f;
    _sendButton.layer.shadowOffset = CGSizeZero;
    _sendButton.layer.shadowRadius = 1.5f;
    _sendButton.layer.shadowOffset = CGSizeMake(0.0, 1.5f);
    _sendButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_sendButton.bounds cornerRadius:_sendButton.frame.size.width/2].CGPath;
    [_sendButton setExclusiveTouch:YES];
    [_sendButton setHidden:![[[self fsAbstraction] selectedFiles] count] > 0];
    
    //Navigation Bar Setup
    _collectionViewBackButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 20, 24)];
    [_collectionViewBackButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_collectionViewBackButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonStringIdentifier]] forState:UIControlStateNormal];
    [_collectionViewBackButton setExclusiveTouch:YES];
    _collectionViewBackBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_collectionViewBackButton];
    
    //Unselect button
    HighlightButton* unselectButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [unselectButton addTarget:self action:@selector(unselectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [unselectButton setImage:[UIImage imageNamed:[AppConstants unselectXStringIdentifier]] forState:UIControlStateNormal];
    [unselectButton setExclusiveTouch:YES];
    _unselectBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:unselectButton];
    
    [self.navigationItem setLeftBarButtonItem:_collectionViewBackBarButtonItem];
    [self.navigationItem setRightBarButtonItem: [[[self fsAbstraction] selectedFiles] count] > 0? _unselectBarButtonItem : nil];
    
    //GESTURE RECOGNIZER: Right swipe to dismiss this VC
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipeRight)];
    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [_selectedFilesCollectionView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    [_emptyMessageScrollView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    
    //GESTURE RECOGNIZER: Long Press for collectionView
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.minimumPressDuration = .35; //seconds
    longPressRecognizer.delegate = self;
    [_selectedFilesCollectionView addGestureRecognizer:longPressRecognizer];

    // Setup
    _selectedFilesViewControllerDelegate = [self.navigationController.viewControllers objectAtIndex:0];
    _selectedFilesCollectionView.delegate = self;
    _selectedFilesCollectionView.dataSource = self;
    
    _dbServiceManager = [[DBServiceManager alloc] init];
    _gdServiceManager = [[GDServiceManager alloc] init];
    
    //Make room for sendButton
    _selectedFilesCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    
    //Add listener for selectedFilesUpdated notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filesToSendUpdated)
                                                 name:@"filesToSendUpdated"
                                               object:nil];
    //empties out and cleans up after we send.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emptyFilesAndDismissOnSend) name:@"emptyFilesAndDismissOnSend"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backButtonPressed:)
                                                 name:@"popSelectedFilesVC"
                                               object:nil];
    
    // Setup
    _selectedFilesViewControllerDelegate = [self.navigationController.viewControllers objectAtIndex:0];
    _selectedFilesCollectionView.delegate = self;
    _selectedFilesCollectionView.dataSource = self;
    _selectedFilesCollectionView.allowsMultipleSelection = YES; //...ugh...can'tbeleive I forgot that.
    
    _arrayForFoldersToDisplay = [[NSMutableArray alloc]init];
    _arrayForNonFoldersToDisplay = [[NSMutableArray alloc]init];
    
    _dbServiceManager.selectedFilesViewCloudNavDelegate = self;
    _gdServiceManager.selectedFilesViewCloudNavDelegate = self;
    
    // Do any additional setup after loading the view.
    //this creates a copy of the original selectedFilesArray in these two new mutable arrays
    //we use these to display the files we want and deteremine whether they are selected
    //files that we need to display ( all file icons
    
    _selectedFilesArrayCopy = [[NSMutableArray alloc] init];
    _fileLoadingFilesCopy = [[NSMutableArray alloc] init];
    
    //only load file objects from the file loading copy if those file objects were also
    //originall selected files
    for(File* fileSelected in [[self fsAbstraction] arrayForLoadingFiles]) {
        if ([[[self fsAbstraction] selectedFiles] containsObject:fileSelected]) {
            [_fileLoadingFilesCopy addObject:fileSelected];
        }
    }
    
    //add objects from selected files in a copy of that array
    //for proper display in the selecte files view controller
    for(File* fileSelected in [[self fsAbstraction] selectedFiles]){
        
        if(![_fileLoadingFilesCopy containsObject:fileSelected]){
            [_selectedFilesArrayCopy addObject:fileSelected];
        }
    }
    
    _filesToDisplay = [[NSMutableArray alloc] initWithArray:_selectedFilesArrayCopy]; //currentDirectory equivalent
    _selectedFilesToDisplay = [[NSMutableArray alloc] initWithArray:_selectedFilesArrayCopy]; //selected files equivalent
    
    //we need this or else cloud services will double add
    //the contents on a re-navigate.
    [[self fsAbstraction] removeAllObjectsFromFilesToSendArray];
    [[self fsAbstraction] addObjectsToFilesToSendFromArray:[[self fsAbstraction]selectedFiles]];
    [self splitFoldersAndDontReloadCollectionView];
    
    //both the label and the view need the frame.
    
    // Set navigation Title depending on where files are selected from
    if ([_filesToDisplay count] != 0) {
        if ([[self fsInterface] filePath:((File*)[_filesToDisplay objectAtIndex:0]).path isLocatedInsideDirectoryName:@"Dropbox"]) {
            [self setNavigationItemToTextAndImage:[AppConstants dropboxNavStringIdentifier]];
        }
        else if ([[self fsInterface] filePath:((File*)[_filesToDisplay objectAtIndex:0]).path isLocatedInsideDirectoryName:@"GoogleDrive"]) {
            [self setNavigationItemToTextAndImage:[AppConstants googleDriveNavStringIdentifier]];
        }
        else if ([[self fsInterface] filePath:((File*)[_filesToDisplay objectAtIndex:0]).path isLocatedInsideDirectoryName:@"Local"]) {
            [self setNavigationItemToTextAndImage:[AppConstants localNavStringIdentifier]];
        }
    }
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

-(NSMutableArray*) directoryPathStackCopy{
    
    if(!_directoryPathStackCopy){_directoryPathStackCopy = [[NSMutableArray alloc]init];}
    return _directoryPathStackCopy;
}

-(BOOL) pushOntoPathStack:(File*) directoryToPush{
    
    if (directoryToPush.isDirectory == YES) {
        [[self directoryPathStackCopy] addObject:directoryToPush];
        NSLog(@"%s DIRECTORY PUSHED ONTO STACK IN SELECTED FILES VIEW: %@", __PRETTY_FUNCTION__, directoryToPush.name);
        return YES;
    }
    NSLog(@"%s YOU LITTLE SHIT, WHY YOU TRY TO PUSH NON-FOLDER ONTO STACK?: %@", __PRETTY_FUNCTION__, directoryToPush.name);
    return NO;
}

-(File*) popDirectoryOffPathStack{
    
    File* returnObj = [_directoryPathStackCopy lastObject];
    if (returnObj) {
        [_directoryPathStackCopy removeLastObject];
        NSLog(@"%s DIRECTORY POPPED OFF OF STACK: %@", __PRETTY_FUNCTION__, returnObj.name);
    }
    return returnObj;
}

-(NSString *) reduceStackCopyToPath{
    
    NSString* path = @"/";
    for(File* file in [self directoryPathStackCopy]){
        path = [path stringByAppendingPathComponent:file.name];
    }
    NSLog(@"%s PATH COMPONENT REDUCING: %@", __PRETTY_FUNCTION__, path);
    return path;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //if we've got nothing to show on reload
    //set the message and hide the collection view.
    if([_filesToDisplay count] == 0){
        collectionView.hidden=YES;
        if([[self reduceStackCopyToPath] isEqualToString:@"/"]){
            _emptyTableMessage.text = @"No Files Selected";
            [_sendButton setHidden:YES];
        }else{
            _emptyTableMessage.text = @"Nothing Here";//for an empty selected file
        }
    } else {
        [_sendButton setHidden:NO];
        collectionView.hidden = NO;
    }

    return [_filesToDisplay count];
}

-(HomeCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeCollectionViewCell* cell;
    File* file;
    
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    
    BOOL fileIsSelected = [_selectedFilesToDisplay containsObject:file];
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //Set File Cell Image
    if(file.isDirectory){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectedFileCell" forIndexPath:indexPath];
        
        //Get rid of border from reusing cell
        [cell.cellImageSelected.layer setBorderWidth:0.0];
        
        cell.cellImage.image = [self assignIconForFileType:file isSelected:NO];
        cell.cellImageSelected.image = [self assignIconForFileType:file isSelected:YES];
        
        if(fileIsSelected){
            cell.cellImageSelected.hidden = NO;
            cell.cellImage.hidden = YES;
        }else{
            cell.cellImageSelected.hidden = YES;
            cell.cellImage.hidden = NO;
        }
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectedFileCell" forIndexPath:indexPath];
        
        //Get rid of border from reusing cell
        [cell.cellImageSelected.layer setBorderWidth:0.0];
        
        if([self isFileAnImage:file.name] && [[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"Local"]){
            
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
            
            NSString *previousDirectory = [self reduceStackCopyToPath];
            
            if(fileIsSelected){
                [cell.cellImageSelected setHidden:NO];
                [cell.cellImage setHidden:YES];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                    UIImage* imageForCell = [self getImageForCellFromPath:file.path];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [UIView transitionWithView:cell.cellImageSelected
                                          duration:.25
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            HomeCollectionViewCell *cellNow = (HomeCollectionViewCell*)[_selectedFilesCollectionView cellForItemAtIndexPath:indexPath];
                                            
                                            //Only load image if we haven't changed directory
                                            if ([previousDirectory isEqualToString:[self reduceStackCopyToPath]]) {
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
                        [UIView transitionWithView:cell.cellImage
                                          duration:.25
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            HomeCollectionViewCell *cellNow = (HomeCollectionViewCell*)[_selectedFilesCollectionView cellForItemAtIndexPath:indexPath];
                                            
                                            //Only load image if we haven't changed directory
                                            if ([previousDirectory isEqualToString:[self reduceStackCopyToPath]]) {
                                                cellNow.cellImage.image = imageForCell;
                                                cellNow.cellImageSelected.image = imageForCell;
                                                cellNow.cellImageSelected.layer.borderColor = [UIColor colorWithRed:214.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0].CGColor;
                                            }
                                        } completion:nil];
                    });
                });
            }
        }else{
            cell.cellImageSelected.image = [self assignIconForFileType:file isSelected:YES];
            cell.cellImage.image = [self assignIconForFileType:file isSelected:NO];
            
            if(fileIsSelected){
                cell.cellImageSelected.hidden = NO;
                cell.cellImage.hidden = YES;
            }else{
                cell.cellImageSelected.hidden = YES;
                cell.cellImage.hidden = NO;
            }
        }
    }
    
    //Set File Cell Text
    cell.cellLabel.text = file.name;
    cell.cellLabel.numberOfLines = 2;
    cell.cellLabel.preferredMaxLayoutWidth = 97.0;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    File* file;
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    //1. whn we navigate in we first find the filesystem.json on the disk
    //to populate teh contents
    if (file.isDirectory) {
        // - THE "pressedXFolder" should be separate and test for an absolute path that proves
        // - it is the dropbox/googledrive/ or box folder, otherwise and path where the word "Box"
        // - or "Dropbox" or "GoogleDrive" is a substring will trigger the authentication process.
        // - if we pressed the dropbox cell/folder icon in the collectionview at the root directory
        if([[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"Dropbox"]){
            // - check to make sure out account is registered, if it is not present registration - //
            [_dbServiceManager pressedDropboxFolder:self withFile:file shouldReloadMainView:NO];
            [self hideCollectionView];
        }else if([[self fsInterface] filePath:file.path isLocatedInsideDirectoryName:@"GoogleDrive"]){
            [_gdServiceManager pressedGoogleDriveFolder:self withFile:(File*)file shouldReloadMainView:NO andMoveToGD:NO];
            [self hideCollectionView];
        }else{
            
            //got rid of the if/else with all the cloud services, we hust need one of them.
            //push file onto the stack, this is meant to be used on folders
            [[self fsInterface] populateArrayWithFileSystemJSON:[self filesToDisplay] inDirectoryPath:file.path];
            
            [self pushOntoPathStack:file];
            [self splitFoldersAndReloadCollectionView];
        }
    }else{
        //deals with resolving the quite complicated state
        //problem of deteremining whether a file is selected
        //or not. I know it sounds simple. It is not.
        //there are many features/scenarios that complicate
        //the state for selected files.
        [self resolveSelectionOfFilesWithIndexPath:indexPath];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    File* file;
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    if (file.isDirectory) {
        // - push file onto the stack, this is meant to be used on folders - //
        [self pushOntoPathStack:file];
        [[self fsInterface] populateArrayWithFileSystemJSON:[self filesToDisplay] inDirectoryPath:[[self fsAbstraction]reduceStackToPath]];
        //split the newly populated current directory into
        //folders and non folders arrays for ordering
        //during the display
        
        [self splitFoldersAndReloadCollectionView];
    } else {
        [self resolveSelectionOfFilesWithIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize fileIconSize;
    fileIconSize.height = 121;
    fileIconSize.width = 100;
    return fileIconSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
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

//tests is a file is an image, may have to support more image types in the future.

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

//function to resolve the selection of files/folders
//called in the longpress handler and file select
//to make sure that selection occurs in a consistent
//manner

-(void) resolveSelectionOfFilesWithIndexPath: (NSIndexPath*)indexPath {
    
    File* file;
    HomeCollectionViewCell* cell;
    
    if(indexPath.row < [_arrayForFoldersToDisplay count]){
        file = [_arrayForFoldersToDisplay objectAtIndex:indexPath.row];
    }else{
        file = [_arrayForNonFoldersToDisplay objectAtIndex:indexPath.row - [_arrayForFoldersToDisplay count]];
    }
    
    BOOL fileIsSelected = [_selectedFilesToDisplay containsObject:file];
    
    //Remove File
    if(fileIsSelected){
        [_selectedFilesToDisplay removeObject:file];
        [[self fsAbstraction] removeObjectFromFilesToSend:file];
    //Add File
    } else {
        [_selectedFilesToDisplay addObject:file];
        [[self fsAbstraction] addObjectToFilesToSend:file];
    }
    
    //Show or hide the cell
    cell = (HomeCollectionViewCell*)[_selectedFilesCollectionView cellForItemAtIndexPath:indexPath];
    if(fileIsSelected){
        [cell.cellImageSelected setHidden:YES];
        [cell.cellImage setHidden:NO];
    }else{
        [cell.cellImageSelected setHidden:NO];
        [cell.cellImage setHidden:YES];
    }
}

//reload the collectionview on a dispatch async queue
-(void) splitFoldersAndReloadCollectionView{
    //first split the folders, then reload the collectionview.
    dispatch_sync(_splitFoldersQueue, ^{
        [self splitFoldersAndNonFolders];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [_selectedFilesCollectionView reloadData];
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

//method we call after we populate the current directory with the filesystem.json
//should also sort the folders/files by name alphabetically
-(void) splitFoldersAndNonFolders{
    [_arrayForFoldersToDisplay removeAllObjects];
    [_arrayForNonFoldersToDisplay removeAllObjects];
    for(File* file in _filesToDisplay){
        if(file.isDirectory){
            [_arrayForFoldersToDisplay addObject:file];
        }else{
            [_arrayForNonFoldersToDisplay addObject:file];
        }
    }
    _arrayForFoldersToDisplay = [[NSMutableArray alloc] initWithArray:[[self fsFunctions]  sortFoldersOrFiles:_arrayForFoldersToDisplay] copyItems:YES];
    _arrayForNonFoldersToDisplay = [[NSMutableArray alloc] initWithArray:[[self fsFunctions] sortFoldersOrFiles:_arrayForNonFoldersToDisplay] copyItems:YES];
}

-(void) unselectAllCellImages {
    for (int i = 0; i<[_filesToDisplay count]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_selectedFilesCollectionView cellForItemAtIndexPath:indexPath];
        [cell.cellImageSelected setHidden:YES];
        [cell.cellImage setHidden:NO];
    }
}

-(void) selectAllCellImages {
    for (int i = 0; i<[_selectedFilesToDisplay count]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        HomeCollectionViewCell* cell = (HomeCollectionViewCell*)[_selectedFilesCollectionView cellForItemAtIndexPath:indexPath];
        [cell.cellImageSelected setHidden:NO];
        [cell.cellImage setHidden:YES];
    }
}

#pragma mark - IBActions

/* - sendButton appears when there are visible files in selectedFilesVC - */

-(IBAction)sendButtonPressed:(id)sender {
    _sendViewSendType = [AppConstants SEND_TYPE_FILE];
    [self performSegueWithIdentifier:@"selectedFiles-to-send" sender:self];
}

- (IBAction)unselectButtonPressed:(id)sender {
    [self.navigationItem setRightBarButtonItem:nil];
    //reset the images, then repopulate the array to empty
    [self unselectAllCellImages];
    [_selectedFilesToDisplay removeAllObjects];
    //mirror selected files to display
    [[self fsAbstraction] removeAllObjectsFromFilesToSendArray];
}

/* - Used with custom back button image to keep consistency with the homeVC back button - */
- (IBAction)backButtonPressed:(id)sender {
    //if we're not in a file (the string is empty), then put up the custom back button
    if([[self reduceStackCopyToPath] isEqualToString:@"/"]){
        //this for loop just looks at what selection changes the user
        //has made in the selected files view and propagates them
        //back into the normal file collection view.
        [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
        [_selectedFilesToDisplay addObjectsFromArray:_fileLoadingFilesCopy];
        for(File* fileToPropagateSelection in _selectedFilesToDisplay){
            if(![[[self fsAbstraction] selectedFiles] containsObject:fileToPropagateSelection]){
                [[self fsAbstraction] addObjectToSelectedFiles:fileToPropagateSelection];
            }
        }
        //tells the hoemview controller to reload its collectionview
        //to propagate cahnges in selected files made in the selected fiel view
        [_selectedFilesViewControllerDelegate selectedFileViewPoppedOff];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self popDirectoryOffPathStack];
        //if aftwer we do a pop and we're back at the original selected view
        //repopulate the files to show with items from that array.
        if([[self reduceStackCopyToPath] isEqualToString:@"/"]){
            [_filesToDisplay removeAllObjects];
            [_filesToDisplay addObjectsFromArray:_selectedFilesArrayCopy];
        }else{//if there's still stuff on the stack path and it's not "/" then make it a backarrow
            File* fileToLoad = [[self directoryPathStackCopy] lastObject];
            NSLog(@"%@", fileToLoad.path);
            //do not repopulate selectedFilesTodisplay.
            //this also works for the cloud because the cloud beams the json files and creates the directories
            //into the right places
            [[self fsInterface] populateArrayWithFileSystemJSON:_filesToDisplay inDirectoryPath:fileToLoad.path];
        }
        
        [self splitFoldersAndReloadCollectionView];
    }
}

-(void)userSwipeRight {
    //Dismiss selectedFilesViewController, do not replace this with a call to [self cancelButton]
    //this for loop just looks at what selection changes the user
    //has made in the selected files view and propagates them
    //back into the normal file collection view.
    [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
    [_selectedFilesToDisplay addObjectsFromArray:_fileLoadingFilesCopy];
    for(File* fileToPropagateSelection in _selectedFilesToDisplay){
        if(![[[self fsAbstraction] selectedFiles] containsObject:fileToPropagateSelection]){
            [[self fsAbstraction] addObjectToSelectedFiles:fileToPropagateSelection];
        }
    }
    //tells the hoemview controller to reload its collectionview
    //to propagate cahnges in selected files made in the selected fiel view
    [_selectedFilesViewControllerDelegate selectedFileViewPoppedOff];
    [self.navigationController popViewControllerAnimated:YES];
}

//handles the long press event of a user.
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    CGPoint p = [gestureRecognizer locationInView:_selectedFilesCollectionView];
    NSIndexPath *indexPath = [_selectedFilesCollectionView indexPathForItemAtPoint:p];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (indexPath == nil){
            NSLog(@"%s COULDN'T FIND INDEX PATH IN handleLongPress", __PRETTY_FUNCTION__);
        }else{
            //in the future this long press event for a non-folder file
            //will open a viewer, it will not select the file.
            [self resolveSelectionOfFilesWithIndexPath:indexPath];
        }
    }
}

-(void)sendLinkButtonPressed: (UIButton*)sender {
    
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
        [self performSegueWithIdentifier:@"selectedFiles-to-send" sender:self];
    }
}

#pragma mark - Alerts

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


#pragma mark - Helper methods

-(void)setNavigationItemToTextAndImage: (NSString*)imageStringIdentifier {
    UILabel* labelForTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 112, self.navigationController.navigationBar.frame.size.height)];
    UIImage *image = [UIImage imageNamed:imageStringIdentifier];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    UIView* viewForTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 152, self.navigationController.navigationBar.frame.size.height)];
    
    labelForTitle.text = @"Selected in";
    labelForTitle.textColor = [UIColor whiteColor];
    labelForTitle.textAlignment = NSTextAlignmentCenter;
    [labelForTitle setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:20.0]];
    
    CGRect frame = imageView.frame;
    frame.origin.x = 113;
    imageView.frame = frame;
    
    [viewForTitleView addSubview:labelForTitle];
    [viewForTitleView addSubview:imageView];
    
//    [labelForTitle setBackgroundColor:[UIColor colorWithRed:100 green:100 blue:100 alpha:.25]];
//    [viewForTitleView setBackgroundColor:[UIColor colorWithRed:50 green:50 blue:50 alpha:.5]];
//    [imageView setBackgroundColor:[UIColor colorWithRed:100 green:100 blue:100 alpha:.25]];
    
    //DO NOT USE addsubview here
    self.navigationItem.titleView = viewForTitleView;
}

#pragma mark - NSNotificationCenter

-(void)filesToSendUpdated {
    //Show or hide Send Button
    if ([[[self fsAbstraction] filesToSend] count] == 0) {
        [_sendButton setUserInteractionEnabled:NO];
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             [_sendButton setAlpha:0.0];
                         }
                         completion:nil];
    }
    else {
        File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
        //if our single selected file is in local then all our files are located in the Local folder
        
        //Show send button
        if ([[self fsInterface]filePath:singleSelectedFile.path isLocatedInsideDirectoryName:@"Local"]) {
            [_sendButton removeTarget:self action:@selector(sendLinkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
            [_sendButton setImage:[UIImage imageNamed:[AppConstants sendImageStringIdentifier]] forState:UIControlStateNormal];
            [_sendButton setUserInteractionEnabled:YES];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 [_sendButton setAlpha:1.0];
                             }
                             completion:nil];
        }
        //Show sendLink button
        else {
            [_sendButton removeTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_sendButton addTarget:self action:@selector(sendLinkButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
            [_sendButton setImage:[UIImage imageNamed:[AppConstants sendLinkImageStringIdentifier]] forState:UIControlStateNormal];
            [_sendButton setUserInteractionEnabled:YES];
            [UIView animateWithDuration:.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 [_sendButton setAlpha:1.0];
                             }
                             completion:nil];
        }
    }
    
    //Show or hide unselected Button
    [self.navigationItem setRightBarButtonItem: [[[self fsAbstraction] filesToSend] count] > 0? _unselectBarButtonItem : nil];
}

-(void)emptyFilesAndDismissOnSend {
    //cleanup after a user has hit send.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self unselectAllCellImages];
        [_sendButton setHidden:YES];
    });
                   
     [_selectedFilesToDisplay removeAllObjects];
}

#pragma mark CloudNavigateDelegate

//responds to incoming data from the cloud. WE NEED THIS TO POPULATE THE DIRECTORY
-(void)populateWithFilesToDisplay:(NSMutableArray*)newFilesToDisplay withPassed:(File *)file{
    [[self filesToDisplay] removeAllObjects];
    [[self fsAbstraction] removeAllObjectsFromFilesToSendArray];
    [[self filesToDisplay] addObjectsFromArray:newFilesToDisplay];
    [[self fsAbstraction] addObjectsToFilesToSendFromArray:_selectedFilesToDisplay];
    [self showCollectionView];
    [self pushOntoPathStack:file];
    [self splitFoldersAndReloadCollectionView];
}

//hides the collection view
//when we are waiting for the cloud
//to load
-(void) hideCollectionView{
    _selectedFilesCollectionView.hidden = YES;
    _selectedFilesCollectionView.userInteractionEnabled = NO;
    _emptyTableMessage.text = @"";
    [_collectionViewActivityIndicator startAnimating];
}

//re-shows the collection view when
//the cloud files are ready do do stuff.
-(void) showCollectionView{
    _selectedFilesCollectionView.hidden = NO;
    _selectedFilesCollectionView.userInteractionEnabled = YES;
    [_collectionViewActivityIndicator stopAnimating];
}
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
        
    }
}

@end
