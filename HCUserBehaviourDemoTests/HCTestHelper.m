//
//  HCTestHelper.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 2017/4/6.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCTestHelper.h"

@implementation HCTestHelper

+ (void)createTestData {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *testFilesPath = [documentPath stringByAppendingPathComponent:@"TestData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:testFilesPath isDirectory:nil]) {
        [fileManager createDirectoryAtPath:testFilesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    for (int i = 0; i < 50; i++) {
        NSString *testStr = @"this is a test text";
        NSData *testData = [testStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *fileName = [NSString stringWithFormat:@"%d.json",i];
        NSString *filePath = [testFilesPath stringByAppendingPathComponent:fileName];
        [fileManager createFileAtPath:filePath contents:testData attributes:nil];
    }
}

+ (NSArray *)getFiles {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *testFilesPath = [documentPath stringByAppendingPathComponent:@"TestData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *subDir = [fileManager subpathsOfDirectoryAtPath:testFilesPath error:nil];
    NSMutableArray *mutableArray = [NSMutableArray array];
    [subDir enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = obj;
        NSString *path = [testFilesPath stringByAppendingPathComponent:name];
        [mutableArray addObject:path];
    }];
    return [mutableArray copy];
}

@end
