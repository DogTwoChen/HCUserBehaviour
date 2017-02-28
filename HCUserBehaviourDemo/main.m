//
//  main.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HCPage.h"
#import "HCUser.h"
#import "NSObject+HCJSON.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        HCPage *page = [[HCPage alloc]initWithName:@"HCLoginViewController" userName:@"lhc"];
//        page.beginTime = 10000;
//        page.endTime = 15000;
//        [page event:@"LogInAction" attributes:@{@"name":@"lhc",@"password":@"123456",@"vertyCode":@"123212"}];
//        HCUser *user = [[HCUser alloc]initWithName:@"haichuan" channel:@"WeChat"];
//        NSError *pageJsonError = nil;
//        NSData *pageJsonData = [page hc_getJsonWithError:&pageJsonError];
//        NSString *pageJson = [[NSString alloc]initWithData:pageJsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"pageJson:%@",pageJson);
//        
//        NSError *userJsonError = nil;
//        NSData *userJsonData = [user hc_getJsonWithError:&userJsonError];
//        NSString *userJson = [[NSString alloc]initWithData:userJsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"userJson:%@",userJson);
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
