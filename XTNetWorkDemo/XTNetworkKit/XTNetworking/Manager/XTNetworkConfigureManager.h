//
//  XTNetworkConfigureManager.h
//  XTNetworkKit
//
//  Created by Tong on 2018/5/29.
//  Copyright © 2018年 Tong. All rights reserved.
//

/**
 网络库常用配置管理类(可以根据自己的需求自定义)
 */

#import <Foundation/Foundation.h> 

@interface XTNetworkConfigureManager : NSObject

+ (XTNetworkConfigureManager *)sharedManager;

/** 是否打印输出 - 总开关（YES:不输出） */
@property (nonatomic, assign) BOOL disableLog;

/**
 获取网络缓存总大小
 
 @return 缓存大小字节（bytes）
 */
+ (NSInteger)getAllHttpResponseDataCacheSize;

/**
 清理网络库缓存数据
 */
+ (void)removeAllHttpResponseDataCache;

/**
 获取当前APP版本
 */
+ (NSString *)currentAppVersion;

@end
