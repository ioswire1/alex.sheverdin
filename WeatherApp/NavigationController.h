//
//  NavigationController.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/28/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class City;

@interface NavigationController : UINavigationController

@property (nonatomic, strong) NSArray *cities;
@property (nonatomic) NSUInteger pageIndex;

@end
