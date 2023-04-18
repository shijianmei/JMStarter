//
//  JMMap.h
//  Mediator
//
//  Created by jianmei on 2022/10/19.
//

#import <Foundation/Foundation.h>
#import "JMMapNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMMap : NSObject
@property(nonatomic, strong) NSArray<JMMapNode *> *nodes;

- (JMMapNode *)findMapNodeByValue:(NSString *)valueStr;
- (BOOL)detectCircle;

@end

NS_ASSUME_NONNULL_END
