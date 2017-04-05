//
//  HCUserBehaviour.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

/*
 数据读写注意线程安全和队列
 懒加载
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
 3. 上传数据
    封装成任务单元，参考 SDWebImage
 
 //接口增加
    数据文件的存储路径
    并发数
    文件设置成不拷贝
 */

#import <Foundation/Foundation.h>
#import "HCUploadDataOperation.h"
#import "HCPage.h"
#import "HCUser.h"


/**
 上传用户行为数据

 - HCReportPolicyBatch: 每次启动时上传
 - HCReportPolicyBatchInterval: 时间间隔上传
 */
typedef NS_ENUM(NSInteger, HCReportPolicy) {
    HCReportPolicyBatch,
    HCReportPolicyBatchInterval
};

@protocol HCUserBehaviourDelegate <NSObject>

@optional

/**
 用户行为数据的保存路径

 @return 返回绝对路径
 */
- (NSString *)userBehaviourDataSavePath;

@required

/**
 提供保存的用户行为数据路径，开发者提供上传的接口。

 @param path 数据路径
 @param completedBlock 上传成功一定要回调，因为还有删除旧数据的处理。
 */
- (void)userBehaviourUploadWithFilePath:(NSString *)path
                         completedBlock:(HCUploadDataCompletedBlock)completedBlock;

@end

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

@property (nonatomic, weak) id delegate; //实现这个代理，用来上传文件。

@property (nonatomic, assign) NSUInteger maxConcurrentUploadNumber;

+ (id)sharedInstance;

- (void)reportPolicy:(HCReportPolicy)reportPolicy;

- (void)enterPage:(NSString *)pageName;

- (void)exitPage:(NSString *)pageName;

- (void)event:(NSString *)eventId;

- (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes; //字符串 键值对，看下友盟有没有要求。

- (void)userSignInWithName:(NSString *)userName channel:(NSString *)channel;

- (void)userSignOut;

- (NSArray *)getBlackPageNameList;

- (void)setBlackPageNameList:(NSArray *)array;

@end
/*
 _lastPages:
    UINavigationController,UIInputWindowController
 
 */
