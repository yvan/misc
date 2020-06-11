//
//  LegalContentViewController.m
//  Hexlist
//
//  Created by Yvan Scher on 1/21/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "LegalContentViewController.h"

@interface LegalContentViewController ()

@end

@implementation LegalContentViewController

- (void)viewDidLoad {
    // this stack post
    // http://stackoverflow.com/questions/2832245/iphone-can-we-open-pdf-file-using-uiwebview
    
    [super viewDidLoad];
    
    // Navigation Bar Setup
    HighlightButton *backButton = [[HighlightButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:[AppConstants backArrowButtonImageStringIdentifier]] forState:UIControlStateNormal];
    
    [backButton setExclusiveTouch:YES];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    //Swipe back to settings
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPressed)];
    [rightSwipeGestureRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [self.legalContentWebView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGestureRecognizer];
    
    //if the thing we're supposed to
    //present is a privacy policy
    if (_legalType == LegalTypePrivacyPolicy){
        self.navigationItem.title = @"Privacy Policy";
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HexlistPrivacyPolicy" ofType:@"pdf"];
        NSURL *targetURL = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [_legalContentWebView loadRequest:request];
        //if the thing we're supposed to present
        //is the end user license agreement
    } else if (_legalType == LegalTypeEndUserLicenseAgreement) {
        self.navigationItem.title = @"EULA";
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HexlistEndUserLicense" ofType:@"pdf"];
        NSURL *targetURL = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [_legalContentWebView loadRequest:request];
    } else if (_legalType == LegalTypeAttribution) {
        self.navigationItem.title = @"Attributions";
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HexlistAttributions" ofType:@"pdf"];
        NSURL *targetURL = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [_legalContentWebView loadRequest:request];
    }
    [self.view addSubview:_legalContentWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popBackToRootViewController)
                                                 name:@"popBackToRootViewController"
                                               object:nil];
}

-(void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
