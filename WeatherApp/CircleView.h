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

@property (nonatomic) double temperature;

@property (nonatomic) IBInspectable double initAngle;
@property (nonatomic) IBInspectable double lineWidth;
@property (nonatomic) IBInspectable double duration;
@property (nonatomic, strong) IBInspectable UIColor *backLineColor;


@end


