//
//  JMLaunchProtocol.h
//  Mediator
//
//  Created by jianmei on 2022/3/19.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JMLaunchStage) {
    JMLaunchStage_Load = 0,
    JMLaunchStage_Constructor,
    JMLaunchStage_DidBecomeActive,
    JMLaunchStage_WillEnterForeground,
    JMLaunchStage_DidEnterBackground,
    JMLaunchStage_WillResignActive,
    // 需要在外部合适的时机触发
    JMLaunchStage_WillFinishLaunching,
    JMLaunchStage_DidFinishLaunchingBeforeHomeRender,
    JMLaunchStage_DidFinishLaunchingAfterHomeRender,
    JMLaunchStage_HomePageDidAppear,
    JMLaunchStage_Min = JMLaunchStage_Load,
    JMLaunchStage_Max = JMLaunchStage_HomePageDidAppear,
};

typedef NS_ENUM(NSInteger, JMLaunchThread) {
    JMLaunchThread_Main, //主线程
    JMLaunchThread_Work,
};

typedef NS_ENUM(NSInteger, JMLaunchPriority) {
    JMLaunchPriority_default = 0,
    JMLaunchPriority_Low = -1,
    JMLaunchPriority_High = 1,
};

NS_ASSUME_NONNULL_BEGIN

@protocol JMTaskBaseProtocol, JMTaskActionInterceptProtocol;

@protocol JMLaunchProtocol <JMTaskBaseProtocol, JMTaskActionInterceptProtocol>
@required
/// 要执行的操作
- (void)executeAction;

/// 启动阶段
- (JMLaunchStage)launchStage;

/// 指定启动任务的执行优先级
- (JMLaunchPriority)priority;

/// 指定启动任务的执行线程
- (JMLaunchThread)threadForRunIn;

@end

@protocol JMTaskBaseProtocol <NSObject>


@optional

/// 获取任务执行的时间
- (CFAbsoluteTime)getOperateTime;

/// 指定启动任务的依赖任务
- (NSArray <NSString *> *)dependentTasksForRun;

@end


@protocol JMTaskActionInterceptProtocol <NSObject>

@optional
/// 任务即将执行
- (void)taskWillExecute;

/// 任务完成执行
- (void)taskDidExecute;

@end

NS_ASSUME_NONNULL_END
