//
//  UIViewController+HCUserBehaviour.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/17.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "UIViewController+HCUserBehaviour.h"
#import "HCUserBehaviour.h"
#import <objc/runtime.h>

@implementation UIViewController (HCUserBehaviour)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(swizzliedViewWillAppear);
        SEL originalSelector02 = @selector(viewWillDisappear:);
        SEL swizzledSelector02 = @selector(swizzliedViewWillDisappear);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method originalMethod02 = class_getInstanceMethod(class, originalSelector02);
        Method swizzledMethod02 = class_getInstanceMethod(class, swizzledSelector02);
        
        BOOL didHasMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didHasMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }
        else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        BOOL didHasMethod02 = class_addMethod(class, originalSelector02, method_getImplementation(swizzledMethod02), method_getTypeEncoding(swizzledMethod02));
        if (didHasMethod02) {
            class_replaceMethod(class, swizzledSelector02, method_getImplementation(originalMethod02), method_getTypeEncoding(originalMethod02));
        }
        else {
            method_exchangeImplementations(originalMethod02, swizzledMethod02);
        }
    });
}

- (void)swizzliedViewWillAppear {
    [self swizzliedViewWillAppear];
    [[HCUserBehaviour sharedInstance] enterPage:NSStringFromClass(self.class)];
}

- (void)swizzliedViewWillDisappear {
    [self swizzliedViewWillDisappear];
    [[HCUserBehaviour sharedInstance] exitPage:NSStringFromClass(self.class)];
}

@end
