//
//  PageWeatherController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/28/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "PageWeatherController.h"
#import "WeatherViewController.h"
#import "NavigationController.h"
#import "ForecastViewController.h"
#import "Design.h"
#import "WeatherManager.h"
#import "SettingsViewController.h"


@interface PageWeatherController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation PageWeatherController 


- (NSMutableArray *)controllers {
    if (!_controllers) {
        _controllers = [@[] mutableCopy];
//        for (int i = 0; i < [[WeatherManager defaultManager].places count]; i++) {
//            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"WeatherViewController")];
//            [_controllers addObject:controller];
//        }
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"LocatedWeatherViewController")];
        [_controllers addObject:controller];

    }
    return _controllers;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = self.controllers.count;
        _pageControl.currentPage = 0;
        [self.view addSubview:_pageControl];
    }
    return _pageControl;
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    // Scroll to page
    self.pageControl.currentPage = currentPage;
}

- (NSUInteger)currentPage {
    return self.pageControl.currentPage;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect frame = self.view.bounds;
    frame.size.height = 40;
    self.pageControl.frame = frame;
    [self.view bringSubviewToFront:self.pageControl];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        self.currentPage = [self.controllers indexOfObject:self.viewControllers.firstObject];
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.controllers indexOfObject:viewController];
    index++;
    if (index < self.controllers.count) {
        return self.controllers[index];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.controllers indexOfObject:viewController];
    index--;
    if (index >= 0) {
        return self.controllers[index];
    }
    return nil;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    [self setViewControllers:@[self.controllers.firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCityAdded:) name:kNewPlaceAddedNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSArray *cities = [WeatherManager defaultManager].places;
//    for (int i = 0; i < [cities count] - [_controllers count]; i++) {
//            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"WeatherViewController")];
//            [_controllers addObject:controller];
//    }
    _pageControl.numberOfPages = self.controllers.count;
}

- (void)onCityAdded:(NSNotification *) notification {
    
    if ([notification.name isEqualToString:kNewPlaceAddedNotification])
    {
        NSDictionary* userInfo = notification.userInfo;
        Place* place = (Place*)userInfo[@"Place"];
        NSLog (@"Place = %@", place.name);
        WeatherViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"WeatherViewController")];
        controller.place = place;
        [_controllers addObject:controller];
        
            _pageControl.numberOfPages = self.controllers.count;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSettings"]) {
        SettingsViewController *controller = segue.destinationViewController;
        controller.cityDidSelect = ^(NSUInteger pageIndex) {
        
        [self setViewControllers:@[self.controllers[pageIndex]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO completion:nil];
            self.currentPage = pageIndex;
        };
        
    }
}

@end
