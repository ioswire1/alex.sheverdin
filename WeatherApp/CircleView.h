//
//  CircleView.h
//  WeatherApp
//
//  Created by Alexey Sheverdin on 9/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface CircleView : UIView

@property (nonatomic) double progress;

@property (nonatomic) double initAngle;
@property (nonatomic) double lineWidth;
@property (nonatomic) double duration;
@property (nonatomic) double radius;
@property (nonatomic, strong) IBInspectable UIColor *backLineColor;

- (void)addLoadingAnimation;
- (void)addProgressAnimation:(CGFloat)progress completion:(void (^)(BOOL finished))callbackBlock;


@end


