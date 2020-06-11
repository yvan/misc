//
//  HexJM.m
//  Hexlist
//
//  Created by Roman Scher on 1/13/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "HexJM.h"

@implementation HexJM

//Constructor
+(HexJM*)createHexJMWithSenderUUID:(NSString*)senderUUID
                     AndSenderName:(NSString*)senderName
                 AndHexDescription:(NSString*)hexDescription
                       AndHexColor:(NSString*)hexColor
                          AndLinks:(NSArray*)links {
    
    HexJM *hexJM = [[HexJM alloc] init];
    hexJM.senderUUID = senderUUID;
    hexJM.senderName = senderName;
    hexJM.hexDescription = hexDescription;
    hexJM.hexColor = hexColor;
    hexJM.links = links;
    
    return hexJM;
}

+(void)fillInMissingHexJMFieldsWithDefaultValues:(HexJM*)hexJM {
    if (!hexJM.senderUUID)
        hexJM.senderUUID = @"";
    if (!hexJM.senderName)
        hexJM.senderName = @"";
    if (!hexJM.hexDescription)
        hexJM.hexDescription = @"";
    if (!hexJM.hexColor)
        hexJM.hexColor = @"";
    if (!hexJM.links)
        hexJM.links = [[NSArray alloc] init];
}

@end
