//
//  ChangeNameViewController.m
//  Airdoc
//
//  Created by Roman Scher on 3/27/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "ChangeNameViewController.h"

@interface ChangeNameViewController ()

@end

@implementation ChangeNameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    HighlightButton *backButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 20, 24)];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonStringIdentifier]] forState:UIControlStateNormal];
    [backButton setExclusiveTouch:YES];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    
    HighlightButton *acceptButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 26, 21)];
    [acceptButton addTarget:self action:@selector(submitButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton setImage:[UIImage imageNamed:[AppConstants acceptWhiteImageStringIdentifier]] forState:UIControlStateNormal];
    [acceptButton setExclusiveTouch:YES];
    UIBarButtonItem *acceptBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:acceptButton];
    [self.navigationItem setRightBarButtonItem:acceptBarButtonItem];
    _submitButton = acceptBarButtonItem;
    
    //Dissmiss Keyboard on tap off of textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //Swipe back to settings 
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPressed)];
    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [_nameTableView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    
    // Setup
    _localStorageManager = [[LocalStorageManager alloc] init];
    
    // Table view Setup
    [_submitButton setEnabled:NO];
    [_nameTableView setDelegate:self];
    [_nameTableView setDataSource:self];
    _nameTableView.rowHeight = 60;
    _nameTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    _nameTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NameCell *nameCell = [self.nameTableView dequeueReusableCellWithIdentifier:[AppConstants nameCellStringIdentifier]];
        
    if (indexPath.row == 0) {
        nameCell.label.text = @"First Name";
        nameCell.textField.text = [LocalStorageManager getUserFirstName];
        nameCell.textField.returnKeyType = UIReturnKeyDone;
        nameCell.textField.enablesReturnKeyAutomatically = YES;
        nameCell.textField.delegate = self;
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(20, 59, [[UIScreen mainScreen] bounds].size.width - 40, .5)];
        line.backgroundColor = [AppConstants settingsTableViewSeparatorColor];
        [nameCell addSubview:line];
    }
    else if (indexPath.row == 1) {
        nameCell.label.text = @"Last Name";
        nameCell.textField.text = [LocalStorageManager getUserLastName];
        nameCell.textField.returnKeyType = UIReturnKeyDone;
        nameCell.textField.enablesReturnKeyAutomatically = YES;
        nameCell.textField.delegate = self;
    }
    
    return nameCell;
    
}

#pragma mark - UITableViewDelegate

/* - Causes selection of the cell to start editing the cell's textfield - */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NameCell *nameCell = (NameCell*)[tableView cellForRowAtIndexPath:indexPath];
    [nameCell.textField becomeFirstResponder];
}

#pragma mark - IBAction

-(void)dismissKeyboard {
    [((NameCell *)[_nameTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField resignFirstResponder];
    [((NameCell *)[_nameTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField resignFirstResponder];
}

- (IBAction)submitButtonTap:(id)sender {

    NSString *newFirstName = [((NameCell*)[_nameTableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]]).textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *newLastName = [((NameCell*)[_nameTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Name validation
    if ([self validNewFirstName: newFirstName AndNewLastName: newLastName]) {
        [LocalStorageManager setUserFirstName:newFirstName];
        [LocalStorageManager setUserLastName:newLastName];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/* - Used with custom back button image to keep consistency with the homeVC back button - */

-(void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

/* - These methods actively enable/disable submit button
 - depending on whether all fields have inputs
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
    NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *secondCellIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    if ([((NameCell *)[self.nameTableView cellForRowAtIndexPath:firstCellIndexPath]).textField.text length] != 0 && [((NameCell *)[self.nameTableView cellForRowAtIndexPath:secondCellIndexPath]).textField.text length] != 0) {
            [_submitButton setEnabled:YES];
    }
    else {
        [_submitButton setEnabled:NO];
    }
}

/* - Sets behavior for 'done' key on keyboard - */

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self submitButtonTap: self];
    return YES;
}

#pragma mark - Validation

/* - Checks if name input is valid - */

-(BOOL)validNewFirstName: (NSString*)newFirstName AndNewLastName: (NSString*)newLastName{
    
    BOOL validName = YES;
    NSString *invalidNameReason;
    NSString *newFullDisplayName = [[[newFirstName stringByAppendingPathComponent:@" "]  stringByAppendingPathComponent:newLastName] lowercaseString];
    
    if ([newFirstName length] == 0 && [newLastName length] == 0) {
        validName = NO;
        invalidNameReason = @"Please enter your first and last name!";
    }
    else if ([newFirstName length] == 0) {
        validName = NO;
        invalidNameReason = @"Please enter your first name!";
    }
    else if ([newLastName length] == 0) {
        validName = NO;
        invalidNameReason = @"Please enter your last name!";
    }
    if (newFullDisplayName.length > 26) {
        validName = NO;
        invalidNameReason = @"Your full name must be 25 characters or less.";
    }
    else if (!([newFullDisplayName rangeOfString:@"|"].location == NSNotFound)) {
        validName = NO;
        invalidNameReason = @"Thats not a name.";
    }
    
    if (!validName) {
        [self AlertToInvalidInputOrErrorWithTitle:@"" AndMessage:invalidNameReason AndButtonText:@"Ok"];
    }
    
    return validName;
}

-(void)AlertToInvalidInputOrErrorWithTitle: (NSString*)title AndMessage: (NSString*)message AndButtonText: (NSString*)buttonText {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonText style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
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
