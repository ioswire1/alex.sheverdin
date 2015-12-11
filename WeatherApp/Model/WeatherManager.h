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

static NSString *const kNewPlaceAddedNotification = @"DidPlaceAddedNotification";

@interface Place : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) CLLocation *location;

- (instancetype) initWithName: (NSString *) name;

@end

@interface WeatherManager : NSObject

@property (nonatomic, strong) NSMutableArray<Place*> *places;
- (void) addNewPlace:(Place *) place;


+ (instancetype)defaultManager;

- (void)getWeatherByLocation:(CLLocation *)location success:(void (^)(OWMObject <OWMCurrentWeatherObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getWeatherByCity:(NSString *)city success:(void (^)(OWMObject <OWMCurrentWeatherObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastByLocation:(CLLocation *)location success:(void (^)(OWMObject <OWMForecastObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastByCity:(NSString *)city success:(void (^)(OWMObject <OWMForecastObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastDailyByLocation:(CLLocation *)location forDaysCount:(NSUInteger) daysCount success:(void (^)(OWMObject <OWMForecastDailyObject> *weather))success failure:(void (^)(NSError *error))failure;
- (void)getForecastDailyByCity:(NSString *)city forDaysCount:(NSUInteger) daysCount success:(void (^)(OWMObject <OWMForecastDailyObject> *weather))success failure:(void (^)(NSError *error))failure;

- (NSArray <__kindof OWMObject <OWMCurrentWeatherObject>*> *) forecastArrayOneDayFromInterval:(NSTimeInterval) secondsFrom;
@property (strong, nonatomic) NSArray <__kindof OWMObject <OWMCurrentWeatherObject>*> * forecastArrayOneDayFromLastUpdate;

@property (strong, nonatomic) NSArray <__kindof OWMObject <OWMCurrentWeatherObject>*> * forecastDailyArray;

@end

