//
//  LinkJM.h
//  
//
//  Created by Roman Scher on 12/29/15.
//
//

#import <JSONModel/JSONModel.h>

@interface LinkJM : JSONModel

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *type;

//Constants
+(NSString*)LINK_TYPE_DROPBOX;
+(NSString*)LINK_TYPE_GOOGLE_DRIVE;

@end
