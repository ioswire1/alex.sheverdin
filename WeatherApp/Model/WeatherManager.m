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

static NSString *const kLastWeatherKey = @"lastWeather";

@interface WeatherManager()

@end

@implementation WeatherManager

+ (instancetype)defaultManager {
    static WeatherManager *instance;
    
    dispatch_once_t predicate;
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

- (void)getWeatherByLocation:(CLLocation *)location success:(void (^)(Weather *weather))success failure:(void (^)(NSError *error))failure {
    __weak typeof(self) wSelf = self;
    [[OpenWeatherMap service] getWeatherForLocation:location.coordinate completion:^(NSDictionary * _Nullable dictionary, NSError * _Nullable error) {
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        if (dictionary) {
            
            Weather *weather = [Weather objectWithDictionary:dictionary error:&error];
            if (weather) {
                wSelf.lastWeather = weather;
            } else if (failure && !wSelf.lastWeather) {
                failure(error);
                return;
            }
        }
        
        if (success) {
            success(wSelf.lastWeather);
        }
    }];
}

- (void)getWeatherByCity:(NSString *)city success:(void (^)(Weather *weather))success failure:(void (^)(NSError *error))failure {
    // TODO: implementation
}

#pragma mark - Memento Design Pattern

- (void)setLastWeather:(Weather *)lastWeather {
    [[NSUserDefaults standardUserDefaults] setObject:lastWeather forKey:kLastWeatherKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (Weather *)lastWeather {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastWeatherKey];
}


@end
