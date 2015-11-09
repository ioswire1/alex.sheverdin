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

@property (nonatomic, strong) OWMObject<OWMCurrentWeatherObject> *lastWeather;
@property (nonatomic, strong) OWMObject<OWMForecastObject> *lastForecast;


+ (instancetype)defaultManager;

- (void)getWeatherByLocation:(CLLocation *)location success:(void (^)(OWMObject<OWMCurrentWeatherObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getWeatherByCity:(NSString *)city success:(void (^)(OWMObject<OWMCurrentWeatherObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastByLocation:(CLLocation *)location success:(void (^)(OWMObject<OWMForecastObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastByCity:(NSString *)city success:(void (^)(OWMObject<OWMForecastObject> *weather))success failure:(void (^)(NSError *error))failure;

- (NSArray *) forecast3hFromDate:(NSDate *) date count: (NSUInteger) count;
- (NSArray *) forecast3hFromDate:(NSDate *) fromDate toDate: (NSDate *) toDate;

@end
