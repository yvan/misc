//
//  LinkJM.h
//  
//
//  Created by Roman Scher on 12/29/15.
//
//

#import <JSONModel/JSONModel.h>

@interface LinkJM : JSONModel

@property (strong, nonatomic) NSString<Optional> *url;
@property (strong, nonatomic) NSString<Optional> *linkDescription;
@property (strong, nonatomic) NSString<Optional> *service;

//Constructor
+(LinkJM*)createLinkJMWithURL:(NSString*)url
          AndLinkDescription:(NSString*)linkDescription
                  AndService:(NSString*)service;

+(void)fillInMissingLinkJMFieldsWithDefaultValues:(LinkJM*)linkJM;

@end
