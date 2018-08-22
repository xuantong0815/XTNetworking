//
//  WPApiReqeustTimeHelper.h
//  WPNetworkKit
//
//  Created by Tong on 2018/7/9.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPApiReqeustTimeHelper : NSObject

+ (WPApiReqeustTimeHelper *)sharedManager;

/** 时间戳 */
@property (nonatomic,assign, readonly) long long timestamp;

/** 程序启动时间 */
@property (nonatomic,assign, readonly) double applaunchTimestamp;

/**
 刷新服务器时间戳
 */
- (void)refreshServerTimestamp;

/**
 获取当前根据服务器日期校准后的日期
 */
- (NSDate *)getCurrentCorrectDate;

@end
