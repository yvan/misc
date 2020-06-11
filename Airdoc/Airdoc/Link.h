//
//  Link.h
//  
//
//  Created by Roman Scher on 12/21/15.
//
//

#import <Realm/Realm.h>

@interface Link : RLMObject

@property NSString *url;
@property NSString *fileName;
@property NSString *type;

//Constants
+(NSString*)LINK_TYPE_DROPBOX;
+(NSString*)LINK_TYPE_GOOGLE_DRIVE;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Link>
RLM_ARRAY_TYPE(Link)
