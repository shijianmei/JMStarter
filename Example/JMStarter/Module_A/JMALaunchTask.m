//
//  JMALaunchTask.m
//  JMStarter_Example
//
//  Created by jianmei on 2023/4/19.
//  Copyright © 2023 jianmei. All rights reserved.
//

#import "JMALaunchTask.h"

@implementation JMALaunchTask
- (void)executeAction {
    NSLog(@"a模块启动任务");
}

///// 启动阶段
- (JMLaunchStage)launchStage {
    return JMLaunchStage_DidFinishLaunchingBeforeHomeRender;
}

- (JMLaunchThread)threadForRunIn {
    return JMLaunchThread_Work;
}

@end
