//
//  WeatherService.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "WeatherService.h"

@interface WeatherService ()

- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(id result))completion;
- (void)getForecastForCityName:(NSString *)cityName completion:(void (^)(id result))completion;

@end

@implementation WeatherService

+ (instancetype)sharedService {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(id result))completion {
    
    [self getForecastForLocation:location completion:completion];
}

- (void)getWeatherForCityName:(NSString *)cityName completion:(void (^)(id result))completion {
    
    [self getForecastForCityName:cityName completion:completion];
}

@end
