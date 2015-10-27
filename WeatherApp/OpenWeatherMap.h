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

typedef void (^GetWeatherCompletion)(OWMObject * __nullable dictionary, NSError * __nullable error);

@interface OpenWeatherMap : NSObject

+ (nonnull instancetype)service;
+ (void)setApiKey:(NSString  * _Nullable)apiKey;
+ (void)setUnits:(NSString * _Nonnull)units;

- (void)getWeatherForLocation:(CLLocationCoordinate2D)coordinate completion:(GetWeatherCompletion __nullable) completion;
- (void)getForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(GetWeatherCompletion __nullable)completion;
- (void)getWeatherForCityName:(NSString * __nullable)cityName completion:(GetWeatherCompletion __nullable)completion;
- (void)getForecastForCityName:(NSString * __nullable)cityName completion:(GetWeatherCompletion __nullable)completion;

@end
