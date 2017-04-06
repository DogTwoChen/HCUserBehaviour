//
//  HCJSONTests.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/5.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+HCJSON.h"
#import "HCPage.h"
#import "HCUser.h"
#import "HCEvent.h"

@interface HCJSONTests : XCTestCase
{
    HCUser *_user;
    HCPage *_page;
    HCEvent *_event;
}
@end

@implementation HCJSONTests

- (void)setUp {
    [super setUp];
    NSString *userName = @"Mike";
    NSString *pageName = @"HCJSONTests";
    NSString *eventName = @"buy goods";
    NSDictionary *infos = @{@"GoodsName":@"T-shirt",@"GoodsPrice":@"80.00"};
    _user = [[HCUser alloc] initWithName:userName channel:@"wechat"];
    _page = [[HCPage alloc] initWithName:pageName userName:userName];
    _event = [[HCEvent alloc] initWithName:eventName page:pageName parameters:infos];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_setterBlackNames_setArray_getNotNil {
    [_page hc_setJSONBlackNameList:@[@"_mutableEvents"]];
    NSArray *blackNameList = [_page hc_getJSONBlackNameList];
    BOOL isTure = (blackNameList.count == 1 && [blackNameList.lastObject isEqualToString:@"_mutableEvents"]);
    XCTAssertTrue(isTure, @"the black name list is not right");
}

- (void)test_objcTransformJson_setObjc_getJsonData {
    NSError *userError;
    NSData *userData = [_user hc_getJsonWithError:&userError];
    XCTAssertNil(userError, @"userError should be nil, but isnot, error is %@",userError);
    XCTAssertNotNil(userData, @"userData should be not nil");
    
    NSError *eventError;
    NSData *eventData = [_event hc_getJsonWithError:&eventError];
    XCTAssertNil(userError, @"eventError should be nil, but isnot, error is %@",eventError);
    XCTAssertNotNil(eventData, @"eventData should be not nil");
    
    NSError *pageError;
    [_page event:@"SocialShare" attributes:@{@"channel":@"wechat"}];
    NSData *pageData = [_page hc_getJsonWithError:&pageError];
    XCTAssertNil(userError, @"pageError should be nil, but isnot, error is %@",pageError);
    XCTAssertNotNil(pageData, @"pageData should be not nil");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
