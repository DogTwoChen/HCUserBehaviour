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

@interface HCUploadDataManagerTests : XCTestCase <HCUserBehaviourProtocol>
{
    HCUploadDataManager *_uploadManager;
    dispatch_group_t _group_t;
}
@end

@implementation HCUploadDataManagerTests

- (void)setUp {
    [super setUp];
    _group_t = dispatch_group_create();
    _uploadManager = [HCUploadDataManager sharedManager];
    _uploadManager.delegate = self;
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
        dispatch_group_enter(_group_t);
        [_uploadManager uploadWithFilePath:path completed:^(NSData *data, NSError *error, BOOL finished) {
            XCTAssertNil(error, @"operation error should be nil,but error is %@",error);
            dispatch_group_leave(_group_t);
        }];
    }];
    
    XCTAssertTrue(_uploadManager.operationDict.count == subDir.count, @"the operations count should be equal to files count");
    
    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    dispatch_group_wait(_group_t, wait_time);
    XCTAssertTrue(_uploadManager.currentUploaderCount == 0, @"the operation count should be zero,otherwise timeout");
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
    
    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    dispatch_group_wait(_group_t, wait_time);
    XCTAssertTrue(_uploadManager.currentUploaderCount > 0, @"the operation count should be greater than zero,otherwise susended failed");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - HCUserBehaviourProtocol
- (void)userBehaviourUploadWithFilePath:(NSString *)path
                         completedBlock:(HCUploadDataCompletedBlock)completedBlock {
    sleep(1);
    HCUploadDataOperation *operation = [_uploadManager getUploadDataOperationWith:path];
    [operation notifyOperationThatUploadStateWith:nil error:nil isFinished:YES];
}

@end