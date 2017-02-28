//
//  HCUser.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCUser.h"

@implementation HCUser

- (instancetype)initWithName:(NSString *)name
                     channel:(NSString *)channel {
    self = [super init];
    if (self) {
        _name = name;
        _channel = channel;
    }
    return self;
}

- (void)logIn {
    _beginTime = [[NSDate new] timeIntervalSince1970];
}

- (void)logOut {
    _endTime = [[NSDate new] timeIntervalSince1970];
    if (_beginTime > 0 && _endTime > 0) {
        _stayTime = _endTime - _beginTime;
    }
}

@end
