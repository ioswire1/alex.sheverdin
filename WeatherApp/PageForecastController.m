//
//  PageForecastController.m
//  WeatherApp
//
//  Created by User on 30.11.15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "PageForecastController.h"
#import "WeatherViewController.h"
#import "NavigationController.h"
#import "ForecastViewController.h"
#import "WeatherManager.h"

@interface PageForecastController ()

@end

@implementation PageForecastController

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NavigationController *nvc = (NavigationController *) self.navigationController;
    if (nvc) {
        if (nvc.pageIndex >= 2) {
            return nil;
        } else {
            nvc.pageIndex++;
        }
    }
    return [self viewControllerAtIndex:nvc.pageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NavigationController *nvc = (NavigationController *) self.navigationController;
    if (nvc) {
        if (nvc.pageIndex <= 0) {
            return nil;
        } else {
            nvc.pageIndex--;
        }
    }
    return [self viewControllerAtIndex:nvc.pageIndex];
}

- (UIViewController *) viewControllerAtIndex:(NSInteger) index {
    if (index < 0|| index > 2) {
        return nil;
    }
    ForecastViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"ForecastViewController")];
    if (controller) {
        controller.pageIndex = index;
        return controller;
    }
    return nil;
}




#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;

}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"PageForecastCtr Appear!");
    NavigationController *nvc = (NavigationController *) self.navigationController;
    [self setViewControllers:@[[self viewControllerAtIndex:nvc.pageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ;
}


@end
