//
//  DataSendWrapper.m
//  Hexlist
//
//  Created by Roman Scher on 1/15/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "DataSendWrapper.h"

@implementation DataSendWrapper

//Constructors
+(DataSendWrapper*)createDataSendWrapperWithVersionID:(NSString*)versionID
                                     AndOperationType:(OperationType)operationType
                                      AndJMObjectType:(JMObjectType)jmObjectType
                                          AndJMObject:(JSONModel*)jmObject {
    
    DataSendWrapper *dataSendWrapper = [[DataSendWrapper alloc] init];
    dataSendWrapper.versionID = versionID;
    dataSendWrapper.operationType = [AppConstants stringForOperationType:operationType];
    dataSendWrapper.jmObjectType = [AppConstants stringForJMObjectType:jmObjectType];
    dataSendWrapper.jmObject = [jmObject toDictionary];
    
    return dataSendWrapper;
}

+(DataSendWrapper*)createDataSendWrapperWithVersionID:(NSString*)versionID
                                     AndOperationType:(OperationType)operationType
                                           AndMessage:(NSString*)message {
    
    DataSendWrapper *dataSendWrapper = [[DataSendWrapper alloc] init];
    dataSendWrapper.versionID = versionID;
    dataSendWrapper.operationType = [AppConstants stringForOperationType:operationType];
    dataSendWrapper.message = message;
    
    return dataSendWrapper;
}

@end
