//
//  LinkJM.m
//  
//
//  Created by Roman Scher on 12/29/15.
//
//

#import "LinkJM.h"

@implementation LinkJM

//Constructor
+(LinkJM*)createLinkJMWithURL:(NSString*)url
          AndLinkDescription:(NSString*)linkDescription
                  AndService:(NSString*)service {
    
    LinkJM *linkJM = [[LinkJM alloc] init];
    linkJM.url = url;
    linkJM.linkDescription = linkDescription;
    linkJM.service = service;
    
    return linkJM;
}

+(void)fillInMissingLinkJMFieldsWithDefaultValues:(LinkJM*)linkJM {
    if (!linkJM.url)
        linkJM.url = @"";
    if (!linkJM.linkDescription)
        linkJM.linkDescription = @"";
    if (!linkJM.service)
        linkJM.service = @"";
}

@end
