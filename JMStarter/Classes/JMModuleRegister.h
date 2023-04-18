//
//  JMModuleRegister.h
//
//  Created by jianmei on 2019/8/1.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMAppLaunchBaseTask.h"

#define JMM_ADD_SECTION_DATA(sectname) __attribute((used, section("__DATA," #sectname " ")))

#define JMM_EXPORT_MODULE_PROTOCOL(protocolName, impl) \
    char* k##protocolName##_service JMM_ADD_SECTION_DATA(JMModuleImpl) = "" #protocolName ":" #impl "";

NS_ASSUME_NONNULL_BEGIN

@interface JMModuleRegister : JMAppLaunchBaseTask
@end

NS_ASSUME_NONNULL_END
