//
//  FileLoadingObject.h
//  Airdoc
//
//  Created by Yvan Scher on 4/4/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "File.h"

@interface FileLoadingObject : NSObject

@property (nonatomic) File* file;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat oldProgress;
@property (nonatomic) NSString* originalReducedStack;
@property (nonatomic) NSIndexPath* indexpath;

-(instancetype) initWithFile:(File*)file andProgress:(CGFloat)progress andOldProgress:(CGFloat)oldProgress andIndexPath:(NSIndexPath*)indexpath oldReduceStack:(NSString*)originalReducedStack;

@end
