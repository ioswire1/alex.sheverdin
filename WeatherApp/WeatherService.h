//
//  WeatherService.h
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

@import Foundation;
@import CoreLocation;


typedef NS_ENUM(NSInteger, ASHWeatherType) {
    ASHURLTypeWeatherCoords,
    ASHURLTypeForecastCoords,
    ASHURLTypeWeatherCityName,
    ASHURLTypeForecastCityName
};


@interface WeatherService : NSObject


+ (instancetype)sharedService;
//- (void)downloadWeatherData:(NSURL *) url withCompletionBlock:(void(^)(id result))completion;
- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(id result))completion;
- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(id result))completion;

@end
