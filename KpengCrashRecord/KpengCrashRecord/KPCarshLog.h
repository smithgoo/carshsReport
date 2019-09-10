//
//  KPCarshLog.h
//  KpengCrashRecord
//
//  Created by 王朋 on 2019/9/7.
//  Copyright © 2019 王朋. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^logsCallBack)(NSArray *arr);
@interface KPCarshLog : NSObject

+ (void)collectCrashInfoWithException:(NSException *)exception exceptionStackInfo:(NSString *)exceptionStackInfo viewControllerStackInfo:(NSString *)viewControllerStackInfo;
+ (void)uploadCrashLogToServer:(logsCallBack)logs;
+ (void)removeCrashLog;
@end

NS_ASSUME_NONNULL_END
