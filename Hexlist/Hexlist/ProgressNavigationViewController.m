//
//  ProgressNavigationViewController.m
//  Hexlist
//
//  Created by Roman Scher on 8/13/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "ProgressNavigationViewController.h"

@interface ProgressNavigationViewController ()

@end

@implementation ProgressNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sendProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [_sendProgress setTintColor:[AppConstants appSchemeColorC]];
    [_sendProgress setTrackTintColor:[UIColor colorWithRed:208.0/255.0 green:143.0/255.0 blue:156.0/255.0 alpha:1.0]];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    _sendProgress.transform = transform;
    [self.view addSubview:_sendProgress];
    UINavigationBar *navBar = [self navigationBar];
    
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:_sendProgress attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-1];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:_sendProgress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:_sendProgress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    [_sendProgress setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_sendProgress setHidden:YES];
//    [_sendProgress setProgress:0.5 animated:NO];
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
