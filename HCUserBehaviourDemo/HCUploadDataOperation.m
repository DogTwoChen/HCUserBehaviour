//
//  HCUploadDataOperation.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/3/3.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCUploadDataOperation.h"
#import <UIKit/UIKit.h>

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

- (instancetype)initWithRequest:(NSURLRequest *)request
                        fileURL:(NSURL *)fileURL
                      completed:(HCUploadDataCompletedBlock)completedBlock
                      cancelled:(HCUploadDataCancelBlock)cancelledBlock {
    if ((self = [super init])) {
        _request = request;
        _fileURL = fileURL;
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
        /*
        if (!self.ownedSession) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            self.ownedSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:nil
                                                         delegateQueue:nil];
        }
        self.uploadTask = [self.ownedSession uploadTaskWithRequest:_request fromFile:_fileURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //判断 error
            //判断业务逻辑错误
            //上传成功后，进行 标记文件已上传/删除的操作
            NSLog(@"上传成功 fileURL:%@",[_fileURL absoluteString]);
            
            NSError *removeFileError = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:_fileURL error:&removeFileError];
            if (removeFileError) {
                NSLog(@"removeFIleError:%@",removeFileError);
            }
            
            _completedBlock(data ,error,YES);
        }];
        */
        self.executing = YES;
        sleep(2);

        NSError *removeFileError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:_fileURL error:&removeFileError];
        if (removeFileError) {
            NSLog(@"removeFileError:%@",removeFileError);
        }
        
        self.finished = YES;
        _completedBlock(nil ,nil,YES);
    }
    /*
    [self.uploadTask resume];
    if (self.uploadTask) {
        
    } else {
        if (self.completedBlock) {
            self.completedBlock(nil, [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Connection can't be initialized"}], YES);
        }
    }
     */
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
