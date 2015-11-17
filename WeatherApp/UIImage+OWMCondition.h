//
//  UIImage+OWMCondition.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/17/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenWeatherMap.h"

@interface UIImage (OWMCondition)

+ (UIImage *) imageWithConditionGroup:(OWMConditionGroup) conditionGroup;

@end
