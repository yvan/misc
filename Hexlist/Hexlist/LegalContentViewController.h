//
//  LegalContentViewController.h
//  Hexlist
//
//  Created by Yvan Scher on 1/21/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "HighlightButton.h"

@interface LegalContentViewController : UIViewController

@property (nonatomic, assign) LegalType legalType;
@property (nonatomic) IBOutlet UIWebView* legalContentWebView;

@end
