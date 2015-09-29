//
//  WeatherService.h
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

@import Foundation;
@import CoreLocation;

typedef void (^GetWeatherCompletion)(BOOL success, NSDictionary * __nullable dictionary, NSError * __nullable error);

@interface OpenWeatherMap : NSObject

+ (nonnull instancetype)service;

- (void)getWeatherForLocation:(CLLocation * __nullable)location completion:(GetWeatherCompletion __nullable) completion;
- (void)getForecastForLocation:(CLLocation * __nullable)location completion:(GetWeatherCompletion __nullable)completion;
- (void)getWeatherForCityName:(NSString * __nullable)cityName completion:(GetWeatherCompletion __nullable)completion;
- (void)getForecastForCityName:(NSString * __nullable)cityName completion:(GetWeatherCompletion __nullable)completion;

@end
