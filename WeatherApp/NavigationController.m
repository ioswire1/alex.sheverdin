//
//  NavigationController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/28/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "NavigationController.h"
#import "WeatherViewController.h"
#import "ForecastViewController.h"


@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    WeatherViewController *vc = (WeatherViewController *) [self visibleViewController];
//    vc.pageIndex = self.pageIndex;
//    
//    UIViewController *topVC = [self topViewController];
//    UIViewController *visiVC = [self visibleViewController];
//    NSLog(@"top: %@, visi: %@", [topVC class], [visiVC class]);
    
    
//    ForecastViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:(@"ForecastViewController")];
//    [self setViewControllers:@[controller] animated:NO];
//    ForecastViewController *tempVC = (ForecastViewController *)[self visibleViewController];
//    tempVC.pageIndex = self.pageIndex;
//    NSLog(@"new vc: %@", [tempVC class]);
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"NaviCtr Appear!");
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"NaviCtr Disappear!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    WeatherViewController *vc = (WeatherViewController *)[segue destinationViewController];
//    vc.pageIndex = self.pageIndex;
//    vc.indexLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)vc.pageIndex];
//}


@end
