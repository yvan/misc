//
//  FileSystem.m
//  malamute
//
//  Created by Yvan Scher on 1/3/15.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "File.h"

@implementation File

/* - inits a File object with a name and url path - */
/* - all file names and paths have percent encoding removed - */
-(instancetype)initWithName:(NSString*)name andPath:(NSString*)path andDate:(NSDate*)date andRevision:(NSString*)revision andDirectoryFlag:(BOOL)isDirectory andBoxId:(NSString*)boxID{
    
//    //decode the string
//    NSString* testDecodeName = [name stringByRemovingPercentEncoding];
//    NSString* testDecodePath = [path stringByRemovingPercentEncoding];
//    
//    //if the test decode yeilds a null string, it contains a character like a %
//    //that shouldn't be there.
//    //the long term solution is to let the user have wtvr name they want
//    //and then map that to the real file name a unique id.
//    if (!testDecodeName || !testDecodePath){
//        name = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
    
    _name = [name stringByRemovingPercentEncoding];
    _path = [path stringByRemovingPercentEncoding];
    _dateCreated = date;
    _isDirectory = isDirectory;
    _revision = revision;
    _parentURLPath = [[path stringByDeletingLastPathComponent] stringByRemovingPercentEncoding];
    _boxid = boxID;
    return self;
}

-(BOOL) isEqual:(id)object{
    
    if (object == self){
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]){
        return NO;
    }
    if (![self.path isEqualToString:((File*)object).path]){
        return NO;
    }
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setName:[self.name copyWithZone:zone]];
        [copy setPath:[self.path copyWithZone:zone]];
        [copy setDateCreated:[self.dateCreated copyWithZone:zone]];
        [copy setRevision:[self.revision copyWithZone:zone]];
        [copy setParentURLPath:[self.parentURLPath copyWithZone:zone]];
        [copy setBoxid:[self.boxid copyWithZone:zone]];
        
        // Set primitives
        [copy setIsDirectory:self.isDirectory];
    }
    
    return copy;
}

@end
