//
//  HCUploadDataOperationTests.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/6.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HCUploadDataOperation.h"

@interface HCUploadDataOperationTests : XCTestCase
{
    NSOperationQueue *_operationQueue;
}
@end

@implementation HCUploadDataOperationTests

- (void)setUp {
    [super setUp];
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 3;
    _operationQueue.name = @"com.liuhaichuan.HCUploadDataOperationTests.operationQueue";
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSString *path = @"";
    for (int i = 0; i < 100; i++) {
        HCUploadDataOperation *operation = [[HCUploadDataOperation alloc] initWithFilePath:path
                                                                                 completed:^(NSData *data, NSError *error, BOOL finished) {
            //
        } cancelled:^{
            
        }];
        operation.delegate = self;
        [_operationQueue addOperation:operation];
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
