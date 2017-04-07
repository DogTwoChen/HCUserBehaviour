//
//  HCUploadDataOperation.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/3/3.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCUserBehaviourProtocol.h"

@interface HCUploadDataOperation : NSOperation

@property (copy, nonatomic, readonly) NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath
                      completed:(HCUploadDataCompletedBlock)completedBlock
                      cancelled:(HCUploadDataCancelBlock)cancelledBlock;

- (void)notifyOperationThatUploadStateWith:(id )responseObject error:(NSError *)error isFinished:(BOOL)finished;

- (void)reset;

@end
