//
//  HCUploadDataManager.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/3/3.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCUploadDataOperation.h"

@interface HCUploadDataManager : NSObject

@property (assign, nonatomic) NSInteger maxConcurrentUploader;

@property (readonly, nonatomic) NSUInteger currentUploaderCount;

@property (weak, nonatomic) id <HCUserBehaviourProtocol> delegate;

+ (HCUploadDataManager *)sharedManager;

- (HCUploadDataOperation *)uploadWithFilePath:(NSString *)path;

- (HCUploadDataOperation *)uploadWithFilePath:(NSString *)path
                               completed:(HCUploadDataCompletedBlock)completedBlock;

- (void)setSuspended:(BOOL)suspended;

- (void)cancelAllDownloads;

@end
