//
//  HCEventTests.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/5.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HCEvent.h"

@interface HCEventTests : XCTestCase
{
    HCEvent *_event;
}
@end

@implementation HCEventTests

- (void)setUp {
    [super setUp];
    _event = [[HCEvent alloc] initWithName:@"tap event" page:@"HCEventTests" parameters:@{@"key01":@"value01",@"key02":@"value02"}];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_initialize_propertys_NotNil {
    XCTAssertNotNil(_event.name,@"name should be not nil");
    XCTAssertNotNil(_event.pageName,@"name should be not nil");
    XCTAssertNotNil(_event.parameters,@"name should be not nil");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
