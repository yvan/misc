//
//  LinkPackageJM.h
//  
//
//  Created by Roman Scher on 12/29/15.
//
//

#import <JSONModel/JSONModel.h>

@interface LinkPackageJM : JSONModel

@property (strong, nonatomic) NSString *packageUUID;
@property (strong, nonatomic) NSString *senderUUID;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSArray *links;
@property (strong, nonatomic) NSString* timestamp;

@end
