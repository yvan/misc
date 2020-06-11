//
//  GDOperationWrapper.h
//  Envoy
//
//  Created by Yvan Scher on 10/3/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLDrive.h"

@interface GDOperationWrapper : NSObject

-(id) getServiceTicketOrFetcher;
-(void) setServiceTicketOrFetcher:(id)serviceTicketOrFetcher;
-(int) getTypeOfQuery;
-(NSString*) getFilename;
-(NSString*) getPath1; // destination path for uploads, source path for downloads
-(NSString*) getPath2; // source path for uploads, desination path for downloads
-(instancetype) initWithSeviceTicketOrFetcher:(id)serviceTicketOrFetcher andPath1:(NSString*)path1 andPath2:(NSString*)path2 andTypeOfQuery:(int)typeOfQuery andFilename:(NSString*)filename;
-(void) setFetcherDataCompletionBlock:(void (^)(NSData *, NSError *))fetcherDataCompletionBlock;
-(void (^)(NSData *data, NSError *error)) getFetcherDataCompletionBlock;
-(void) setUploadCompletionBlock: (void(^)(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error)) uploadCompletionBlock;
-(void(^)(GTLServiceTicket *ticket, GTLDriveFile *uploadedFile, NSError *error)) getUploadCompletionHandler;
-(void) setDriveQuery:(GTLQueryDrive*) driveQuery;
-(GTLQueryDrive*) getDriveQuery;

@end
