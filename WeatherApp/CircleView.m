//
//  CircleView.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 9/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "CircleView.h"

static inline double DegreesToRadians(double angle) { return M_PI * angle / 180.0; }

#define RGBA(r, g, b, a) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]

@interface CircleView()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end


@implementation CircleView


- (CAShapeLayer *)circleLayer {
    if (nil == _circleLayer) {
        _circleLayer = [[CAShapeLayer alloc] init];
    }
    return  _circleLayer;
}

- (void)setTemperature:(CGFloat)temperature {
    _temperature = temperature;
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    float radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0);
    //_temperature = -45.0; //for UI testing
    CGFloat angle = self.temperature*360/50;

    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:center
                    radius:radius - self.lineWidth/2
                startAngle:DegreesToRadians(self.startAngle)
                  endAngle:DegreesToRadians(self.startAngle + angle)
                 clockwise:self.temperature >=0 ? YES : NO];
    path.lineWidth = self.lineWidth;
    self.circleLayer.path = path.CGPath;
    self.circleLayer.position = bounds.origin;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.lineWidth = self.lineWidth;
    [self.layer addSublayer:self.circleLayer];
 
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = 1;
    drawAnimation.autoreverses = NO;
    drawAnimation.fromValue = @(0.0f);
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];

    UIColor *startColor = RGBA(3,193,190,1);
    UIColor *endColor = self.temperature >= 0 ? RGBA(203,53,54,1) : RGBA(30,53,190,1);
    self.circleLayer.strokeColor = endColor.CGColor;
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    colorAnimation.duration            = 2.0;
    colorAnimation.repeatCount         = 1;
    colorAnimation.autoreverses = NO;
    colorAnimation.fromValue = (__bridge id)(startColor.CGColor);
    colorAnimation.toValue   = (__bridge id)(endColor.CGColor);
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    
    [self.circleLayer addAnimation:colorAnimation forKey:@"colorCircleAnimation"];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.clearsContextBeforeDrawing = YES;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    // The circle will be the largest that will fit in the view
    float radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0);
    UIBezierPath *backgroundPath = [[UIBezierPath alloc] init];
    [backgroundPath addArcWithCenter:center
                              radius:radius - self.lineWidth/2
                          startAngle:DegreesToRadians(self.startAngle)
                            endAngle:DegreesToRadians(self.startAngle + 360)
                           clockwise:YES];
    backgroundPath.lineWidth = self.lineWidth;
    [self.backLineColor setStroke];
    [backgroundPath stroke];
    CGFloat angle = self.temperature*360/50;
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:center
                    radius:radius - self.lineWidth/2
                startAngle:DegreesToRadians(self.startAngle)
                  endAngle:DegreesToRadians(self.startAngle + angle)
                 clockwise:self.temperature >=0 ? YES : NO];
    path.lineWidth = self.lineWidth;
    CGContextRestoreGState(context);
}


@end
