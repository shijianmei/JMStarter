# JMStarter

ios 启动器,解耦Appdelegate,启动任务的创建,并发执行，任务优先级控制及模块间的服务注册
## Installation

```ruby
pod 'JMStarter'
```
## used
### 添加启动任务
// JMALaunchTask.h
```
JMLAUNCH_REGISTER(JMALaunchTask)
@interface JMALaunchTask : JMAppLaunchBaseTask
@end
```

// JMALaunchTask.m

```
@implementation JMALaunchTask
- (void)executeAction {
    NSLog(@"a模块启动任务");
}

- (JMLaunchStage)launchStage {
    return JMLaunchStage_DidFinishLaunchingBeforeHomeRender;
}

- (JMLaunchThread)threadForRunIn {
    return JMLaunchThread_Work;
}

@end

```
## License

JMStarter is available under the MIT license. See the LICENSE file for more info.
