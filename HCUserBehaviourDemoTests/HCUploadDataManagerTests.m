//
//  HCUploadDataManagerTests.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/6.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HCUploadDataManager.h"
#import "HCUploadDataOperation.h"
#import "HCTestHelper.h"

/// 测试用例需要重写
@interface HCUploadDataManagerTests : XCTestCase
{
    HCUploadDataManager *_uploadManager;
    dispatch_group_t _group_t;
    dispatch_semaphore_t _semaphore_t;
}
@end

@implementation HCUploadDataManagerTests

- (void)setUp {
    [super setUp];
    _group_t = dispatch_group_create();
    _semaphore_t = dispatch_semaphore_create(0);
    _uploadManager = [HCUploadDataManager sharedManager];
    _uploadManager.maxConcurrentUploader = 2;
    [HCTestHelper createTestData];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_upload_mutipleOperation_finished {
    NSArray *subDir = [HCTestHelper getFiles];
    [subDir enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = obj;
        [_uploadManager uploadWithFilePath:path completed:^(NSData *data, NSError *error, BOOL finished) {
            XCTAssertNil(error, @"operation error should be nil,but error is %@",error);
        }];
    }];
    
    XCTAssertTrue(_uploadManager.operationDict.count == subDir.count, @"the operations count should be equal to files count");
    
//    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    dispatch_semaphore_wait(_semaphore_t, DISPATCH_TIME_FOREVER);
    NSLog(@"success");
}

- (void)test_uploadSuspended_mutipleOperation_suspended {
    NSArray *subDir = [HCTestHelper getFiles];
    [subDir enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = obj;
        dispatch_group_enter(_group_t);
        [_uploadManager uploadWithFilePath:path completed:^(NSData *data, NSError *error, BOOL finished) {
            XCTAssertNil(error, @"operation error should be nil,but error is %@",error);
            dispatch_group_leave(_group_t);
        }];
    }];
    
    XCTAssertTrue(_uploadManager.operationDict.count == subDir.count, @"the operations count should be equal to files count");
    
    sleep(10);
    [_uploadManager setSuspended:YES];
    
    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    dispatch_group_wait(_group_t, wait_time);
    NSLog(@"the _uploadManager.currentUploaderCount is %ld", _uploadManager.currentUploaderCount);
    XCTAssertTrue(_uploadManager.currentUploaderCount > 0, @"the operation count should be greater than zero,otherwise susended failed");
}

- (void)test_uploadCancel_mutipleOperation_allCancel {
    NSArray *subDir = [HCTestHelper getFiles];
    [subDir enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = obj;
        dispatch_group_enter(_group_t);
        [_uploadManager uploadWithFilePath:path completed:^(NSData *data, NSError *error, BOOL finished) {
            XCTAssertNil(error, @"operation error should be nil,but error is %@",error);
            dispatch_group_leave(_group_t);
        }];
    }];
    
    sleep(10);
    [_uploadManager cancelAllDownloads];
    
    NSLog(@"cancel all count1 is %ld",_uploadManager.currentUploaderCount);
    sleep(10);
    NSLog(@"cancel all count2 is %ld",_uploadManager.currentUploaderCount);
    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    dispatch_group_wait(_group_t, wait_time);
    XCTAssertTrue(_uploadManager.currentUploaderCount == 0, @"the operation count should be greater than zero,otherwise susended failed, count is %ld", _uploadManager.currentUploaderCount);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
