//
//  XTApiRequestManager.m
//  XTNetworkKit
//
//  Created by Tong on 2018/5/29.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import "XTApiRequestUtilsManager.h"

#import "XTApiRequest.h"

#import "AFNetworking.h"
#import "XTNetworkConfigureManager.h"

#import <sys/utsname.h>

@implementation XTApiRequestUtilsManager

static XTApiRequestUtilsManager *_manager;

+ (XTApiRequestUtilsManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[XTApiRequestUtilsManager alloc] init];
    });
    return _manager;
}


/**
 有网：YES，无网：NO
 */
+ (BOOL)hasNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}


/**
 wifi 网络返回 YES
 */
+ (BOOL)isWiFiNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}


/**
 手机移动网络
 */
+ (BOOL)isWWANNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}



/**
 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
 */
+ (void)getNetworkStatusWithBlock:(XTNetworkStatus)networkStatus
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                if (networkStatus) {
                    networkStatus(XTNetworkStatusUnknown);
                }
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                if (networkStatus) {
                    networkStatus(XTNetworkStatusNotReachable);
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                if (networkStatus) {
                    networkStatus(XTNetworkStatusReachableViaWWAN);
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                if (networkStatus) {
                    networkStatus(XTNetworkStatusReachableViaWiFi);
                }
            }
                break;
            default:
                break;
        }
        
    }];
}

/**
 获取通用参数 - Header
 
 @param parameters 接口参数
 @return 通用接口参数
 */
+ (NSDictionary *)parameterForHttpHeadWithDictionary:(NSDictionary *)parameters
{
    // 设置必须要的参数
    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionary];
    
    if (parameters && parameters.count != 0) {
        [parameterDic addEntriesFromDictionary:parameterDic];
    }
    
    static NSMutableDictionary * __needAllDatas;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        __needAllDatas = [[NSMutableDictionary alloc]initWithCapacity:10];

        // info.plist
        NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
        
        // app bundle id
        NSString *bundle = [infoPlist objectForKey:(NSString*)kCFBundleIdentifierKey];
        [__needAllDatas setObject:bundle ? bundle : @"" forKey:@"bundleId"];
        
        // app version
        [__needAllDatas setObject:[XTNetworkConfigureManager currentAppVersion] forKey:@"appVersion"];
        
        // 设备唯一码
        NSString *deviceCode = @"xxxxx";
        if (deviceCode && [deviceCode isKindOfClass:[NSString class]] && deviceCode.length > 0) {
            [__needAllDatas setObject:deviceCode forKey:@"deviceId"];
        }
        
        // 设备型号
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *devicePlatform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
        [__needAllDatas setObject:devicePlatform forKey:@"devicePlatform"];
        
        // 设备类型
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [__needAllDatas setObject:@"phone" forKey:@"agent"];
        } else {
            [__needAllDatas setObject:@"pad" forKey:@"agent"];
        }
        
        // 网络类型
        NSString *netType = [self isWiFiNetwork] ? @"wifi" : @"cellular";
        [__needAllDatas setObject:netType forKey:@"network"];
        
        // 操作系统版本
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        [__needAllDatas setObject:osVersion forKey:@"osVersion"];
    });

#warning - Add Common parameters - 添加通用的参数到Header
    
    // 添加通用参数
    [parameters setValuesForKeysWithDictionary:__needAllDatas];
    

    return parameterDic;
}


/**
 获取通用参数 - Body
 
 @param parameters 接口参数
 @return 通用接口参数
 */
+ (NSDictionary *)parameterForHttpBodyWithDictionary:(NSDictionary *)parameters
{
    return parameters;
}


/**
 获取 sign 签名
 
 @param parameters 参数
 @param skey skey
 @return sign签名
 */
+ (NSString *)getRequestSignWithDictionary:(NSDictionary *)parameters skey:(NSString *)skey
{
    if (!parameters || parameters.count == 0) {
        return @"";
    }

#warning Get Sign - 根据自己的需求生成Sign签名
    
    NSString *sign = @"";

    return sign;
}

/**
 获取带 sign 签名的最终参数
 
 @param parameters 接口参数
 @param skey skey
 @return 最终的参数
 */
+ (NSDictionary *)getFinalParametersWithSignByDictionary:(NSDictionary *)parameters skey:(NSString *)skey
{
    NSMutableDictionary *parametersDic = [NSMutableDictionary dictionaryWithDictionary:[XTApiRequestUtilsManager parameterForHttpBodyWithDictionary:parameters]];

#warning Add Sign - 添加生成的sign到Body，根据自己的需要设置字段名
    
    // 非 GET请求增加 sign 签名
    NSString *sign = [XTApiRequestUtilsManager getRequestSignWithDictionary:parametersDic skey:skey];
    
    [parametersDic setObject:sign forKey:@"__sign"];

    return parametersDic;
}

@end








