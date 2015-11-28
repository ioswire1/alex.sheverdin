//
//  PageViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/28/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "PageViewController.h"
#import "ChartsViewController.h"
#import "ForecastViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController {
    
    NSArray *_pages;
    
}

- (void)setupPages {
    /*
     * set up three pages, each with a different background color
     */
    
    ChartsViewController *a = [[ChartsViewController alloc] initWithNibName:nil bundle:nil];
    //a.indexLabel.text = @"first";
    ChartsViewController *b = [[ChartsViewController alloc] initWithNibName:nil bundle:nil];
    //b.indexLabel.text = @"second";
    ChartsViewController *c = [[ChartsViewController alloc] initWithNibName:nil bundle:nil];
    //c.indexLabel.text = @"third";
    
    _pages = @[a, b, c];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (nil == viewController) {
        return _pages[0];
    }
    NSInteger idx = [_pages indexOfObject:viewController];
    NSParameterAssert(idx != NSNotFound);
    if (idx >= [_pages count] - 1) {
        // we're at the end of the _pages array
        return nil;
    }
    // return the next page's view controller
    return _pages[idx + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (nil == viewController) {
        return _pages[0];
    }
    NSInteger idx = [_pages indexOfObject:viewController];
    NSParameterAssert(idx != NSNotFound);
    if (idx <= 0) {
        // we're at the end of the _pages array
        return nil;
    }
    // return the previous page's view controller
    return _pages[idx - 1];
}


#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPages];
    self.dataSource = self;
    [self setViewControllers:@[_pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
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
