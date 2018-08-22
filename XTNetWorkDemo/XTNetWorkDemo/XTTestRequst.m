//
//  XTTestRequst.m
//  XTNetWorkDemo
//
//  Created by Tong on 2018/8/21.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import "XTTestRequst.h"

@implementation XTTestRequst

- (void)sendToGetLoginUserInfo:(XTApiRequestResultBlock)resultBlock
{
    self.needRetainWhenAsyncUploadFile = YES;
    
    __weak XTTestRequst *weakSelf = self;
    
    // 处理数据，这里可以把请求到数据，转换成我们需要的Model
    [self setHandleDataBlock:^id(id responseObject) {
    
        if (weakSelf.needRetainWhenAsyncUploadFile) {
            weakSelf.needRetainWhenAsyncUploadFile = NO;
        }
        
        return nil;
    }];
    
    // 发起请求
    [self requestBy:XTApiRequestMethodGET urlString:@"" parameters:@{} result:^(BOOL success, id responseObject, NSDictionary *status) {
        
        if (resultBlock) {
            resultBlock(success, responseObject, status);
        }
    }];
}



@end
