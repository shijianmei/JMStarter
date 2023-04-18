//
//  JMModuleMediator.h
//
//  Created by jianmei on 2022/7/24.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMModuleBaseProtocol.h"
#import "JMModuleRegister.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMModuleMediator : NSObject

+ (instancetype)sharedInstance;

//注册类
- (void)registerProtocol:(Protocol*)protocol forClass:(Class)cls;
- (Class)classForProtocol:(Protocol*)protocol;

//接口的实现类
- (id)implForProtocol:(Protocol*)protocol;

+ (id)implObjForProtocol:(Protocol*)protocol;

@end

NS_ASSUME_NONNULL_END
