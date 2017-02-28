//
//  NSObject+HCJSON.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/22.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HCJSON)

- (NSData *)hc_getJsonWithError:(NSError **)error;

- (NSArray *)hc_getJSONBlackNameList;

- (void)hc_setJSONBlackNameList:(NSArray *)array;

@end
