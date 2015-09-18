//
//  WeatherService.h
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

@import Foundation;
@import CoreLocation;


@interface WeatherService : NSObject

+ (instancetype)sharedService;
- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(NSURLResponse * response, NSData * result,                               NSError * error))completion;
- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(id result))completion;
//- (void)getForecastForCityName:(NSString *)cityName completion:(void (^)(id result))completion;
//- (void)getWeatherForCityName:(NSString *)cityName completion:(void (^)(id result))completion;

@end
