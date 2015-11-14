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
#import "GradientPlots.h"
#import "ForecastViewController.h"

#define UIColorFromRGB(rgbValue) (id)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0].CGColor


@interface ChartsViewController () <GradientPlotsDataSource>

@property (nonatomic, strong) IBOutlet GradientPlots *plots;
@property (strong, nonatomic) id <OWMCurrentWeatherObject> currentWeather;
@property (strong, nonatomic) id <OWMForecastObject> currentForecast;

@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
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
        
        self.navigationItem.title = self.currentWeather.name;
        self.temperatureLabel.text = [NSString stringWithFormat:@"%dº",[self.currentWeather.main.temp intValue]];
    } failure:^(NSError *error) {
        // TODO: implementation
    }];
}


- (void)loadForecast:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    
    [[WeatherManager defaultManager] getForecastByLocation:location success:^(OWMObject <OWMForecastObject> *object) {
//    [[WeatherManager defaultManager] getForecastByCity:@"London" success:^(OWMObject <OWMForecastObject> *object) {
        wSelf.currentForecast = object;
  
        if (completion) {
            completion();
        }
        
    } failure:^(NSError *error) {
        // TODO: implementation
    }];
}

#pragma mark - Prossessing weather data 

- (NSString *)stringFromTimeInterval:(NSTimeInterval) seconds withFormat:(NSString *) format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    dateFormatter.locale = [NSLocale currentLocale];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSString *dateString = [[NSString alloc] initWithString:[dateFormatter stringFromDate:date]];
    
    return dateString;
}

- (void)setScaleMinMax {
    
    float xmax, xmin, ymin1, ymax1, ymin2, ymax2;
    xmax = ymax1 = ymax2 = - MAXFLOAT;
    xmin = ymin1 = ymin2 = MAXFLOAT;

    NSArray * weatherArray = [[WeatherManager defaultManager] forecast3hForOneDayFromInterval:[NSDate date].timeIntervalSince1970];

    if (weatherArray) {
        for (id <OWMWeather> object in weatherArray) {
            
            CGFloat x = object.dt.floatValue;
            if (x < xmin) xmin = x;
            if (x > xmax) xmax = x;
            
            CGFloat y1 = object.main.temp_max.floatValue;
            if (y1 < ymin1) ymin1 = y1;
            if (y1 > ymax1) ymax1 = y1;

            CGFloat y2 = object.main.temp_min.floatValue;
            if (y2 < ymin2) ymin2 = y2;
            if (y2 > ymax2) ymax2 = y2;
        }
        
        _plots.start = xmin;
        _plots.length = xmax - xmin;
        
        _plots.minTempereature = - 55.0;//ymin2 - (ymax1 - ymin2) * axisTopBottomPadding;
        _plots.maxTempereature = 50.0;//ymax1 + (ymax1 - ymin2) * axisTopBottomPadding;
    }

}


- (CAGradientLayer *)getGradientLayer {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    OWMWeatherSysObject *sys = (OWMWeatherSysObject *)self.currentWeather.sys;
    DayTime daytime = [sys dayTime];
    switch (daytime) {
        case DayTimeMorning:
            gradient.frame = self.view.bounds;
            gradient.colors = @[UIColorFromRGB(0x3a4f6e), UIColorFromRGB(0x55e75), UIColorFromRGB(0xd3808a), UIColorFromRGB(0xf4aca0), UIColorFromRGB(0xf8f3c9)];
            gradient.locations = @[@(0.0), @(0.3), @(0.66), @(0.8), @(1.0)];
            break;
        case DayTimeDay:
            gradient.frame = self.view.bounds;
            gradient.colors = @[UIColorFromRGB(0x6dcff6), UIColorFromRGB(0x0daaed), UIColorFromRGB(0x0771c7), UIColorFromRGB(0x012d78)];
            gradient.locations = @[@(0.0), @(0.35), @(0.6), @(1.0)];
            break;
        case DayTimeEvening:
            gradient.frame = self.view.bounds;
            gradient.colors = @[UIColorFromRGB(0xb47c4b), UIColorFromRGB(0xac6049), UIColorFromRGB(0x432a51), UIColorFromRGB(0x110724), UIColorFromRGB(0x150c1f)];
            gradient.locations = @[@(0.0), @(0.11), @(0.36), @(0.7), @(1.0)];
            break;
        case DayTimeNigth:
            gradient.frame = self.view.bounds;
            gradient.colors = @[UIColorFromRGB(0x387d7e), UIColorFromRGB(0x154e59), UIColorFromRGB(0x05111d), UIColorFromRGB(0x02020c)];
            gradient.locations = @[@(0.0), @(0.14), @(0.55), @(1.0)];
            break;
        default:
            break;
    }
    return gradient;
}

#pragma mark - Setters

- (void)setCurrentForecast:(id<OWMForecastObject>)currentForecast {
    
    _currentForecast = currentForecast;
    //[self.tableView reloadData];
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
    if (notification.object) {
        NSLog(@"Location Changed!");
        __weak typeof(self) wSelf = self;
        [self loadWeather:^{
            [self.view.layer insertSublayer:[self getGradientLayer] atIndex:0];
        }];
        [self loadForecast:^{//
            [wSelf setScaleMinMax];
            [wSelf.plots redrawPlots];
        }];
    }
}


#pragma mark - Datasource for plots

- (NSUInteger)numberOfRecords {
    NSArray * weatherArray = [[WeatherManager defaultManager] forecast3hForOneDayFromNow];
    if (weatherArray) {
        return [weatherArray count];
    }
    return 0;
}

- (CGPoint)valueForMaxTemperatureAtIndex:(NSUInteger)index {

    NSArray * weatherArray = [[WeatherManager defaultManager] forecast3hForOneDayFromNow];
    id <OWMWeather> object = weatherArray[index];
    CGFloat X = object.dt.floatValue;
    CGFloat Y = object.main.temp_max.floatValue;
    return CGPointMake(X, Y);
}

- (CGPoint)valueForMinTemperatureAtIndex:(NSUInteger)index {

    NSArray * weatherArray = [[WeatherManager defaultManager] forecast3hForOneDayFromNow];
    id <OWMWeather> object = weatherArray[index];
    CGFloat X = object.dt.floatValue;
    CGFloat Y = object.main.temp_min.floatValue - 2.0;
    return CGPointMake(X, Y);
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.view.layer insertSublayer:[self getGradientLayer] atIndex:0];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    __weak typeof(self) wSelf = self;
    [self loadWeather:^{
       
    }];
    
    [self loadForecast:^{
        [wSelf setScaleMinMax];
        [wSelf.plots redrawPlots];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ToForecast"]) {
        Class class = [ForecastViewController class];
        class = [segue.destinationViewController class];
        if ([segue.destinationViewController isKindOfClass:[ForecastViewController class]]) {
            ForecastViewController *vc = (ForecastViewController *)segue.destinationViewController;
            vc.forecasts = [[WeatherManager defaultManager] forecast3hForOneDayFromNow];
            [vc.view.layer insertSublayer:[self getGradientLayer] atIndex:0];
            
        }
    }

    
}



@end
