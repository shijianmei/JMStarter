//
//  JMMap.m
//  Mediator
//
//  Created by jianmei on 2022/10/18.
//

#import "JMMapNode.h"

@implementation JMMapNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        _predecessors = [NSMutableArray array];
        _successors = [NSMutableArray array];
    }
    return self;
}

@end
