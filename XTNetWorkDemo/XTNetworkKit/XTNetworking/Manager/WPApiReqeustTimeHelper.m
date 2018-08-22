//
//  WPApiReqeustTimeHelper.m
//  WPNetworkKit
//
//  Created by Tong on 2018/7/9.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import "WPApiReqeustTimeHelper.h"

#import "WPEncrypt.h"

@interface WPApiReqeustTimeHelper ()

@property (nonatomic,assign) BOOL isRequestTimeing;                 // 是否正在请求服务器时间

@property (nonatomic,assign, readwrite) long long timestamp;        // 时间戳

@property (nonatomic,assign, readwrite) double applaunchTimestamp;  // 程序启动时间

@end

@implementation WPApiReqeustTimeHelper

static WPApiReqeustTimeHelper *_manager;

+ (WPApiReqeustTimeHelper *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[WPApiReqeustTimeHelper alloc] init];
    });
    return _manager;
}



/**
 获取当前根据服务器日期校准后的日期
 */
- (NSDate *)getCurrentCorrectDate
{
    long long timestamp = self.timestamp;
    
    NSDate *date = nil;
    
    if (timestamp > 0) {
        
        /** app 启动进程时间 */
        double applaunchTimestamp = self.applaunchTimestamp;
        
        /** app 当前进程时间 */
        double currentTimestamp =  [[NSProcessInfo processInfo] systemUptime];
        
        /** 运行时间 */
        double lunchtime = currentTimestamp - applaunchTimestamp;
        
        if (lunchtime >= 0) {
            
            /** 最终的时间戳 */
            double lastTimestamp = timestamp + lunchtime;
            
            /** 当前日期 */
            NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:lastTimestamp];//相差8小时 计算
            
            /** 解决相差8小时 */
            date = [self getNowDateFromatAnDate:currentDate];
            
            return date;
        }
    }
    
    /** 重新刷新服务器时间戳 */
    [self refreshServerTimestamp];
    
    date = [NSDate date];
    date = [self getNowDateFromatAnDate:date];
    
    return date;
}

/**
 获取当前时间时间
 */
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    /** 设置源日期时区 */
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    
    /** 设置转换后的目标日期时区 */
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    
    /** 得到源日期与世界标准时间的偏移量 */
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    
    /** 目标日期与本地时区的偏移量 */
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    
    /** 得到时间偏移量的差值 */
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    /** 转为现在时间 */
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    
    return destinationDateNow;
}

/**
 刷新服务器时间戳
 */
- (void)refreshServerTimestamp
{
    if (self.isRequestTimeing) {
        return;
    }
    self.isRequestTimeing = YES;
    
    NSURL * url = [[NSURL alloc]initWithString:@"http://passport.feng.com/t.php"];
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:queue];
    
    __weak WPApiReqeustTimeHelper *sself = self;
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [sself handleServerTimestamp:data];
    }];
    
    [dataTask resume];
}


/**
 处理刷新服务器时间戳请求返回数据
 */
- (void)handleServerTimestamp:(NSData *)data
{
    if (data) {
        
        NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (result && [result isKindOfClass:[NSString class]] && result.length > 0) {
            
            NSDictionary *jsonDic = [WPEncrypt jsonDecode:result];
            
            if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]] && [jsonDic objectForKey:@"data"]) {
                
                NSDictionary *data = [jsonDic objectForKey:@"data"];
                
                if ([data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"time"]) {
                    
                    long long timestamp = [[data objectForKey:@"time"]longLongValue] ;
                    self.timestamp = timestamp;
                    self.applaunchTimestamp = [[NSProcessInfo processInfo] systemUptime];
                }
            }
        }
    }
    
    self.isRequestTimeing = NO;
}




@end








