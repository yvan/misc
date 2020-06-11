//
//  DBQueryLimitWrapper.h
//  Envoy
//
//  Created by Yvan Scher on 10/9/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBQueryLimitWrapper : NSObject

@property (nonatomic) NSString* path1; // destination path for uploads, source path for downloads
@property (nonatomic) NSString* path2; // source path for uploads, desination path for downloads
@property (nonatomic) int numberOfTimesQueried;
@property (nonatomic) int typeOfQuery;

-(instancetype) initWithPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery;

@end
