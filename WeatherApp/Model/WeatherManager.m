//
//  WeatherManager.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 10/23/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "WeatherManager.h"
#import "OpenWeatherMap.h"
#import "AppDelegate.h"



@interface WeatherManager()

@end

@implementation WeatherManager

+ (instancetype)defaultManager {
    static WeatherManager *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[WeatherManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)getWeatherByLocation:(CLLocation *)location success:(void (^)(OWMObject <OWMCurrentWeatherObject> *weather))success failure:(void (^)(NSError *error))failure {
    __weak typeof(self) wSelf = self;
    [[OpenWeatherMap service] getWeatherForLocation:location.coordinate completion:^(OWMObject <OWMCurrentWeatherObject> *object, NSError * _Nullable error) {
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        if (![object conformsToProtocol:@protocol(OWMCurrentWeatherObject)]) {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Wrong response data!"}];
            if (failure) {
                failure(error);
            }
            return;
        }
        
        wSelf.lastWeather = object;
        
        if (success) {
            success(wSelf.lastWeather);
        }
    }];
}

- (void)getWeatherByCity:(NSString *)city success:(void (^)(OWMObject <OWMCurrentWeatherObject> *))success failure:(void (^)(NSError *error))failure {
    // TODO: implementation
}

- (void)getForecastByLocation:(CLLocation *)location success:(void (^)(OWMObject <OWMForecastObject> *weather))success failure:(void (^)(NSError *error))failure {
    __weak typeof(self) wSelf = self;
    [[OpenWeatherMap service] getForecastForLocation:location.coordinate completion:^(OWMObject <OWMForecastObject> *object, NSError * _Nullable error) {
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        if (![object conformsToProtocol:@protocol(OWMForecastObject)]) {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Wrong response data!"}];
            if (failure) {
                failure(error);
            }
            return;
        }
        
        wSelf.lastForecast = object;
        
        if (success) {
            success(wSelf.lastForecast);
        }
    }];
}

#pragma mark - Memento Design Pattern

static NSString *const kLastWeatherKey = @"lastWeatherKey";
static NSString *const kLastForecastKey = @"lastForecastKey";


- (void)setLastWeather:(OWMObject <OWMCurrentWeatherObject> *)lastWeather {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:lastWeather];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:kLastWeatherKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (OWMObject <OWMCurrentWeatherObject>*)lastWeather {
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kLastWeatherKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

- (void)setLastForecast:(OWMObject<OWMForecastObject> *)lastForecast{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:lastForecast];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:kLastForecastKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (OWMObject <OWMForecastObject>*)lastForecast {
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kLastForecastKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

@end
