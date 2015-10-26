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
    [[OpenWeatherMap service] getWeatherForLocation:location.coordinate completion:^(OWMObject *object, NSError * _Nullable error) {
        if (error) {
            if (failure)
                failure(error);
            return;
        }
        
        if (object) {
            wSelf.lastWeather = (OWMObject<OWMCurrentWeatherObject> *)object;
        } else if (failure && !wSelf.lastWeather) {
            failure(error);
            return;
        }
        
        if (success) {
            success((OWMObject<OWMCurrentWeatherObject> *)object);
        }
    }];
}

- (void)getWeatherByCity:(NSString *)city success:(void (^)(OWMObject <OWMCurrentWeatherObject> *))success failure:(void (^)(NSError *error))failure {
    // TODO: implementation
}

#pragma mark - Memento Design Pattern

static NSString *const kLastWeatherKey = @"lastWeatherKey";

- (void)setLastWeather:(OWMObject <OWMCurrentWeatherObject> *)lastWeather {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:lastWeather];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:kLastWeatherKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (OWMObject <OWMCurrentWeatherObject>*)lastWeather {
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kLastWeatherKey];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    // TODO: 1
    return [[OWMObject alloc] initWithJsonDictionary:object];
}


@end
