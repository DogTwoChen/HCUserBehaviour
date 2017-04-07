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
#import "AFNetworking.h"

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

- (void)start {
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
        //自己实现上传接口
        /**/
        NSData *fileData = [NSData dataWithContentsOfFile:_filePath];
        NSError *jsonSerializationError;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableContainers error:&jsonSerializationError];
        
        NSAssert(jsonSerializationError == nil, @"the JSONSerialization should has not error!,errpr:%@",jsonSerializationError);
        
        NSString *requestUrl = @"https://api.leancloud.cn/1.1/classes/Post";
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:@"X1Htn6OE2zLE9rpAb0PWHYJ5-gzGzoHsz" forHTTPHeaderField:@"X-LC-Id"];
        [requestSerializer setValue:@"lEtBUFav7d6zOhWHFmD5Jp4c" forHTTPHeaderField:@"X-LC-Key"];
        AFHTTPSessionManager *sessonManager = [AFHTTPSessionManager manager];
        sessonManager.requestSerializer = requestSerializer;
        [sessonManager POST:requestUrl parameters:@{@"data":dictData} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"responseObject:%@",responseObject);
            [self notifyOperationThatUploadStateWith:responseObject error:nil isFinished:YES];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self notifyOperationThatUploadStateWith:nil error:error isFinished:NO];
        }];
        self.executing = YES;
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
    
    [self done];
}

- (void)done {
    if (self.isExecuting) {
        self.executing = NO;
    }
    if (!self.isFinished) {
        self.finished = YES;
    }
    [self reset];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)notifyOperationThatUploadStateWith:(id )responseObject
                                     error:(NSError *)error
                                isFinished:(BOOL)finished {
    if (finished) {
        //上传成功后，删除文件。
        NSError *removeFileError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self->_filePath error:&removeFileError];
        if (removeFileError) {
            NSLog(@"removeFileError:%@",removeFileError);
        }
        self.completedBlock(responseObject ,removeFileError,finished);
        [self done];
    } else {
        self.completedBlock(responseObject ,error,finished);
        [self done];
    }
}

@end
