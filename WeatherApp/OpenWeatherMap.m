//
//  OpenWeatherMap.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

@import UIKit;
#import "OpenWeatherMap.h"

static NSString *const kBaseWeatherURL = @"http://api.openweathermap.org/data/2.5";
static NSString *const kWeatherDomain = @"com.wire.OpenWeatherMap";
static NSTimeInterval const kRequestTimeLimits = 100;//36000.0; // 10 minutes
static NSInteger const kCacheLimit = 1024 * 1024 * 2; // 2 mb

#pragma mark - Category NSDictionary (HTTPGETParameters)

@interface NSDictionary (HTTPGETParameters)

- (NSString *)wic_GETParameters; // return a string in format ?key1=value1&key2=value2&...

@end

@implementation NSDictionary (HTTPGETParameters)

- (NSString *)wic_GETParameters {
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

@interface OWMResponseCacheObject : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) NSURLResponse *response;
@property (nonatomic, strong, readonly) NSDate *requestDate;

+ (instancetype)responseCacheObject:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;

@end

@implementation OWMResponseCacheObject

- (instancetype)initWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    self = [super init];
    if (self) {
        _data = data;
        _response = response;
        _error = error;
        _requestDate = [NSDate date];
    }
    return self;
}

+ (instancetype)responseCacheObject:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    return [[OWMResponseCacheObject alloc] initWithData:data response:response error:error];
}

@end

@interface OpenWeatherMap()

@property (nonatomic, strong) NSOperationQueue* serviceQueue;
@property (nonatomic, strong) NSCache *cache;

@end


@implementation OpenWeatherMap

static NSString *_apiKey = nil;
static NSString *_units = @"metric";

+ (void)setApiKey:(NSString *)apiKey {
    _apiKey = apiKey;
}

+ (void)setUnits:(NSString *)units {
    _units = units;
}

+ (nonnull instancetype)service {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSCache *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        _cache.name = kWeatherDomain;
        _cache.totalCostLimit = kCacheLimit;
    }
    return _cache;
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

- (void)getWeatherForLocation:(CLLocationCoordinate2D)coordinate completion:(OWMCompletionBlock)completion{
    NSDictionary *params = @{@"lat": @(coordinate.latitude),
                             @"lon": @(coordinate.longitude),
                             @"units": _units,
                             @"APPID": _apiKey};
    [self getDataAtPath:@"/weather" params:params completion:completion];
}

- (void)getWeatherForCityName:(NSString *)cityName completion:(OWMCompletionBlock) completion {
    NSDictionary *params = @{@"q": cityName,
                             @"units": _units,
                             @"APPID": _apiKey};
    [self getDataAtPath:@"/weather" params:params completion:completion];
}

- (void)getForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(OWMCompletionBlock) completion {
    NSDictionary *params = @{@"lat": @(coordinate.latitude),
                             @"lon": @(coordinate.longitude),
                             @"units": _units,
                             @"APPID": _apiKey};
    [self getDataAtPath:@"/forecast" params:params completion:completion];
}

- (void)getForecastForCityName:(NSString *)cityName completion:(OWMCompletionBlock) completion {
    NSDictionary *params = @{@"q": cityName,
                             @"units": _units,
                             @"APPID": _apiKey};
    [self getDataAtPath:@"/forecast" params:params completion:completion];
}

- (void)getForecastDailyForLocation:(CLLocationCoordinate2D)coordinate forDaysCount:(NSUInteger) daysCount completion:(OWMCompletionBlock) completion {
    NSDictionary *params = @{@"lat": @(coordinate.latitude),
                             @"lon": @(coordinate.longitude),
                             @"units": _units,
                             @"cnt": @(daysCount),
                             @"APPID": _apiKey};
    [self getDataAtPath:@"/forecast/daily" params:params completion:completion];
}

- (void)getForecastDailyForCityName:(NSString *)cityName forDaysCount:(NSUInteger) daysCount completion:(OWMCompletionBlock) completion {
    NSDictionary *params = @{@"q": cityName,
                             @"units": _units,
                             @"cnt": @(daysCount),
                             @"APPID": _apiKey};
    [self getDataAtPath:@"/forecast/daily" params:params completion:completion];
}


- (void)getDataAtPath:(NSString *)path params:(nullable NSDictionary *)params completion:(OWMCompletionBlock) completion {
    
    NSString *urlString = [[kBaseWeatherURL stringByAppendingPathComponent:path] stringByAppendingString:[params wic_GETParameters]];
    
    OWMResponseCacheObject *lastResponse = [self.cache objectForKey:urlString];
    if (lastResponse) {
        
        // Confirm API requirments http://openweathermap.org/apieff #1
        NSTimeInterval requestTimeInterval = [[NSDate date] timeIntervalSinceDate:lastResponse.requestDate];
        if (requestTimeInterval < kRequestTimeLimits) {
            [self handleResponse:lastResponse completion:completion];
            return;
        }
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    __weak typeof(self) wSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:self.serviceQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        OWMResponseCacheObject *responseCacheObject = [OWMResponseCacheObject responseCacheObject:data response:response error:error];
        [wSelf.cache setObject:responseCacheObject
                        forKey:urlString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf handleResponse:responseCacheObject completion:completion];
        });
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)handleResponse:(OWMResponseCacheObject *)responseCachedObject completion:(OWMCompletionBlock)completion {
    
    if (responseCachedObject.error) {
        completion(nil, responseCachedObject.error);
    } else {
        NSError *error;
        id serializedObject = [NSJSONSerialization JSONObjectWithData:responseCachedObject.data
                                                              options:0
                                                                error:&error];
        
        OWMObject *object = [[OWMObject alloc] initWithJsonDictionary:serializedObject];
        if (error) {
            completion(nil, error);
        } else {
            int code = 0;
            if ([object conformsToProtocol:@protocol(OWMResponseObject)]) {
                code = [(id <OWMResponseObject>)object cod].intValue;
                if (code == 404) {
                    error = [NSError errorWithDomain:kWeatherDomain
                                                code:9999
                                            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Not found city!", nil)}];
                    completion(nil, error);
                } else {
                    completion((OWMObject<OWMResponseObject> *)object, nil);
                }
            } else { // Wrong response
                NSError *error = nil; //
                if (completion) {
                    completion(nil, error);
                }
            }
        }
    }
}

@end
