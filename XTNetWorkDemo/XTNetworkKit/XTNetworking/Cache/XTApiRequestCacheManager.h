//
//  XTApiRequestCacheManager.h
//  XTNetworkKit
//
//  Created by Tong on 2018/5/29.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTApiRequestCacheManager : NSObject

/**
 添加网络请求的返回结果，使用 url和parameters 做缓存key

 @param responseData 返回的请求结果
 @param urlString 请求地址
 @param parameters 请求参数
 */
+ (void)addHttpResponseData:(id)responseData url:(NSString *)urlString parameters:(id)parameters;


/**
 获取网络请求缓存结果

 @param urlString 请求地址
 @param parameters 请求参数
 @return 请求结果
 */
+ (id)getHttpResponseDataWithUrl:(NSString *)urlString parameters:(id)parameters;


/**
 获取网络缓存总大小

 @return 缓存大小字节（bytes）
 */
+ (NSInteger)getAllHttpResponseDataCacheSize;


/**
 移除网络缓存

 @param urlString 请求地址
 @param parameters 请求参数
 */
+ (void)removeHttpResponseDataCacheWithUrl:(NSString *)urlString parameters:(id)parameters;

/**
 移除所有的网络缓存
 */
+ (void)removeAllHttpResponseDataCache;


@end







