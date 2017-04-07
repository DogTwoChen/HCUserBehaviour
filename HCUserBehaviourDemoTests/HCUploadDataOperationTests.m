//
//  HCUploadDataOperationTests.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/6.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HCUploadDataOperation.h"
#import "HCTestHelper.h"

@interface HCUploadDataOperationTests : XCTestCase <HCUserBehaviourProtocol>
{
    NSOperationQueue *_operationQueue;
    dispatch_semaphore_t _semaphore_t;
    dispatch_group_t _group_t;
    int _concurrentCount;
    
    NSMutableDictionary *_operationDict;
}
@end

@implementation HCUploadDataOperationTests

- (void)setUp {
    [super setUp];
    _concurrentCount = 50;
    _semaphore_t = dispatch_semaphore_create(0);
    _group_t = dispatch_group_create();
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 3;
    _operationQueue.name = @"com.liuhaichuan.HCUploadDataOperationTests.operationQueue";
    
    [HCTestHelper createTestData];
    
    _operationDict = [NSMutableDictionary new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_upload_operations_finish {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    NSArray *subDir = [HCTestHelper getFiles];
    [subDir enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = obj;
        dispatch_group_enter(_group_t);
        HCUploadDataOperation *operation = [[HCUploadDataOperation alloc] initWithFilePath:path completed:^(NSData *data, NSError *error, BOOL finished) {
            XCTAssertNil(error, @"operation error should be nil,but error is %@",error);
            dispatch_group_leave(_group_t);
        } cancelled:^{
            XCTFail(@"operation should be not chancelled");
        }];
        operation.delegate = self;
        [_operationQueue addOperation:operation];
        [_operationDict setObject:operation forKey:path];
    }];

    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    dispatch_group_wait(_group_t, wait_time);
    XCTAssertTrue(_operationQueue.operationCount == 0, @"the operation count should be zero,otherwise timeout");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - HCUserBehaviourProtocol
- (void)userBehaviourUploadWithFilePath:(NSString *)path {
    sleep(1);
    HCUploadDataOperation *op = _operationDict[path];
    [op notifyOperationThatUploadStateWith:nil error:nil isFinished:YES];
}

@end
