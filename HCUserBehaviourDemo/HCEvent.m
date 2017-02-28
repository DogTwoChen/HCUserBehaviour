//
//  HCEvent.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCEvent.h"

@implementation HCEvent

- (instancetype)initWithName:(NSString *)name
                        page:(NSString *)pageName
                  parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        _name = name;
        _pageName = pageName;
        _parameters = [parameters copy];
    }
    return self;
}

@end
