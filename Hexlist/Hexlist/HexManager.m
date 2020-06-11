//
//  HexManager.m
//  Hexlist
//
//  Created by Roman Scher on 1/14/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "HexManager.h"

@implementation HexManager

#pragma mark - Initial Setup

+(void)initialSetup {
    [self createHexLocationsForAllHexLocationTypes];
    [self reduceNumberOfUncheckedHexesToZero];
}

+(void)createHexLocationsForAllHexLocationTypes {
    NSArray *hexLocationTypes = [AppConstants allHexLocationTypes];
    
    for (NSNumber *hexLocation in hexLocationTypes) {
        [self createHexLocationForHexLocationType:[hexLocation integerValue]];
    }
}

+(void)createHexLocationForHexLocationType:(HexLocationType)hexLocationType {
    Location *location = [Location createLocationWithHexLocation:hexLocationType];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:location];
    [realm commitWriteTransaction];
}

#pragma mark - Inbox NSUserDefaults

//Hexes

+(void)incrementnumberOfUncheckedHexes {
    NSString *numUncheckedHexesString = [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedHexesStringIdentifier]];
    NSInteger numUncheckedHexesIncrement = [numUncheckedHexesString integerValue] + 1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat: @"%ld", (long)numUncheckedHexesIncrement] forKey:[AppConstants numberOfUncheckedHexesStringIdentifier]];
}

+(void)reduceNumberOfUncheckedHexesToZero {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[AppConstants numberOfUncheckedHexesStringIdentifier]];
}

+(NSString*)getNumberOfUncheckedHexes {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[AppConstants numberOfUncheckedHexesStringIdentifier]];
}

#pragma mark - Inbox Hex & Link methods

+(RLMResults*)getAllHexesInInbox {
    Location *inboxLocation = [Location objectForPrimaryKey:[AppConstants stringForHexLocationType:HexLocationTypeInbox]];
    return [inboxLocation.hexes sortedResultsUsingProperty:@"timestamp" ascending:NO];
}

+(void)saveNewHexToInbox:(Hex*)hex WithLinks:(NSArray<Link*>*)links {
    //Update timestamp of hex.
    hex.timestamp = [NSDate date];
    
    Location *inboxLocation = [Location objectForPrimaryKey:[AppConstants stringForHexLocationType:HexLocationTypeInbox]];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [inboxLocation.hexes insertObject:hex atIndex:0];
    [hex.links addObjects:links];
    [realm commitWriteTransaction];
}

+(void)deleteHexFromInbox:(Hex*)hex {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:hex];
    [realm commitWriteTransaction];
}

/*- Takes a hex jsonModel object, converts it to a realm hex object for the inbox, and saves it - */

+(Hex*)generateHexFromHexJM:(HexJM*)hexJM {
    //If any fields are null/empty, replace them with default values.
    [HexJM fillInMissingHexJMFieldsWithDefaultValues:hexJM];
    
    Hex *hex = [Hex createHexWithUUID:[[NSUUID UUID] UUIDString]
                        AndSenderUUID:hexJM.senderUUID
                        AndSenderName:hexJM.senderName
                    AndHexDescription:hexJM.hexDescription
                          AndHexColor:hexJM.hexColor];
    
    return hex;
}

+(NSArray<Link*>*)generateArrayOfLinksFromLinksJM:(NSArray<LinkJM*>*)linksJM {
    NSMutableArray *links = [[NSMutableArray alloc] init];
    for (LinkJM *linkJM in linksJM) {
        [links addObject:[self generateLinkFromLinkJM:linkJM]];
    }
    
    return links;
}

+(Link*)generateLinkFromLinkJM:(LinkJM*)linkJM {
    //If any fields are null/empty, replace them with default values.
    [LinkJM fillInMissingLinkJMFieldsWithDefaultValues:linkJM];
    
    Link *link = [Link createLinkWithUUID:[[NSUUID UUID] UUIDString]
                                   AndURL:linkJM.url
                       AndLinkDescription:linkJM.linkDescription
                               AndService:[AppConstants serviceTypeForString:linkJM.service]];
   
    return link;
}

#pragma mark - My Hexlist methods

+(RLMArray*)getAllHexesInMyHexlist {
    Location *myHexlistLocation = [Location objectForPrimaryKey:[AppConstants stringForHexLocationType:HexLocationTypeMyHexlist]];
    return myHexlistLocation.hexes;
}

+(void)saveNewHexToMyHexlist:(Hex*)hex WithLinks:(NSArray<Link*>*)links {
    //Update timestamp of hex.
    hex.timestamp = [NSDate date];
    
    Location *myHexlistLocation = [Location objectForPrimaryKey:[AppConstants stringForHexLocationType:HexLocationTypeMyHexlist]];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [myHexlistLocation.hexes insertObject:hex atIndex:0];
    [hex.links addObjects:links];
    [realm commitWriteTransaction];
}

+(void)deleteHexFromMyHexlist:(Hex*)hex {
    //Remove hex located in myHexlist from Realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:hex];
    [realm commitWriteTransaction];
}

#pragma mark - Send Preparation methods

//These methods generate JsonModel objects (sometimes from existing realm objects)
//and prepare them to be sent to peers

+(HexJM*)generateSendableHexJMWithLinkJMs:(NSArray<LinkJM*>*)links {
    
    //Convert Links into LinkJM dictionaries.
    NSMutableArray<NSDictionary*> *linkDictionaries = [[NSMutableArray alloc] init];
    for (LinkJM *linkJM in links) {
        [linkDictionaries addObject:[linkJM toDictionary]];
    }
    
    //Form hex
    HexJM *sendableHexJM = [HexJM
                            createHexJMWithSenderUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                            AndSenderName:[SettingsManager getUserDisplayableFullName]
                            AndHexDescription:@""
                            AndHexColor:[AppConstants hexStringFromColor:[AppConstants niceRandomColor]]
                            AndLinks:[linkDictionaries copy]];
    
    return sendableHexJM;
}

+(HexJM*)generateSendableHexJMFromHex:(Hex*)hex {
    
    //Convert Links into LinkJM dictionaries.
    NSMutableArray<NSDictionary*> *linkDictionaries = [[NSMutableArray alloc] init];
    for (Link *link in hex.links) {
        [linkDictionaries addObject:[(LinkJM*)[self generateLinkJMFromLink:link] toDictionary]];
    }
    
    HexJM *sendableHexJM = [HexJM
                            createHexJMWithSenderUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                        AndSenderName:[SettingsManager getUserDisplayableFullName]
                                    AndHexDescription:hex.hexDescription
                                          AndHexColor:hex.hexColor
                                             AndLinks:[linkDictionaries copy]];
    
    return sendableHexJM;
}

+(LinkJM*)generateLinkJMFromLink:(Link*)link {
    LinkJM *linkJM = [LinkJM createLinkJMWithURL:link.url
                              AndLinkDescription:link.linkDescription
                                      AndService:link.service];
 
    return linkJM;
}

//+(NSString*)generateNSStringTimestampFromNSDateTimestamp:(NSDate*)timestamp {
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
//    return [dateFormat stringFromDate:timestamp];
//}

//+(NSDate*)generateNSDateTimestampFromNSStringTimestamp:(NSString*)timestamp {
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
//    return [dateFormat dateFromString:timestamp];
//}


@end
