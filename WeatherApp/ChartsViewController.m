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

static double progressMax = 50.0;

#define UIColorFromRGB(rgbValue) (id)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0].CGColor


@interface ChartsViewController () <GradientPlotsDataSource>

@property (nonatomic, strong) IBOutlet GradientPlots *plots;
@property (strong, nonatomic) id <OWMCurrentWeatherObject> currentWeather;
@property (strong, nonatomic) id <OWMForecastObject> currentForecast;

@property (strong, nonatomic) NSMutableArray *plotsData;
@property (strong, nonatomic) NSMutableArray *dates;

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

// generates arrays of weatherObjects, grouped by date
- (NSArray *)setDates {
//TODO: implement sorting
    if (!_dates) {
        _dates = [[NSMutableArray alloc] init];
    } else {
        [_dates removeAllObjects];
    }
    OWMObject <OWMWeather> *firstObject = [self.currentForecast.list firstObject];
    
    if (firstObject) {
        NSString *prevShortDate = [self stringFromTimeInterval:firstObject.dt.floatValue withFormat:@"dd.MM"];
        NSMutableArray *sameDates = [[NSMutableArray alloc] init];
        
        for (id <OWMWeather> object in self.currentForecast.list) {
            NSString *shortDate = [self stringFromTimeInterval:object.dt.floatValue withFormat:@"dd.MM"];
            
            if ([shortDate isEqualToString:prevShortDate]) {
                [sameDates addObject:object];
            } else {
                [_dates addObject:[sameDates copy]];
                [sameDates removeAllObjects];
                [sameDates addObject:object];
                prevShortDate = shortDate;
            }
        }
        
        [_dates addObject:[sameDates copy]];
    }
    return [_dates copy];
}


// generates data for plots (array of array with 2 points) by date index (0 - today, 1 - tomorrow)
- (void) generatePlotsDataForDatesIndex:(NSUInteger)dateIndex {
    
    if (!_plotsData) {
        _plotsData = [[NSMutableArray alloc] init];
    }
    [_plotsData removeAllObjects];
//TODO: implement real hour for X instead index
    int index = 0;
    for (id <OWMWeather> obj in self.dates[dateIndex]) {
        NSMutableArray *array = [NSMutableArray array];
//        CGFloat X = [[self stringFromTimeInterval:obj.dt.floatValue withFormat:@"H"] doubleValue];
        NSRange range = NSMakeRange(11, 2);
        CGFloat X = [[obj.dt_txt substringWithRange: range] doubleValue];
//        CGFloat X = [obj.dt doubleValue];
        CGFloat Y = [obj.main.temp_max doubleValue];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(X, Y)]];
        Y = [obj.main.temp_min doubleValue] - 5.0; // minus 5 because "temp" & "temp_min"("temp_max") mostly equals :(
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(X, Y)]];
        [_plotsData addObject:array];
        NSLog(@"%d, %.1f, %.1f, %@", index, X, Y, obj.dt_txt);
        index++;
    }
}

static double const axisTopBottomPadding = 0.05;

- (void)setScaleMinMax {
    
    float xmax, xmin, ymin1, ymax1, ymin2, ymax2;
    xmax = ymax1 = ymax2 = - MAXFLOAT;
    xmin = ymin1 = ymin2 = MAXFLOAT;

    if (_plotsData) {
        for (NSArray *array in _plotsData) {
            CGPoint point1 = [array[0] CGPointValue];
//            CGFloat x = point1.x;
//            if (x < xmin) xmin = x;
//            if (x > xmax) xmax = x;
            CGFloat y1 = point1.y;
            if (y1 < ymin1) ymin1 = y1;
            if (y1 > ymax1) ymax1 = y1;
            
            CGPoint point2 = [array[1] CGPointValue];
            CGFloat y2 = point2.y;
            if (y2 < ymin2) ymin2 = y2;
            if (y2 > ymax2) ymax2 = y2;
        }

//        _plots.start = xmin;
//        _plots.length = xmax - xmin;
        
        _plots.minTempereature = ymin2;// - ymin2 * axisTopBottomPadding;
        _plots.maxTempereature = ymax1 + ymax1 * axisTopBottomPadding;
    }
}


- (void)setGradient {
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
    [self.view.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Setters

- (void)setCurrentForecast:(id<OWMForecastObject>)currentForecast {
    
    _currentForecast = currentForecast;
    [self setDates];
    [self generatePlotsDataForDatesIndex:1];
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
            [self setGradient];
        }];
        [self loadForecast:^{//
            wSelf.plots.start = 0.0;
            wSelf.plots.length = [_plotsData count];
            [wSelf setScaleMinMax];
//            wSelf.plots.minTempereature = -20.0;
//            wSelf.plots.maxTempereature = 20.0;
            [wSelf.plots redrawPlots];
        }];
    }
}


#pragma mark - Datasource

- (NSUInteger)numberOfRecords {
    if (_dates) {
        return [_dates[1] count];
    }
    return 0;
}

- (CGPoint)valueForMaxTemperatureAtIndex:(NSUInteger)index {

    return [[_plotsData[index] objectAtIndex:0] CGPointValue];
}

- (CGPoint)valueForMinTemperatureAtIndex:(NSUInteger)index {
    
    return [[_plotsData[index] objectAtIndex:1] CGPointValue];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setGradient];
    __weak typeof(self) wSelf = self;
    [self loadWeather:^{
       
    }];
    
    [self loadForecast:^{

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
