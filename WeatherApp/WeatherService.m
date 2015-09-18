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


- (void)getWeatherForLocation:(CLLocation *)location completion:(void (^)(NSURLResponse * response,
                                                                          NSData * data,
                                                                          NSError * error))completion {

    double longitude = location.coordinate.longitude;
    double latitude = location.coordinate.latitude;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.2f&lon=%.2f&units=metric", latitude, longitude];
    
    [self downloadWeatherData:[NSURL URLWithString:urlString] withCompletionBlock:completion];
    
}

- (void)getForecastForLocation:(CLLocation *)location completion:(void (^)(id))completion {

    double longitude = location.coordinate.longitude;
    double latitude = location.coordinate.latitude;

    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.2f&lon=%.2f&units=metric", latitude, longitude];

//    NSDictionary *params = @{@"lat": @(latitude),
//                             @"lon": @(longitude),
//                             @"units": @"metric"};
//    
//    [self getDataAtPath:@"/forecast" params:params completion:completion];
    
//    [self downloadWeatherData:[NSURL URLWithString:urlString] withCompletionBlock:completion];
    
}

//- (void)getDataAtPath:(NSString *)path params:(NSDictionary *)params completion:(void(^)(id result))completion
//
//{
//    NSString *urlString = [kBaseWeatherURL stringByAppendingPathComponent:path];
//    //NSURLConnection
//    //NSURL *url = [self composeURLWithType:weatherType];
//    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
//    __weak typeof(request) wRequest = request;
//    
//    [request setCompletionBlock:^{
//        if (completion) {
//            //sleep(5);
//            completion(wRequest.responseData);
//        }
//    }];
//    
//    [request setFailedBlock:^{
//        if (completion) {
//            completion(wRequest.error);
//        }
//    }];
//    
//    [request startAsynchronous];
//    
//}

- (void)downloadWeatherData:(NSURL *) url withCompletionBlock:(void(^)(NSURLResponse * response,
                                                                       NSData * data,
                                                                       NSError * error))completion {
    
    //NSURL *url = [self composeURLWithType:weatherType];
  

    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:completion];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse * response,
//                                               NSData * data,
//                                               NSError * error) {
//                               NSImage* image = [[NSImage alloc] initWithData:data];
//                               imageView.image = image;
//                           }];
    
    
    
//    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
//    __weak typeof(request) wRequest = request;
//    
//    [request setCompletionBlock:^{
//        if (completion) {
//            //sleep(5);
//            completion(wRequest.responseData);
//        }
//    }];
//    
//    [request setFailedBlock:^{
//        if (completion) {
//            completion(wRequest.error);
//        }
//    }];
//    
//    [request startAsynchronous];
}

@end
