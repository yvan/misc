//
//  DBQueryLimitWrapper.m
//  Envoy
//
//  Created by Yvan Scher on 10/9/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "DBQueryLimitWrapper.h"

@implementation DBQueryLimitWrapper

-(instancetype) initWithPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery{
    _path1 = path1;
    _path2 = path2;
    _typeOfQuery = typeOfQuery;
    return self;
}

@end
