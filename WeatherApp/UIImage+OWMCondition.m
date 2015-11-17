//
//  UIImage+OWMCondition.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/17/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "UIImage+OWMCondition.h"

@implementation UIImage (OWMCondition)

+ (UIImage *) imageWithConditionGroup:(OWMConditionGroup) conditionGroup {
    NSString *pictureString = [NSString new];
    switch (conditionGroup) {
        case OWMConditionGroupThunderstorm:
            pictureString = @"thunderstorm";
            break;
        case OWMConditionGroupDrizzle:
            pictureString = @"rain_d";
            break;
        case OWMConditionGroupRain:
            pictureString = @"rain_d";
            break;
        case OWMConditionGroupFreezingRain:
            pictureString = @"rain_d";
            break;
        case OWMConditionGroupShowerRain:
            pictureString = @"shower_rain";
            break;
        case OWMConditionGroupSnow:
            pictureString = @"snow";
            break;
        case OWMConditionGroupAtmosphere:
            pictureString = @"mist";
            break;
        case OWMConditionGroupClear:
            pictureString = @"clear_sky_d";
            break;
        case OWMConditionGroupFewClouds:
            pictureString = @"few_clouds_d";
            break;
        case OWMConditionGroupScatteredClouds:
            pictureString = @"scattered_clouds";
            break;
        case OWMConditionGroupOvercastClouds:
            pictureString = @"broken_clouds";
            break;
        case OWMConditionGroupTornado:
            pictureString = @"wind";
            break;
        case OWMConditionGroupCalm:
            pictureString = @"clear_sky_d";
            break;
            
        default:
            pictureString = @"clear_sky_d";
            break;
    }
    return [UIImage imageNamed:pictureString];
}

@end
