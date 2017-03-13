//
//  ViewController.m
//  HCUserBehaviourDemo
//
//  Created by 刘海川 on 17/2/16.
//  Copyright © 2017年 Haichuan Liu. All rights reserved.
//

#import "ViewController.h"
#import "HCRegisterViewController.h"
#import "HCLoginViewController.h"
#import "HCGoodsDetailViewController.h"
#import "HCUploadDataManager.h"


@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSURL *fileURL = [NSURL URLWithString:@"/Users/lhc/Desktop/testJson.json"];
////    NSURL *serverURL = [NSURL URLWithString:@"http://198.1.244.44:8082/pweb/uploadFileTest.do"];
//    NSURL *serverURL = [NSURL URLWithString:@"http://192.168.1.116:8080/SpringMVC0002/spring/byebye.action"];
//    [[HCUploadDataManager sharedManager] uploadWithURL:serverURL parameters:@{@"UploadFile":@"lhc"} fileURL:fileURL];
    // Do any additional setup after loading the view, typically from a nib.
//    
//    for (int i = 0; i < 100; i++) {
//        [[HCOperationManager shared] addTask:[NSString stringWithFormat:@"%d",i]];
//    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"注册";//短信验证码，注册
            break;
        case 1:
            cell.textLabel.text = @"登录";//普通登录，wechat ，webo，qq
            break;
        case 2:
            cell.textLabel.text = @"产品详情";//分享 收藏 购买
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            HCRegisterViewController *vc = [HCRegisterViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            HCLoginViewController *vc = [HCLoginViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            HCGoodsDetailViewController *vc = [HCGoodsDetailViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
