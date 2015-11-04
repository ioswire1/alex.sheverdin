//
//  ChartsViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/1/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "ChartsViewController.h"
#import "WeatherManager.h"
#import "AppDelegate.h"

#import "GradientPlot.h"

static double progressMax = 50.0;

@interface ChartsViewController ()

@property (strong, nonatomic) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, retain) GradientPlot *scatterPlot;

@property (strong, nonatomic) id <OWMCurrentWeatherObject> currentWeather;
@property (strong, nonatomic) id <OWMForecastObject> currentForecast;
@property (strong, nonatomic) NSMutableArray *minTemps;
@property (strong, nonatomic) NSMutableArray *maxTemps;
@property (strong, nonatomic) NSMutableArray *temps;

-(CPTTheme *)currentTheme;

@property (nonatomic, readwrite) UIPopoverController *themePopoverController;

-(void)setupView;
-(void)themeChanged:(NSNotification *)notification;

@end

@implementation ChartsViewController


#pragma mark - Load weather data

- (void)loadWeather:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    [[WeatherManager defaultManager] getWeatherByLocation:location success:^(OWMObject <OWMCurrentWeatherObject> *object) {
        
        wSelf.currentWeather = object;
        if (completion) {
            completion();
        }
        
    } failure:^(NSError *error) {
        // TODO: implementation
    }];
}

- (NSArray *)temps {
    if (!_temps) {
        _temps = [[NSMutableArray alloc] init];
    }
    return _temps;
}

- (void)loadForecast:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    
//    [[WeatherManager defaultManager] getForecastByLocation:location success:^(OWMObject <OWMForecastObject> *object) {
    [[WeatherManager defaultManager] getForecastByCity:@"Kharkov" success:^(OWMObject <OWMForecastObject> *object) {
        wSelf.currentForecast = object;
        
        if (!_maxTemps) {
            _maxTemps = [[NSMutableArray alloc] init];
        }
        int index = 0;
        
        for (id <OWMWeather> obj in self.currentForecast.list) {
            CGFloat Y = [obj.main.temp_max doubleValue];
            [_maxTemps addObject:[NSValue valueWithCGPoint:CGPointMake(index, Y)]];
//            [_minTemps addObject:obj.main.temp_min];
            index++;
        }
      
        if (completion) {
            completion();
        }

        
    } failure:^(NSError *error) {
        // TODO: implementation
    }];
}


#pragma mark - Location

- (CLLocation *)currentLocation {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
}


#pragma mark - Notifications

- (void)appDidBecomeActive {
//TODO: to implement
}

- (void)locationDidChange:(NSNotification *)notification {

//    if (notification.object) {
//        __weak typeof(self) wSelf = self;
//        [self loadWeather:^{
//            nil;
//        }];
//        [self loadForecast:nil];
//    }
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadForecast:^{
        self.scatterPlot = [[GradientPlot alloc] initWithHostingView:_graphHostingView andData:_maxTemps];
        [self.scatterPlot initialisePlot];
    }];
    

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kDidUpdateLocationsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    

    
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
