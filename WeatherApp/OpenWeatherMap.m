//
//  OpenWeatherMap.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "OpenWeatherMap.h"
#import "ASIHTTPRequest.h"

static NSString *const kBaseWeatherURL = @"http://api.openweathermap.org/data/2.5";
static NSString *const kWeatherDomain = @"com.wire.OpenWeatherMap";

#pragma mark - Category NSDictionary (HTTPGETParameters)

@interface NSDictionary (HTTPGETParameters)

- (NSString *)GETParameters; // return a string in format ?key1=value1&key2=value2&...

@end

@implementation NSDictionary (HTTPGETParameters)

- (NSString *)GETParameters {
    NSString *resultString = [NSString string];
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    
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

@interface OpenWeatherMap()

@property (nonatomic, strong) NSOperationQueue* serviceQueue;

@end


@implementation OpenWeatherMap


+ (nonnull instancetype)service {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (nonnull NSOperationQueue *)serviceQueue {
        if (!_serviceQueue) {
            _serviceQueue = [[NSOperationQueue alloc] init];
            //TODO: to implement init  ;
            [_serviceQueue setMaxConcurrentOperationCount:2]; //is it necessary?  - setMaxConcurrentOperationCount = ?
            [_serviceQueue setName:kWeatherDomain];
        }
    return  _serviceQueue;
}

- (void)getWeatherForLocation:(CLLocationCoordinate2D)coordinate completion:(GetWeatherCompletion)completion{
    NSDictionary *params = @{@"lat": @(coordinate.latitude),
                             @"lon": @(coordinate.longitude),
                             @"units": @"metric",
                             @"APPID": @"317eb1575c16aa97869f70407660d3e6"};
    [self getDataAtPath:@"/weather" params:params completion:completion];
}

- (void)getForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(GetWeatherCompletion) completion {
    NSDictionary *params = @{@"lat": @(coordinate.latitude),
                             @"lon": @(coordinate.longitude),
                             @"units": @"metric",
                             @"APPID": @"317eb1575c16aa97869f70407660d3e6"};
    [self getDataAtPath:@"/forecast" params:params completion:completion];
}

- (void)getWeatherForCityName:(NSString *)cityName completion:(GetWeatherCompletion) completion {
    NSDictionary *params = @{@"q": cityName,
                             @"units": @"metric",
                             @"APPID": @"317eb1575c16aa97869f70407660d3e6"};
    [self getDataAtPath:@"/weather" params:params completion:completion];
}

- (void)getForecastForCityName:(NSString *)cityName completion:(GetWeatherCompletion) completion {
    NSDictionary *params = @{@"q": cityName,
                             @"units": @"metric",
                             @"APPID": @"317eb1575c16aa97869f70407660d3e6"};
    [self getDataAtPath:@"/forecast" params:params completion:completion];
}

- (void)getDataAtPath:(NSString *)path params:(nullable NSDictionary *)params completion:(GetWeatherCompletion) completion {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *urlString = [[kBaseWeatherURL stringByAppendingPathComponent:path] stringByAppendingString:[params GETParameters]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:self.serviceQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        } else {
            NSDictionary * weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
            else {
                if ([weatherData[@"cod"]  isEqual: @"404"]) {
                    error = [NSError errorWithDomain:kWeatherDomain
                                                code:9999
                                            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Not found city!", nil)}];                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"city is not found");
                        completion(nil, error);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(weatherData, nil);
                    });
                }
                
                

            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

@end
