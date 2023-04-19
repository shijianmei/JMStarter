//
//  JMAServiceImp.h
//  JMStarter_Example
//
//  Created by jianmei on 2023/4/19.
//  Copyright © 2023 jianmei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModuleAProtocol.h"
#import "JMModuleMediator.h"

NS_ASSUME_NONNULL_BEGIN

JMM_EXPORT_MODULE_PROTOCOL(ModuleAProtocol, JMAServiceImp)
@interface JMAServiceImp : NSObject <ModuleAProtocol>

@end

NS_ASSUME_NONNULL_END
