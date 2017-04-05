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

@property (strong, nonatomic) NSURLSession *ownedSession;

@property (strong, nonatomic, readwrite) NSURLSessionUploadTask *uploadTask;

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

        __weak typeof(self) weak_self = self;
        if (_delegate && [_delegate respondsToSelector:@selector(userBehaviourUploadWithFilePath:completedBlock:)]) {
            [_delegate userBehaviourUploadWithFilePath:_filePath completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                __strong typeof(self) strong_self = weak_self;
                if (strong_self) {
                    if (finished) {
                        //上传成功后，删除文件。
                        NSError *removeFileError = nil;
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:_filePath error:&removeFileError];
                        if (removeFileError) {
                            //有可能代理中执行了删除
                            NSLog(@"removeFileError:%@",removeFileError);
                        }
                        self.finished = YES;
                        _completedBlock(data ,removeFileError,finished);
                    } else {
                        self.finished = YES;
                        _completedBlock(data ,error,finished);
                    }
                    
                }
            }];
            self.executing = YES;
        }
    }
}

- (void)reset {
    self.completedBlock = nil;
    self.cancelBlock = nil;
    self.uploadTask = nil;
    if (self.ownedSession) {
        [self.ownedSession invalidateAndCancel];
        self.ownedSession = nil;
    }
}

- (void)cancel {
    [super cancel];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    if (self.uploadTask) {
        [self.uploadTask cancel];
        if (self.isExecuting) {
            self.executing = NO;
        }
        if (!self.isFinished) {
            self.finished = YES;
        }
    }
    
    [self reset];
}

@end
