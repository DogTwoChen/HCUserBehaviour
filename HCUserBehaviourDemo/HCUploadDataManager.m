//
//  HCUploadDataManager.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/3/3.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCUploadDataManager.h"

@interface HCUploadDataManager ()

@property (strong, nonatomic) NSOperationQueue *uploaderQueue;

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

- (HCUploadDataOperation *)uploadWithURL:(NSURL *)url
                              parameters:(NSDictionary *)parameters
                                 fileURL:(NSURL *)fileURL {
    return [self uploadWithURL:url parameters:parameters fileURL:fileURL completed:nil];
}

- (HCUploadDataOperation *)uploadWithURL:(NSURL *)url
                              parameters:(NSDictionary *)parameters
                                 fileURL:(NSURL *)fileURL
                               completed:(HCUploadDataCompletedBlock)completedBlock {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"POST";
    if (parameters) {
        NSError *error;
        NSData *parametersData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:parametersData];
    }
    HCUploadDataOperation *operation = [[HCUploadDataOperation alloc] initWithRequest:request fileURL:fileURL completed:^(NSData *data, NSError *error, BOOL finished) {
        if (finished && !error) {
            completedBlock(nil,nil,finished);
        }
    } cancelled:^{
        
    }];
    [_uploaderQueue addOperation:operation];
    return operation;
}

- (void)setSuspended:(BOOL)suspended {
    [_uploaderQueue setSuspended:suspended];
}

- (void)cancelAllDownloads {
    [_uploaderQueue cancelAllOperations];
}


@end
