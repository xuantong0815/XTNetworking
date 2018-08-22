//
//  ApiRequestCacheManager.m
//  XTNetworkKit
//
//  Created by Tong on 2018/5/29.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import "XTApiRequestCacheManager.h"

#import "YYCache.h"

static NSString *const kXTNetworkResponseDataCache = @"kXTNetworkResponseDataCache";

@implementation XTApiRequestCacheManager

static YYCache *_dataCache;

+ (void)initialize
{
    _dataCache = [YYCache cacheWithName:kXTNetworkResponseDataCache];
    _dataCache.memoryCache.costLimit = 100000000;
    _dataCache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = NO;
}

/**
 添加网络请求的返回结果，使用 url和parameters 做缓存key
 
 @param responseData 返回的请求结果
 @param urlString 请求地址
 @param parameters 请求参数
 */
+ (void)addHttpResponseData:(id)responseData url:(NSString *)urlString parameters:(id)parameters
{
    NSString *cacheKey = [self getCacheKeyWithUrl:urlString parameters: parameters];
    
    // 异步缓存
    [_dataCache setObject:responseData forKey:cacheKey withBlock:nil];
}


/**
 获取网络请求缓存结果
 
 @param urlString 请求地址
 @param parameters 请求参数
 @return 请求结果
 */
+ (id)getHttpResponseDataWithUrl:(NSString *)urlString parameters:(id)parameters
{
    NSString *cacheKey = [self getCacheKeyWithUrl:urlString parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}


/**
 获取网络缓存总大小
 
 @return 缓存大小字节（bytes）
 */
+ (NSInteger)getAllHttpResponseDataCacheSize
{
    return [_dataCache.diskCache totalCost];
}

/**
 移除网络缓存
 
 @param urlString 请求地址
 @param parameters 请求参数
 */
+ (void)removeHttpResponseDataCacheWithUrl:(NSString *)urlString parameters:(id)parameters
{
    NSString *cacheKey = [self getCacheKeyWithUrl:urlString parameters:parameters];
    [_dataCache.diskCache removeObjectForKey:cacheKey];
}


/**
 移除所有的网络缓存
 */
+ (void)removeAllHttpResponseDataCache
{
    [_dataCache.diskCache removeAllObjects];
}


/**
 生成网络请求缓存key

 @param urlString 请求地址
 @param parameters 请求参数
 @return 缓存key
 */
+ (NSString *)getCacheKeyWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters
{
    if(!parameters || parameters.count == 0) {
        return urlString;
    }
    
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSString *parametersString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"%@%@",urlString,parametersString];
}

@end
