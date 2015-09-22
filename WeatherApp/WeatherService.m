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
//TODO: is it necessary? setMaxConcurrentOperationCount = ?
        [_serviceQueue setMaxConcurrentOperationCount:2];
        [_serviceQueue setName:@"com.wire.serviceQueue"];
    }
    return  _serviceQueue;
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
        
    [NSURLConnection sendAsynchronousRequest:request queue:self.serviceQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // Check for errors
        if (error) {
            //NSLog(@"Connection error: %@ %@", error, [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, error);
            });
            
        } else if (!data) {
            NSError *error = [NSError errorWithDomain:@"com.WeatherService.Network"
                                                 code:9999
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Ther is no data get from server!", nil)}];
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
                //NSLog(@"JSONSerialization error: %@ %@", error, [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, error);
                });
            }
        }
    }];

}


@end
