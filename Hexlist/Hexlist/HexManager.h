//
//  HexManager.h
//  Hexlist
//
//  Created by Roman Scher on 1/14/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "SettingsManager.h"
#import "AlertManager.h"
#import "Hex.h"
#import "Link.h"
#import "HexJM.h"
#import "LinkJM.h"
#import "Location.h"

//This class manages all methods related to Hex and Link objects with respect to the 'Inbox' and 'MyHexlist'.

//It Contains methods to convert Hex and Link Objects to their JsonModel equivalents and vice versa. It is designed to give flexibility in the type of information a hexJM/LinkJM object can hold when two peers with different app versions are sending HexJM objects to each other.

//The end result is to allow us to recreate a stable Realm Hex object from a hexHM object no matter the version of HexJM/LinkJM the sender and receiver are using

//Case 1: Sender sends hexJM with extra fields -> receiver ignores extra fields and uses only fields it needs.
//Case 2: Sender sends hexJM with missing fields -> receiver fills in missing fields with default values

//The fact that every property of hexJM is optional, allows for us to convert the hexJMJson string into a valid (even if partially filled) hexJM object regardless of any missing properties (no issues arise from extra properties to begin with).


@interface HexManager : NSObject

#pragma mark - Initial Setup

+(void)initialSetup;

#pragma mark - Inbox NSUserDefaults

//Hexes
+(void)incrementnumberOfUncheckedHexes;
+(void)reduceNumberOfUncheckedHexesToZero;
+(NSString*)getNumberOfUncheckedHexes;

#pragma mark - Inbox Hex methods

+(RLMResults*)getAllHexesInInbox;
+(void)saveNewHexToInbox:(Hex*)hex WithLinks:(NSArray<Link*>*)links;
+(void)deleteHexFromInbox:(Hex*)hex;
+(Hex*)generateHexFromHexJM:(HexJM*)hexJM;
+(NSArray<Link*>*)generateArrayOfLinksFromLinksJM:(NSArray<LinkJM*>*)linksJM;
+(Link*)generateLinkFromLinkJM:(LinkJM*)linkJM;

#pragma mark - My Hexlist methods

+(RLMArray*)getAllHexesInMyHexlist;
+(void)saveNewHexToMyHexlist:(Hex*)hex WithLinks:(NSArray<Link*>*)links;
+(void)deleteHexFromMyHexlist:(Hex*)hex;

#pragma mark - Send Preparation methods

//These methods generate JsonModel objects (sometimes from existing realm objects)
//and prepare them to be sent to peers
+(HexJM*)generateSendableHexJMWithLinkJMs:(NSArray<LinkJM*>*)links;
+(HexJM*)generateSendableHexJMFromHex:(Hex*)hex;

@end
