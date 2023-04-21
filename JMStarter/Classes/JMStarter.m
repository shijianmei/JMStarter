//
//  JMStarter.m
//  Mediator
//
//  Created by jianmei on 2022/3/19.
//

#import "JMStarter.h"
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <mach-o/ldsyms.h>
#include <mach-o/loader.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "JMMap.h"

const char* kJMStarterSectionName = "JMStarter";
const NSInteger JMMaxConcurrentOperationCount = 6;

NSArray<NSString *>* JMLaunchLoadConfiguration(const char *sectionName){
    #ifndef __LP64__
        const struct mach_header *mhp = NULL;
    #else
        const struct mach_header_64 *mhp = NULL;
    #endif
        
        NSMutableArray *configs = [NSMutableArray array];
        Dl_info info;
        if (mhp == NULL) {
            dladdr(JMLaunchLoadConfiguration, &info);
    #ifndef __LP64__
            mhp = (struct mach_header*)info.dli_fbase;
    #else
            mhp = (struct mach_header_64*)info.dli_fbase;
    #endif
        }
        
    #ifndef __LP64__
        unsigned long size = 0;
     // 找到之前存储的数据段的一片内存
        uint32_t *memory = (uint32_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
    #else /* defined(__LP64__) */
        unsigned long size = 0;
        uint64_t *memory = (uint64_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
    #endif /* defined(__LP64__) */
        
        for(int idx = 0; idx < size/sizeof(void*); ++idx){
            char *string = (char*)memory[idx];
            // 把特殊段里面的数据都转换成字符串存入数组中
            NSString *str = [NSString stringWithUTF8String:string];
            if(!str)continue;
            if(str) [configs addObject:str];
        }
        return configs;
}

__attribute__((constructor)) static void constructJMStarter(void)
{
    [[JMStarter sharedLauncher] performTasks:JMLaunchStage_Constructor];
}

@interface JMStarter () {
    NSMutableArray<id<JMLaunchProtocol>>* _launchTasks;
    NSMutableDictionary *_launchTaskReportDict;
    NSLock *_lock;
    NSLock *_blockOperationLock;
    NSOperationQueue *_commonConcurrentQueue;
    NSMutableDictionary<NSString *, NSDictionary *> *_launchTaskOperationDict;
}

@end

@implementation JMStarter

+ (void)load
{
    [[JMStarter sharedLauncher] performTasks:JMLaunchStage_Load];
}

+ (instancetype)sharedLauncher
{
    static dispatch_once_t onceToken;
    static JMStarter* launcher;
    dispatch_once(&onceToken, ^{
        launcher = [[self alloc] init];
        NSArray<NSString*>* registerTaskNames = JMLaunchLoadConfiguration(kJMStarterSectionName);
        NSMutableArray *taskNames = [NSMutableArray array];
        [taskNames addObjectsFromArray:registerTaskNames];
        for (NSString *name in taskNames) {
            [launcher registerLaunchTaskName:name];
        }
    });
    return launcher;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _launchTasks = [NSMutableArray array];
        _launchTaskReportDict = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
        _commonConcurrentQueue = [[NSOperationQueue alloc] init];
        _commonConcurrentQueue.maxConcurrentOperationCount = JMMaxConcurrentOperationCount;
        _launchTaskOperationDict = [NSMutableDictionary dictionary];
        _blockOperationLock = [[NSLock alloc] init];
        
        [self addAppLifeNotis];
    }
    
    return self;
}

- (void)addAppLifeNotis {
       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundAction:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveAction:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundAction:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveAction:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActiveAction:(UIApplication *)application {
    [[JMStarter sharedLauncher] performTasks:JMLaunchStage_WillResignActive];
}

- (void)applicationDidBecomeActiveAction:(UIApplication *)application {
    [[JMStarter sharedLauncher] performTasks:JMLaunchStage_DidBecomeActive];
}

- (void)applicationDidEnterBackgroundAction:(UIApplication *)application {
    [[JMStarter sharedLauncher] performTasks:JMLaunchStage_DidEnterBackground];
}

- (void)applicationWillEnterForegroundAction:(UIApplication *)application {
    [[JMStarter sharedLauncher] performTasks:JMLaunchStage_WillEnterForeground];
}

- (void)registerLaunchTaskName:(NSString*)name
{
    Class taskClass = NSClassFromString(name);
    NSAssert([taskClass conformsToProtocol:@protocol(JMLaunchProtocol)], @"%@ does not conform to JMLaunchProtocol", name);
    
    if ([taskClass conformsToProtocol:@protocol(JMLaunchProtocol)]) {
        id<JMLaunchProtocol> task = [[taskClass alloc] init];
        
        if (task) {
            [_launchTasks addObject:task];
        }
    }
}

- (void)registerBlockOperationsWithStage:(JMLaunchStage)stage {
    [_launchTasks enumerateObjectsUsingBlock:^(id<JMLaunchProtocol>  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerBlockWithTask:task stage:stage];
    }];
}

- (void)registerBlockWithTask:(id<JMLaunchProtocol>)task stage:(JMLaunchStage)stage {
        
    NSMutableDictionary *runLiftOperationDict = [NSMutableDictionary dictionary];
    NSString *taskKey = NSStringFromClass(task.class);
    if ([_launchTaskOperationDict.allKeys containsObject:taskKey]) {
        [runLiftOperationDict addEntriesFromDictionary:[_launchTaskOperationDict objectForKey:taskKey]];
    }
    
    if (task.launchStage == stage) {
        __weak typeof(self) weakSelf = self;
        NSBlockOperation *liftOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (weakSelf) {
                [weakSelf willExcuteTask:task];
            }
            [task executeAction];
            if (weakSelf) {
                [weakSelf didExcuteTask:task];
            }
        }];
        
        if (liftOperation) {
            [runLiftOperationDict setObject:liftOperation forKey:@(stage)];
        }
    }
    
    [_blockOperationLock lock];
    [_launchTaskOperationDict setValue:runLiftOperationDict.copy forKey:taskKey];
    [_blockOperationLock unlock];
}

- (void)performTasks:(JMLaunchStage)stage
{
    JMMap *map = [self p_creatMapWithStage:stage];
    NSAssert(![map detectCircle], @"启动任务存在循环依赖！");
    if ([map detectCircle]) {
        return ;
    }
    
    //生成type对应的BlockOperation
    [self registerBlockOperationsWithStage:stage];
    //增加依赖
    [self addDependencysWithStage:stage];
    
    // 启动流程应该是串型的，所以这里不加锁处理
    NSMutableArray<id<JMLaunchProtocol>>* lowPriorityLaunchers = [NSMutableArray arrayWithCapacity:_launchTasks.count];
    NSMutableArray<id<JMLaunchProtocol>>* normalPriorityLaunchers = [NSMutableArray arrayWithCapacity:_launchTasks.count];
    NSMutableArray<id<JMLaunchProtocol>>* deleteLaunchers = [NSMutableArray arrayWithCapacity:_launchTasks.count];
    
    [_launchTasks enumerateObjectsUsingBlock:^(id<JMLaunchProtocol> launcher, NSUInteger idx, BOOL* stop) {
        JMLaunchPriority priority = JMLaunchPriority_default;
        if ([launcher respondsToSelector:@selector(priority)]) {
            priority = [launcher priority];
        }
        
        switch (priority) {
            case JMLaunchPriority_High:
                [self runOnStage:stage forTask:launcher deleteArr:deleteLaunchers];
                break;
            case JMLaunchPriority_default:
                [normalPriorityLaunchers addObject:launcher];
                break;
            case JMLaunchPriority_Low:
                [lowPriorityLaunchers addObject:launcher];
                break;
            default:
                break;
        }
    }];
    if (normalPriorityLaunchers.count > 0) {
        [normalPriorityLaunchers enumerateObjectsUsingBlock:^(id<JMLaunchProtocol> launcher, NSUInteger idx, BOOL* stop) {
            [self runOnStage:stage forTask:launcher deleteArr:deleteLaunchers];
        }];
    }
    if (lowPriorityLaunchers.count > 0) {
        [lowPriorityLaunchers enumerateObjectsUsingBlock:^(id<JMLaunchProtocol> launcher, NSUInteger idx, BOOL* stop) {
            [self runOnStage:stage forTask:launcher deleteArr:deleteLaunchers];
        }];
    }
    
    if (deleteLaunchers.count > 0) {
        [_launchTasks removeObjectsInArray:deleteLaunchers];
    }
}

- (void)runOnStage:(NSInteger)stage forTask:(id<JMLaunchProtocol>)task deleteArr:(NSMutableArray<id<JMLaunchProtocol>>*)deleteArr {
    if (stage != task.launchStage) {
        return;
    }
    
    JMLaunchThread launchThread = JMLaunchThread_Main;
    if ([task respondsToSelector:@selector(threadForRunIn)]) {
        launchThread = [task threadForRunIn];
    }
    
    NSDictionary *runThisTaskLifeOperationDict = [_launchTaskOperationDict objectForKey:NSStringFromClass(task.class)];
    NSBlockOperation *runThisTaskLifeOperation = [runThisTaskLifeOperationDict objectForKey:@(stage)];
    
    if (launchThread == JMLaunchThread_Work) {
        if (runThisTaskLifeOperation) {
            [_commonConcurrentQueue addOperation:runThisTaskLifeOperation];
        }
    }else{
        //主线程
        [self willExcuteTask:task];
        [task executeAction];
        [self didExcuteTask:task];
    }
}

- (void)addDependencysWithStage:(NSInteger)stage{
    [_launchTasks enumerateObjectsUsingBlock:^(id<JMLaunchProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self getDependentTasksForTask:obj stage:stage]) {
            NSArray *runPredecessors = [self getDependentTasksForTask:obj stage:stage];
            if (runPredecessors && runPredecessors.count > 0) {
                NSDictionary *runThisTaskLifeOperationDict = [_launchTaskOperationDict objectForKey:NSStringFromClass(obj.class)];
                NSBlockOperation *runThisTaskLifeOperation = [runThisTaskLifeOperationDict objectForKey:@(stage)];
                for (NSString *runPredecessorName in runPredecessors) {
                    NSDictionary *runPredecessorTaskLifeOperationDict = [_launchTaskOperationDict objectForKey:runPredecessorName];
                    NSBlockOperation *runPredecessorTaskLifeOperation = [runPredecessorTaskLifeOperationDict objectForKey:@(stage)];
                    if (runPredecessorTaskLifeOperation) {
                        [runThisTaskLifeOperation addDependency:runPredecessorTaskLifeOperation];
                    }
                }
            }
        }
    }];
}

- (NSDictionary *)getLaunchTaskReport{
    return _launchTaskReportDict.copy;
}

#pragma mark private method
- (void)willExcuteTask:(id<JMLaunchProtocol>)task {
    if ([task respondsToSelector:@selector(taskWillExecute)]) {
        [task taskWillExecute];
    }
}

- (void)didExcuteTask:(id<JMLaunchProtocol>)task {
    if ([task respondsToSelector:@selector(taskDidExecute)]) {
        [task taskDidExecute];
        [self p_addToReportDictByTask:task];
    }
}

- (void)p_addToReportDictByTask:(id<JMLaunchProtocol>)task {
    if ([task launchStage] == JMLaunchStage_DidFinishLaunchingBeforeHomeRender || [task launchStage] == JMLaunchStage_DidFinishLaunchingAfterHomeRender) {
        if ([task respondsToSelector:@selector(getOperateTime)]) {
            NSString *operateTimeStr = [NSString stringWithFormat:@"%lf", [task getOperateTime]];
            [_lock lock];
            [_launchTaskReportDict setValue:operateTimeStr forKey:NSStringFromClass(task.class)];
            [_lock unlock];
        }
    }
}

- (NSArray<NSString *> *)getDependentTasksForTask:(id<JMLaunchProtocol>)task stage:(JMLaunchStage)stage{
    if ([task respondsToSelector:@selector(dependentTasksForRun)] && [task launchStage] == stage) {
        NSArray *predecessors = [task dependentTasksForRun];
        if (predecessors && predecessors.count > 0) {
            return predecessors;
        }
    }
    
    return nil;
}

#pragma mark Map

- (JMMap *)p_creatMapWithStage:(JMLaunchStage)stage{
    JMMap *map = [[JMMap alloc] init];
    NSMutableArray<JMMapNode *> *mapNodeArr = [NSMutableArray array];
    [_launchTasks enumerateObjectsUsingBlock:^(id<JMLaunchProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JMMapNode *node = [[JMMapNode alloc] init];
        node.valueStr = NSStringFromClass(obj.class);
        
        if ([self getDependentTasksForTask:obj stage:(JMLaunchStage)stage]) {
            NSArray *predecessors = [self getDependentTasksForTask:obj stage:stage];
            if (predecessors && predecessors.count > 0) {
                [node.predecessors addObjectsFromArray:predecessors];
            }
        }
        [mapNodeArr addObject:node];
    }];
    map.nodes = mapNodeArr.copy;
    
    [_launchTasks enumerateObjectsUsingBlock:^(id<JMLaunchProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self getDependentTasksForTask:obj stage:stage]) {
            NSArray *predecessors = [self getDependentTasksForTask:obj stage:stage];
            if (predecessors && predecessors.count > 0) {
                for (NSString *predecessor in predecessors) {
                    JMMapNode *node = [map findMapNodeByValue:predecessor];
                    if (node) {
                        [node.successors addObject:NSStringFromClass(obj.class)];
                    }
                }
            }
        }
    }];
    return map;
}

@end

