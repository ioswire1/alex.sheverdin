//
//  WeatherService.h
//  WeatherApp
//
//  Created by Alexey Sheverdin on 8/14/15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

@import Foundation;
@import CoreLocation;


typedef NS_ENUM(NSInteger, ASHWeatherType) {
    ASHURLTypeWeatherCoords,
    ASHURLTypeForecastCoords,
    ASHURLTypeWeatherCityName,
    ASHURLTypeForecastCityName
};


@interface WeatherService : NSObject

@property (nonatomic) double longitude;
@property (nonatomic) double latitude;

+ (instancetype)sharedService;
- (void)downloadWeatherData:(ASHWeatherType) weatherType withBlock:(void(^)(id result))completion;


@end
