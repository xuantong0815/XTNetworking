//
//  XTApiRequest.h
//  XTNetworkKit
//
//  Created by Tong on 2018/5/28.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XTApiRequestCacheType) {
    
    XTApiRequestCacheTypeNone = 0,     // 不缓存
    XTApiRequestCacheTypeCacheFrist,   // 先使用缓存，后请求数据在缓存
};

typedef NS_ENUM(NSUInteger, XTApiRequestMethod) {
    
    XTApiRequestMethodGET = 0,  // GET    请求
    XTApiRequestMethodPOST,     // POST   请求
    XTApiRequestMethodPUT,      // PUT    请求
    XTApiRequestMethodPATCH,    // PATCH  请求
    XTApiRequestMethodDELETE,   // DELETE 请求
};

typedef NS_ENUM(NSUInteger, XTApiRequestSerializer) {
    
    XTApiRequestSerializerJSON = 0,    // 设置请求数据为JSON格式
    XTApiRequestSerializerHTTP,        // 设置请求数据为二进制格式
};

typedef NS_ENUM(NSUInteger, XTApiResponseSerializer) {
    
    XTApiResponseSerializerJSON = 0,   // 设置响应数据为JSON格式
    XTApiResponseSerializerHTTP,       // 设置响应数据为二进制格式
};


/**
 数据返回结果 block

 @param success 成功
 @param responseObject 返回数据
 @param status 返回结果状态
 */
typedef void(^XTApiRequestResultBlock)(BOOL success, id responseObject, NSDictionary *status);


/**
 处理数据 block，目的是使处理过程仍然是异步的
 
 @param responseObject 处理后的数据（调用了Block必须把数据转成对应的Model）
 @return 处理后的结果
 */
typedef id(^XTApiRequestHandleDataBlock)(id responseObject);


/**
 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
 */
typedef void (^XTApiRequestProgress)(NSProgress *progress);

@interface XTApiRequest : NSObject


#pragma mark - 属性

/** 请求的缓存类型，默认不使用缓存 */
@property (nonatomic, assign) XTApiRequestCacheType cacheType;

/** 是否开启返回结果打印，默认关闭 */
@property (nonatomic, assign) BOOL isOpenResultLog;

/** 移除通用参数，默认不移除 */
@property (nonatomic, assign) BOOL removeCommonParameters;

/** 请求超时时间 默认20秒 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/** 处理数据的 block（异步进行）*/
@property (nonatomic, copy) XTApiRequestHandleDataBlock handleDataBlock;

/** 请求数据格式 */
@property (nonatomic, assign) XTApiRequestSerializer requestSerializer;

/** 响应数据格式 */
@property (nonatomic, assign) XTApiResponseSerializer responseSerializer;

/** 是否需要继续保持对象，当存在异步上传图片 */
@property (nonatomic,assign) BOOL needRetainWhenAsyncUploadFile;

#pragma mark - 请求设置，子类重写

/**
 请求加密的 sKey（必须）
 */
- (NSString *)sKey;


/**
 子类的公用参数（可选）
 */
- (NSDictionary *)getCommonParametersOfSubclasses;


/**
 获取 api 请求 url（可选）
 
 @param action api名称
 @return api 请求地址
 */
- (NSString *)getUrlWithAction:(NSString *)action;


/**
 获取测试地址 api 请求 url（可选）
 
 @param action api名册
 @return 测试请求地址
 */
- (NSString *)getTestUrlWithAction:(NSString *)action;


/**
 校验接口返回数据格式中是返回成功标志 (可选)
 */
- (BOOL)checkResultValid:(id)resultDic;


/**
 获取错误信息(可选)
 
 @param resultDic 返回结果
 */
- (NSDictionary *)getErrorInfoWithRespose:(id)resultDic;


#pragma mark - 请求方法


/**
 发起请求

 @param method      请求方式
 @param urlString   请求地址
 @param parameters  请求参数
 @param resultBlock 结果回调
 @return 请求对象
 */
- (NSURLSessionTask *)requestBy:(XTApiRequestMethod)method urlString:(nullable NSString *)urlString parameters:(id)parameters result:(XTApiRequestResultBlock)resultBlock;


/**
 上传文件

 @param urlString   请求地址
 @param parameters  请求参数
 @param serverName  文件对应服务器上的字段
 @param filePaths   文件本地的沙盒路径
 @param progress    上传进度信息
 @param resultBlock 结果回调
 @return 请求对象
 */
- (NSURLSessionTask *)uploadFileWithURL:(NSString *)urlString parameters:(id)parameters serverName:(NSString *)serverName filePath:(NSArray *)filePaths progress:(XTApiRequestProgress)progress result:(XTApiRequestResultBlock)resultBlock;


/**
 下载文件

 @param urlString   请求地址
 @param fileDir     文件存储目录(默认存储目录为Download)
 @param progress    文件下载的进度信息
 @param resultBlock 结果回调
 @return 请求对象
 */
- (NSURLSessionTask *)downloadWithURL:(NSString *)urlString fileDir:(NSString *)fileDir progress:(XTApiRequestProgress)progress result:(XTApiRequestResultBlock)resultBlock;


/**
 取消当前请求
 */
- (void)cancel;

#pragma mark - 设置请求参数

/**
 设置参数到 HTTP header field
 */
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(NSString *)field;


/**
 设置参数到 HTTP header field

 @param parameters 参数字典，必须是 {field:value} 的样式
 */
- (void)setParametersForHTTPHeaderField:(NSDictionary *)parameters;


/**
 添加参数到 Body
 */
- (void)setRequestBodyData:(NSMutableURLRequest *)request withParameters:(NSDictionary *)parameters;


@end

























