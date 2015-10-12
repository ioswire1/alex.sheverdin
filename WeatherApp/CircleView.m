//
//  CircleView.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 9/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "CircleView.h"
#import "UIImage+Picker.h"

static double temperatureMax = 50.0;

#define RGBA(r, g, b, a) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]

@interface CircleView()

@property (nonatomic, strong) CAShapeLayer *circleLayer; // animation layer
@property (nonatomic, strong) CAShapeLayer *backLayer; // background layer
@property (nonatomic, strong) UIImage *colorSpectrum; // image with color gradient

@end


@implementation CircleView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

    }
    return self;
}

-(void)awakeFromNib {
  
    _temperature = - temperatureMax;
    _duration = 2.0;
    _colorSpectrum = [UIImage imageNamed:@"color_spectrum"];
    _initAngle = - M_PI / 2;
    _lineWidth = 15.0;
    
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    // The circle will be the largest that will fit in the view
    float radius = (MIN(bounds.size.width, bounds.size.height) / 2.0);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:center
                    radius:radius - _lineWidth / 2
                startAngle:_initAngle
                  endAngle:_initAngle + 2 * M_PI
                 clockwise:YES];
    
    //create background layer
    _backLayer = [CAShapeLayer layer];
    _backLayer.path = path.CGPath;
    _backLayer.position = bounds.origin;
    _backLayer.fillColor = [UIColor clearColor].CGColor;
    _backLayer.lineWidth = _lineWidth;
    _backLayer.strokeColor = _backLineColor.CGColor;
    [self.layer addSublayer:_backLayer];
    
    //create animation layer
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.path = _backLayer.path;
    _circleLayer.position = bounds.origin;
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.lineWidth = _lineWidth;
    //_circleLayer.strokeEnd = 0.0;
    [self.layer addSublayer:_circleLayer];
}


- (UIColor *)colorByValue:(CGFloat)value {
    CGPoint valuePosition = CGPointMake(_colorSpectrum.size.width * value, 1);
    return [_colorSpectrum colorAtPosition:valuePosition];
}

- (CAKeyframeAnimation *)colorAnimationFromValue:(CGFloat)fromValue
                                         toValue:(CGFloat)toValue
                                         keyPath:(NSString *)keyPath {
    
    NSMutableArray *values = [NSMutableArray array];
    int from = fromValue * temperatureMax;
    int to = toValue * temperatureMax;
    
    if (from < to) {
        for (int i = from; i <= to; i++) {
            CGFloat value = ((float)i)/temperatureMax;
            [values addObject:(id)[self colorByValue:value].CGColor];
        }
    } else {
        for (int i = from; i >= to; i--) {
            CGFloat value = ((float)i)/temperatureMax;
            [values addObject:(id)[self colorByValue:value].CGColor];
        }
    }
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    colorAnimation.values               = values;
    colorAnimation.duration             = _duration;  // "animate over 3 seconds or so.."
    colorAnimation.repeatCount          = 1.0;  // Animate only once..
    colorAnimation.removedOnCompletion  = NO;   // Remain stroked after the animation..
    colorAnimation.fillMode             = kCAFillModeForwards;
    colorAnimation.timingFunction       = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return colorAnimation;
}


- (void)setTemperature:(double)temperature {
    temperature = 50.0; //for UI testing

    double prevTemperature = _temperature;
    if (temperature > temperatureMax)
        temperature = temperatureMax;
    if (temperature < -temperatureMax)
        temperature = -temperatureMax;
    _temperature = temperature;
    
    CGFloat toValue = (_temperature + temperatureMax) / (2 * temperatureMax);
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration  = _duration;
    drawAnimation.fromValue = @((prevTemperature + temperatureMax) / (2 * temperatureMax));
    drawAnimation.toValue   = @((_temperature + temperatureMax) / (2 * temperatureMax));
    drawAnimation.fillMode = kCAFillModeForwards;
    drawAnimation.removedOnCompletion = NO;
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];

    CAKeyframeAnimation *colorAnimation = [self colorAnimationFromValue:[_circleLayer.presentationLayer strokeEnd] toValue:toValue keyPath:@"strokeColor"];
    [_circleLayer addAnimation:colorAnimation forKey:@"colorCircleAnimation"];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
