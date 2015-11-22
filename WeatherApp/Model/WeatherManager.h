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
@property (nonatomic, strong) OWMObject<OWMForecastDailyObject> *lastForecastDaily;
//@property (nonatomic, strong) NSArray <__kindof OWMObject *> *dayForecast;


+ (instancetype)defaultManager;

- (void)getWeatherByLocation:(CLLocation *)location success:(void (^)(OWMObject <OWMCurrentWeatherObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getWeatherByCity:(NSString *)city success:(void (^)(OWMObject <OWMCurrentWeatherObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastByLocation:(CLLocation *)location success:(void (^)(OWMObject <OWMForecastObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastByCity:(NSString *)city success:(void (^)(OWMObject <OWMForecastObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastDailyByLocation:(CLLocation *)location forDaysCount:(NSUInteger) daysCount success:(void (^)(OWMObject <OWMForecastDailyObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastDailyByCity:(NSString *)city forDaysCount:(NSUInteger) daysCount success:(void (^)(OWMObject <OWMForecastDailyObject> *weather))success failure:(void (^)(NSError *error))failure;

- (NSArray <__kindof OWMObject <OWMCurrentWeatherObject>*> *) forecastArrayOneDayFromInterval:(NSTimeInterval) secondsFrom;
- (NSArray <__kindof OWMObject <OWMCurrentWeatherObject>*> *) forecastArrayOneDayFromNow;
- (NSArray <__kindof OWMObject <OWMCurrentWeatherObject>*> *) forecastDailyArray;

@end
