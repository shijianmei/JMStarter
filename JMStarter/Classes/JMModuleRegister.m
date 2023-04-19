//
//  JMModuleRegister.m
//
//  Created by jianmei on 2019/8/1.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "JMModuleRegister.h"
#import "JMModuleMediator.h"
#import "JMStarter.h"
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <mach-o/ldsyms.h>
#include <mach-o/loader.h>
#import <objc/message.h>
#import <objc/runtime.h>

NSArray<NSString*>* BHReadConfiguration(char* sectionName, const struct mach_header* mhp);

static void dyld_callback(const struct mach_header* mhp, intptr_t vmaddr_slide)
{
    NSArray<NSString*>* protocol2Impls = BHReadConfiguration("JMModuleImpl", mhp);
    for (NSString* protocol2ImplConfig in protocol2Impls) {

        NSArray* array = [protocol2ImplConfig componentsSeparatedByString:@":"];

        if (array.count == 2) {
            NSString* protocol = array[0];
            NSString* clsName = array[1];

            if (protocol && clsName) {
                [[JMModuleMediator sharedInstance] registerProtocol:NSProtocolFromString(protocol) forClass:NSClassFromString(clsName)];
            }
        }
    }
}

NSArray<NSString*>* BHReadConfiguration(char* sectionName, const struct mach_header* mhp)
{
    NSMutableArray* configs = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t* memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64* mhp64 = (const struct mach_header_64*)mhp;
    uintptr_t* memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif

    unsigned long counter = size / sizeof(void*);
    for (int idx = 0; idx < counter; ++idx) {
        char* string = (char*)memory[idx];
        NSString* str = [NSString stringWithUTF8String:string];
        if (!str)
            continue;

        if (str)
            [configs addObject:str];
    }

    return configs;
}

JMLAUNCH_REGISTER(JMModuleRegister)
@interface JMModuleRegister ()

@end

@implementation JMModuleRegister

- (void)executeAction {
    _dyld_register_func_for_add_image(dyld_callback);
}

/// 启动阶段
- (JMLaunchStage)launchStage {
    return JMLaunchStage_Constructor;
}
@end
