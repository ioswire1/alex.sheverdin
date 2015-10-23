//
//  WeatherManager.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 10/23/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

@import Foundation;
@import CoreLocation;

#import "Weather.h"

@interface WeatherManager : NSObject

+ (instancetype)defaultManager;

- (void)getWeatherByLocation:(CLLocation *)location success:(void (^)(Weather *weather))success failure:(void (^)(NSError *error))failure;
- (void)getWeatherByCity:(NSString *)city success:(void (^)(Weather *weather))success failure:(void (^)(NSError *error))failure;

@property (nonatomic, strong) Weather *lastWeather;

@end
