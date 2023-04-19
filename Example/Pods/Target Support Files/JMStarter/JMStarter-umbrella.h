#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JMAppLaunchBaseTask.h"
#import "JMLaunchContext.h"
#import "JMLaunchProtocol.h"
#import "JMModuleBaseProtocol.h"
#import "JMModuleMediator.h"
#import "JMModuleRegister.h"
#import "JMStarter.h"
#import "JMMap.h"
#import "JMMapNode.h"

FOUNDATION_EXPORT double JMStarterVersionNumber;
FOUNDATION_EXPORT const unsigned char JMStarterVersionString[];

