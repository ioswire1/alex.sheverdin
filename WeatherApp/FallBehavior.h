//
//  FallBehavior.h
//  Task1
//
//  Created by User on 03.08.15.
//  Copyright (c) 2015 Alexey Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FallBehavior : UIDynamicBehavior <UICollisionBehaviorDelegate>

@property (nonatomic, copy) void (^bounceAction)(id <UIDynamicItem>);
@property (nonatomic, strong) NSArray <id<UIDynamicItem>> *items;

- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;
- (void)addCollisionBoundaryWithIdentifier: (nonnull id<NSCopying>) identifier fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
@property (nonatomic) BOOL isActive;

@end
