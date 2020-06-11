//
//  SharedServiceManager.h
//  Hexlist
//
//  Created by Yvan Scher on 1/12/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "DBServiceManager.h"
#import "GDServiceManager.h"
#import "BXServiceManager.h"
#import <Foundation/Foundation.h>

@interface SharedServiceManager : NSObject

// these should eventually be internal and use methods to query
// and the service managers themselves.
@property (nonatomic) DBServiceManager* dbServiceManager;
@property (nonatomic) GDServiceManager* gdServiceManager;
@property (nonatomic) BXServiceManager* bxServiceManager;

+(id)sharedServiceManager;
-(int)getNumberOfAuthenticatedServices;
-(BOOL) serviceIsAuthorized:(ServiceType)serviceType;
-(NSMutableArray*) getArrayOfAuthenticatedServices;

@end
