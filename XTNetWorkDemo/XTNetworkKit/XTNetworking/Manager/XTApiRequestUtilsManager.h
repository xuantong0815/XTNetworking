//
//  XTApiRequestManager.h
//  XTNetworkKit
//
//  Created by Tong on 2018/5/29.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, XTNetworkStatusType) {
    
    XTNetworkStatusUnknown = 0,         // 未知网络
    XTNetworkStatusNotReachable,        // 无网络
    XTNetworkStatusReachableViaWWAN,    // 手机网络
    XTNetworkStatusReachableViaWiFi     // WIFI网络
};

// 网络状态的Block
typedef void(^XTNetworkStatus)(XTNetworkStatusType status);


@interface XTApiRequestUtilsManager : NSObject


+ (XTApiRequestUtilsManager *)sharedManager;


/**
 有网：YES，无网：NO
 */
+ (BOOL)hasNetwork;


/**
 wifi 网络返回 YES
 */
+ (BOOL)isWiFiNetwork;


/**
 手机移动网络
 */
+ (BOOL)isWWANNetwork;


/**
 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
 */
+ (void)getNetworkStatusWithBlock:(XTNetworkStatus)networkStatus;


/**
 添加通用参数 - Header
 
 @param parameters 接口参数
 @return 通用接口参数
 */
+ (NSDictionary *)parameterForHttpHeadWithDictionary:(NSDictionary *)parameters;


/**
 添加通用参数 - Body
 
 @param parameters 接口参数
 @return 通用接口参数
 */
+ (NSDictionary *)parameterForHttpBodyWithDictionary:(NSDictionary *)parameters;


/**
 获取 sign 签名

 @param parameters 参数
 @param skey skey
 @return sign签名
 */
+ (NSString *)getRequestSignWithDictionary:(NSDictionary *)parameters skey:(NSString *)skey;


/**
 获取带 sign 签名的最终参数

 @param parameters 接口参数
 @param skey skey
 @return 最终的参数
 */
+ (NSDictionary *)getFinalParametersWithSignByDictionary:(NSDictionary *)parameters skey:(NSString *)skey;

@end










