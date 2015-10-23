//
//  CircleView.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 9/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "CircleView.h"
#import "UIImage+Picker.h"

static int COLOR_QUANT = 50;
static inline double DegreesToRadians(double angle) { return M_PI * angle / 180.0; }

#define RGBA(r, g, b, a) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]

@interface CircleView()

@property (nonatomic, strong) CAShapeLayer *circleLayer; // animation layer
@property (nonatomic, strong) CAShapeLayer *backLayer; // background layer
@property (nonatomic, strong) UIImage *colorSpectrum; // image with color gradient
@property (nonatomic, copy) void (^completionBlock)(BOOL finished);

@end


@implementation CircleView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self customize];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

    }
    return self;
}

-(void)awakeFromNib {
    [self customize];

}

- (void)customize {
    _progress = 0;
    _duration = 2.0;
    _colorSpectrum = [UIImage imageNamed:@"color_spectrum"];
    _initAngle = 90;
    _lineWidth = 30.0;
    
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    // The circle will be the largest that will fit in the view
    float radius = (MIN(bounds.size.width, bounds.size.height) / 2.0);
    self.radius = radius;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:center
                    radius:radius - _lineWidth / 2
                startAngle:DegreesToRadians(_initAngle)
                  endAngle:DegreesToRadians(_initAngle + 360)
                 clockwise:YES];
    
    //create animation layer
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.path = path.CGPath;
    _circleLayer.position = bounds.origin;
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.lineWidth = _lineWidth;
    _circleLayer.lineCap = kCALineCapRound;
    _circleLayer.strokeColor = [UIColor blueColor].CGColor;
    _circleLayer.strokeEnd = 0.0001;
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
    int from = fromValue * COLOR_QUANT;
    int to = toValue * COLOR_QUANT;
    
    if (from < to) {
        for (int i = from; i < to; i++) {
            CGFloat value = ((float)i) / COLOR_QUANT;
            [values addObject:(id)[self colorByValue:value].CGColor];
        }
    } else {
        for (int i = from; i >= to; i--) {
            CGFloat value = ((float)i) / COLOR_QUANT;
            [values addObject:(id)[self colorByValue:value].CGColor];
        }
    }
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    colorAnimation.values               = values;
    colorAnimation.duration             = _duration;
    colorAnimation.repeatCount          = 1.0;
    colorAnimation.removedOnCompletion  = NO;
    colorAnimation.fillMode             = kCAFillModeForwards;
    colorAnimation.timingFunction       = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    colorAnimation.delegate = self;
    return colorAnimation;
}

- (void)addProgressAnimation:(CGFloat)progress completion:(void (^)(BOOL))callbackBlock {
    //progress = 1.0; //for UI testing
//    progress = progress < 0.0001 ? 0.0001 : progress;
    
    self.completionBlock = callbackBlock;
    double prevprogress = _progress;
    _progress = progress;
    
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration  = _duration;
    drawAnimation.fromValue = @(prevprogress);
    drawAnimation.toValue   = @(progress);
    drawAnimation.fillMode = kCAFillModeForwards;
    drawAnimation.removedOnCompletion = NO;
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    
    CAKeyframeAnimation *colorAnimation = [self colorAnimationFromValue:prevprogress toValue:progress keyPath:@"strokeColor"];
    [_circleLayer addAnimation:colorAnimation forKey:@"colorCircleAnimation"];
}

- (void)addProgressAnimation:(double)progress {
    
    [self addProgressAnimation:progress completion:nil];
}

#pragma mark - Animation Cleanup

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    void (^completionBlock)(BOOL) = self.completionBlock;
    if (completionBlock){
        completionBlock(flag);
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
