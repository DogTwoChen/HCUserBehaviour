//
//  HCUserTests.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/5.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HCUser.h"

@interface HCUserTests : XCTestCase
{
    HCUser *_user;
}
@end

@implementation HCUserTests

- (void)setUp {
    [super setUp];
    _user = [[HCUser alloc] initWithName:@"mike001" channel:@"wechat"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_initialize_propertys_NotNil {
    XCTAssertNotNil(_user.name, @"name should is not nil");
    XCTAssertNotNil(_user.channel, @"channel should is not nil");
}

- (void)test_signIn_beginTime_NotNil {
    [_user signIn];
    XCTAssertTrue(_user.beginTime > 0, @"the user' beginTime should is not 0");
}

- (void)test_signOut_time_accuracy {
    [_user signOut];
    XCTAssertTrue(_user.endTime > 0, @"the end time should is greatest than 0");
    XCTAssertTrue((_user.endTime - _user.beginTime) > 0, @"the stay time should is greatest than 0");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
