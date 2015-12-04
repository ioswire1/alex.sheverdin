//
//  OpenWeatherMap.h
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import "Weather.h"

static NSString *const _Nonnull kUnitKey = @"units";
static NSString *const _Nonnull kWeatherUnitMetric = @"metric";
static NSString *const _Nonnull kWeatherUnitImperial = @"imperial";

typedef void (^OWMCompletionBlock)(OWMObject <OWMResponseObject> * __nullable dictionary, NSError * __nullable error);

@interface OpenWeatherMap : NSObject

+ (nonnull instancetype)service;
+ (void)setApiKey:(NSString  * _Nullable)apiKey;
+ (void)setUnits:(NSString * _Nonnull)units;

- (void)getWeatherForLocation:(CLLocationCoordinate2D)coordinate completion:(OWMCompletionBlock __nullable) completion;
- (void)getForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(OWMCompletionBlock __nullable)completion;
- (void)getWeatherForCityName:(NSString * __nullable)cityName completion:(OWMCompletionBlock __nullable)completion;
- (void)getForecastForCityName:(NSString * __nullable)cityName completion:(OWMCompletionBlock __nullable)completion;
- (void)getForecastDailyForLocation:(CLLocationCoordinate2D)coordinate forDaysCount:(NSUInteger) daysCount completion:(OWMCompletionBlock __nullable)completion;
@end

// Weather condition codes http://openweathermap.org/weather-conditions
typedef NS_ENUM(NSUInteger, OWMConditionCode) {
    OWMConditionThunderstormLightRain       = 200,
    OWMConditionThunderstormRain            = 201,
    OWMConditionThunderstormHeavyRain       = 202,
    OWMConditionLightThunderstorm           = 210,
    OWMConditionThunderstorm                = 211,
    OWMConditionHeavyThunderstorm           = 212,
    OWMConditionRaggedThunderstorm          = 221,
    OWMConditionThunderstormLightDrizzle    = 230,
    OWMConditionThunderstormDrizzle         = 231,
    OWMConditionThunderstormHeavyDrizzle    = 232,
    
    OWMConditionLightDrizzle  = 300,
    OWMConditionDrizzle  = 301,
    OWMConditionHeavyDrizzle  = 302,
    OWMConditionLightDrizzleRain  = 310,
    OWMConditionDrizzleRain  = 311,
    OWMConditionHeavyDrizzleRain  = 312,
    OWMConditionShowerRainDrizzle  = 313,
    OWMConditionHeavyShowerRainDrizzle  = 314,
    OWMConditionShowerDrizzle  = 321,
    
    OWMConditionLightRain   = 500,
    OWMConditionModerateRain   = 501,
    OWMConditionHeavyRain   = 502,
    OWMConditionVeryHeavyRain   = 503,
    OWMConditionExtremeRain   = 504,
    
    OWMConditionFreezingRain   = 511,
    
    OWMConditionLightShowerRain   = 520,
    OWMConditionShowerRain   = 521,
    OWMConditionHeavyShowerRain   = 522,
    OWMConditionRaggedShowerRain   = 531,
    
    OWMConditionLightSnow   = 600,
    OWMConditionSnow   = 601,
    OWMConditionHeavySnow   = 602,
    
    OWMConditionSleet   = 611,
    OWMConditionShowerSleet   = 612,
    
    OWMConditionLightRainSnow   = 615,
    OWMConditionRainSnow   = 616,
    OWMConditionLightShowerSnow   = 620,
    OWMConditionShowerSnow   = 621,
    OWMConditionHeavyShowerSnow   = 622,
    
    OWMConditionMist        = 701,
    OWMConditionSmoke        = 711,
    //TODO: add 7xx

    OWMConditionClearSky    = 800,
    OWMConditionFewClouds   = 801,
    OWMConditionScatteredClouds   = 802,
    OWMConditionBrokenClouds   = 803,
    OWMConditionOvercastClouds   = 804,

    OWMConditionTornado     = 900,
    OWMConditionCalm        = 951,
    //TODO: add 9xx
    
};

typedef NS_ENUM(NSUInteger, OWMConditionGroup) {
    OWMConditionGroupThunderstorm  = 200,
    OWMConditionGroupDrizzle  = 300,
    OWMConditionGroupRain  = 500,
    OWMConditionGroupFreezingRain  = 511,
    OWMConditionGroupShowerRain  = 520,
    OWMConditionGroupSnow  = 600,
    OWMConditionGroupAtmosphere  = 700,
    OWMConditionGroupClear  = 800,
    OWMConditionGroupFewClouds  = 801,
    OWMConditionGroupScatteredClouds  = 802,
    OWMConditionGroupOvercastClouds  = 803,
    OWMConditionGroupTornado  = 900,
    OWMConditionGroupCalm  = 951,
};

static inline OWMConditionGroup OWMConditionGroupByConditionCode(OWMConditionCode condition) {
    OWMConditionGroup conditionGroup = OWMConditionGroupClear;
    if (condition >= 200 && condition <= 232) {
        conditionGroup = OWMConditionGroupThunderstorm;
    } else if (condition >= 300 && condition <= 321) {
        conditionGroup = OWMConditionGroupDrizzle;
    } else if (condition >= 500 && condition <= 504) {
        conditionGroup = OWMConditionGroupRain;
    } else if (condition == 511) {
        conditionGroup = OWMConditionGroupFreezingRain;
    } else if (condition >= 520 && condition <= 531) {
        conditionGroup = OWMConditionGroupShowerRain;
    } else if (condition >= 600 && condition <= 622) {
        conditionGroup = OWMConditionGroupSnow;
    } else if (condition >= 700 && condition <= 781) {
        conditionGroup = OWMConditionGroupAtmosphere;
    } else if (condition == 800) {
        conditionGroup = OWMConditionGroupClear;
    } else if (condition == 801) {
        conditionGroup = OWMConditionGroupFewClouds;
    } else if (condition == 802) {
        conditionGroup = OWMConditionGroupScatteredClouds;
    } else if (condition >= 803 && condition <= 804) {
        conditionGroup = OWMConditionGroupOvercastClouds;
    } else if (condition >= 900 && condition <= 906) {
        conditionGroup = OWMConditionGroupTornado;
    } else if (condition >= 951 && condition <= 962) {
        conditionGroup = OWMConditionGroupCalm;
    }
    return conditionGroup;
}