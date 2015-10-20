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
@property (nonatomic) int bounceCount;
@property (nonatomic, strong) NSArray <id<UIDynamicItem>> *items;

@end

@implementation FallBehavior

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addChildBehavior:self.gravity];
        [self addChildBehavior:self.collision];
        [self addChildBehavior:self.animationOptions];
        __weak typeof(self) wSelf = self;
        [self setAction:^{
            static CGFloat xPrev = 0, xPrevDelta = 0;
            UIView *item = (UIView *)wSelf.items.firstObject;
            CGFloat xCurrentDelta = item.center.y - xPrev;
            if ((xCurrentDelta < 0) && (xPrevDelta >= 0)) {
                if (wSelf.bounceAction) {
                    wSelf.bounceAction(item);
                }
                xPrev = xPrevDelta = 0.0;
            }
            xPrev = item.center.y;
            xPrevDelta = xCurrentDelta;
        }];
    }
    return self;
}

- (NSArray <id<UIDynamicItem>> *)items {
    return self.gravity.items;
}

- (UIGravityBehavior *)gravity {
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        _gravity.magnitude = 0.9;
    }
    return _gravity;
}

- (void)setCollisionInset:(UIEdgeInsets)collisionInset {
    _collisionInset.left = collisionInset.left;
    _collisionInset.top = collisionInset.top;
    _collisionInset.bottom = collisionInset.bottom;
    _collisionInset.right = collisionInset.right;
    [_collision setTranslatesReferenceBoundsIntoBoundaryWithInsets:_collisionInset];
}

- (UICollisionBehavior *)collision {
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        UIEdgeInsets inset;
        inset.left = 0.0;
        inset.top = 0.0;
        inset.bottom = 0.0;
        inset.right = 0.0;
        [_collision setTranslatesReferenceBoundsIntoBoundaryWithInsets:inset];
        _collision.collisionMode = UICollisionBehaviorModeBoundaries;
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

@end

