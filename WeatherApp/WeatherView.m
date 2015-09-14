//
//  WeatherView.m
//  WeatherApp
//
//  Created by User on 14.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "WeatherView.h"


@implementation WeatherView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    self.clearsContextBeforeDrawing = YES;
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context); // save context

    CGRect bounds = self.bounds;
    
    // Find the center of the view
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    CGFloat lineWidth = 10.0;
    
    // The circle will be the largest that will fit in the view
    float radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    // Add an arc to the path at center, with given radius,
    // from 0 to some radians (part of circle)
    
    [path addArcWithCenter:center
                    radius:radius - lineWidth/2
                startAngle:M_PI/2
                  endAngle:M_PI*5/2
                 clockwise:YES];
    
    [[UIColor lightGrayColor] setStroke];
    [path stroke];
    
    CGContextRestoreGState(context); // restore context
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = path.CGPath;
    circle.position = bounds.origin;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor blueColor].CGColor;
    circle.lineWidth = lineWidth;
    
    // needed???
    [self.layer removeAllAnimations];
    // Add to parent layer
    [self.layer addSublayer:circle];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = HUGE_VALF;  // animate forever
    drawAnimation.autoreverses = YES; // reverse
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.removedOnCompletion = YES; // needed?
    // Timing Function for fading start-end
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Add the animation to the circle
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    circle.strokeEnd = 0.0f;

//    CGContextRestoreGState(context); // restore context
}


- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}

@end
