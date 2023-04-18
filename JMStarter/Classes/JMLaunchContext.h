//
//  JMLaunchContext.h
//  
//
//  Created by jianmei on 2022/3/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMLaunchContext : NSObject

@property (nonatomic, strong) UIApplication* application;
@property (nonatomic, strong) NSDictionary* launchOptions;

@end

NS_ASSUME_NONNULL_END
