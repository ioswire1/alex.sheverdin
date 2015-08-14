//
//  ViewController.h
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, ASHURLType) {
    ASHURLTypeWeatherCoords,
    ASHURLTypeForecastCoords,
    ASHURLTypeWeatherCityName,
    ASHURLTypeForecastCityName
};

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@end

