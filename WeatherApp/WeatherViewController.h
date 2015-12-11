//
//  WeatherViewController.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/1/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

//@class PlotItem;

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>
#import "WeatherManager.h"

@interface WeatherViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) Place *place;

- (void)loadWeather:(void (^)())completion;
- (void)loadForecast:(void (^)())completion;
- (void)loadForecastDaily:(void (^)())completion;

@end
