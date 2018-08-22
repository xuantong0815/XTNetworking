//
//  ViewController.m
//  XTNetWorkDemo
//
//  Created by Tong on 2018/8/21.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import "ViewController.h"

#import "XTTestRequst.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    XTTestRequst *request = [[XTTestRequst alloc] init];
    
    [request sendToGetLoginUserInfo:^(BOOL success, id responseObject, NSDictionary *status) {
        
        
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
