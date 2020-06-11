//
//  HexJM.h
//  Hexlist
//
//  Created by Roman Scher on 1/13/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "LinkJM.h"

@interface HexJM : JSONModel

@property (strong, nonatomic) NSString<Optional> *senderUUID;
@property (strong, nonatomic) NSString<Optional> *senderName;
@property (strong, nonatomic) NSString<Optional> *hexDescription;
@property (strong, nonatomic) NSString<Optional> *hexColor;
@property (strong, nonatomic) NSArray<NSDictionary*><Optional> *links;

//Constructor
+(HexJM*)createHexJMWithSenderUUID:(NSString*)senderUUID
                     AndSenderName:(NSString*)senderName
                 AndHexDescription:(NSString*)hexDescription
                       AndHexColor:(NSString*)hexColor
                          AndLinks:(NSArray<NSDictionary*>*)links;

+(void)fillInMissingHexJMFieldsWithDefaultValues:(HexJM*)hexJM;

@end
