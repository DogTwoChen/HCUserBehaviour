//
//  HCPage.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCPage.h"
#import "NSObject+HCJSON.h"
@interface HCPage ()
{
    NSMutableArray *_mutableEvents;
}
//@property (nonatomic, readwrite, assign) NSTimeInterval stayTime;
@end
@implementation HCPage

- (instancetype)initWithName:(NSString *)pageName userName:(NSString *)userName {
    self = [super init];
    if (self) {
        _name = pageName;
        _userName = userName;
        _mutableEvents = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)events {
    return [_mutableEvents copy];
}

- (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes {
    HCEvent *event = [[HCEvent alloc]initWithName:eventId
                                             page:_name
                                       parameters:attributes];
    [_mutableEvents addObject:event];
}

- (void)setEndTime:(NSTimeInterval)endTime {
    _endTime = endTime;
    if (_beginTime > 0 && _endTime > 0) {
        _stayTime = _endTime - _beginTime;
    }
}

@end
