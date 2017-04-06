//
//  HCUserBehaviourProtocol.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/6.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HCUploadDataCompletedBlock)(NSData *data, NSError *error, BOOL finished);

typedef void(^HCUploadDataCancelBlock)();

@protocol HCUserBehaviourProtocol <NSObject>

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
