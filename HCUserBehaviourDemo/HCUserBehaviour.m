//
//  HCUserBehaviour.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCUserBehaviour.h"
#import <UIKit/UIKit.h>
#import "NSObject+HCJSON.h"
#import "HCUploadDataManager.h"

@interface HCUserBehaviour ()
{
    NSMutableArray *_mutablePages;
    NSMutableArray *_mutableUsers;
    NSMutableDictionary *_lastPages;
}

@property (nonatomic, readwrite, assign) NSTimeInterval lastUploadTime;

@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@property (nonatomic, strong) dispatch_semaphore_t uploadTaskSemaphore;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, copy) NSArray *blackNameList;

@end

@implementation HCUserBehaviour

static NSString *const kReportPolicyKey = @"kReportPolicyKey";
static NSString *const kReportIntervalKey = @"kReportIntervalKey";
static NSString *const kLastUploadTime = @"kLastUploadTime";

static NSString *const kDataMainPath = @"HCUserBehaviour";
static NSString *const kDataSubPath = @"data";

#pragma mark - 初始化

+ (id)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initRequisiteInfo];
        [self initReportPolicy];
        [self addApplicationObserver];
        [self addRunloopObserver];
    }
    return self;
}

- (void)initRequisiteInfo {
    _dateFormatter = [[NSDateFormatter alloc]init];
    _dateFormatter.dateFormat = @"yyyyMMdd";
    
    [self hc_setJSONBlackNameList:@[@"concurrentQueue",@"dateFormatter",@"blackNameList",@"uploadTaskSemaphore"]];
    
    _mutablePages = [NSMutableArray array];
    _mutableUsers = [NSMutableArray array];
    _lastPages = [NSMutableDictionary new];
    _maxConcurrentUploadNumber = 3;
    _concurrentQueue = dispatch_queue_create("com.hcuserbehaviour.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    _uploadTaskSemaphore = dispatch_semaphore_create(_maxConcurrentUploadNumber * 2);//暂定 6 个
    
    UIDevice *device = [[UIDevice alloc]init];
    _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _appBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    _deviceMode = device.model;
    _deviceSystemName = device.systemName;
    _deviceSystemVersion = device.systemVersion;
    _deviceUUID = device.identifierForVendor.UUIDString;
}

- (void)initReportPolicy {
    NSInteger policy = [[self UBUserDefaults] integerForKey:kReportPolicyKey];
    double interval = [[self UBUserDefaults] doubleForKey:kReportIntervalKey];
    double lastUploadTime = [[self UBUserDefaults] doubleForKey:kLastUploadTime];
    if (policy && (policy == HCReportPolicyBatch || policy == HCReportPolicyBatchInterval)) {
        _reportPolicy = policy;
    }
    else {
        _reportPolicy = HCReportPolicyBatch;
    }
    if (interval > 0) {
        _reportInterval = interval;
    }
    else {
        _reportInterval = 60 * 60 * 24;//one day
    }
    if (lastUploadTime > 0) {
        [self setLastUploadTime:lastUploadTime];
    }
    else {
        _lastUploadTime = [[NSDate new] timeIntervalSince1970];
    }
}

- (void)addApplicationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserBehaviourDataInBackgrount)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserBehaviourData)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationLaunching)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

- (void)addRunloopObserver {
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (activity == kCFRunLoopBeforeWaiting && _reportPolicy == HCReportPolicyBatchInterval) {
            NSLog(@"RunLoop 即将休眠, 判断是否到达上传时间。");
            NSTimeInterval currentTime = [[NSDate new] timeIntervalSince1970];
            NSTimeInterval timeGap = currentTime - _lastUploadTime;
            if (timeGap > _reportInterval) {
                NSLog(@"到达上传数据的时间，开始上传。");
                [self uploadData];
            }
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 保存/上传等操作

- (void)applicationLaunching {
    if (_reportPolicy == HCReportPolicyBatch) {
        [self uploadData];
    }
}

- (void)handleUserBehaviourData {
    [self saveData:nil];
}

- (void)handleUserBehaviourDataInBackgrount {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self saveData:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
}

- (void)saveData:(void (^)())doneBlock {
    if (_mutablePages.count == 0 && _mutableUsers.count == 0) {
        doneBlock();
        return;
    }
    
    dispatch_async(_concurrentQueue, ^{
        NSLog(@"保存数据");
        NSError *error = nil;
        NSData *data = [self hc_getJsonWithError:&error];
        if (data) {
            NSDate *todayDate = [NSDate new];
            NSString *todayStr = [_dateFormatter stringFromDate:todayDate];
            
            NSString *documentDirectory;
            if (_delegate && [_delegate respondsToSelector:@selector(userBehaviourDataSavePath)]) {
                documentDirectory = [_delegate userBehaviourDataSavePath];
            } else {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                documentDirectory = paths.firstObject;
            }
            
            NSString *userBehaviourPath = [documentDirectory stringByAppendingPathComponent:kDataMainPath];
            NSString *dataPath = [userBehaviourPath stringByAppendingPathComponent:kDataSubPath];
            NSString *todayPath = [dataPath stringByAppendingPathComponent:todayStr];
            
            NSTimeInterval nowTime = [todayDate timeIntervalSince1970];
            NSString *nowTimeFilePath = [NSString stringWithFormat:@"%0.f.json",nowTime];
            NSString *jsonPath = [todayPath stringByAppendingPathComponent:nowTimeFilePath];
            
            [self saveData:data fileName:jsonPath directoryName:todayPath];
            [self cleanMemory];
        } else {
            NSLog(@"HCUserBehaviour object -> data error:%@",error);
        }
        
        if (doneBlock) {
            doneBlock();
        }
    });
}

- (void)cleanMemory {
    NSLog(@"清理内存");
    _mutablePages = [NSMutableArray array];
    _mutableUsers = [NSMutableArray array];
}

- (void)uploadData {
    //构建 操作单元 执行上传文件的任务，串行并行都可以。参考 SDWebImage
    //获取 /data 下面的日期目录列表
    NSLog(@"开始上传---------");
    [HCUploadDataManager sharedManager].maxConcurrentUploader = _maxConcurrentUploadNumber;
    [HCUploadDataManager sharedManager].delegate = self;
    NSString *documentDirectory;
    if (_delegate && [_delegate respondsToSelector:@selector(userBehaviourDataSavePath)]) {
        documentDirectory = [_delegate userBehaviourDataSavePath];
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentDirectory = paths.firstObject;
    }
    NSString *userBehaviourPath = [documentDirectory stringByAppendingPathComponent:kDataMainPath];
    NSString *dataPath = [userBehaviourPath stringByAppendingPathComponent:kDataSubPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *subDir = [fileManager subpathsOfDirectoryAtPath:dataPath error:&error];
    if (error) {
        NSLog(@"获取 ./data 下的子目录 失败");
    } else {
        [subDir enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path = obj;
            NSString *filePath = [dataPath stringByAppendingPathComponent:path];
            NSLog(@"uploadData,遍历路径：%@",filePath);
            BOOL isDir;
            [fileManager fileExistsAtPath:filePath isDirectory:&isDir];//看下有没有更方便的方法
            if (isDir) {
                NSError *filesError;
                NSArray *subFiles = [fileManager subpathsOfDirectoryAtPath:filePath error:&filesError];
#ifdef TARGET_IPHONE_SIMULATOR
                if ([subFiles count] == 1) {//mac OS 应排除 .DS_Store 再测试下
                    [self deleteFileWithPath:filePath];
                }
#endif
                if ([subFiles count] <= 0) {
                    [self deleteFileWithPath:filePath];
                }
            } else {//是文件
                NSString *fileExtension = [filePath pathExtension];
                if ([fileExtension rangeOfString:@"json"].location != NSNotFound) {
                    //则是待上传的文件 323242342.json
                    //打算用信号量控制...
                    dispatch_semaphore_wait(_uploadTaskSemaphore, DISPATCH_TIME_FOREVER);
                    //默认 队列里 可以追加的任务最大为：最大并发数 * 2 完成一个则
                    if (_delegate && [_delegate respondsToSelector:@selector(userBehaviourUploadWithFilePath:completedBlock:)]) {
                        [_delegate userBehaviourUploadWithFilePath:filePath completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                            if (finished) {
                                dispatch_semaphore_signal(_uploadTaskSemaphore);
                                [[HCUploadDataManager sharedManager] uploadWithFilePath:filePath completed:^(NSData *data, NSError *error, BOOL finished) {
                                    if (finished) {
                                        NSLog(@"上传任务成功---------");
                                        NSLog(@"成功任务路径:%@",filePath);
                                    } else {
                                        NSLog(@"上传任务失败---------");
                                        NSLog(@"失败任务路径:%@",filePath);
                                        NSLog(@"error：%@",error);
                                    }
                                    dispatch_semaphore_signal(_uploadTaskSemaphore);
                                }];
                                NSLog(@"当前队列任务数:%ld",[HCUploadDataManager sharedManager].currentUploaderCount);
                            }
                        }];
                    } else {
                        NSLog(@"需要设置代理，自行提供上传接口。");
                    }
                } else {
                    //文件不是 json 就不是存储的数据，可能是 .DS_Store 等其它的东西。
                    [self deleteFileWithPath:filePath];
                }
            }
        }];
    }
    [self setLastUploadTime:[[NSDate new]timeIntervalSince1970]];
}

#pragma mark - 属性读写

- (void)reportPolicy:(HCReportPolicy)reportPolicy; {
    _reportPolicy = reportPolicy;
    [[self UBUserDefaults] setInteger:_reportPolicy forKey:kReportPolicyKey];
}

- (void)setReportInterval:(NSTimeInterval)reportInterval {
    _reportInterval = reportInterval;
    [[self UBUserDefaults] setDouble:_reportInterval forKey:kReportIntervalKey];
}

- (void)setLastUploadTime:(NSTimeInterval)lastUploadTime {
    _lastUploadTime = lastUploadTime;
    [[self UBUserDefaults] setDouble:_lastUploadTime forKey:kLastUploadTime];
}

- (HCPage *)currentPage {
    @synchronized (_mutablePages) {
        return _mutablePages.lastObject;
    }
}

- (NSArray *)pages {
    return [_mutablePages copy];
}

- (NSArray *)users {
    return [_mutableUsers copy];
}

- (NSUserDefaults *)UBUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:@"com.HCUserBehaviour.preference"];
}

- (NSArray *)getBlackPageNameList {
    return _blackNameList;
}

- (void)setBlackPageNameList:(NSArray *)array {
    _blackNameList = array;
}

- (void)setMaxConcurrentUploadNumber:(NSUInteger)maxConcurrentUploadNumber {
    _maxConcurrentUploadNumber = maxConcurrentUploadNumber;
    @synchronized (_uploadTaskSemaphore) {
        _uploadTaskSemaphore = dispatch_semaphore_create(_maxConcurrentUploadNumber * 2);
    }
}

#pragma mark - 文件操作
- (void)saveData:(NSData *)data fileName:(NSString *)fileName directoryName:(NSString *)directoryName{
    NSLog(@"保存数据的路径:%@",directoryName);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:directoryName isDirectory:&isDirectory]) {
        if (isDirectory) {
            [fileManager createFileAtPath:fileName contents:data attributes:nil];
        } else {
            //文件存在但不是文件夹，这种情况几乎不会出现。
            [self deleteFileWithPath:directoryName];
            NSError *createDirError = nil;
            [fileManager createDirectoryAtPath:directoryName withIntermediateDirectories:YES attributes:nil error:&createDirError];
            if (createDirError) {
                NSLog(@"%@ 文件路径创建失败 error:%@",directoryName,createDirError);
            } else {
                NSLog(@"%@ 文件路径创建成功",directoryName);
                [fileManager createFileAtPath:fileName contents:data attributes:nil];
            }
        }
    } else {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:directoryName withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@ 文件路径创建失败 error:%@",directoryName,error);
        } else {
            NSLog(@"%@ 文件路径创建成功",directoryName);
            [fileManager createFileAtPath:fileName contents:data attributes:nil];
        }
    }
}

- (void)deleteFileWithPath:(NSString *)path {
    NSError *removeFileError;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&removeFileError];
    if (removeFileError) {
        NSLog(@"删除该路径失败：%@ #%@#",path,removeFileError);
    } else {
        NSLog(@"删除该路径成功：%@",path);
    }
}

#pragma mark - 记录
- (void)enterPage:(NSString *)pageName {
    @synchronized (_blackNameList) {
        if ([_blackNameList containsObject:pageName]) {
            return;
        }
    }
    
    HCPage *page = [[HCPage alloc]initWithName:pageName userName:_currentUser.name];
    @synchronized (_mutablePages) {
        [_mutablePages addObject:page];
    }
    @synchronized (_lastPages) {
        [_lastPages setObject:page forKey:pageName];
    }
    page.beginTime = [[NSDate new]timeIntervalSince1970];
    
    NSLog(@"进入页面,%@:%@",pageName,page);
}

- (void)exitPage:(NSString *)pageName {
    @synchronized (_blackNameList) {
        if ([_blackNameList containsObject:pageName]) {
            NSLog(@"exitPage 该 page 在 黑名单中");
            return;
        }
    }
    
    @synchronized (_lastPages) {
        HCPage *lastPage = _lastPages[pageName];
        if (lastPage) {
            lastPage.endTime = [[NSDate new]timeIntervalSince1970];
            [_lastPages removeObjectForKey:pageName];
        }
        else {
            NSLog(@"_lastPages 取不到对应的页面");
        }
        NSLog(@"离开页面,%@:%@",pageName,lastPage);
    }
}

- (void)event:(NSString *)eventId {
    [self event:eventId attributes:nil];
}

- (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes {
    NSLog(@"记录事件，page:%@, eventId:%@, attributes:%@",[self currentPage].name,eventId,attributes);
    [[self currentPage] event:eventId attributes:attributes];
}

- (void)userSignInWithName:(NSString *)userName channel:(NSString *)channel {
    @synchronized (_mutableUsers) {
        _currentUser = [[HCUser alloc]initWithName:userName channel:channel];
        [_currentUser logIn];
        [_mutableUsers addObject:_currentUser];
        NSLog(@"用户登录，用户:%@, 登录渠道:%@",_currentUser,channel);
    }
}

- (void)userSignOut {
    @synchronized (_mutableUsers) {
        NSLog(@"用户退出,用户:%@",_currentUser);
        [_currentUser logOut];
        _currentUser = nil;
        [_mutableUsers removeObject:_currentUser];
    }
}

@end
