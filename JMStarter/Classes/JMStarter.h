//
//  JMStarter.h
//  Mediator
//
//  Created by jianmei on 2022/3/19.
//

#import <Foundation/Foundation.h>
#import "JMLaunchProtocol.h"
#import "JMLaunchContext.h"

#define JML_ADD_SECTION_DATA(sectname) __attribute((used, section("__DATA," #sectname " ")))

#define JMLAUNCH_REGISTER(task) \
    char* k##task##_register JML_ADD_SECTION_DATA(JMStarter) = "" #task "";

#define JMLocalLaunchConfigName @"JMLaunchTask"

NS_ASSUME_NONNULL_BEGIN

extern NSArray<NSString*>* JMLaunchLoadConfiguration(const char* sectionName);

@interface JMStarter : NSObject

@property (nonatomic, strong) JMLaunchContext* context;

+ (instancetype)sharedLauncher;

/// 执行某一阶段的任务
/// - Parameter stage: 阶段
- (void)performTasks:(JMLaunchStage)stage;

- (NSDictionary *)getLaunchTaskReport;

@end

NS_ASSUME_NONNULL_END

