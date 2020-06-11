//
//  DBOperationWrapper.h
//  Envoy
//
//  Created by Yvan Scher on 10/3/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBOperationWrapper : NSObject

-(id) getRestClient;
-(int) getTypeOfQuery;
-(NSString*) getPath1; // destination path for uploads, source path for downloads
-(NSString*) getPath2; // source path for uploads, desination path for downloads
-(NSString*) getFilename;
-(instancetype) initWithRestClient:(id)restClient andPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery andFilename:(NSString*)filename;

@end
