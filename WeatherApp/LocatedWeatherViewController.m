//
//  LocatedWeatherViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 12/11/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "LocatedWeatherViewController.h"
#import "AppDelegate.h"

@interface LocatedWeatherViewController ()

@end

@implementation LocatedWeatherViewController

#pragma mark - Notifications

- (void)appDidBecomeActive {
    //TODO: to implement
}

#pragma mark - Life cycle

- (void)locationDidChange:(NSNotification *)notification {
    if (notification.object) {
        NSLog(@"Location Changed!");
        __weak typeof(self) wSelf = self;
        [self loadWeather:^{
            
        }];
        [self loadForecast:^{//
//            [wSelf setScaleMinMax];
//            [wSelf.plots redrawPlots];
        }];
        [self loadForecastDaily:^{
            
        }];
        
    }
}

- (CLLocation *)currentLocation {
    
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kDidUpdateLocationsNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
