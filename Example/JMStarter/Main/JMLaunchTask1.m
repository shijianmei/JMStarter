//
//  JMLaunchTask1.m
//  JMStarter_Example
//
//  Created by jianmei on 2023/4/18.
//  Copyright © 2023 jianmei. All rights reserved.
//

#import "JMLaunchTask1.h"
#import <JMStarter/JMLaunchProtocol.h>

@implementation JMLaunchTask1

- (void)executeAction {
    NSLog(@"启动任务1");
}

///// 启动阶段
- (JMLaunchStage)launchStage {
    return JMLaunchStage_DidFinishLaunchingBeforeHomeRender;
}


- (JMLaunchThread)threadForRunIn {
    return JMLaunchThread_Work;
}

@end
