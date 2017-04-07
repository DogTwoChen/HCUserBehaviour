//
//  HCPage.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCEvent.h"
@interface HCPage : NSObject

@property (nonatomic, readonly, copy) NSString *name;

@property (nonatomic, readonly, copy) NSString *userName;

@property (nonatomic, assign) NSTimeInterval beginTime;

@property (nonatomic, assign) NSTimeInterval endTime;

@property (nonatomic, readonly, assign) NSTimeInterval stayTime;

//@property (nonatomic, readonly, assign) NSUInteger *amount;

//@property (nonatomic, readonly, copy) NSString *description;

@property (nonatomic, readonly, copy) NSArray *events;

- (instancetype)initWithName:(NSString *)pageName userName:(NSString *)userName;

- (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes;

@end
