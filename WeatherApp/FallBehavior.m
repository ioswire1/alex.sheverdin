//
//  FallBehavior.m
//  Task1
//
//  Created by User on 03.08.15.
//  Copyright (c) 2015 Alexey Sheverdin. All rights reserved.
//

#import "FallBehavior.h"

@interface FallBehavior ()

@property (strong, nonatomic) UIGravityBehavior *gravity;
@property (strong, nonatomic) UICollisionBehavior *collision;
@property (strong, nonatomic) UIDynamicItemBehavior *animationOptions;

@end

@implementation FallBehavior

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addChildBehavior:self.gravity];
        [self addChildBehavior:self.collision];
        [self addChildBehavior:self.animationOptions];
    }
    return self;
}

- (NSArray <id<UIDynamicItem>> *)items {
    return self.collision.items;
}

- (UIGravityBehavior *)gravity {
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        _gravity.magnitude = 0.9;
    }
    return _gravity;
}

- (void)addCollisionBoundaryWithIdentifier:(id<NSCopying>)identifier fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    [self.collision addBoundaryWithIdentifier:identifier fromPoint:fromPoint toPoint:toPoint];
}

- (UICollisionBehavior *)collision {
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
//        _collision.translatesReferenceBoundsIntoBoundary = YES;
        _collision.collisionMode = UICollisionBehaviorModeBoundaries;
        _collision.collisionDelegate = self;
    }
    
    return _collision;
}

- (UIDynamicItemBehavior *)animationOptions {
    if (!_animationOptions) {
        _animationOptions = [[UIDynamicItemBehavior alloc] init];
        _animationOptions.allowsRotation = NO;
        _animationOptions.elasticity = 1.0;
//        _animationOptions.resistance = 0.5;
//        _animationOptions.friction = 0.5;
//        _animationOptions.density = 1.0;
    }
    return _animationOptions;
}

- (void)addItem:(id <UIDynamicItem>)item {
    [self.gravity addItem:item];
    [self.collision addItem:item];
    [self.animationOptions addItem:item];
}
- (void)removeItem:(id <UIDynamicItem>)item {
    [self.gravity removeItem:item];
    [self.collision removeItem:item];
    [self.animationOptions removeItem:item];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    __weak typeof(self) wSelf = self;
    if (wSelf.bounceAction) {
        wSelf.bounceAction(item);
    }
}

@end

