//
//  HCEvent.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCEvent : NSObject

@property (nonatomic, readonly, copy) NSString *name;

@property (nonatomic, readonly, copy) NSString *pageName;

//@property (nonatomic, readonly, copy) NSString *description;

@property (nonatomic, readonly, copy) NSDictionary *parameters;

- (instancetype)initWithName:(NSString *)name
                        page:(NSString *)pageName
                  parameters:(NSDictionary *)parameters;

@end
