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

@interface PageForecastController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray <UIViewController *> *controllers;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation PageForecastController

static NSUInteger const pageCount = 5;

- (NSMutableArray *)controllers {
    if (!_controllers) {
        _controllers = [@[] mutableCopy];
        for (int i = 0; i < pageCount; i++) {
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"WeatherViewController")];
            [_controllers addObject:controller];
        }
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
    self.navigationItem.title = [self.controllers[currentPage] title];
}

- (NSUInteger)currentPage {
    return self.pageControl.currentPage;
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
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"PageForecastCtr Appear!");
    NavigationController *nvc = (NavigationController *) self.navigationController;
//    [self setViewControllers:@[[self viewControllerAtIndex:nvc.pageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
