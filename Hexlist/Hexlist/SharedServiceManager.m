//
//  SharedServiceManager.m
//  Hexlist
//
//  Created by Yvan Scher on 1/12/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "AppConstants.h"
#import "SharedServiceManager.h"

@implementation SharedServiceManager

+(id)sharedServiceManager {
    
    static dispatch_once_t pred;
    static SharedServiceManager *sharedServiceManager = nil;
    
    dispatch_once(&pred, ^{
        if(sharedServiceManager == nil) {
            sharedServiceManager = [[self alloc] init];
        }
    });
    

    return sharedServiceManager;
}

// gets the raw number of authenticated services.
-(int) getNumberOfAuthenticatedServices {
    int count = 0;
    NSArray* serviceTypes = [AppConstants allServiceTypes];
    for (NSNumber* serviceType in serviceTypes) {
        id serviceManager = [self getServiceManagerForService:[serviceType integerValue]];
        if([serviceManager respondsToSelector:@selector(isAuthorized)] && [serviceManager isAuthorized]) {
            count++;
        }
    }
    return count;
}

// gets a service manager for a given service object
-(id) getServiceManagerForService:(ServiceType)serviceType {
    if (serviceType == ServiceTypeDropbox) {
        return _dbServiceManager;
    } else if (serviceType == ServiceTypeBox) {
        return _bxServiceManager;
    } else if (serviceType == ServiceTypeGoogleDrive){
        return _gdServiceManager;
    } else {
        return nil;
    }
}

//checks whether a service is authorized
-(BOOL) serviceIsAuthorized:(ServiceType)serviceType {
    id serviceManager = [self getServiceManagerForService:serviceType];
    return ([serviceManager respondsToSelector:@selector(isAuthorized)] && [serviceManager isAuthorized]);
}

//gets an array of services that are authorized
-(NSArray*) getArrayOfAuthenticatedServices {
    NSMutableArray* authenticatedServices = [[NSMutableArray alloc] init];
    NSArray* serviceTypes = [AppConstants allServiceTypes];
    for (NSNumber* serviceType in serviceTypes) {
        id serviceManager = [self getServiceManagerForService:[serviceType integerValue]];
        if([serviceManager respondsToSelector:@selector(isAuthorized)] && [serviceManager isAuthorized]) {
            [authenticatedServices addObject:serviceType];
        }
    }
    
    return [authenticatedServices copy];
}


@end
