//
//  HCUserBehaviourProtocol.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/6.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HCUploadDataCompletedBlock)(id responseObject, NSError *error, BOOL finished);

typedef void(^HCUploadDataCancelBlock)();

@protocol HCUserBehaviourProtocol <NSObject>

@optional

/**
 用户行为数据的保存路径
 
 @return 返回绝对路径
 */
- (NSString *)userBehaviourDataSavePath;

@end
