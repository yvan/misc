//
//  HomeCollectionViewCell.h
//  Hexlist
//
//  Created by Yvan Scher on 1/8/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *cellLabel;
@property (nonatomic, strong) IBOutlet UIImageView *cellImage;
@property (nonatomic, strong) IBOutlet UIImageView *cellImageSelected;

@end
