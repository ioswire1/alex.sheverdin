//
//  CircleView.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 9/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "CircleView.h"
#import "UIImage+Picker.h"

static inline double DegreesToRadians(double angle) { return M_PI * angle / 180.0; }
static double temperatureMax = 50.0;

#define RGBA(r, g, b, a) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]

@interface CircleView()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *backLayer;
@property (nonatomic, strong) UIImage *colorSpectrum;

@end


@implementation CircleView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _temperature = - temperatureMax;
        _colorSpectrum = [UIImage imageNamed:@"color_spectrum"];
    }
    return self;
}

- (UIColor *)colorByValue:(CGFloat)value {
    CGPoint valuePosition = CGPointMake(_colorSpectrum.size.width * value, 1);
    return [_colorSpectrum colorAtPosition:valuePosition];
}

- (CAKeyframeAnimation *)colorAnimationFromValue:(CGFloat)fromValue
                                         toValue:(CGFloat)toValue
                                         keyPath:(NSString *)keyPath
{
    
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *keyTimes = [NSMutableArray array];
    int from = fromValue * temperatureMax;
    int to = toValue * temperatureMax;
    
    if (from < to) {
        for (int i = from; i <= to; i ++) {
            CGFloat value = ((float)i)/temperatureMax;
            CGFloat position = i / (float)abs(to - from);
#warning Check this please!
            [values addObject:(id)[self colorByValue:value].CGColor];
            [keyTimes addObject:@(position)];
        }
    } else {
        for (int i = from; i >= to; i--) {
            CGFloat value = ((float)i)/temperatureMax;
            CGFloat position = i / (float)abs(from - to);
            
            [values addObject:(id)[self colorByValue:value].CGColor];
            [keyTimes addObject:@(position)];
        }
    }
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    colorAnimation.values               = values;
    colorAnimation.duration             = 3.0;  // "animate over 3 seconds or so.."
    colorAnimation.repeatCount          = 1.0;  // Animate only once..
    colorAnimation.removedOnCompletion  = NO;   // Remain stroked after the animation..
    colorAnimation.fillMode             = kCAFillModeForwards;
    colorAnimation.timingFunction       = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return colorAnimation;
}

- (CAShapeLayer *)circleLayer {
    if (nil == _circleLayer) {
        _circleLayer = [[CAShapeLayer alloc] init];
    }
    return  _circleLayer;
}

- (CAShapeLayer *)backLayer {
    if (nil == _backLayer) {
        _backLayer = [[CAShapeLayer alloc] init];
    }
    return  _backLayer;
}

- (void)setTemperature:(double)temperature {
    //temperature = 0.0; //for UI testing
    double prevTemperature = _temperature;
    if (temperature > temperatureMax)
        temperature = temperatureMax;
    if (temperature < -temperatureMax)
        temperature = -temperatureMax;
    _temperature = temperature;
    self.initAngle = - M_PI / 2;
    self.duration = 3.0;
    
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    // The circle will be the largest that will fit in the view
    float radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0);
    
    //create background layer
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:center
                              radius:radius - self.lineWidth / 2
                          startAngle:self.initAngle
                            endAngle:self.initAngle + 2 * M_PI
                           clockwise:YES];
    self.backLayer.path = path.CGPath;
    self.backLayer.position = bounds.origin;
    self.backLayer.fillColor = [UIColor clearColor].CGColor;
    self.backLayer.lineWidth = self.lineWidth;
    self.backLayer.strokeColor = self.backLineColor.CGColor;
    [self.layer addSublayer:self.backLayer];
  
    //create animation layer
  
    self.circleLayer.path = path.CGPath;
    self.circleLayer.position = bounds.origin;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.lineWidth = self.lineWidth;
    [self.layer addSublayer:self.circleLayer];
    
    
    CGFloat toValue = (_temperature + temperatureMax) / (2 * temperatureMax);
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration  = self.duration;
    drawAnimation.fromValue = @((prevTemperature + temperatureMax) / (2 * temperatureMax));
    drawAnimation.toValue   = @((_temperature + temperatureMax) / (2 * temperatureMax));

    drawAnimation.fillMode = kCAFillModeForwards;
    drawAnimation.removedOnCompletion = NO;
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    
    
    CAKeyframeAnimation *colorAnimation = [self colorAnimationFromValue:self.circleLayer.strokeEnd toValue:toValue keyPath:@"strokeColor"];
    
    [self.circleLayer addAnimation:colorAnimation forKey:@"colorCircleAnimation"];
    
//    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
//    colorAnimation.duration = self.duration;
//
//    colorAnimation.values   = colors;
//    //colorAnimation.path = path.CGPath;
//    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    colorAnimation.fillMode = kCAFillModeForwards;
//    colorAnimation.removedOnCompletion = NO;
//
//    double koef = (2 * temperatureMax)  / (_temperature + temperatureMax);
//    double delta = 0;//(prevTemperature + temperatureMax) / (2 * temperatureMax);
//    NSArray *times = @[@(0.0f * koef - delta), @(0.2f * koef - delta), @(0.4f * koef - delta), @(0.6 * koef - delta), @(0.8 * koef - delta), @(1.0f * koef - delta)];
//    [colorAnimation setKeyTimes:times];
//
//    [self.circleLayer addAnimation:colorAnimation forKey:@"colorCircleAnimation"];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


@end
