//
//  GDOperationWrapper.m
//  Envoy
//
//  Created by Yvan Scher on 10/3/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import "GDOperationWrapper.h"


@interface GDOperationWrapper ()

//source and destination path if they exist
@property (nonatomic) NSString* path1;
@property (nonatomic) NSString* path2;
@property (nonatomic) NSString* filename; // here for convinience we could just extract from one of the paths but eh? this is clearer.
@property (nonatomic) int typeOfQuery;
@property (nonatomic) id serviceTicketOrFetcher;
@property (nonatomic) id fetcherCompletionHandler;
@property (nonatomic) id uploadCompletionHandler;
@property (nonatomic) GTLQueryDrive* driveQuery;

@end

@implementation GDOperationWrapper

// we have path1 and path2 here so we can purge the operation wrappers on cancel.

-(instancetype) initWithSeviceTicketOrFetcher:(id)serviceTicketOrFetcher andPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery andFilename:(NSString*)filename{
    _typeOfQuery = typeOfQuery;
    _filename = filename;
    _serviceTicketOrFetcher = serviceTicketOrFetcher;
    _path1 = path1;
    _path2 = path2;
    return self;
}

-(void) setServiceTicketOrFetcher:(id)serviceTicketOrFetcher {
    _serviceTicketOrFetcher = serviceTicketOrFetcher;
}

-(id) getServiceTicketOrFetcher {
    return _serviceTicketOrFetcher;
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

-(void) setFetcherDataCompletionBlock:(void (^)(NSData *, NSError *))fetcherDataCompletionBlock {
    _fetcherCompletionHandler = fetcherDataCompletionBlock;
}

-(void (^)(NSData *data, NSError *error)) getFetcherDataCompletionBlock{
    return _fetcherCompletionHandler;
}

-(void) setUploadCompletionBlock: (void(^)(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error)) uploadCompletionBlock{
    _uploadCompletionHandler = uploadCompletionBlock;
}

-(void(^)(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error)) getUploadCompletionHandler {
    return _uploadCompletionHandler;
}

-(void) setDriveQuery:(GTLQueryDrive*) driveQuery {
    _driveQuery = driveQuery;
}

-(GTLQueryDrive*) getDriveQuery {
    return _driveQuery;
}

@end
