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

@property (nonatomic, strong) OWMObject<OWMCurrentWeatherObject> *lastWeather;
@property (nonatomic, strong) OWMObject<OWMForecastObject> *lastForecast;
@property (nonatomic, strong) OWMObject<OWMForecastDailyObject> *lastForecastDaily;

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
            
            if (wSelf.lastWeather && success)
                success(wSelf.lastWeather);
                
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
            
            NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kLastForecastKey];
            OWMObject <OWMForecastObject>* lastForecast = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            
            if (lastForecast && success)
                success(lastForecast);

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


- (void)getForecastByCity:(NSString *)city success:(void (^)(OWMObject<OWMForecastObject> *))success failure:(void (^)(NSError *))failure {
    __weak typeof(self) wSelf = self;
    [[OpenWeatherMap service] getForecastForCityName:city completion:^(OWMObject<OWMForecastObject> * _Nullable object, NSError * _Nullable error) {
        
        if (error) {
            if (failure)
                failure(error);
            
            NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kLastForecastKey];
            OWMObject <OWMForecastObject>* lastForecast = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            
            if (lastForecast && success)
                success(lastForecast);
            
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


- (void)getForecastDailyByLocation:(CLLocation *)location forDaysCount:(NSUInteger) daysCount success:(void (^)(OWMObject <OWMForecastDailyObject> *weather))success failure:(void (^)(NSError *error))failure {
    __weak typeof(self) wSelf = self;
    [[OpenWeatherMap service] getForecastDailyForLocation:location.coordinate forDaysCount:(NSUInteger) daysCount completion:^(OWMObject <OWMForecastDailyObject> *object, NSError * _Nullable error) {
        if (error) {
            if (failure)
                failure(error);
            
            NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kLastForecastDailyKey];
            OWMObject <OWMForecastDailyObject>*lastForecastDaily = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            if (lastForecastDaily && success)
                success(lastForecastDaily);
        
            return;
        }
        
        if (![object conformsToProtocol:@protocol(OWMForecastDailyObject)]) {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Wrong response data!"}];
            if (failure) {
                failure(error);
            }
            return;
        }
        
        wSelf.lastForecastDaily = object;
        
        if (success) {
            success(wSelf.lastForecastDaily);
        }
    }];
}

- (void)getForecastDailyByCity:(NSString *)city forDaysCount:(NSUInteger)daysCount success:(void (^)(OWMObject<OWMForecastDailyObject> *))success failure:(void (^)(NSError *))failure {
    
}

- (NSArray<OWMObject *> *)forecastArrayOneDayFromInterval:(NSTimeInterval)secondsFrom {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    if (self.lastForecast) {
        NSTimeInterval secondsPerDay = 24 * 60 * 60;
        
        for (id <OWMWeather> object in self.lastForecast.list) {

            if (object.dt.floatValue > secondsFrom && object.dt.floatValue < secondsFrom + secondsPerDay) {
                [resultArray addObject:object];
            }
        }
    }
    return [resultArray copy];
}


#pragma mark - Memento Design Pattern

static NSString *const kLastWeatherKey = @"lastWeatherKey";
static NSString *const kLastForecastKey = @"lastForecastKey";
static NSString *const kLastForecastDailyKey = @"lastForecastDailyKey";

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
    _lastForecast = lastForecast;
    
    _forecastArrayOneDayFromLastUpdate = [self forecastArrayOneDayFromInterval:[NSDate date].timeIntervalSince1970];
}

- (void)setLastForecastDaily:(OWMObject<OWMForecastDailyObject> *)lastForecastDaily{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:lastForecastDaily];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:kLastForecastDailyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _lastForecastDaily = lastForecastDaily;    
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    if (_lastForecastDaily) {
        
        for (int index = 0; index < [_lastForecastDaily.list count]; index++) {
            id <OWMWeatherDaily> object = _lastForecastDaily.list[index];
            
            [resultArray addObject:object];
            
        }
    }
    _forecastDailyArray = [resultArray copy];
    }

- (NSArray<City *> *)cities {
    if (!_cities) {
        NSMutableArray *array = [@[] mutableCopy];
        City *city = [[City alloc] initWithName:@"Kharkov"];
        [array addObject:city];
        city = [[City alloc] initWithName:@"Mumbai"];
        [array addObject:city];
        city = [[City alloc] initWithName:@"Tokyo"];
        [array addObject:city];
        city = [[City alloc] initWithName:@"Moscow"];
        [array addObject:city];
//        city = [[City alloc] initWithName:@"Sydney"];
//        [array addObject:city];
        _cities = [@[] copy];
        _cities = [array copy];
        
//        CLGeocoder* gc = [[CLGeocoder alloc] init];
//        [gc geocodeAddressString:@"Kharkov" completionHandler:^(NSArray *placemarks, NSError *error) {
//            if ([placemarks count]>0)
//            {
//                CLPlacemark* mark = (CLPlacemark*)[placemarks objectAtIndex:0];
//                double lat = mark.location.coordinate.latitude;
//                double lng = mark.location.coordinate.longitude;
//                lat = 0;
//            }
//        }];
        
    }
    return _cities;
}


@end

@implementation City

- (instancetype) initWithName: (NSString *) name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}


@end


