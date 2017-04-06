//
//  HCUser.h
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCUser : NSObject

@property (nonatomic, readonly, copy) NSString *name;

@property (nonatomic, readonly, copy) NSString *channel;

@property (nonatomic, readonly, assign) NSTimeInterval beginTime;

@property (nonatomic, readonly, assign) NSTimeInterval endTime;

@property (nonatomic, readonly, assign) NSTimeInterval stayTime;

- (instancetype)initWithName:(NSString *)name
                     channel:(NSString *)channel;
- (void)signIn;
- (void)signOut;

@end
