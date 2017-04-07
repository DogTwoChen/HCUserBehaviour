//
//  HCUploadDataManager.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/3/3.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCUploadDataManager.h"
#import "HCUploadDataOperation.h"

@interface HCUploadDataManager ()
{
    NSMutableDictionary *_operationMutableDict;
}

@property (strong, nonatomic) NSOperationQueue *uploaderQueue;

@property (copy, nonatomic, readwrite) NSDictionary *operationDict;

@end

@implementation HCUploadDataManager

+ (HCUploadDataManager *)sharedManager {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uploaderQueue = [NSOperationQueue new];
        _uploaderQueue.maxConcurrentOperationCount = 3;
        _uploaderQueue.name = @"com.hcuserbehaviour.operationQueue";
        _operationMutableDict = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    [_uploaderQueue cancelAllOperations];
//    dispatch_release(_uploaderQueue);
}

- (void)setMaxConcurrentUploader:(NSInteger)maxConcurrentUploader {
    _uploaderQueue.maxConcurrentOperationCount = maxConcurrentUploader;
}

- (NSInteger)maxConcurrentUploader {
    return _uploaderQueue.maxConcurrentOperationCount;
}

- (NSUInteger)currentUploaderCount {
    return _uploaderQueue.operationCount;
}

- (HCUploadDataOperation *)uploadWithFilePath:(NSString *)path {
    return [self uploadWithFilePath:path completed:nil];
}

- (HCUploadDataOperation *)uploadWithFilePath:(NSString *)path
                                    completed:(HCUploadDataCompletedBlock)completedBlock {
    HCUploadDataOperation *oldOperation = [self getUploadDataOperationWith:path];
    if (oldOperation) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    HCUploadDataOperation *operation = [[HCUploadDataOperation alloc] initWithFilePath:path completed:^(NSData *data, NSError *error, BOOL finished) {
        completedBlock(data, error, finished);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [self removeUploadDataOperationWith:path];
        }
    } cancelled:^{
        completedBlock(nil, nil, NO);
    }];
    operation.delegate = _delegate;
    [_uploaderQueue addOperation:operation];
    
    [_operationMutableDict setObject:operation forKey:path];//path算md5 做 key
    return operation;
}

- (NSDictionary *)operationDict {
    return [_operationMutableDict copy];
}

- (HCUploadDataOperation *)getUploadDataOperationWith:(NSString *)key {
    return [[self operationDict] objectForKey:key];
}

- (void)removeUploadDataOperationWith:(NSString *)key {
    return [_operationMutableDict removeObjectForKey:key];
}

- (void)setSuspended:(BOOL)suspended {
    [_uploaderQueue setSuspended:suspended];
}

- (void)cancelAllDownloads {
    [_operationMutableDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[HCUploadDataOperation class]]) {
            HCUploadDataOperation *op = obj;
            [op reset];
        }
    }];
    [_operationMutableDict removeAllObjects];
    [_uploaderQueue cancelAllOperations];
}


@end
