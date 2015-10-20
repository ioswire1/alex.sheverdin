//
//  FallBehavior.h
//  Task1
//
//  Created by User on 03.08.15.
//  Copyright (c) 2015 Alexey Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FallBehavior : UIDynamicBehavior

@property (nonatomic) UIEdgeInsets collisionInset;
@property (nonatomic, copy) void (^bounceAction)(id <UIDynamicItem>);

- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;

@end
