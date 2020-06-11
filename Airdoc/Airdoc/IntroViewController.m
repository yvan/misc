//
//  IntroViewController.m
//  Airdoc
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
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[AppConstants desertAStringIdentifier]]];
    
    // Setup
    _localStorageManager = [[LocalStorageManager alloc] init];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
