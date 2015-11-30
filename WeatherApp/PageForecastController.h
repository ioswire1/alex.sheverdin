//
//  PageForecastController.h
//  WeatherApp
//
//  Created by User on 30.11.15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageForecastController : UIPageViewController <UIPageViewControllerDataSource>

@property (nonatomic) NSUInteger pageIndex;

- (UIViewController *) viewControllerAtIndex:(NSInteger) index;

@end
