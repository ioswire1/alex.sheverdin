//
//  PageWeatherController.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/28/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageWeatherController : UIPageViewController
@property (nonatomic, strong) NSMutableArray <UIViewController *> *controllers;
@property NSUInteger currentPage;
@end
