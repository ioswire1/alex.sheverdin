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
@property (nonatomic, strong, readonly) NSArray <id<UIDynamicItem>> *items;
@property (nonatomic, getter=isActive, readonly) BOOL active;

- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;

@end
