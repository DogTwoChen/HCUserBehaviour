//
//  HCRegisterViewController.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/17.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCRegisterViewController.h"
#import "HCUserBehaviour.h"

@interface HCRegisterViewController ()

@end

@implementation HCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(rect);
    
    UIButton *button01 = [[UIButton alloc]initWithFrame:CGRectMake(0, 64+30, width, 50)];
    [button01 setTitle:@"短信验证码" forState:UIControlStateNormal];
    [button01 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button01 addTarget:self action:@selector(getMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button01];
    
    UIButton *button02 = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button01.frame)+30, width, 50)];
    [button02 setTitle:@"短信验证码" forState:UIControlStateNormal];
    [button02 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button02 addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button02];
}

- (void)getMessage {
    [[HCUserBehaviour sharedInstance] event:@"Event&GetMessage"];
}

- (void)registerUser {
    [[HCUserBehaviour sharedInstance] event:@"Event&RegisterUser" attributes:@{@"username":@"mike",@"identifier":@"89865"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
