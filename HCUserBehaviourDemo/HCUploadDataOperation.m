//
//  HCUploadDataOperation.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/3/3.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCUploadDataOperation.h"
#import "HCUserBehaviour.h"
#import <UIKit/UIKit.h>

static NSString *const userBehaviourUploadErrorDomain = @"com.haichuan.userBehaviour.HCUploadDataOperation";

@interface HCUploadDataOperation ()

@property (copy, nonatomic) HCUploadDataCompletedBlock completedBlock;
@property (copy, nonatomic) HCUploadDataCancelBlock cancelBlock;

@property (assign, nonatomic, getter=isFinished) BOOL finished;
@property (assign, nonatomic, getter=isExecuting) BOOL executing;

@property (copy, nonatomic, readwrite) NSString *filePath;

#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@end

@implementation HCUploadDataOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (instancetype)initWithFilePath:(NSString *)filePath
                       completed:(HCUploadDataCompletedBlock)completedBlock
                       cancelled:(HCUploadDataCancelBlock)cancelledBlock {
    if ((self = [super init])) {
        _filePath = filePath;
        _completedBlock = [completedBlock copy];
        _cancelBlock = [cancelledBlock copy];
        _finished = NO;
        _executing = NO;
        
    }
    return self;
}

- (void)main {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        } else if ( !_filePath || [_filePath isEqualToString:@""]) {
            self.finished = YES;
            [self reset];
            return;
        }
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
        if (hasApplication) {
            __weak __typeof__ (self) wself = self;
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wself) sself = wself;
                if (sself) {
                    [sself cancel];
                    [app endBackgroundTask:sself.backgroundTaskId];
                    sself.backgroundTaskId = UIBackgroundTaskInvalid;
                }
            }];
        }
#endif
        if (_delegate && [_delegate respondsToSelector:@selector(userBehaviourUploadWithFilePath:)]) {
            [_delegate userBehaviourUploadWithFilePath:_filePath];
            self.executing = YES;
        } else {
            //自己实现上传接口
        }
    }
}

- (void)reset {
    self.completedBlock = nil;
    self.cancelBlock = nil;
}

- (void)cancel {
    [super cancel];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    if (self.isExecuting) {
        self.executing = NO;
    }
    if (!self.isFinished) {
        self.finished = YES;
    }
    
    [self reset];
}

- (void)notifyOperationThatUploadStateWith:(NSData *)data
                                     error:(NSError *)error
                                isFinished:(BOOL)finished {
    if (finished) {
        //上传成功后，删除文件。
        NSError *removeFileError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self->_filePath error:&removeFileError];
        if (removeFileError) {
            //有可能代理中执行了删除
            NSLog(@"removeFileError:%@",removeFileError);
        }
        self.finished = YES;
        self.completedBlock(data ,removeFileError,finished);
    } else {
        self.finished = YES;
        self.completedBlock(data ,error,finished);
    }
}

@end
