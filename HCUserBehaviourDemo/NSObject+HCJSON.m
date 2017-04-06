//
//  NSObject+HCJSON.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/22.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "NSObject+HCJSON.h"
#import <objc/runtime.h>
#import "HCUser.h"
#import "HCPage.h"
#import "HCUser.h"

static char kBlackNameListKey;

@implementation NSObject (HCJSON)

- (NSData *)hc_getJsonWithError:(NSError **)error {
    NSArray *names = [self propertyNames:[self class]];
    NSDictionary *values = [self propertyValues:names];
    NSData *data = [NSJSONSerialization dataWithJSONObject:values options:NSJSONWritingPrettyPrinted error:error];
    return data;
}

- (NSArray *)propertyNames:(Class)class {
    NSArray *blackNameList = [self hc_getJSONBlackNameList];
    
    NSMutableArray *propertyNames = [[NSMutableArray alloc]init];
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList(class, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertys[i];
        const char *name = property_getName(property);
        //黑名单
        NSString *p_name = [NSString stringWithUTF8String:name];
        if ([blackNameList containsObject:p_name]) {
            continue;
        }
        [propertyNames addObject:p_name];
    }
    free(propertys);
    return propertyNames;
}

- (NSDictionary *)propertyValues:(NSArray *)propertys {
    NSMutableDictionary *propertyValuesDic = [[NSMutableDictionary alloc]init];
    for (NSString *propertyName in propertys) {
        SEL getterSEL = NSSelectorFromString(propertyName);
        if ([self respondsToSelector:getterSEL]) {
            NSMethodSignature *signature = nil;
            signature = [self methodSignatureForSelector:getterSEL];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:getterSEL];
            [invocation setTarget:self];
            [invocation invoke];
            __weak NSObject *valueObj = nil;
            const char *returnType = [[invocation methodSignature] methodReturnType];
            
            NSString *returnTypeStr = [NSString stringWithUTF8String:returnType];
            if ([returnTypeStr isEqualToString:@"d"]) {
                double valueD = 0;
                //TODO:待优化
                [invocation getReturnValue:&valueD];
                if (valueD > 0) {
                    valueObj = [NSString stringWithFormat:@"%0.f",valueD];
                } else {
                    valueObj = @"0";
                }
            }
            else {
                [invocation getReturnValue:&valueObj];
                if (valueObj == nil) {
                    valueObj = @"";
                }
            }
            NSLog(@"name:%@,value:%@",propertyName,valueObj);
            if ([valueObj isKindOfClass:[NSArray class]]) {
                NSArray *array = (NSArray *)valueObj;
                NSMutableArray *mutableArray = [array mutableCopy];
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSArray *names = [obj propertyNames:[obj class]];
                    NSDictionary *values = [obj propertyValues:names];
                    [mutableArray replaceObjectAtIndex:idx withObject:values];
                }];
                valueObj = mutableArray;
                propertyValuesDic[propertyName] = valueObj;
            }
            else if ([valueObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)valueObj;
                NSMutableDictionary *mutableDict = [dict mutableCopy];
                [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                        
                    } else {
                        NSArray *names = [obj propertyNames:[obj class]];
                        NSDictionary *values = [obj propertyValues:names];
                        [mutableDict setObject:values forKey:key];
                    }
                }];
                valueObj = mutableDict;
                propertyValuesDic[propertyName] = valueObj;
            }
            else if ([valueObj isKindOfClass:[HCUser class]] || [valueObj isKindOfClass:[HCPage class]] || [valueObj isKindOfClass:[HCEvent class]]) {
                NSArray *names = [valueObj propertyNames:[valueObj class]];
                NSDictionary *values = [valueObj propertyValues:names];
                valueObj = values;
                propertyValuesDic[propertyName] = valueObj;
            }//其他对象怎么处理
            else if ([valueObj isKindOfClass:[NSString class]]||[returnTypeStr isEqualToString:@"d"]) {
                propertyValuesDic[propertyName] = valueObj;
            }
//            propertyValuesDic[propertyName] = valueObj;
            valueObj = nil;
        }
    }
    return propertyValuesDic;
}

- (NSArray *)hc_getJSONBlackNameList {
    NSArray *array = objc_getAssociatedObject(self, &kBlackNameListKey);
    return array;
}

- (void)hc_setJSONBlackNameList:(NSArray *)array {
    objc_setAssociatedObject(self, &kBlackNameListKey, array, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


@end
