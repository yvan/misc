//
//  NameFileViewController.m
//  Envoy
//
//  Created by Roman Scher on 8/22/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "NameFileViewController.h"

@interface NameFileViewController ()

@end

@implementation NameFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navigation Bar Update
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    _navigationBarBackgroundImage = navigationBar.backIndicatorImage;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    _navigationBarShadowImage = navigationBar.shadowImage;
    [navigationBar setShadowImage:[UIImage new]];
    
    HighlightButton *cancelButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [cancelButton addTarget:self action:@selector(cancelNameFileButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:[AppConstants cancelStringIdentifier]] forState:UIControlStateNormal];
    [cancelButton setExclusiveTouch:YES];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
          
    HighlightButton *acceptButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 26, 21)];
    [acceptButton addTarget:self action:@selector(acceptButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton setImage:[UIImage imageNamed:[AppConstants acceptWhiteImageStringIdentifier]] forState:UIControlStateNormal];
    [acceptButton setExclusiveTouch:YES];
    UIBarButtonItem *acceptBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:acceptButton];
    [self.navigationItem setRightBarButtonItem:acceptBarButtonItem];
    _acceptNameButton = acceptBarButtonItem;

    _savedTitleView = self.navigationItem.titleView;
    [self.navigationItem setTitleView:nil];
    [_acceptNameButton setEnabled:NO];
    
    if ([_actionStringIdentifier isEqualToString:[AppConstants toolbarRenameActionStringIdentifier]]) {
        [self.navigationItem setTitle:@"RENAME"];
    }
    else if ([_actionStringIdentifier isEqualToString:[AppConstants newFolderPopupImageStringIdentifier]]) {
        [self.navigationItem setTitle:@"NEW FOLDER"];
    }
    
    //Set Frame for Name File View
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _nameFileView = [[UIView alloc] initWithFrame:screenRect];
    CGPoint nameFileViewCenter = _nameFileView.center;
    _nameFileView.backgroundColor = [AppConstants appSchemeColor];
    
    NSNumber *numFilesSelected = [NSNumber numberWithInteger:[[[self fsAbstraction] selectedFiles] count]];
    
    //Create file icon image
    UIImage *fileIconImage;
    File *file;
    if ([_actionStringIdentifier isEqualToString:[AppConstants toolbarRenameActionStringIdentifier]]) {
        if ([numFilesSelected intValue] == 1) {
            file = ((File*)[[[self fsAbstraction] selectedFiles] objectAtIndex:0]);
            if(file.isDirectory){
                fileIconImage = [UIImage imageNamed:@"folder"];
            } else {
                fileIconImage = [self assignIconForFileType:file.name isSelected:NO];
            }
            UIImage *whiteFileIconImage = [AppConstants changeColorOfImage:fileIconImage ToColor:[UIColor whiteColor]];
            fileIconImage = whiteFileIconImage;
        }
    }
    UIImageView *fileIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 64)];
    if ([_actionStringIdentifier isEqualToString:[AppConstants toolbarRenameActionStringIdentifier]]) {
        [fileIconImageView setImage:fileIconImage];
    }
    else if ([_actionStringIdentifier isEqualToString:[AppConstants newFolderPopupImageStringIdentifier]]) {
        UIImage *whiteFileIconImage = [AppConstants changeColorOfImage:[UIImage imageNamed:[AppConstants folderImageStringIdentifier]] ToColor:[UIColor whiteColor]];
        [fileIconImageView setImage:whiteFileIconImage];
    }
    CGPoint imageLocation = nameFileViewCenter;
    //    imageLocation.y = imageLocation.y - 170;
    imageLocation.y = imageLocation.y - (screenRect.size.height/3.25);
    [fileIconImageView setCenter:imageLocation];
    
    //Create file name textfield
    UITextField *fileNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, screenRect.size.width - 40, 44)];
    _fileNameTextField = fileNameTextField;
    _fileNameTextField.delegate = self;
    [fileNameTextField setTextColor:[UIColor whiteColor]];
    [fileNameTextField setTintColor:[UIColor whiteColor]];
    [fileNameTextField setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:17]];
    [fileNameTextField setTextAlignment:NSTextAlignmentCenter];
    [fileNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [fileNameTextField setReturnKeyType:UIReturnKeyDone];
    if ([_actionStringIdentifier isEqualToString:[AppConstants toolbarRenameActionStringIdentifier]]) {
        [fileNameTextField setText:[file.name stringByDeletingPathExtension]];
        _originalFile = file;
    }
    CGPoint textFieldLocation = nameFileViewCenter;
    //    textFieldLocation.y = textFieldLocation.y - 120;
    textFieldLocation.y = textFieldLocation.y - (screenRect.size.height/3.25) + 50;
    [fileNameTextField setCenter:textFieldLocation];
    
    // Present nameFile view over home VC
    [_nameFileView addSubview:fileIconImageView];
    [_nameFileView addSubview:fileNameTextField];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissNameFileView)];
//    [_nameFileView addGestureRecognizer:tap];
    [self.view addSubview:_nameFileView];
    [fileNameTextField becomeFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(FileSystemInterface*) fsInterface{
    
    if(!_fsInterface){
        _fsInterface = [FileSystemInterface sharedFileSystemInterface];
    }
    return _fsInterface;
}

-(FileSystemAbstraction*) fsAbstraction{
    
    if(!_fsAbstraction){
        _fsAbstraction = [FileSystemAbstraction sharedFileSystemAbstraction];
    }
    return _fsAbstraction;
}

-(FileSystemFunctions*) fsFunctions {
    if(!_fsFunctions){
        _fsFunctions = [FileSystemFunctions sharedFileSystemFunctions];
    }
    return _fsFunctions;
}

/* - Called when we dismiss nameFileView - */

-(void)dismissNameFileView {
    [_fileNameTextField resignFirstResponder];
    
    //Custom animation overrides default pop animation for uinavigationcontroller
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    self.navigationController.navigationBar.shadowImage = _navigationBarShadowImage;
    [self.navigationController.navigationBar setBackgroundImage:_navigationBarBackgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    [self.navigationController popViewControllerAnimated:NO];
    [CATransaction commit];
}

/* - Dismisses nameFileView with cancel - */

-(void)cancelNameFileButtonPressed {
    NSLog(@"Cancel NameFile Button Pressed");
    
    [self dismissNameFileView];
}

-(void)acceptButtonPress {
    //if we're renaming a file set the button to the appropriate method for that.
    if([_actionStringIdentifier isEqualToString:[AppConstants toolbarRenameActionStringIdentifier]]){
        [self acceptNameFileButtonPressed];
    //if we're creating a new folder send us to the appropriate method for that.
    } else if ([_actionStringIdentifier isEqualToString:[AppConstants newFolderPopupImageStringIdentifier]]) {
        [self acceptNameFolderButtonPressed];
    }
}

//button press for accepting the creation of a new folder.
//ONLY for creating a new folder/file(but only folders for now). NOT for renaming.

-(void)acceptNameFolderButtonPressed {
    
    NSLog(@"accept Name Folder");
    
    NSString* newFolderPathToAttempt = [[[self fsAbstraction] reduceStackToPath] stringByAppendingPathComponent: _fileNameTextField.text];
    
    //if the path does not already exist make the file and everythang, then dismiss the view
    //if the user continually enters an invalid name (one that is already taken) the view
    //just sits there judging them, no feedback.
    if(![[self fsInterface] isValidPath:newFolderPathToAttempt]){
        File* newDir = [[File alloc] initWithName:_fileNameTextField.text andPath:newFolderPathToAttempt andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:YES andBoxId:@"-1"];
        
        //if the encoded file name is too long truncate that thing and its path
        if([newDir.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
            NSString* extension = [newDir.name pathExtension];
            newDir.name = [[newDir.name substringToIndex:newDir.name.length/2] stringByAppendingPathExtension:extension];
            newDir.path = [[newDir.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newDir.name];
        }
        
        [[self fsInterface] createDirectoryAtPath:newFolderPathToAttempt withIntermediateDirectories:NO attributes:nil];
        [[self fsInterface] saveSingleFileToFileSystemJSON:newDir inDirectoryPath:newDir.parentURLPath];
        [[[self fsAbstraction] currentDirectory] addObject:newDir];
        //reorganize index paths
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reorganizeIndexPathsFromNotification" object:self];
        //reload the collectionview
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
        [self dismissNameFileView];
    } else {
        [self alertUserToFileNameAlreadyExistsIsFolder:YES];
    }
}

/* - Dismisses nameFileView with accept for renaming an old file/folder - */
//button press for renaming ONLY renaming not creating a new folder/file

-(void)acceptNameFileButtonPressed {
    NSLog(@"Accept NameFile Button Pressed");
    
    //get the file entries stored in teh .filesystem.json where the file to be renamed is stored.
    //it can't be the current directory because we could be not in the same place when we press
    //rename, remove the file immediately from selected files
    File* singleSelectedFile = [[[self fsAbstraction] selectedFiles] lastObject];
    
    NSString* pathExtension = [singleSelectedFile.name pathExtension];
    NSString* newfileNameAndExten = @"";
    
    if(singleSelectedFile.isDirectory){// if it's a direcotry we're renaming don't mess w/ path extension.
        newfileNameAndExten = _fileNameTextField.text;
    } else { // if it's a non-directory then we deal w/ path extension
        newfileNameAndExten = [_fileNameTextField.text stringByAppendingPathExtension:pathExtension];
    }
    
    File* fileToAdd = [[File alloc] initWithName:newfileNameAndExten andPath:[[singleSelectedFile.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newfileNameAndExten] andDate:[NSDate date] andRevision:@"a" andDirectoryFlag:singleSelectedFile.isDirectory andBoxId:@"-1"];
    
     NSLog(@"NEW FOLDER PATH TO ATTEMPT %@", fileToAdd.path);
    
    //if the encoded file name is too long truncate that thing and its path
    if([fileToAdd.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].length > 255){
        NSString* extension = [fileToAdd.name pathExtension];
        fileToAdd.name = [[fileToAdd.name substringToIndex:fileToAdd.name.length/2] stringByAppendingPathExtension:extension];
        fileToAdd.path = [[fileToAdd.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileToAdd.name];
    }
    
    //if the file does NOT already exist create it.
    if (![[self fsInterface] isValidPath:fileToAdd.path]) {
        //move item works for both folders and non folder files
        if(singleSelectedFile.isDirectory){//if a directory don't deal w/ path extension
            [[self fsFunctions] moveFileAndSubChildrenByEnumeration:singleSelectedFile fromPath:singleSelectedFile.path toPath:fileToAdd.path];
        }else{//if it's a non-direcotry we gotta deal w/ path extension
            [[self fsFunctions] moveFileAndSubChildrenByEnumeration:singleSelectedFile fromPath:singleSelectedFile.path toPath:fileToAdd.path];
        }
        
        //replace the old file/folder in the reduce stack to path with the new file/folder
        //prevents the collectionview from bugging out and the user having to navigate
        //all the way back up the path of folders, ONLY DO THIS if we're not at or above
        //the folder if we're right above the folder looking at it and we try to remove
        //if from path stack, this will crash the app.
        if([singleSelectedFile.parentURLPath rangeOfString:[[self fsAbstraction] reduceStackToPath]].location == NSNotFound){
            [[self fsAbstraction] replaceFileInPathStack:singleSelectedFile withFile:fileToAdd];
        }
        
        //populate the current directory again with the new reduce stakc to path path (renamed path)
        [[self fsInterface] populateArrayWithFileSystemJSON:[[self fsAbstraction] currentDirectory] inDirectoryPath:[[self fsAbstraction] reduceStackToPath]];
        
        //reorganize index paths
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reorganizeIndexPathsFromNotification" object:self];
        //reload the collection view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];

        [self dismissNameFileView];
        
    //else if the file does already exist but the name is exactly the same, dismissthe view and remove selected files.
    // or if the path is valid and already exists.
    } else  {
        if ([_originalFile.name isEqualToString:fileToAdd.name]) {
            [[self fsAbstraction] removeAllObjectsFromSelectedFilesArray];
            //reorganize index paths
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reorganizeIndexPathsFromNotification" object:self];
            //reload the collectionview
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHomeCollectionViewNotification" object:self];
            [self dismissNameFileView];
        }
        else {
            [self alertUserToFileNameAlreadyExistsIsFolder:singleSelectedFile.isDirectory];
        }
    }
}

#pragma mark - UITextFieldDelegate

/* - These methods actively enable/disable name view accept button
 - depending on whether the text field has an input
 - */

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UITextFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:textField];
}

- (void) UITextFieldTextDidChange:(NSNotification*)notification
{
    NSLog(@"Text field changed");
    if ([_fileNameTextField.text length] != 0) {
        [_acceptNameButton setEnabled:YES];
    }
    else {
        [_acceptNameButton setEnabled:NO];
    }
}

/* - Sets behavior for 'next' and 'submit' keys on keyboard - */

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if (_fileNameTextField.text.length > 0) {
        [self acceptButtonPress];
    }
    else {
        [self alertToInvalidInputOrErrorWithTitle:@"" AndMessage:@"Please enter a name for this folder." AndButtonText:@"Ok"];
    }
    
    return YES;
}

-(void)alertToInvalidInputOrErrorWithTitle: (NSString*)title AndMessage: (NSString*)message AndButtonText: (NSString*)buttonText {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonText style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [_fileNameTextField becomeFirstResponder];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Helper Methods

-(void)alertUserToFileNameAlreadyExistsIsFolder:(BOOL)isFolder {
    UIAlertController* alert;
    if (isFolder) {
        alert = [UIAlertController alertControllerWithTitle:@"A folder with that name already exists."
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        alert = [UIAlertController alertControllerWithTitle:@"A file with that name already exists."
                                                    message:nil
                                             preferredStyle:UIAlertControllerStyleAlert];

    }
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [_fileNameTextField becomeFirstResponder];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(UIImage *) assignIconForFileType:(NSString *)filename isSelected:(BOOL)selected{
    
    NSString *fileExtension = [filename pathExtension];
    UIImage *image;
    fileExtension = [fileExtension lowercaseString];
    if(selected){
        
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-sel", fileExtension]];
        if(image == nil){//we don't have a proper image file for this type of file yet then put a generic placeholder
            image = [UIImage imageNamed:@"unidentified-sel"];
        }
    }else{
        
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", fileExtension]];
        if(image == nil){//we don't have a proper image file for this type of file yet then put a generic placeholder
            image = [UIImage imageNamed:@"unidentified"];
        }
    }
    return image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
