//
//  IntroViewController.m
//  Hexlist
//
//  Created by Roman Scher on 1/4/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController()

@end

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!_presentedFromSettings) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
        [super viewWillDisappear:animated];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[AppConstants desertAImageStringIdentifier]]];
    
    if (!_presentedFromSettings) {
        //Swipe back to settings
        UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(beginButtonPressed)];
        [leftSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
        [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    }
    
    NSRange rangeTerms = [_termsOfServiceText.text rangeOfString:@"End User License Agreement"];
    NSRange rangePrivacy = [_termsOfServiceText.text rangeOfString:@"Privacy Policy"];
    [_termsOfServiceText addLinkToURL:[NSURL URLWithString:@"http://hexlist.com/assets/HexlistEndUserLicense.pdf"] withRange:rangeTerms];
    [_termsOfServiceText addLinkToURL:[NSURL URLWithString:@"http://hexlist.com/assets/HexlistPrivacyPolicy.pdf"] withRange:rangePrivacy];
    _termsOfServiceText.delegate = self;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

-(IBAction)beginButtonPressed {
    if (_presentedFromSettings) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self performSegueWithIdentifier:@"intro-to-give-name" sender:self];
    }
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[GiveNameViewController class]]) {
        ((GiveNameViewController*)[segue destinationViewController]).nameViewType = NameViewTypeGiveName;
    }
}



@end
