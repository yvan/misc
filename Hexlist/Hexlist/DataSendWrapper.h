//
//  DataSendWrapper.h
//  Hexlist
//
//  Created by Roman Scher on 1/15/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "AppConstants.h"
#import "SettingsManager.h"

@interface DataSendWrapper : JSONModel

@property (strong, nonatomic) NSString *versionID;
@property (strong, nonatomic) NSString *operationType;
@property (strong, nonatomic) NSString<Optional> *message;
@property (strong, nonatomic) NSString<Optional> *jmObjectType;
@property (strong, nonatomic) NSDictionary<Optional> *jmObject;

//Constructor
+(DataSendWrapper*)createDataSendWrapperWithVersionID:(NSString*)versionID
                                     AndOperationType:(OperationType)operationType
                                          AndJMObjectType:(JMObjectType)jmObjectType
                                              AndJMObject:(JSONModel*)jmObject;

+(DataSendWrapper*)createDataSendWrapperWithVersionID:(NSString*)versionID
                                     AndOperationType:(OperationType)operationType
                                           AndMessage:(NSString*)message;

@end
