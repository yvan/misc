//
//  GiveNameViewController.m
//  Hexlist
//
//  Created by Roman Scher on 1/7/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "GiveNameViewController.h"

@interface GiveNameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet HighlightButton *continueButton;

@end

@implementation GiveNameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Navigation Bar Setup
    HighlightButton *backButton;
    if (_nameViewType == NameViewTypeGiveName) {
        backButton =[[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 26, 21)];
    }
    else {
        backButton =[[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    }
    
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonImageStringIdentifier]] forState:UIControlStateNormal];
    [backButton setExclusiveTouch:YES];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    
    _leftButton = backButton;

    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    
    //Dissmiss Keyboard on tap off of textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //Swipe back to intro screen
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPressed)];
    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
    // Setup
    [_continueButton.layer setCornerRadius:5];
    _firstNameInput.delegate = self;
    _lastNameInput.delegate  = self;
    [_firstNameInput setTintColor:[UIColor whiteColor]];
    [_lastNameInput setTintColor:[UIColor whiteColor]];
    [_firstNameInput setText:[SettingsManager getUserFirstName]];
    [_lastNameInput setText:[SettingsManager getUserLastName]];
    if (![_firstNameInput.text isEqualToString: @""] && ![_lastNameInput.text isEqualToString: @""]) {
        [_continueButton setEnabled:YES];
    }
    else {
        [_continueButton setEnabled:NO];
        [_continueButton setAlpha:0.5];
    }
    
    if (_nameViewType == NameViewTypeChangeName) {
        [_continueButton setAlpha:0.0];
        self.navigationItem.title = @"Change Name";
        [_prompt setHidden:YES];
        [_leftButton setImage:[UIImage imageNamed:[AppConstants cancelImageStringIdentifier]] forState:UIControlStateNormal];
        
        HighlightButton *acceptButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 26, 21)];
        [acceptButton addTarget:self action:@selector(continueButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [acceptButton setImage:[UIImage imageNamed:[AppConstants acceptWhiteImageStringIdentifier]] forState:UIControlStateNormal];
        [acceptButton setExclusiveTouch:YES];
        UIBarButtonItem *acceptBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:acceptButton];
        [self.navigationItem setRightBarButtonItem:acceptBarButtonItem];
        
        _rightButton = acceptButton;
        
        [_rightButton setEnabled:NO];
    }
    
    if (_nameViewType != NameViewTypeGiveName) {
         [_firstNameInput becomeFirstResponder];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popBackToRootViewController)
                                                 name:@"popBackToRootViewController"
                                               object:nil];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    if (_nameViewType == NameViewTypeGiveName) {
        [_firstNameInput becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissThisViewController {
    if (_nameViewType == NameViewTypeGiveName) {
       [self.navigationController popViewControllerAnimated:YES];
    }
    else {
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

#pragma mark - IBActions

/* - Used with custom back button image to keep consistency with the homeVC back button - */

-(void)backButtonPressed {
    [self dismissThisViewController];
}

-(void)dismissKeyboard {
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
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
    if ([_firstNameInput.text length] != 0 && [_lastNameInput.text length] != 0) {
        if (_nameViewType == NameViewTypeGiveName) {
            [_continueButton setEnabled:YES];
            [_continueButton setAlpha:1.0];
        }
        else {
            [_rightButton setEnabled:YES];
        }
    }
    else {
        if (_nameViewType == NameViewTypeGiveName) {
            [_continueButton setEnabled:NO];
            [_continueButton setAlpha:0.5];
        }
        else {
            [_rightButton setEnabled:NO];
        }
    }
}

/* - Sets behavior for 'next' and 'submit' keys on keyboard - */

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _firstNameInput) {
        [textField resignFirstResponder];
        [_lastNameInput becomeFirstResponder];
    }
    else if (textField == _lastNameInput) {
        [self continueButtonPress: self];
    }
    
    return YES;
}

#pragma mark - Validation 

/* - Checks if name input is valid - */

-(BOOL)validFirstName: (NSString*)firstName AndLastName: (NSString*)lastName {
    
    NSString *fullDisplayName = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
    
    BOOL validName = YES;
    NSString *invalidNameReason;
    
    if ([firstName length] == 0 && [lastName length] == 0) {
        validName = NO;
        invalidNameReason = @"Please enter your first and last name!";
    }
    else if ([firstName length] == 0) {
        validName = NO;
        invalidNameReason = @"Please enter your first name!";
    }
    else if ([lastName length] == 0) {
        validName = NO;
        invalidNameReason = @"Please enter your last name!";
    }
    else if ([fullDisplayName length] > 26) {
        validName = NO;
        invalidNameReason = @"Your full name must be 25 characters or less.";
    }
    else if (!([fullDisplayName rangeOfString:@"|"].location == NSNotFound)) {
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

#pragma mark - Navigation

/* - Saves first and last name - */
- (IBAction)continueButtonPress:(id)sender {
    
    //Trim all inputs
    NSString *firstNameTrimmed = [_firstNameInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *lastNameTrimmed = [_lastNameInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([self validFirstName:firstNameTrimmed AndLastName:lastNameTrimmed]) {
        
        [SettingsManager setUserFirstName:firstNameTrimmed];
        [SettingsManager setUserLastName:lastNameTrimmed];
        
        [self dismissKeyboard];
        
        if (_nameViewType == NameViewTypeChangeName) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userChangedNameNotification" object:self];
            [self dismissThisViewController];
        }
        else {
            UITabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"multipeerInitializerTabBarController"];
            tabBarVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:tabBarVC animated:YES completion:nil];
        }
    }
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
