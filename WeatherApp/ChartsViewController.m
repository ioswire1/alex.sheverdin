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
        CGFloat Y = [obj.main.temp_max doubleValue];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(X, Y)]];
        Y = [obj.main.temp_min doubleValue] - 5.0; // minus 5 because "temp" & "temp_min"("temp_max") mostly equals :(
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(X, Y)]];
        [_plotsData addObject:array];
        NSLog(@"%d, %.1f, %.1f, %@", index, X, Y, obj.dt_txt);
        index++;
    }
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
//        [self loadWeather:^{
//            nil;
//        }];
        [self loadForecast:^{
//            [wSelf.plots drawPlotsWithData:wSelf.plotsData];
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

    return [[_plotsData[1] objectAtIndex:0] CGPointValue];
}

- (CGPoint)valueForMinTemperatureAtIndex:(NSUInteger)index {
    
    return [[_plotsData[1] objectAtIndex:1] CGPointValue];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak typeof(self) wSelf = self;
    [self loadForecast:^{
//        wSelf.plots = [[GradientPlots alloc] initWithHostingView:wSelf.graphHostingView];
//        [wSelf.plots drawPlotsWithData:wSelf.plotsData];
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
