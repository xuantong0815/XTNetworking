//
//  XTTestRequst.h
//  XTNetWorkDemo
//
//  Created by Tong on 2018/8/21.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import "XTApiRequest.h"

@interface XTTestRequst : XTApiRequest

- (void)sendToGetLoginUserInfo:(XTApiRequestResultBlock)resultBlock;

@end
