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
@property (nonatomic, strong) CAShapeLayer *backLayer;

@end


@implementation CircleView

- (NSArray *)colors {
    if (self.temperature > 0) {
        return @[(id)RGBA(3,193,190,1).CGColor, (id)RGBA(80,224,340,1).CGColor, (id)RGBA(245,189,6,1).CGColor, (id)RGBA(234,86,13,1).CGColor, (id)RGBA(203,53,54,1).CGColor];
    }
    else {
        return @[(id)RGBA(3,193,190,1).CGColor, (id)RGBA(1,140,226,1).CGColor, (id)RGBA(8,106,221,1).CGColor, (id)RGBA(20,74,200,1).CGColor, (id)RGBA(28,47,82,1).CGColor];
    }


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

- (void)setTemperature:(CGFloat)temperature {
    _temperature = temperature;
    //_temperature = -45.0; //for UI testing
    
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    // The circle will be the largest that will fit in the view
    float radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0);
    
    //create background layer
    UIBezierPath *backgroundPath = [[UIBezierPath alloc] init];
    [backgroundPath addArcWithCenter:center
                              radius:radius - self.lineWidth/2
                          startAngle:DegreesToRadians(0)
                            endAngle:DegreesToRadians(360)
                           clockwise:YES];
    self.backLayer.path = backgroundPath.CGPath;
    self.backLayer.position = bounds.origin;
    self.backLayer.fillColor = [UIColor clearColor].CGColor;
    self.backLayer.lineWidth = self.lineWidth;
    self.backLayer.strokeColor = self.backLineColor.CGColor;
    [self.layer addSublayer:self.backLayer];
  
    //create animation layer
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat angle = self.temperature*360/50;
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
    
    self.circleLayer.strokeColor = (__bridge CGColorRef _Nullable)([[self colors] lastObject]);
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration  = 2.0;
    drawAnimation.fromValue = @(0.0f);
    drawAnimation.toValue   = @(1.0f);
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    colorAnimation.duration = 2.0;
    colorAnimation.values   = [self colors];
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleLayer addAnimation:colorAnimation forKey:@"colorCircleAnimation"];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


@end
