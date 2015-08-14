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
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context); // save context
   // UIBezierPath *arcPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:3.0];

 	   UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:10 startAngle:0.0 endAngle:M_PI clockwise:YES];
                                 
    //[arcPath addClip];
    UIColor *backColor, *strokeColor;
    
    //	backColor = [UIColor redColor];
    strokeColor = [UIColor blueColor];
    
    //[backColor setFill];
    [arcPath stroke];
    
    CGContextRestoreGState(context); // restore context
    

}


@end
