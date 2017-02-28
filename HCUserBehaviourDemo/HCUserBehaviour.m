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

@interface HCUserBehaviour ()
{
    NSMutableArray *_mutablePages;
    NSMutableArray *_mutableUsers;
    NSMutableDictionary *_lastPages;
}

@property (nonatomic, readwrite, assign) NSTimeInterval lastUploadTime;

@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

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
        //序列化对象，没有在 new。
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
    
    [self hc_setJSONBlackNameList:@[@"concurrentQueue",@"dateFormatter"]];
    
    _mutablePages = [NSMutableArray array];
    _mutableUsers = [NSMutableArray array];
    _lastPages = [NSMutableDictionary new];
    _concurrentQueue = dispatch_queue_create("com.hcuserbehaviour.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    
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
    dispatch_async(_concurrentQueue, ^{
        NSLog(@"保存数据");
        NSError *error = nil;
        NSData *data = [self hc_getJsonWithError:&error];
//        NSData *data = [NSData new];
        if (data) {
            NSDate *todayDate = [NSDate new];
            NSString *todayStr = [_dateFormatter stringFromDate:todayDate];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = paths.firstObject;
            
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);
        NSLog(@"上传成功");
        [self setLastUploadTime:[[NSDate new]timeIntervalSince1970]];
        NSLog(@"清理本地数据");
    });
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
    return _mutablePages.lastObject;
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
            NSError *removeItemError = nil;
            [fileManager removeItemAtPath:directoryName error:&removeItemError];
            if (removeItemError) {
                NSLog(@"文件删除失败 error:%@",removeItemError);
            }
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

#pragma mark - 记录
- (void)enterPage:(NSString *)pageName {
    HCPage *page = [[HCPage alloc]initWithName:pageName userName:_currentUser.name];
    [_mutablePages addObject:page];
    [_lastPages setObject:page forKey:pageName];
    page.beginTime = [[NSDate new]timeIntervalSince1970];
    
    NSLog(@"进入页面,%@:%@",pageName,page);
}

- (void)exitPage:(NSString *)pageName {
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

- (void)event:(NSString *)eventId {
    [self event:eventId attributes:nil];
}

- (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes {
    NSLog(@"记录事件，page:%@, eventId:%@, attributes:%@",[self currentPage].name,eventId,attributes);
    [[self currentPage] event:eventId attributes:attributes];
}

- (void)userlogInWithName:(NSString *)userName channel:(NSString *)channel {
    _currentUser = [[HCUser alloc]initWithName:userName channel:channel];
    [_currentUser logIn];
    [_mutableUsers addObject:_currentUser];
    NSLog(@"用户登录，用户:%@, 登录渠道:%@",_currentUser,channel);
}

- (void)userlogOut {
    NSLog(@"用户退出,用户:%@",_currentUser);
    [_currentUser logOut];
    _currentUser = nil;
    [_mutableUsers removeObject:_currentUser];
}

@end







