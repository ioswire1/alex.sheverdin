//
//  WeatherService.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "WeatherService.h"
#import "ASIHTTPRequest.h"

static NSString *const kBaseWeatherURL = @"http://api.openweathermap.org/data/2.5";

//static NSString  *urlWeather = @"http://api.openweathermap.org/data/2.5/weather?lat=50&lon=36.25&units=metric";
//static NSString  *urlWeather = @"http://api.openweathermap.org/data/2.5/weather?q=kharkiv&units=metric";
//static NSString  *urlForecast = @"http://api.openweathermap.org/data/2.5/forecast?lat=50&lon=36.25&units=metric";
//static NSString  *urlForecast = @"http://api.openweathermap.org/data/2.5/forecast?q=kharkiv&units=metric";


@implementation WeatherService


+ (instancetype)sharedService {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void)getWeatherForLocationOld:(CLLocation *)location completion:(void (^)(BOOL success,
                                                                          NSDictionary * dictionary,
                                                                          NSError * error))completion {

    double longitude = location.coordinate.longitude;
    double latitude = location.coordinate.latitude;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric", latitude, longitude];
    
    [self downloadData:[NSURL URLWithString:urlString] withCompletionBlock:completion];
    
}


- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(BOOL, NSDictionary *, NSError *))completion {
    
    double longitude = location.coordinate.longitude;
    double latitude = location.coordinate.latitude;
    
    NSDictionary *params = @{@"lat": @(latitude),
                             @"lon": @(longitude),
                             @"units": @"metric"};
    
    [self getDataAtPath:@"/weather" params:params completion:completion];
}


- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(BOOL, NSDictionary *, NSError *))completion {

    double longitude = location.coordinate.longitude;
    double latitude = location.coordinate.latitude;
    
    NSDictionary *params = @{@"lat": @(latitude),
                             @"lon": @(longitude),
                             @"units": @"metric"};
    
    [self getDataAtPath:@"/forecast" params:params completion:completion];
}


- (void)getWeatherForCityName:(NSString *)cityName completion:(void (^)(BOOL, NSDictionary *, NSError *))completion {
  
    NSDictionary *params = @{@"q": cityName,
                             @"units": @"metric"};
    
    [self getDataAtPath:@"/weather" params:params completion:completion];
}


- (void)getForecastForCityName:(NSString *)cityName completion:(void (^)(BOOL, NSDictionary *, NSError *))completion {
    
    NSDictionary *params = @{@"q": cityName,
                             @"units": @"metric"};
    
    [self getDataAtPath:@"/forecast" params:params completion:completion];
}


- (void)getDataAtPath:(NSString *)path params:(NSDictionary *)params completion:(void(^)(BOOL success, NSDictionary * dictionary, NSError * error))completion {
    
    NSString *urlString = [kBaseWeatherURL stringByAppendingPathComponent:path];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (id key in [params allKeys]) {
        NSString *string = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]];
        [array addObject:string];
    }

    for (int i=0; i<array.count; i++) {
        NSString * sign;
        if (i==0) sign = @"?";
        else sign = @"&";
        urlString = [[urlString stringByAppendingString:sign] stringByAppendingString:array[i]];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // Check to make sure there are no errors
        if (error) {
            NSLog(@"Error in connection: %@ %@", error, [error localizedDescription]);
            completion(NO, nil, error);
        } else if (!response) {
            completion(NO, nil, error);
        } else if (!data) {
            completion(NO, nil, error);
        } else {
            NSDictionary * weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:&error];
            if (!error)
                completion(YES, weatherData, nil);
        }
    }];
}


- (void)downloadData:(NSURL *) url withCompletionBlock:(void(^)(BOOL success, NSDictionary * dictionary, NSError * error))completion {
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // Check to make sure there are no errors
        if (error) {
            NSLog(@"Error in connection: %@ %@", error, [error localizedDescription]);
            completion(NO, nil, error);
        } else if (!response) {
            completion(NO, nil, error);
        } else if (!data) {
            completion(NO, nil, error);
        } else {
            NSDictionary * weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:&error];
            if (!error)
                completion(YES, weatherData, nil);
        }
    }];
}

@end
