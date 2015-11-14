//
//  ForecastViewController.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/13/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherManager.h"

@interface ForecastViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) id <OWMForecastDailyObject> forecastsDaily;
//@property (nonatomic, strong)NSArray <__kindof OWMObject <OWMWeather> *> *forecasts;

@end
