//
//  KPCarshLog.m
//  KpengCrashRecord
//
//  Created by 王朋 on 2019/9/7.
//  Copyright © 2019 王朋. All rights reserved.
//

#import "KPCarshLog.h"
#import <UIKit/UIKit.h>
#define CrashLogDirectory @"CrashLog"
#define CrashLogFileName @"crashLog.log"

@implementation KPCarshLog

+ (void)collectCrashInfoWithException:(NSException *)exception exceptionStackInfo:(NSString *)exceptionStackInfo viewControllerStackInfo:(NSString *)viewControllerStackInfo {
    NSMutableDictionary *crashInfoDic = [NSMutableDictionary dictionary];
    
    //require
    NSString *dateStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    [crashInfoDic setObject:dateStr forKey:@"date"];
    [crashInfoDic setObject:exception.name forKey:@"type"];
    [crashInfoDic setObject:[self SystemVersion] forKey:@"CurrentSysVersion"];
    [crashInfoDic setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"version"];
    //exception log info
    NSMutableDictionary *exceptionInfoDic = [NSMutableDictionary dictionary];
    [exceptionInfoDic setObject:exception.name forKey:@"exception_name"];
    [exceptionInfoDic setObject:exception.reason forKey:@"exception_reason"];
    [exceptionInfoDic setObject:exceptionStackInfo forKey:@"exception_stackInfo"];
    NSData *exceptionInfoData = [NSJSONSerialization dataWithJSONObject:exceptionInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    [crashInfoDic setObject:[[NSString alloc] initWithData:exceptionInfoData encoding:NSUTF8StringEncoding] forKey:@"logRecord"];
    
    //optional
#ifdef DEBUG
    [crashInfoDic setObject:@"DEBUG" forKey:@"environment"];
#else
    [crashInfoDic setObject:@"RELEASE" forKey:@"environment"];
#endif
    [crashInfoDic setObject:viewControllerStackInfo forKey:@"currentCarshVC"];
    
    //read
    NSData *oldCrashData = [NSData dataWithContentsOfFile:[KPCarshLog getCrashLogSavePath]];
    NSMutableArray *oldCrashArray;
    if (oldCrashData.length == 0) {
        oldCrashArray = [NSMutableArray array];
    } else {
        oldCrashArray = [NSJSONSerialization JSONObjectWithData:oldCrashData options:NSJSONReadingMutableContainers error:nil];
    }
    [oldCrashArray addObject:crashInfoDic];
    
    //write
    NSData *newCrashData = [NSJSONSerialization dataWithJSONObject:oldCrashArray options:NSJSONWritingPrettyPrinted error:nil];
    [newCrashData writeToFile:[KPCarshLog getCrashLogSavePath] atomically:YES];
}


+ (NSString *)getCrashLogSavePath {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *crashLogDir = [documentPath stringByAppendingPathComponent:CrashLogDirectory];
    BOOL isDir = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:crashLogDir isDirectory:&isDir];
    if (!isExist || !isDir) {
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:crashLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSuccess) {
            NSLog(@"******文件夹创建失败*******");
            return nil;
        }
    }
    
    NSString *crashLogPath = [crashLogDir stringByAppendingPathComponent:CrashLogFileName];
    isDir = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:crashLogPath isDirectory:&isDir];
    if (!isExist || isDir) {
        BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:crashLogPath contents:nil attributes:nil];
        if (!isSuccess) {
            NSLog(@"******文件创建失败*******");
            return nil;
        }
    }
    
    return crashLogPath;
}


+ (void)removeCrashLog {
    NSLog(@"delete crash log success");
    [[NSFileManager defaultManager] removeItemAtPath:[KPCarshLog getCrashLogSavePath] error:nil];
}

+(NSString*)SystemVersion
{
    NSString * str = [NSString stringWithFormat:@"%.2f",[[[UIDevice currentDevice] systemVersion]   floatValue]];
    return  str;
}



+ (void)uploadCrashLogToServer:(logsCallBack)logs {
    NSData *logData = [NSData dataWithContentsOfFile:[KPCarshLog getCrashLogSavePath]];
    NSArray *log = [NSJSONSerialization JSONObjectWithData:logData options:NSJSONReadingMutableLeaves error:nil];
    if (log.count == 0||log==nil) {
        return;
    }
//回调出去
    logs(log);
}



@end
