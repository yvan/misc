//
//  LinkView.h
//  
//
//  Created by Roman Scher on 12/31/15.
//
//

#import <UIKit/UIKit.h>
#import "LinkButton.h"
#import "AppConstants.h"

@interface LinkView : UIView

@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet LinkButton *linkButton;

@end
