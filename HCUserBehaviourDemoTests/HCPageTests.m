//
//  HCPageTests.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/5.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HCPage.h"

@interface HCPageTests : XCTestCase
{
    HCPage *_page;
}
@end

@implementation HCPageTests

- (void)setUp {
    [super setUp];
    _page = [[HCPage alloc] initWithName:@"HCPageTests" userName:@"mike"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_initialize_propertys_NotNil {
    XCTAssertNotNil(_page.name, @"name should is not nil");
    XCTAssertNotNil(_page.userName, @"userName should is not nil");
    XCTAssertNotNil(_page.events, @"events should is not nil");
}

- (void)test_addEvent_mutableEvents_right {
    [_page event:@"test event" attributes:@{@"key01":@"value01",@"key02":@"value02"}];
    XCTAssertTrue(_page.events.count == 1, @"events container' count should be is one, but %ld was returned instead",_page.events.count);
    XCTAssertTrue(([_page.events.lastObject isKindOfClass:[HCEvent class]] && _page.events.lastObject != nil), @"events container' event should be is HCEvent class and it is not nil, but it's class is %@",NSStringFromClass([_page.events.lastObject class]));
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
