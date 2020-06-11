//
//  SettingsViewController.m
//  Airdoc
//
//  Created by Roman Scher on 1/6/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

-(void)viewWillAppear:(BOOL)animated {
    [_settingsTableView reloadData];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Navigation Bar Setup
    HighlightButton *backButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:[AppConstants cancelStringIdentifier]] forState:UIControlStateNormal];
    [backButton setExclusiveTouch:YES];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    // Setup
    _settingsViewControllerDelegate = (id)self.tabBarController;
    _localStorageManager = [[LocalStorageManager alloc] init];
    _connectedPeopleManager = [ConnectedPeopleManager sharedConnectedPeopleManager];
    
    // Table view Setup
    [_settingsTableView setDelegate:self];
    [_settingsTableView setDataSource:self];
    _settingsTableView.rowHeight = 60;
    _settingsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    _settingsTableView.separatorColor = [UIColor clearColor];
    _settingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Swipe to home
//    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPressed)];
//    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
//    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
//    [_settingsTableView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backButtonPressed)
                                                 name:@"popSettingsViewController"
                                               object:nil];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numRows = 0;
    
    if (section == 0) {
        numRows = 1;
    }
    if (section == 1) {
        numRows = 2;
    }
    else if (section == 2) {
        numRows = 2;
    }
    else if (section == 3) {
        numRows = 1;
    }
    return numRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // User info section
    if (indexPath.section == 0) {
        SettingsCell *settingsCell = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellStringIdentifier]];
        
        settingsCell.leftLabel.text = @"Name";
        settingsCell.rightLabel.text = [LocalStorageManager getUserDisplayableFullName];
        
        return settingsCell;
    }
    // User controls section
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SettingsSwitchCell *settingsSwitchCell = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsSwitchCellStringIdentifier]];
            settingsSwitchCell.selectionStyle = UITableViewCellSelectionStyleNone;
            settingsSwitchCell.leftLabel.text = @"Keep device awake";
            
            [settingsSwitchCell.switchObject setOn:[LocalStorageManager getKeepDeviceAwakeSetting]];
            
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(20, 59, [[UIScreen mainScreen] bounds].size.width - 40, .5)];
            line.backgroundColor = [AppConstants settingsTableViewSeparatorColor];
            [settingsSwitchCell addSubview:line];
            
            return settingsSwitchCell;
        }
        else {
            SettingsSwitchCell *settingsSwitchCell = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsSwitchCellStringIdentifier]];
            settingsSwitchCell.selectionStyle = UITableViewCellSelectionStyleNone;
            settingsSwitchCell.leftLabel.text = @"Receive push notifications";
            
            [settingsSwitchCell.switchObject setOn:[LocalStorageManager getReceivePushNotificationsSetting]];
            
            return settingsSwitchCell;
        }
    }
    // Envoy section
    else if (indexPath.section == 2) {
        SettingsCellSpecial *settingsCellSpecial = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellSpecialStringIdentifier]];
        
        if (indexPath.row == 0) {
            settingsCellSpecial.centerLabel.text = @"Send Feedback";
            [settingsCellSpecial.centerLabel setTextColor:[UIColor blackColor]];
            
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(20, 59, [[UIScreen mainScreen] bounds].size.width - 40, .5)];
            line.backgroundColor = [AppConstants settingsTableViewSeparatorColor];
            [settingsCellSpecial addSubview:line];
        }
        else {
            settingsCellSpecial.centerLabel.text = @"About Envoy";
            [settingsCellSpecial.centerLabel setTextColor:[UIColor blackColor]];
        }
        
        return settingsCellSpecial;
    }
    //Back to Intro
    else {
        SettingsCellSpecial *settingsCellSpecial = [self.settingsTableView dequeueReusableCellWithIdentifier:[AppConstants settingsCellSpecialStringIdentifier]];
        settingsCellSpecial.centerLabel.text = @"Intro Screen";
        [settingsCellSpecial.centerLabel setTextColor:[AppConstants appSchemeColor]];
        
        return settingsCellSpecial;
    }
}

#pragma mark - UITableViewDelegate

/* - Makes section headers dissapear if they don't have any cells - */

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 22;
    }
    else {
        return 21;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return 22;
    }
    else {
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Change Name
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"settings-to-changename" sender:self];
    }
    //Keep device awake
    else if (indexPath.section == 1 && indexPath.row == 0) {

    }
    //Push notifications
    else if (indexPath.section == 1 && indexPath.row == 1) {
        
    }
    //Send Feedback
    else if (indexPath.section == 2 && indexPath.row == 0) {
        
    }
    //About
    else if (indexPath.section == 2 && indexPath.row == 1) {
        
    }
    //Back to intro
    else if (indexPath.section == 3 && indexPath.row == 0) {
        
        //KILL MULTIPEER SESSION
        id<SettingsViewControllerDelegate> strongDelegate = self.settingsViewControllerDelegate;
        
        if ([strongDelegate respondsToSelector:@selector(backToIntroScreenTapped)]) {
            [strongDelegate backToIntroScreenTapped];
        }
        
        //Dissmisses multipeerInitializerTabBarController if intro VC was used, or present intro view controller
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
        if ([appDelegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
               
            UINavigationController *introNavigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"introNavigationController"];
            IntroViewController *introViewController = (IntroViewController *)[storyboard instantiateViewControllerWithIdentifier:@"intro"];
               
            [introNavigationController pushViewController:introViewController animated:NO];
               
            introNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:introNavigationController animated:YES completion:nil];
        }
    }
}

#pragma mark - IBActions

- (IBAction)switchTap:(id)sender {
    
    SettingsSwitchCell *settingsSwitchCell = (SettingsSwitchCell*)[self GetCellFromTableView:_settingsTableView Sender:sender];
    NSIndexPath *indexPath = [_settingsTableView indexPathForRowAtPoint: settingsSwitchCell.center];
    
    // Push Notifications
    if (indexPath.section == 1 && indexPath.row == 0) {
        [LocalStorageManager setKeepDeviceAwakeSettingTo: settingsSwitchCell.switchObject.on];
        if ([LocalStorageManager getKeepDeviceAwakeSetting]) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
        else {
            //If multipeer isn't active with a send/reception, turn device idle timer back on
            if (![_connectedPeopleManager currentlyInTheProcessOfSending] || ![_connectedPeopleManager currentlyInTheProcessOfReceiving]) {
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedKeepDeviceAwake" object:nil];
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        [LocalStorageManager setReceivePushNotificationsSettingTo:settingsSwitchCell.switchObject.on];
    }
}

/* - Used with custom back button image to keep consistency with the homeVC back button - */

-(void)backButtonPressed {
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

#pragma mark - Helper Methods

/* - Method returns cell when cell's button is pushed - */

-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    return [tableView cellForRowAtIndexPath:indexPath];
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
