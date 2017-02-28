//
//  HCGoodsDetailViewController.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/17.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "HCGoodsDetailViewController.h"
#import "HCUserBehaviour.h"

@interface HCGoodsDetailViewController ()

@end

@implementation HCGoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(rect);
    
    UIButton *button01 = [[UIButton alloc]initWithFrame:CGRectMake(0, 64+30, width, 50)];
    [button01 setTitle:@"分享" forState:UIControlStateNormal];
    [button01 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button01 addTarget:self action:@selector(shared) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button01];
    
    UIButton *button02 = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button01.frame)+30, width, 50)];
    [button02 setTitle:@"收藏" forState:UIControlStateNormal];
    [button02 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button02 addTarget:self action:@selector(collecion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button02];
    
    UIButton *button03 = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button02.frame)+30, width, 50)];
    [button03 setTitle:@"购买" forState:UIControlStateNormal];
    [button03 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button03 addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button03];
}

- (void)shared {
    [[HCUserBehaviour sharedInstance] event:@"Event&Shared"];
};

- (void)collecion {
    [[HCUserBehaviour sharedInstance] event:@"Event&Collection"];
}

- (void)buy {
    [[HCUserBehaviour sharedInstance] event:@"Event&Buy"
                                 attributes:@{@"goodsName":@"迪士尼主题公园门票",@"price":@"600.00",@"amount":@"10"}];
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
