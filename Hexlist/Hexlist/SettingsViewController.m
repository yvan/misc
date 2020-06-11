//
//  SettingsViewController.m
//  Hexlist
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "SettingsViewController.h"
//#import <BoxContentSDK/BOXContentSDK.h>
//#import <DropboxSDK/DropboxSDK.h>
#import <Foundation/Foundation.h>

@interface SettingsViewController ()

@end

#define USER_SECTION 0
#define SERVICES_SECTION 1
#define SUPPORT_SECTION 2
#define INTRO_SECTION 3


@implementation SettingsViewController

-(void)viewWillAppear:(BOOL)animated {
    [_settingsTableView reloadData];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Navigation Bar Setup
    HighlightButton *backButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if (_settingsContentType == SettingsContentTypeRoot) {
        [backButton setImage:[UIImage imageNamed:[AppConstants cancelImageStringIdentifier]] forState:UIControlStateNormal];
    }
    else {
        [backButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonImageStringIdentifier]] forState:UIControlStateNormal];
        
        //Swipe back to settings
        UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPressed)];
        [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
        [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
        [_settingsTableView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    }
    
    [backButton setExclusiveTouch:YES];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    // Setup
    _settingsViewControllerDelegate = (id)self.tabBarController;
    
    // Table view Setup
    [_settingsTableView setDelegate:self];
    [_settingsTableView setDataSource:self];
    _settingsTableView.rowHeight = 60;
    _settingsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _settingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _servicesToUnlink = [[NSMutableDictionary alloc] init];
    
    
    //make shared manager or rather procure it since it's intialized first in the home view controller
    _sharedManager = [SharedServiceManager sharedServiceManager];
    
    //get a list of all services
    _tempServicesArray = [_sharedManager getArrayOfAuthenticatedServices];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popBackToRootViewController)
                                                 name:@"popBackToRootViewController"
                                               object:nil];

    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        for (NSString *key in _servicesToUnlink) {
            
            NSString *serviceTypeString = [_servicesToUnlink objectForKey:key];
            ServiceType serviceType = [AppConstants serviceTypeForString:serviceTypeString];
            
            if (serviceType == ServiceTypeDropbox) {
                [_sharedManager.dbServiceManager unlinkService];
            }
            //unlink box
            else if (serviceType == ServiceTypeBox) {
                //get the client and log out
                [_sharedManager.bxServiceManager unlinkService];
            }
            //unlink google drive
            else if (serviceType == ServiceTypeGoogleDrive) {
                [_sharedManager.gdServiceManager unlinkService];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //normal view
    if (_settingsContentType == SettingsContentTypeRoot) {
        return 4;
    //legal view
    } else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numRows = 0;
    NSInteger numAuthedServices = [_tempServicesArray count];
    
    //normal view
    if (_settingsContentType == SettingsContentTypeRoot) {
        if (section == USER_SECTION) {
            numRows = 2;
        }
        else if (section == SERVICES_SECTION) {
            numRows = numAuthedServices;
        }
        else if (section == SUPPORT_SECTION) {
            numRows = 2;
        }
        else {
            numRows = 1;
        }
        return numRows;
    //legal view
    } else {
        return 3;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //normal view
    if (_settingsContentType == SettingsContentTypeRoot) {
        // User info section
        if (indexPath.section == USER_SECTION) {
            if (indexPath.row == 0) {
                SettingsCell *settingsCell = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellStringIdentifier]];
                
                settingsCell.leftLabel.text = @"Name";
                settingsCell.rightLabel.text = [SettingsManager getUserDisplayableFullName];
                
                return settingsCell;
            }
            else {
                MyHexColorCell *myHexColorCell = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants myHexColorCellStringIdentifier]];
                [myHexColorCell.bottomBorder setHidden:YES];
                
                NSString *userName = [SettingsManager getUserDisplayableFullName];
                
                //Draw First Letters of first & name in hexagon
                NSArray *firstAndLastName = [userName componentsSeparatedByString:@" "];
                NSString *firstLetterOfFirstName = [NSString stringWithFormat:@"%c" , [firstAndLastName[0] characterAtIndex:0]];
                //    NSString *firstletterOfLastName = [NSString stringWithFormat:@"%c" , [firstAndLastName[1] characterAtIndex:0]];
                firstLetterOfFirstName = [firstLetterOfFirstName uppercaseString];
                
                myHexColorCell.label.text = @"My Hex color";
                [myHexColorCell.hexagon setTitle:firstLetterOfFirstName forState:UIControlStateNormal];
                [myHexColorCell.hexagon addTarget:self action:@selector(hexagonButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [myHexColorCell.helperButton addTarget:self action:@selector(hexagonButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                
                NSString *myHexColor = [SettingsManager getMyHexColor];
                myHexColorCell.hexagon.tintColor = [AppConstants colorFromHexString:myHexColor];
                
                return myHexColorCell;
            }
        }
//        // User controls section
//        if (indexPath.section == 1) {
//            SettingsSwitchCell *settingsSwitchCell = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsSwitchCellStringIdentifier]];
//            [settingsSwitchCell.bottomBorder setHidden:YES];
//            
//            settingsSwitchCell.leftLabel.text = @"Keep device awake";
//            
//            [settingsSwitchCell.switchObject setOn:[SettingsManager getKeepDeviceAwakeSetting]];
//            
//            return settingsSwitchCell;
//        }
        // service managers...
        else if (indexPath.section == SERVICES_SECTION) {
            SettingsServiceCell *settingsServiceCell = [_settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsServiceCellStringIdentifier]];
            //iterate through all service and get a serivce manager for each
            
            NSNumber* serviceType = [_tempServicesArray objectAtIndex:indexPath.row];
//            NSString* servicename = [AppConstants presentableStringForServiceType:[serviceType integerValue]];
            NSString *serviceTypeString = [AppConstants stringForServiceType:[serviceType integerValue]];
            if ([_servicesToUnlink objectForKey:serviceTypeString] == nil) {
                [settingsServiceCell.switchObject setOn:YES];
            }
            else {
                [settingsServiceCell.switchObject setOn:NO];
            }
            
            settingsServiceCell.serviceImage.image = [AppConstants serviceNavImageForServiceType:[serviceType integerValue]];
            settingsServiceCell.label.text =  [NSString stringWithFormat:@"Linked"];
            
            
            if (indexPath.row == [_tempServicesArray count] - 1) {
                [settingsServiceCell.bottomBorder setHidden:YES];
            }
            
            return settingsServiceCell;
        }
        // unlink content source
        else if (indexPath.section == SUPPORT_SECTION){
            SettingsCellSpecial *settingsCellSpecial = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellSpecialStringIdentifier]];
            
            if (indexPath.row == 0) {
                settingsCellSpecial.centerLabel.text = @"Message us";
            } else {
                settingsCellSpecial.centerLabel.text = @"Legal";
                [settingsCellSpecial.bottomBorder setHidden:YES];
            }
            
            return settingsCellSpecial;
        }
        //Back to Intro
        else {
            SettingsCellSpecial *settingsCellSpecial = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellSpecialStringIdentifier]];
            settingsCellSpecial.centerLabel.text = @"Intro";
            [settingsCellSpecial.centerLabel setTextColor:[AppConstants appSchemeColor]];
            [settingsCellSpecial.bottomBorder setHidden:YES];
            
            return settingsCellSpecial;
        }
    //legal view
    } else {
        //privacy policy
        if (indexPath.row == 0) {
            SettingsCellSpecial *settingsCellSpecial = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellSpecialStringIdentifier]];
            settingsCellSpecial.centerLabel.text = @"Privacy Policy";
            return settingsCellSpecial;
        }
        //end user agreement
        else if (indexPath.row == 1) {
            SettingsCellSpecial *settingsCellSpecial = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellSpecialStringIdentifier]];
            settingsCellSpecial.centerLabel.text = @"End User License Agreement";
            return settingsCellSpecial;
        }
        //attributions
        else {
            SettingsCellSpecial *settingsCellSpecial = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellSpecialStringIdentifier]];
            settingsCellSpecial.centerLabel.text = @"Attributions";
            [settingsCellSpecial.bottomBorder setHidden:YES];
            return settingsCellSpecial;
        }
    }
}

#pragma mark - UITableViewDelegate

/* - Makes section headers dissapear if they don't have any cells - */

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == USER_SECTION) {
        return 22;
    }
    else {
        if (section == SERVICES_SECTION && [_tempServicesArray count] == 0) {
            return .1f;
        }
        else {
            return 21;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == INTRO_SECTION) {
        return 45;
    }
    else {
        return 1;
    }
}

//adding a footer to table view:
//http://stackoverflow.com/questions/14724415/uitableviewcells-footer-text-in-ios
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, 45)];
    if (section == 4) {
        footer.backgroundColor = [UIColor clearColor];
        UILabel *lbl = [[UILabel alloc]initWithFrame:footer.frame];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = [NSString stringWithFormat:@"Hexlist version %@", [SettingsManager getAppVersion]];
        [lbl setFont:[UIFont fontWithName:[AppConstants appFontNameA] size:15]];
        lbl.textAlignment = NSTextAlignmentCenter;
        [footer addSubview:lbl];
    }
    return footer;
}

#pragma mark MFMailDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    switch (result)
    {
        //cancel + delete
        case MFMailComposeResultCancelled:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Wow. You just flaked on us.";
                    hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
                    hud.userInteractionEnabled = NO;
                    [hud hide:YES afterDelay:1.5];
                });
                break;
            }
        //cancel + save for later
        case MFMailComposeResultSaved:
            {
                break;
            }
            
        //email sent
        case MFMailComposeResultSent:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Thanks. We love you.";
                    hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
                    hud.userInteractionEnabled = NO;
                    [hud hide:YES afterDelay:1.5];
                });
                break;
                
            }
        //failure?
        case MFMailComposeResultFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"There was a mystical failure.";
                    hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
                    hud.userInteractionEnabled = NO;
                    [hud hide:YES afterDelay:1.5];
                });
                break;
            }
        default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Here if you need to talk.";
                    hud.labelFont = [UIFont fontWithName:[AppConstants appFontNameB] size:18.0];
                    hud.userInteractionEnabled = NO;
                    [hud hide:YES afterDelay:1.5];
                });
                break;
            }
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //instant highlight of the cell, then unhighlight
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_settingsContentType == SettingsContentTypeRoot) {
        //Change Name
        if (indexPath.section == USER_SECTION && indexPath.row == 0) {
            [self performSegueWithIdentifier:@"settings-to-changename" sender:self];
        }
        
        // instatiate view controller from story board from this link:
        // https://coderwall.com/p/hvr8qq/instantiate-a-view-controller-using-a-storyboard-identifier-in-xcode-ios
        // sending mail:
        // http://stackoverflow.com/questions/310946/how-can-i-send-mail-from-an-iphone-application
        else if (indexPath.section == SUPPORT_SECTION){
            //selected legal cell
            //we pressed feedback.
            if (indexPath.row == 0) {
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
                    controller.mailComposeDelegate = self;
                    [controller setToRecipients:@[@"wizard@hexlist.com"]];
                    [controller setSubject:@"Wizard Feedback"];
                    [controller setMessageBody:@"Dear, wizards..." isHTML:NO];
                    if (controller) [self presentViewController:controller animated:YES completion:nil];
                } else {
                    
                }

            } else if (indexPath.row == 1) {
                //present a re-used version of this settings view controller
                SettingsViewController* settingsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"settings"];
                settingsViewController.settingsContentType = SettingsContentTypeLegal;
                settingsViewController.navigationItem.title = @"Legal";
                [self.navigationController pushViewController:settingsViewController animated:YES];
            }
        }
        
        //Back to intro
        else if (indexPath.section == INTRO_SECTION && indexPath.row == 0) {
            
            //KILL MULTIPEER SESSION
            id<SettingsViewControllerDelegate> strongDelegate = self.settingsViewControllerDelegate;
            
            if ([strongDelegate respondsToSelector:@selector(backToIntroScreenTapped)]) {
                [strongDelegate backToIntroScreenTapped];
            }
            
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            UINavigationController *introNavigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"introNavigationController"];
            IntroViewController *introViewController = (IntroViewController *)[storyboard instantiateViewControllerWithIdentifier:@"intro"];
            
            introViewController.presentedFromSettings = YES;
            
            [introNavigationController pushViewController:introViewController animated:NO];
            
            introNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            
            [self presentViewController:introNavigationController animated:YES completion:nil];
        }
        //legal view
    } else {
        if (indexPath.row == 0) {
            _legalType = LegalTypePrivacyPolicy;
        } else if (indexPath.row == 1) {
            _legalType = LegalTypeEndUserLicenseAgreement;
        } else if (indexPath.row == 2) {
            _legalType = LegalTypeAttribution;
        }
        [self performSegueWithIdentifier:@"legal-settings-to-webview" sender:self];
    }
}

#pragma mark - IBActions

-(void)hexagonButtonPress:(id)sender {
    MyHexColorCell *myHexColorCell = (MyHexColorCell*)[self GetCellFromTableView:_settingsTableView Sender:sender];
    
    UIColor *niceRandomColor = [AppConstants niceRandomColor];
    
    //Set the hexagon background color
    myHexColorCell.hexagon.tintColor = niceRandomColor;
    
    [SettingsManager setMyHexColor:[AppConstants hexStringFromColor:niceRandomColor]];
}

- (IBAction)switchTap:(id)sender {
    
    SettingsSwitchCell *settingsSwitchCell = (SettingsSwitchCell*)[self GetCellFromTableView:_settingsTableView Sender:sender];
    NSIndexPath *indexPath = [_settingsTableView indexPathForRowAtPoint: settingsSwitchCell.center];
    
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        [SettingsManager setKeepDeviceAwakeSettingTo: settingsSwitchCell.switchObject.on];
//        if ([SettingsManager getKeepDeviceAwakeSetting]) {
//            [UIApplication sharedApplication].idleTimerDisabled = YES;
//        }
//        else {
//            [UIApplication sharedApplication].idleTimerDisabled = NO;
//        }
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedKeepDeviceAwake" object:nil];
//    }
    //unlink dropbox
    if (indexPath.section == SERVICES_SECTION) {
        ServiceType serviceType = [((NSNumber*)[_tempServicesArray objectAtIndex:indexPath.row]) integerValue];
        NSString *serviceTypeString = [AppConstants stringForServiceType:serviceType];
        
        if (settingsSwitchCell.switchObject.on) {
            [_servicesToUnlink removeObjectForKey:serviceTypeString];
        }
        else {
            [_servicesToUnlink setObject:serviceTypeString forKey:serviceTypeString];
        }
    }
    
    //NSLog(@"servicesToUnlink: %@", _servicesToUnlink);
}

/* - Used with custom back button image to keep consistency with the homeVC back button - */

-(void)backButtonPressed {
    if (_settingsContentType == SettingsContentTypeRoot) {
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
    else {
        [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Helper Methods

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    return [tableView cellForRowAtIndexPath:indexPath];
}

 #pragma mark - Navigation
 
//  In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[LegalContentViewController class]]) {
        ((LegalContentViewController*)[segue destinationViewController]).legalType = _legalType;
    }
    else if ([[segue destinationViewController] isKindOfClass:[GiveNameViewController class]]) {
        ((GiveNameViewController*)[segue destinationViewController]).nameViewType = NameViewTypeChangeName;
    }
 }

@end
