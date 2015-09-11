//
//  WeatherService.m
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "WeatherService.h"
#import "ASIHTTPRequest.h"

//static NSString  *urlWeather = @"http://api.openweathermap.org/data/2.5/weather?lat=50&lon=36.25&units=metric";
static NSString  *urlWeather = @"http://api.openweathermap.org/data/2.5/weather?q=kharkiv&units=metric";
//static NSString  *urlForecast = @"http://api.openweathermap.org/data/2.5/forecast?lat=50&lon=36.25&units=metric";
static NSString  *urlForecast = @"http://api.openweathermap.org/data/2.5/forecast?q=kharkiv&units=metric";

@interface WeatherService ()

- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(id result))completion;
- (void)getForecastForCityName:(NSString *)cityName completion:(void (^)(id result))completion;
- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(id result))completion;
- (void)getWeatherForCityName:(NSString *)cityName completion:(void (^)(id result))completion;

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


- (NSURL *) composeURLWithType:(ASHWeatherType) weatherType {
    
    NSString *urlString;
    switch(weatherType){
        case ASHURLTypeWeatherCityName  :
            urlString = urlWeather; 
            break;
        case ASHURLTypeForecastCityName  :
            urlString = urlForecast;
            break;
        case ASHURLTypeWeatherCoords  :
            urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.2f&lon=%.2f&units=metric", self.latitude, self.longitude];
            break;
        case ASHURLTypeForecastCoords  :
            urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.2f&lon=%.2f&units=metric", self.latitude, self.longitude];
            break;
    }
    return [NSURL URLWithString:urlString];
}


- (void)downloadWeatherData:(ASHWeatherType) weatherType withBlock:(void(^)(id result))completion {
    
    NSURL *url = [self composeURLWithType:weatherType];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    __weak typeof(request) wRequest = request;
    [request setCompletionBlock:^{
        if (completion) {
            completion(wRequest.responseData);
        }
    }];
    
    [request setFailedBlock:^{
        if (completion) {
            completion(wRequest.error);
        }
    }];
    
    [request startAsynchronous];
}

@end
