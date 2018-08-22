//
//  XTApiRequest.m
//  XTNetworkKit
//
//  Created by Tong on 2018/5/28.
//  Copyright © 2018年 Tong. All rights reserved.
//

#import "XTApiRequest.h"

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "XTNetworkConfigureManager.h"
#import "XTApiRequestCacheManager.h"
#import "XTApiRequestUtilsManager.h"

@interface XTApiRequest ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, copy) XTApiRequestResultBlock resultBlock;  // 完成回调Block

@property (nonatomic, copy) NSString *requestUrl;   // 请求地址

@property (nonatomic, strong) NSDictionary *finalParameters; // 最终接口请求参数

@end

@implementation XTApiRequest

#pragma mark - - - - - - - - - - - - - - - - - Init And Dealloc - - - - - - - - - - - - - - - - -

- (void)dealloc
{
    [self printLog:[NSString stringWithFormat:@"call dealloc -[%@] - %@",self.requestUrl,self]];
}

#pragma mark - - - - - - - - - - - - - - - - - Life Cycle - - - - - - - - - - - - - - - - -


#pragma mark - - - - - - - - - - - - - - - - - Data Request - - - - - - - - - - - - - - - - -


#pragma mark - - - - - - - - - - - - - - - - - Event Response - - - - - - - - - - - - - - - - -


#pragma mark - - - - - - - - - - - - - - - - - Delegate Response - - - - - - - - - - - - - - - - -


#pragma mark - - - - - - - - - - - - - - - - - NSNotification Response - - - - - - - - - - - - - - - - -


#pragma mark - - - - - - - - - - - - - - - - - Public Events - - - - - - - - - - - - - - - - -

#pragma mark - 请求设置，子类重写

/**
 请求的 sKey（必须）
 */
- (NSString *)sKey
{
    return @"";
}


/**
 子类的公用参数（可选）
 */
- (NSDictionary *)getCommonParametersOfSubclasses
{
    return nil;
}


/**
 获取 api 请求 url（可选）
 
 @param action api名称
 @return api 请求地址
 */
- (NSString *)getUrlWithAction:(NSString *)action
{
    return nil;
}


/**
 获取测试地址 api 请求 url（可选）
 
 @param action api名册
 @return 测试请求地址
 */
- (NSString *)getTestUrlWithAction:(NSString *)action
{
    return nil;
}

/**
 校验接口返回数据格式中success值是否为YES
 */
- (BOOL)checkResultValid:(id)resultDic
{
    /**
     // 返回结果格式
    {
        "status": {
            "code": 10086,
            "message": "用户登录用户失败"
        }
     }
     */
    
    // 检测是否是字典返回格式
    if (![resultDic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    // 检测status是否存在
    NSDictionary *status = [resultDic valueForKey:@"status"];
    if (status == nil || status.count == 0) {
        return NO;
    }
    
    // 判断code是否为0, 为0代表成功
    NSString *code = [NSString stringWithFormat:@"%@",[status valueForKey:@"code"]];
    if (code && [code isEqualToString:@"0"]) {
        return YES;
    }
    
    return NO;
}

/**
 获取错误信息
 
 @param resultDic 返回结果
 */
- (NSDictionary *)getErrorInfoWithRespose:(id)resultDic
{
    /**
     // 返回结果格式
     {
        "status": {
            "code": 10086,
            "message": "用户登录用户失败"
        }
     }
     */
    
    // 检测是否是字典返回格式
    if (![resultDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    // 检测status是否存在
    NSDictionary *status = [resultDic valueForKey:@"status"];
    if (status == nil || status.count == 0) {
        return nil;
    }
    
    // 判断code是否为0, 为0代表成功
    NSString *code = [NSString stringWithFormat:@"%@",[status valueForKey:@"code"]];
    if (code && [code isEqualToString:@"0"]) {
        return nil;
    }
    
    return status;
}

#pragma mark - 请求方法

/**
 发起请求
 
 @param method      请求方式
 @param urlString   请求地址
 @param parameters  请求参数
 @param resultBlock 结果回调
 @return 请求对象
 */
- (NSURLSessionTask *)requestBy:(XTApiRequestMethod)method urlString:(nullable NSString *)urlString parameters:(id)parameters result:(XTApiRequestResultBlock)resultBlock
{
    // 添加子类通用参数
    if ([self getCommonParametersOfSubclasses] && parameters && [parameters isKindOfClass:[NSDictionary class]]) {
        [parameters addEntriesFromDictionary:[self getCommonParametersOfSubclasses]];
    }
    
    if (self.cacheType == XTApiRequestCacheTypeCacheFrist) {
        
        id resultData = [XTApiRequestCacheManager getHttpResponseDataWithUrl:urlString parameters:parameters];
        if (resultData) {
            [self didCompleted:resultData status:nil success:YES];
        }
    }
    
    // 赋值请求回调
    if (self.resultBlock) {
        self.resultBlock = nil;
    }
    
    self.resultBlock = resultBlock;

    // 赋值请求
    if (self.requestUrl) {
        self.requestUrl = nil;
    }
    self.requestUrl = urlString;
    
    // 最终的请求参数
    if (method != XTApiRequestMethodGET) {
        
        // 非 GET请求增加 sign 签名
        self.finalParameters = [XTApiRequestUtilsManager getFinalParametersWithSignByDictionary:parameters skey:[self sKey]];

    } else {
        
        self.finalParameters = [NSMutableDictionary dictionaryWithDictionary:[XTApiRequestUtilsManager parameterForHttpBodyWithDictionary:parameters]];
    }
    
    // 打印参数
    [self printLog:self.finalParameters];
    
    
    
    // 设置通用的头部参数
    [self setParametersForHTTPHeaderField:[XTApiRequestUtilsManager parameterForHttpHeadWithDictionary:@{}]];
    
    switch (method) {
        case XTApiRequestMethodGET:
        {
            NSURLSessionTask *sessionTask = [self GET:urlString parameters:self.finalParameters result:resultBlock];
            return sessionTask;
        }
            break;
        case XTApiRequestMethodPOST:
        {
            NSURLSessionTask *sessionTask = [self POST:urlString parameters:self.finalParameters result:resultBlock];
            return sessionTask;
        }
            break;
        case XTApiRequestMethodPUT:
        {
            NSURLSessionTask *sessionTask = [self PUT:urlString parameters:self.finalParameters result:resultBlock];
            return sessionTask;
        }
            break;
        case XTApiRequestMethodPATCH:
        {
            NSURLSessionTask *sessionTask = [self PATCH:urlString parameters:self.finalParameters result:resultBlock];
            return sessionTask;
        }
            break;
        case XTApiRequestMethodDELETE:
        {
            NSURLSessionTask *sessionTask = [self DELETE:urlString parameters:self.finalParameters result:resultBlock];
            return sessionTask;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}


/**
 GET 请求
 
 @param urlString   请求地址
 @param parameters  请求参数
 @param resultBlock 请求结果 block
 @return 请求对象
 */
- (NSURLSessionTask *)GET:(nullable NSString *)urlString parameters:(id)parameters result:(XTApiRequestResultBlock)resultBlock
{
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    self.sessionDataTask = [self.sessionManager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [strongSelf handleResponseObject:responseObject urlString:urlString parameters:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 请求失败
        // 处理请求失败信息
        [strongSelf didEndRequestWithError:error];
    }];
    
    if (self.sessionDataTask) {
        return self.sessionDataTask;
    }
    
    return nil;
}


/**
 POST 请求
 
 @param urlString   请求地址
 @param parameters  请求参数
 @param resultBlock 请求结果 block
 @return 请求对象
 */
- (NSURLSessionTask *)POST:(nullable NSString *)urlString parameters:(id)parameters result:(XTApiRequestResultBlock)resultBlock
{
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    self.sessionDataTask = [self.sessionManager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [strongSelf handleResponseObject:responseObject urlString:urlString parameters:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 请求失败
        // 处理请求失败信息
        [strongSelf didEndRequestWithError:error];
    }];
    
    if (self.sessionDataTask) {
        return self.sessionDataTask;
    }
    
    return nil;
}


/**
 PUT 请求
 
 @param urlString   请求地址
 @param parameters  请求参数
 @param resultBlock 请求结果 block
 @return 请求对象
 */
- (NSURLSessionTask *)PUT:(nullable NSString *)urlString parameters:(id)parameters result:(XTApiRequestResultBlock)resultBlock
{
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    self.sessionDataTask = [self.sessionManager PUT:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [strongSelf handleResponseObject:responseObject urlString:urlString parameters:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 请求失败
        // 处理请求失败信息
        [strongSelf didEndRequestWithError:error];
    }];
    
    if (self.sessionDataTask) {
        return self.sessionDataTask;
    }
    
    return nil;
}


/**
 PATCH 请求
 
 @param urlString   请求地址
 @param parameters  请求参数
 @param resultBlock 请求结果 block
 @return 请求对象
 */
- (NSURLSessionTask *)PATCH:(nullable NSString *)urlString parameters:(id)parameters result:(XTApiRequestResultBlock)resultBlock
{
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    self.sessionDataTask = [self.sessionManager PATCH:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [strongSelf handleResponseObject:responseObject urlString:urlString parameters:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 请求失败
        // 处理请求失败信息
        [strongSelf didEndRequestWithError:error];
    }];
    
    if (self.sessionDataTask) {
        return self.sessionDataTask;
    }
    
    return nil;
}


/**
 DELETE 请求
 
 @param urlString   请求地址
 @param parameters  请求参数
 @param resultBlock 请求结果 block
 @return 请求对象
 */
- (NSURLSessionTask *)DELETE:(nullable NSString *)urlString parameters:(id)parameters result:(XTApiRequestResultBlock)resultBlock
{
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    self.sessionDataTask = [self.sessionManager DELETE:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [strongSelf handleResponseObject:responseObject urlString:urlString parameters:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 请求失败
        // 处理请求失败信息
        [strongSelf didEndRequestWithError:error];
    }];
    
    if (self.sessionDataTask) {
        return self.sessionDataTask;
    }
    
    return nil;
}


/**
 上传文件
 
 @param urlString   请求地址
 @param parameters  请求参数
 @param serverName  文件对应服务器上的字段
 @param filePaths    文件本地的沙盒路径
 @param progress    上传进度信息
 @param resultBlock 结果回调
 @return 请求对象
 */
- (NSURLSessionTask *)uploadFileWithURL:(NSString *)urlString parameters:(id)parameters serverName:(NSString *)serverName filePath:(NSArray *)filePaths progress:(XTApiRequestProgress)progress result:(XTApiRequestResultBlock)resultBlock
{
    // 赋值请求回调
    if (self.resultBlock) {
        self.resultBlock = nil;
    }
    
    self.resultBlock = resultBlock;
    
    // 赋值请求
    if (self.requestUrl) {
        self.requestUrl = nil;
    }
    self.requestUrl = urlString;
    
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    // 设置通用的头部参数
    [self setParametersForHTTPHeaderField:[XTApiRequestUtilsManager parameterForHttpHeadWithDictionary:@{}]];
    
    // 非 GET请求增加 sign 签名
    self.finalParameters = [XTApiRequestUtilsManager getFinalParametersWithSignByDictionary:parameters skey:[self sKey]];

    // 打印参数
    [self printLog:self.finalParameters];
    
    self.sessionDataTask = [self.sessionManager POST:urlString parameters:self.finalParameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error = nil;
        for (NSString *filePath in filePaths) {
            
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:serverName error:&error];
            
            if (error) {
                // 处理请求失败信息
                [strongSelf didEndRequestWithError:error];
            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        // 上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // 上传成功
        [strongSelf handleResponseObject:responseObject urlString:nil parameters:nil isUpLoad:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 请求失败
        // 处理请求失败信息
        [strongSelf didEndRequestWithError:error];
    }];
    
    if (self.sessionDataTask) {
        return self.sessionDataTask;
    }
    
    return nil;
}

/**
 上传图片
 
 @param urlString   请求地址
 @param parameters  请求参数
 @param serverName  图片对应服务器上的字段
 @param images      图片数组
 @param fileNames   图片文件名数组
 @param imageScale  图片文件压缩比 范围 (0.f ~ 1.f)
 @param imageType   图片文件的类型,例:png默认类型、jpg....0
 @param progress    上传进度信息
 @param resultBlock 结果回调
 @return 请求对象
 */
- (NSURLSessionTask *)uploadImagesWithURL:(NSString *)urlString parameters:(id)parameters serverName:(NSString *)serverName images:(NSArray<UIImage *> *)images fileNames:(NSArray<NSString *> *)fileNames imageScale:(CGFloat)imageScale imageType:(NSString *)imageType progress:(XTApiRequestProgress)progress result:(XTApiRequestResultBlock)resultBlock
{
    
    // 赋值请求回调
    if (self.resultBlock) {
        self.resultBlock = nil;
    }
    
    self.resultBlock = resultBlock;
    
    // 赋值请求
    if (self.requestUrl) {
        self.requestUrl = nil;
    }
    self.requestUrl = urlString;
    
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    // 设置通用的头部参数
    [self setParametersForHTTPHeaderField:[XTApiRequestUtilsManager parameterForHttpHeadWithDictionary:@{}]];
    
    // 非 GET请求增加 sign 签名
    self.finalParameters = [XTApiRequestUtilsManager getFinalParametersWithSignByDictionary:parameters skey:[self sKey]];

    // 打印参数
    [self printLog:self.finalParameters];
    
    self.sessionDataTask = [self.sessionManager POST:urlString parameters:self.finalParameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSUInteger i = 0; i < images.count; i++) {
            
            // 图片经过等比压缩后得到的二进制文件
            NSData *imageData = [imageType isEqualToString:@"png"] ? UIImagePNGRepresentation(images[i]) : UIImageJPEGRepresentation(images[i], imageScale ?: 1.f);
            
            // 默认图片的文件名, 若fileNames为nil就使用
            NSTimeInterval times = [[NSDate date] timeIntervalSince1970];
            NSString *imageFileName = [NSString stringWithFormat:@"%f%lu.%@",times,(unsigned long)i,imageType?:@"jpg"];
            
            [formData appendPartWithFileData:imageData name:serverName fileName:fileNames ? ([NSString stringWithFormat:@"%@.%@", fileNames[i],imageType ?: @"jpg"]) : imageFileName mimeType:[NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"]];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        // 上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // 上传成功
        [strongSelf handleResponseObject:responseObject urlString:nil parameters:nil isUpLoad:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 请求失败
        // 处理请求失败信息
        [strongSelf didEndRequestWithError:error];
    }];
    
    if (self.sessionDataTask) {
        return self.sessionDataTask;
    }
    
    return nil;
}

/**
 下载文件
 
 @param urlString   请求地址
 @param fileDir     文件存储目录(默认存储目录为Download)
 @param progress    文件下载的进度信息
 @param resultBlock 结果回调
 @return 请求对象
 */
- (NSURLSessionTask *)downloadWithURL:(NSString *)urlString fileDir:(NSString *)fileDir progress:(XTApiRequestProgress)progress result:(XTApiRequestResultBlock)resultBlock
{
    // 赋值请求回调
    if (self.resultBlock) {
        self.resultBlock = nil;
    }
    
    self.resultBlock = resultBlock;
    
    // 赋值请求
    if (self.requestUrl) {
        self.requestUrl = nil;
    }
    self.requestUrl = urlString;
    
    __weak XTApiRequest *weakSelf = self;
    __strong typeof(weakSelf)strongSelf = weakSelf;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    __block NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // 上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        // 拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        
        // 打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // 创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        // 拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        
        // 返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
       
        // 上传成功
        if (error) {
            [strongSelf didEndRequestWithError:error];
        } else {
            resultBlock(YES, filePath.absoluteString, nil);
        }
    }];
    
    // 开始下载
    [downloadTask resume];
    
    if (downloadTask) {
        return downloadTask;
    }
    
    return nil;
}


/**
 取消当前请求
 */
- (void)cancel
{
    if (self.needRetainWhenAsyncUploadFile) {
        return;
    }
    
    self.resultBlock = nil;
    self.handleDataBlock = nil;
    
    if (self.sessionDataTask) {
        
        [self.sessionDataTask cancel];
        self.sessionDataTask = nil;
    }
    
    [self didEndReqeust];
}

#pragma mark - 设置请求参数

/**
 设置参数到 HTTP header field
 */
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(NSString *)field
{
    [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}


/**
 设置参数到 HTTP header field
 
 @param parameters 参数字典，必须是 {field:value} 的样式
 */
- (void)setParametersForHTTPHeaderField:(NSDictionary *)parameters
{
    @synchronized(self) {
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self setValue:obj forHTTPHeaderField:key];
        }];
    }
}


/**
 添加参数到 Body
 */
- (void)setRequestBodyData:(NSMutableURLRequest *)request withParameters:(NSDictionary *)parameters
{
    NSMutableData *body = [NSMutableData data];
   
    NSUInteger postLength = 0;
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *thisFieldString = [NSString stringWithFormat:@"&%@=%@",key, obj];
        [body appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    postLength = [body length];
    if (postLength >= 1) {
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postLength] forHTTPHeaderField:@"content-length"];
    }
    
    [request setHTTPBody:body];
}

#pragma mark - - - - - - - - - - - - - - - - - Private Events - - - - - - - - - - - - - - - - -

/**
 处理请求响应数据
 */
- (void)handleResponseObject:(id)responseObject urlString:(nullable NSString *)urlString parameters:(id)parameters
{
    [self handleResponseObject:responseObject urlString:urlString parameters:parameters isUpLoad:NO];
}

/**
 处理请求响应数据
 */
- (void)handleResponseObject:(id)responseObject urlString:(nullable NSString *)urlString parameters:(id)parameters isUpLoad:(BOOL)isUpLoad
{
    // 打印输出日志
    if (self.isOpenResultLog) {
        [self printLog:responseObject];
    }
    
    // 检测是否成功
    BOOL success = [self checkResultValid:responseObject];
    
    if (!success) {
        
        // 获取错误信息
        NSDictionary *status = [self getErrorInfoWithRespose:responseObject];
        [self didCompleted:nil status:status success:NO];
        
        // 结束请求
        [self didEndReqeust];
        return;
    }
    
    id resultData = [responseObject valueForKey:@"data"];
    
    if (self.handleDataBlock) {
        resultData = self.handleDataBlock(resultData);
    }
    
    if (self.cacheType != XTApiRequestCacheTypeNone && !isUpLoad) {
        
        // 移除已有的缓存
        [XTApiRequestCacheManager removeHttpResponseDataCacheWithUrl:self.requestUrl parameters:parameters];
        
        // 添加新的缓存
        [XTApiRequestCacheManager addHttpResponseData:resultData url:self.requestUrl parameters:parameters];
    }
    
    [self didCompleted:resultData status:nil success:YES];
    
    // 结束请求
    [self didEndReqeust];
}


/**
 回调完成Block
 */
- (void)didCompleted:(id)result status:(NSDictionary *)status success:(BOOL)success
{
    if (self.resultBlock) {
        self.resultBlock(success, result, status);
    }
}

/**
 处理请求失败信息
 */
- (void)didEndRequestWithError:(NSError *)error
{
    [self printLog:[NSString stringWithFormat:@"警告：接口请求错误［%@］：%@",self.requestUrl,error]];
    
    NSString *message = [self getErrorInfoWithStatusCode:error.code];
    
    [self didCompleted:nil status:@{@"code" : [NSString stringWithFormat:@"%ld",(long)error.code], @"message" : message} success:NO];
    
    // 结束请求
    [self didEndReqeust];
}

/**
 完成请求处理方法
 */
- (void)didEndReqeust
{
    if (self.needRetainWhenAsyncUploadFile) {
        return;
    }
    
    if (self.sessionDataTask) {
        
        [self.sessionDataTask cancel];
        self.sessionDataTask = nil;
    }
}

/**
 打印日志
 */
- (void)printLog:(id)log
{
    if (![XTNetworkConfigureManager sharedManager].disableLog) {
        NSLog(@"url: = %@ \n\n\n---------- \n\n XTApiRequest: \n%@\n\n----------",self.requestUrl, log);
    }
}


#pragma mark - - - - - - - - - - - - - - - - - Setter and Getter - - - - - - - - - - - - - - - - -

/**
 设置超时时间
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    _timeoutInterval = timeoutInterval;
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
}

/**
 设置请求格式
 */
-  (void)setRequestSerializer:(XTApiRequestSerializer)requestSerializer
{
    _requestSerializer = requestSerializer;
    
    self.sessionManager.requestSerializer = (requestSerializer == XTApiRequestSerializerJSON) ? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
}

/**
 设置响应数据格式
 */
- (void)setResponseSerializer:(XTApiResponseSerializer)responseSerializer
{
    _responseSerializer = responseSerializer;
    
    self.sessionManager.responseSerializer = (responseSerializer == XTApiResponseSerializerJSON) ? [AFJSONResponseSerializer serializer] : [AFHTTPResponseSerializer serializer];
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sessionManager.requestSerializer.timeoutInterval = 20.0f;
        
        _sessionManager.responseSerializer =[AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
       
        // 打开状态栏的等待菊花
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return _sessionManager;
}

/**
 获取接口响应的错误信息
 */
- (NSString *)getErrorInfoWithStatusCode:(NSInteger)statusCode
{
    NSString *errMessage = @"数据获取失败";
    
    switch (statusCode) {
        case 400:
            errMessage = @"无效数据请求";
            break;
        case 401:
            errMessage = @"该数据请求未授权";
            break;
        case 403:
            errMessage = @"服务器禁止访问该数据请求";
            break;
        case 404:
            errMessage = @"数据请求接口不存在";
            break;
        case 405:
            errMessage = @"该请求未被许可";
            break;
        case 406:
            errMessage = @"请求的MIME类型错误";
            break;
        case 407:
            errMessage = @"请求未通过服务器代理验证";
            break;
        case 410:
            errMessage = @"请求的文件已删除";
            break;
        case 412:
            errMessage = @"客户端设置条件未通过服务器评估";
            break;
        case 414:
            errMessage = @"请求URL过大";
            break;
        case 500:
            errMessage = @"数据请求服务器出错";
            break;
        case 501:
            errMessage = @"服务器不支持该请求";
            break;
        case 502:
            errMessage = @"无效网关,服务器收到无效回应";
            break;
        case 503:
            errMessage = @"服务器繁忙，无法处理该数据请求";
            break;
        case -1001:
            errMessage = @"数据请求超时";
            break;
        default:
        {
            if (![XTApiRequestUtilsManager hasNetwork]) {
                errMessage = @"网络出错，请检查您的网络";
            }
        }
            break;
    }
    return errMessage;
}

@end











