//
//  HCUploadDataOperation.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/3/3.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HCUploadDataCompletedBlock)(NSData *data, NSError *error, BOOL finished);

typedef void(^HCUploadDataCancelBlock)();

typedef NS_ENUM(NSUInteger, HCURLSessionTask){
    HCURLSessionTaskData,
    HCURLSessionTaskUpload
};

@interface HCUploadDataOperation : NSOperation

@property (strong, nonatomic, readonly) NSURLRequest *request;

@property (strong, nonatomic, readonly) NSURLSessionUploadTask *uploadTask;

@property (strong, nonatomic, readonly) NSURL *fileURL;

- (instancetype)initWithRequest:(NSURLRequest *)request
                        fileURL:(NSURL *)fileURL
                      completed:(HCUploadDataCompletedBlock)completedBlock
                      cancelled:(HCUploadDataCancelBlock)cancelledBlock;

@end
