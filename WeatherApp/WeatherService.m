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

#pragma mark - Category NSDictionary (HTTPGETParameters)

@interface NSDictionary (HTTPGETParameters)

- (NSString *)GETParameters; // return a string in format ?key1=value1&key2=value2&...

@end

@implementation NSDictionary (HTTPGETParameters)

- (NSString *)GETParameters {
    
    NSString *resultString = [NSString string];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (id key in [self allKeys]) {
        NSString *string = [NSString stringWithFormat:@"%@=%@", key, [self objectForKey:key]];
        [array addObject:string];
    }
    
    for (int i=0; i<array.count; i++) {
        NSString * sign;
        if (i==0) sign = @"?";
        else sign = @"&";
        resultString = [[resultString stringByAppendingString:sign] stringByAppendingString:array[i]];
    }
    return resultString;
}

@end


#pragma mark - WeatherService

@interface WeatherService()

@property (nonatomic, strong) NSOperationQueue* serviceQueue;

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


- (NSOperationQueue *)serviceQueue {
    if (!_serviceQueue) {
        _serviceQueue = [[NSOperationQueue alloc] init];
    }
    return  _serviceQueue;
}


- (void)getWeatherForLocationOld:(CLLocation *)location completion:(void (^)(BOOL, NSDictionary *, NSError *))completion {
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric", location.coordinate.latitude, location.coordinate.longitude];
    [self downloadData:[NSURL URLWithString:urlString] withCompletionBlock:completion];
}


- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(BOOL, NSDictionary *, NSError *))completion {
    
    NSDictionary *params = @{@"lat": @(location.coordinate.latitude),
                             @"lon": @(location.coordinate.longitude),
                             @"units": @"metric"};
    [self getDataAtPath:@"/weather" params:params completion:completion];
}


- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(BOOL, NSDictionary *, NSError *))completion {

    NSDictionary *params = @{@"lat": @(location.coordinate.latitude),
                             @"lon": @(location.coordinate.longitude),
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
    
    NSString *urlString = [[kBaseWeatherURL stringByAppendingPathComponent:path] stringByAppendingString:[params GETParameters]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
//    dispatch_async(self.weatherQueue, ^{      
        
        [NSURLConnection sendAsynchronousRequest:request queue:self.serviceQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            // sleep(5); // for testing
            
            // Check for errors
            if (error) {
                NSLog(@"Connection error: %@ %@", error, [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, error);
                });
                
            } else if (!data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, error);
                });
            } else {
                NSDictionary * weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:&error];
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, weatherData, nil);
                    });
                }
                else {
                    NSLog(@"JSONSerialization error: %@ %@", error, [error localizedDescription]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO, nil, error);
                    });
                }
            }
        }];
        
//    });
}


- (void)downloadData:(NSURL *) url withCompletionBlock:(void(^)(BOOL success, NSDictionary * dictionary, NSError * error))completion {
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

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
