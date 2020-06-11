//
//  FileLoadingObject.m
//  Airdoc
//
//  Created by Yvan Scher on 4/4/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "FileLoadingObject.h"

@implementation FileLoadingObject

-(instancetype) initWithFile:(File*)file andProgress:(CGFloat)progress andOldProgress:(CGFloat)oldProgress andIndexPath:(NSIndexPath*)indexpath oldReduceStack:(NSString*)originalReducedStack{
    
    _file = file;
    _progress = progress;
    _oldProgress = oldProgress;
    _originalReducedStack = originalReducedStack;
    _indexpath = indexpath;
    return self;
}

@end
