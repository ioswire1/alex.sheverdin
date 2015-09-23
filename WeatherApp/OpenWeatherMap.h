//
//  WeatherService.h
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

@import Foundation;
@import CoreLocation;


@interface OpenWeatherMap : NSObject

+ (instancetype)service;
- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(BOOL success, NSDictionary * dictionary, NSError * error))completion;
- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(BOOL success, NSDictionary * dictionary, NSError * error))completion;
- (void)getWeatherForCityName:(NSString *)cityName completion:(void (^)(BOOL success, NSDictionary * dictionary, NSError * error))completion;
- (void)getForecastForCityName:(NSString *)cityName completion:(void (^)(BOOL success, NSDictionary * dictionary, NSError * error))completion;

@end
