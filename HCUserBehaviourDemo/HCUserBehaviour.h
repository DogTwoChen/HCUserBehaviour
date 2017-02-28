//
//  HCUserBehaviour.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

/*
 数据读写注意线程安全和队列,懒加载
 数据筛选，可以设置页面的黑名单哪些不被纪录，数据没有变化的不做存储。
 统计类型：
 1. 页面统计：进入页面的顺序，时间轴，停留的时间。
 2. 事件统计：事件埋点（UIButton，UITouch ..），ActionId，attributes
 数据本地存储：
    数据本地存储时机：
    1. 内存警告时，此时需要清理内存，所以数据需要保存。
    2. 进入后台时，此时有可能程序挂掉，需要及时保存。
    数据本次存储的结构：(保障是异步执行和线程安全)
    UserDefault.plist 保存 reportPolicy，reportInterval，lastUploadTime
    /HCUserBehaviour
        /data
            /2017.2.16
                .json01,时间戳.json
                .json02
            /2017.2.17
                .json01
 
 */

#import <Foundation/Foundation.h>

#import "HCPage.h"
#import "HCUser.h"

typedef NS_ENUM(NSInteger, HCReportPolicy) {
    HCReportPolicyBatch,
    HCReportPolicyBatchInterval
};

@interface HCUserBehaviour : NSObject

@property (nonatomic, copy) NSString *appVersion;

@property (nonatomic, copy) NSString *appBuildVersion;

@property (nonatomic, copy) NSString *deviceMode;

@property (nonatomic, copy) NSString *deviceSystemName;

@property (nonatomic, copy) NSString *deviceSystemVersion;

@property (nonatomic, copy) NSString *deviceUUID;

@property (nonatomic, readonly, copy) NSArray *pages;

@property (nonatomic, readonly, copy) NSArray *users;

@property (nonatomic, readonly, assign) NSTimeInterval lastUploadTime;

@property (nonatomic, readonly, copy) NSString *channel;

@property (nonatomic, assign) HCReportPolicy reportPolicy;

@property (nonatomic, assign) NSTimeInterval reportInterval;

@property (nonatomic, readonly, strong) HCUser *currentUser;

+ (id)sharedInstance;

- (void)reportPolicy:(HCReportPolicy)reportPolicy;

- (void)enterPage:(NSString *)pageName;

- (void)exitPage:(NSString *)pageName;

- (void)event:(NSString *)eventId;

- (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes;

- (void)userlogInWithName:(NSString *)userName channel:(NSString *)channel;

- (void)userlogOut;

@end
/*
 _lastPages:
    UINavigationController,UIInputWindowController
 
 */
