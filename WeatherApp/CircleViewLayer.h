//
//  CircleViewLayer.h
//  WeatherApp
//
//  Created by User on 27.09.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CircleViewLayer : CALayer


@property (strong, nonatomic) __attribute__((NSObject)) CGColorRef progressColor;
- (void)setProgressColor:(CGColorRef)progressColor animated:(BOOL)animated;

@property (readwrite, nonatomic) CGFloat progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
