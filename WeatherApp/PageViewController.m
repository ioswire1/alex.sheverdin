//
//  PageViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/28/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "PageViewController.h"
#import "WeatherViewController.h"
#import "NavigationController.h"
#import "ForecastViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController 

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    WeatherViewController *nvc = (WeatherViewController *)viewController;
    NSInteger index = nvc.pageIndex;
    index++;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    WeatherViewController *vc = (WeatherViewController *)viewController;
    NSInteger index = vc.pageIndex;
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *) viewControllerAtIndex:(NSInteger) index {
    if (index < 0|| index > 2) {
        return nil;
    }
    WeatherViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"WeatherViewController")];
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
    [self setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    }];
    
}


-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"PageCtr Appear!");
    NavigationController *nvc = (NavigationController *) self.navigationController;
    NSUInteger index = nvc.pageIndex;
    [self setViewControllers:@[[self viewControllerAtIndex:index]] direction: UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
