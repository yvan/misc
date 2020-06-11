//
//  DBOperationWrapper.m
//  Envoy
//
//  Created by Yvan Scher on 10/3/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "DBOperationWrapper.h"
#import <DropboxSDK/DropboxSDK.h>

// type of query that we will
// use to check against the
// typeOfQuery field in the
// DBQueryWrapper class


@interface DBOperationWrapper ()

//source and destination path if they exist
@property (nonatomic) NSString* path1;
@property (nonatomic) NSString* path2;
@property (nonatomic) NSString* filename; // here for convinience we could just extract from one of the paths but eh? this is clearer.
@property (nonatomic) int typeOfQuery;
@property (nonatomic, strong) DBRestClient* restClient;

@end

@implementation DBOperationWrapper

-(instancetype) initWithRestClient:(id)restClient andPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery andFilename:(NSString*)filename{
    _path1 = path1;
    _path2 = path2;
    _typeOfQuery = typeOfQuery;
    _restClient = restClient;
    _filename = filename;
    return self;
}

-(id) getRestClient {
    return _restClient;
}

-(int) getTypeOfQuery {
    return _typeOfQuery;
}

-(NSString*) getFilename {
    return _filename;
}

-(NSString*) getPath1 {
    return _path1;
}

-(NSString*) getPath2 {
    return _path2;
}

@end
