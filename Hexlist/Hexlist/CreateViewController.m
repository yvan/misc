//
//  CreateViewController.m
//  Hexlist
//
//  Created by Roman Scher on 8/22/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "CreateViewController.h"

@interface CreateViewController ()

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    //Create navbar buttons
    HighlightButton *cancelButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:[AppConstants cancelImageStringIdentifier]] forState:UIControlStateNormal];
    [cancelButton setExclusiveTouch:YES];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    _cancelButton = cancelButton;
          
    HighlightButton *acceptButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 26, 21)];
    [acceptButton addTarget:self action:@selector(acceptButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton setImage:[UIImage imageNamed:[AppConstants acceptWhiteImageStringIdentifier]] forState:UIControlStateNormal];
    [acceptButton setExclusiveTouch:YES];
    UIBarButtonItem *acceptBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:acceptButton];
    [self.navigationItem setRightBarButtonItem:acceptBarButtonItem];
    
    _acceptButton = acceptButton;
    [_acceptButton setEnabled:NO];
    
    
    [_infoLabel setHidden:YES];
    _hexagon.adjustsImageWhenHighlighted = NO;
    
    [_nameTextField setTintColor:[UIColor whiteColor]];
     _nameTextField.delegate = self;
    [_nameTextField becomeFirstResponder];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    if (_createViewAction == CreateViewActionCreateHex) {
        self.navigationItem.title = @"New Hex";
        _nameTextField.placeholder = @"Add a description";
        [_hexagon setTintColor:[AppConstants niceRandomColor]];
        
        //Draw First Letters of first & name in User Circle
        NSArray *firstAndLastName = [[SettingsManager getUserDisplayableFullName] componentsSeparatedByString:@" "];
        NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
        //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
        firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
        
        //Set color and text of hexagon
        [_hexagon setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
    }
    else if (_createViewAction == CreateViewActionEditHex) {
        self.navigationItem.title = @"Edit Hex";
        _nameTextField.placeholder = @"Add a description";
        _nameTextField.text = _hexToEdit.hexDescription;
        [_hexagon setTintColor:[AppConstants colorFromHexString:_hexToEdit.hexColor]];
        
        //Draw First Letters of first & name in User Circle
        NSArray *firstAndLastName = [[SettingsManager getUserDisplayableFullName] componentsSeparatedByString:@" "];
        NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
        //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
        firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
        
        //Set color and text of hexagon
        [_hexagon setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
    }
    else if (_createViewAction == CreateViewActionCloudSend) {
        self.navigationItem.title = @"Send Hex";
        _nameTextField.placeholder = @"Give a description";
        UIColor *myHexColor = [AppConstants colorFromHexString:[SettingsManager getMyHexColor]];
        if (![myHexColor isEqual:[AppConstants myHexColorDefault]]) {
            [_hexagon setTintColor:myHexColor];
        }
        else {
            [_hexagon setTintColor:[AppConstants niceRandomColor]];
        }
        
        //Draw First Letters of first & name in User Circle
        NSArray *firstAndLastName = [[SettingsManager getUserDisplayableFullName] componentsSeparatedByString:@" "];
        NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
        //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
        firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
        
        //Set color and text of hexagon
        [_hexagon setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
    }
    else if (_createViewAction == CreateViewActionEditLink) {
        self.navigationItem.title = @"Edit Link";
        _nameTextField.placeholder = @"Add a description";
        _nameTextField.text = _linkToEdit.linkDescription;
        [_hexagon setUserInteractionEnabled:NO];
        
        //Better sizing for link descriptions
        [_nameTextField setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:22]];
        
        _infoLabel.text = _linkToEdit.url;
        [_infoLabel setHidden:NO];
        [_hexagon setTitle:nil forState:UIControlStateNormal];
        [_hexagon setTintColor:[UIColor whiteColor]];
//        [_hexagon setBackgroundImage:nil forState:UIControlStateNormal];
        [_hexagon setBackgroundImage:[UIImage imageNamed:[AppConstants linkEditImageStringIdentifier]] forState:UIControlStateNormal];
    }
    else if (_createViewAction == CreateViewActionViewLink) {
        self.navigationItem.title = @"Link Info";
        _nameTextField.placeholder = @"Link description";
        _nameTextField.text = _linkToEdit.linkDescription;
        [_nameTextField setUserInteractionEnabled:NO];
        [_hexagon setUserInteractionEnabled:NO];
        [_nameTextField resignFirstResponder];
        
        //Better sizing for link descriptions
        [_nameTextField setFont:[UIFont fontWithName:[AppConstants appFontNameB] size:22]];
        
        _infoLabel.text = _linkToEdit.url;
        [_infoLabel setHidden:NO];
        [_acceptButton setHidden:YES];
        [_hexagon setTitle:nil forState:UIControlStateNormal];
        [_hexagon setTintColor:[UIColor whiteColor]];
        //        [_hexagon setBackgroundImage:nil forState:UIControlStateNormal];
        [_hexagon setBackgroundImage:[UIImage imageNamed:[AppConstants linkEditImageStringIdentifier]] forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popBackToRootViewController)
                                                 name:@"popBackToRootViewController"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)popBackToRootViewController {
    [_nameTextField resignFirstResponder];
    
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

/* - Called when we dismiss view controller - */

-(void)dismissThisViewController {
    [_nameTextField resignFirstResponder];
    
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

-(void)dismissKeyboard {
    [_nameTextField resignFirstResponder];
}

#pragma mark - IBActions

/* - Dismisses nameFileView with cancel - */

-(void)cancelButtonPressed {    
    if (_createViewAction == CreateViewActionCloudSend) {
        [self popBackToRootViewController];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self dismissThisViewController];
    }
}

-(void)acceptButtonPress {
    NSString *description = [_nameTextField.text stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (_createViewAction == CreateViewActionCreateHex) {
        Hex *hex = [Hex createHexWithUUID:[[NSUUID UUID] UUIDString]
                            AndSenderUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                            AndSenderName:[SettingsManager getUserDisplayableFullName]
                        AndHexDescription:description
                              AndHexColor:[AppConstants hexStringFromColor:_hexagon.tintColor]];
        
        [HexManager saveNewHexToMyHexlist:hex WithLinks:_linksToSaveWithHex];
        
        id<CreateViewControllerDelegate> strongDelegate = self.createViewControllerDelegate;
        
        //show a hud to the user confirming the creation of their hex.
        if ([strongDelegate respondsToSelector:@selector(addedToHexShowHUD)]) {
            [strongDelegate addedToHexShowHUD];
        }
    }
    else if (_createViewAction == CreateViewActionEditHex) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        _hexToEdit.hexDescription = description;
        _hexToEdit.hexColor = [AppConstants hexStringFromColor:_hexagon.tintColor];
        [realm commitWriteTransaction];
        
        id<CreateViewControllerDelegate> strongDelegate = self.createViewControllerDelegate;
        
        if ([strongDelegate respondsToSelector:@selector(updateHex:WithDescription:AndColor:)]) {
            [strongDelegate updateHex:_hexToEdit WithDescription:_nameTextField.text AndColor:_hexagon.tintColor];
        }
    }
    else if (_createViewAction == CreateViewActionCloudSend) {
        
        //Convert Links into LinkJM dictionaries.
        NSMutableArray<NSDictionary*> *linkDictionaries = [[NSMutableArray alloc] init];
        for (LinkJM *linkJM in _linksToSendWithHex) {
            [linkDictionaries addObject:[linkJM toDictionary]];
        }
        
        //Form hex
        HexJM *sendableHexJM = [HexJM
                                createHexJMWithSenderUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                AndSenderName:[SettingsManager getUserDisplayableFullName]
                                AndHexDescription:description
                                AndHexColor:[AppConstants hexStringFromColor:_hexagon.tintColor]
                                AndLinks:linkDictionaries];
        
        id<CreateViewControllerDelegate> strongDelegate = self.createViewControllerDelegate;

        if ([strongDelegate respondsToSelector:@selector(hexJMPreparedForSend:)]) {
            [strongDelegate hexJMPreparedForSend:sendableHexJM];
        }
    }
    else if (_createViewAction == CreateViewActionEditLink) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        _linkToEdit.linkDescription = description;
        [realm commitWriteTransaction];
    }
    
    [self dismissThisViewController];
}

- (IBAction)hexagonPressed:(id)sender {
    [_hexagon setTintColor:[AppConstants niceRandomColor]];
    if (_nameTextField.text.length == 0 || _nameTextField.text.length > 40) {
        [_acceptButton setEnabled:NO];
    }
    else {
        [_acceptButton setEnabled:YES];
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:textField];
}

- (void) UITextFieldTextDidChange:(NSNotification*)notification {
    if (_nameTextField.text.length == 0 || _nameTextField.text.length > 40) {
        [_acceptButton setEnabled:NO];
    }
    else {
        [_acceptButton setEnabled:YES];
    }
}

/* - Sets behavior for 'next' and 'submit' keys on keyboard - */

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (_nameTextField.text.length >= 1 && _nameTextField.text.length <= 40) {
        [self acceptButtonPress];
    }
    else if (_nameTextField.text.length > 40)  {
        [self alertToInvalidInputOrErrorWithTitle:@"" AndMessage:@"Hex descriptions must be 40 characters or less." AndButtonText:@"Ok"];
    }
    else {
        [self alertToInvalidInputOrErrorWithTitle:@"" AndMessage:@"This hex needs a description!" AndButtonText:@"Ok"];
    }
    
    return YES;
}

-(void)alertToInvalidInputOrErrorWithTitle: (NSString*)title AndMessage: (NSString*)message AndButtonText: (NSString*)buttonText {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonText style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [_nameTextField becomeFirstResponder];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Helper Methods

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
