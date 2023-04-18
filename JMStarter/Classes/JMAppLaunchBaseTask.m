//
//  JMAppLaunchBaseTask.m
//  
//
//  Created by jianmei on 2022/5/15.
//

#import "JMAppLaunchBaseTask.h"

@interface JMAppLaunchBaseTask ()
@property(nonatomic, assign) CFAbsoluteTime operateTime;
@end

@implementation JMAppLaunchBaseTask

- (void)executeAction {
    
}

/// 启动阶段
- (JMLaunchStage)launchStage {
    return JMLaunchStage_WillFinishLaunching;
}

- (JMLaunchPriority)priority {
    return JMLaunchPriority_default;
}

- (void)taskWillExecute {
    self.operateTime = CFAbsoluteTimeGetCurrent();
}

- (void)taskDidExecute {
    self.operateTime = CFAbsoluteTimeGetCurrent() - self.operateTime;
}

- (CFAbsoluteTime)getOperateTime{
    return _operateTime;
}

- (JMLaunchThread)threadForRunIn {
    return JMLaunchThread_Main;
}


@end
