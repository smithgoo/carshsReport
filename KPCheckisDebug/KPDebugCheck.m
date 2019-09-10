//
//  KPDebugCheck.m
//  KPCheckisDebug
//
//  Created by 王朋 on 2019/9/10.
//  Copyright © 2019 王朋. All rights reserved.
//

#import "KPDebugCheck.h"
#import <sys/sysctl.h>

static dispatch_source_t timer;
@implementation KPDebugCheck

+ (void)load {
    debugCheck();
}

void debugCheck(){
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC, 0.0*NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (isDebugger()) {
            NSLog(@"监测到了hook");
            //
//            ptrace(PT_DENY_ATTACH,getgid(),0,0);
            exit(0);
        } else {
            NSLog(@"正常，还未监测到");
        }
    });
    dispatch_resume(timer);
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        
    });
    dispatch_resume(timer);
    
}



//int    sysctl(int *, u_int, void *, size_t *, void *, size_t);
//检测是否被调试
BOOL isDebugger(){
    //控制码
    //    方式一
    //    int name[] = {
    //        CTL_KERN,
    //        KERN_PROC,
    //        KERN_PROC_PID,
    //        getpid()
    //    };
    //    方式二
    int name[4];//里面放字节码.查询信息
    name[0] = CTL_KERN;//内核查看
    name[1] = KERN_PROC;//查询进程
    name[2] = KERN_PROC_PID;//传递的参数是进程的ID(PID)
    name[3] = getpid();//PID的值告诉
    
    struct kinfo_proc info;//接受进程查询结果信息的结构体
    size_t info_size = sizeof(info);//结构体的大小
    int error = sysctl(name, sizeof(name)/sizeof(*name), &info, &info_size, 0, 0);//sizeof(name)/sizeof(*name)或者sizeof(name)/sizeof(int)
    assert(error == 0);//0就是没有错误,其他就是错误码
    /**
     0000 0000 0000 0000 0100 1000 0000 0100//有调试(info.kp_proc.p_flag=18436)
     &
     0000 0000 0000 0000 0000 1000 0000 0000 （P_TRACED）
     结果：
     0000 0000 0000 0000 0000 1000 0000 0000 （不为0）
     
     
     0000 0000 0000 0000 0100 0000 0000 0100//没有调试(info.kp_proc.p_flag=16388)
     &
     0000 0000 0000 0000 0000 1000 0000 0000   （P_TRACED）
     结果：
     0000 0000 0000 0000 0000 0000 0000 0000 （为0）
     
     结果为0没有调试，结果不为0有调试
     */
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
    
}

@end
