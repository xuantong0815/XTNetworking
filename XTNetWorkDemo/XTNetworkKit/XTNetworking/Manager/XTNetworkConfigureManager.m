//
//  XTNetworkConfigureManager.m
//  XTNetworkKit
//
//  Created by Tong on 2018/5/29.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import "XTNetworkConfigureManager.h"

#import "XTApiRequestCacheManager.h"
#import "AFNetworkReachabilityManager.h"

@implementation XTNetworkConfigureManager

static XTNetworkConfigureManager *configure = nil;

+ (XTNetworkConfigureManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configure = [[XTNetworkConfigureManager alloc] init];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    
    return configure;
}

/**
 获取网络缓存总大小
 
 @return 缓存大小字节（bytes）
 */
+ (NSInteger)getAllHttpResponseDataCacheSize
{
    return [XTApiRequestCacheManager getAllHttpResponseDataCacheSize];
}

/**
 清理网络库缓存数据
 */
+ (void)removeAllHttpResponseDataCache
{
    [XTApiRequestCacheManager removeAllHttpResponseDataCache];
}

/**
 获取当前APP版本
 */
+ (NSString *)currentAppVersion
{
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    
    NSString *version = @"";
    
    if (infoPlist[@"CFBundleShortVersionString"]) {
        version = infoPlist[@"CFBundleShortVersionString"];
    }
    
    if (!version || version.length == 0) {
        version = [infoPlist objectForKey:(NSString*)kCFBundleVersionKey];
    }
    return version;
}


@end
