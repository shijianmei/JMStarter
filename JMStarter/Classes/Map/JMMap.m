//
//  JMMap.m
//  Mediator
//
//  Created by jianmei on 2022/10/19.
//

#import "JMMap.h"

@implementation JMMap

- (JMMapNode *)findMapNodeByValue:(NSString *)valueStr{
    return [self p_findMapNodeByValue:valueStr inArray:self.nodes];
}

- (BOOL)detectCircle{
    BOOL containsCircle = NO;
    NSMutableArray<JMMapNode *> *nodeArr = [NSMutableArray arrayWithArray:self.nodes];
    do {
        BOOL canFindNoPredecessorNode = [self p_findNoPredecessorsNodeAndDeleteInArray:nodeArr];
        
        if (nodeArr.count == 0) {
            break;
        }
        
        if (!canFindNoPredecessorNode && nodeArr.count > 0) {
            containsCircle = YES;
            break;
        }
        
    } while (true);
    
    return containsCircle;
}

- (BOOL)p_findNoPredecessorsNodeAndDeleteInArray:(NSMutableArray<JMMapNode *> *)nodeArr {
    NSInteger index = [nodeArr indexOfObjectPassingTest:^BOOL(JMMapNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
        return node.predecessors.count == 0;
    }];
    
    if (index == NSNotFound) {
        return NO;
    }
    
    JMMapNode *node = [nodeArr objectAtIndex:index];
    if (node.successors.count > 0) {
        for (NSString *successor in node.successors) {
            JMMapNode *successorNode = [self p_findMapNodeByValue:successor inArray:nodeArr];
            if (successorNode && [successorNode.predecessors containsObject:node.valueStr]) {
                [successorNode.predecessors removeObject:node.valueStr];
            }
        }
    }
    [nodeArr removeObject:node];
    return YES;
}

- (JMMapNode *)p_findMapNodeByValue:(NSString *)valueStr inArray:(NSArray<JMMapNode *> *)nodeArr {
    NSInteger index = [nodeArr indexOfObjectPassingTest:^BOOL(JMMapNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [valueStr isEqualToString:obj.valueStr];
    }];
    
    return index == NSNotFound ? nil : [nodeArr objectAtIndex:index];
}

@end
