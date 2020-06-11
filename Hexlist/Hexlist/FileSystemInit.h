//
//  FileSystemInit.h
//  Hexlist
//
//  Created by Yvan Scher on 3/24/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"
#import "AppConstants.h"
#import "FileSystemInterface.h"
#import "FileSystemAbstraction.h"
#import "SharedServiceManager.h"

@interface FileSystemInit : NSObject

#pragma mark FileSystemLazyLoad

@property (nonatomic) FileSystemInterface* fsInterface;
@property (nonatomic) FileSystemAbstraction* fsAbstraction;
@property (nonatomic) SharedServiceManager* sharedServiceManager;

-(FileSystemAbstraction*) fsAbstraction;
-(FileSystemInterface*) fsInterface;

#pragma mark FileSystemInitialization

-(File*) addFirstThreeContentSources;

@end
