//
//  JMMap.h
//  Mediator
//
//  Created by jianmei on 2022/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMMapNode : NSObject
@property(nonatomic, strong) NSMutableArray<NSString *> *predecessors;
@property(nonatomic, strong) NSMutableArray<NSString *> *successors;
@property(nonatomic, strong) NSString *valueStr;
@end

NS_ASSUME_NONNULL_END
