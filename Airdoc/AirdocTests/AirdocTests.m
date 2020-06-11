//
//  ;
//  AirdocTests
//
//  Created by Yvan Scher on 1/2/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MultipeerInitializerTabBarController.h"
#import "HomeViewController.h"

@interface AirdocTests : XCTestCase{
    
    UIApplication* app;
    HomeViewController* viewController;
    NSString* documentsDirectory;
    MCPeerID* testPeer;
    File* testFile;
    NSString* testFilePath;
}

@end

@implementation AirdocTests

- (void)setUp {
    app = [UIApplication sharedApplication];
    viewController = [[HomeViewController alloc] init];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [viewController viewDidDisappear:YES];
    app = nil;
    viewController = nil;
    testPeer = nil;
    testFilePath = nil;
    testFile = nil;
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
