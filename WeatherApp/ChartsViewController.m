//
//  ChartsViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/1/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//


@import Charts;
#import "ChartsViewController.h"
#import "WeatherManager.h"
#import "AppDelegate.h"
#import "Charts-Swift.h"


static double progressMax = 50.0;

@interface ChartsViewController ()

@property (strong, nonatomic) id <OWMCurrentWeatherObject> currentWeather;
@property (strong, nonatomic) id <OWMForecastObject> currentForecast;
@property (strong, nonatomic) NSMutableArray *minTemps;
@property (strong, nonatomic) NSMutableArray *maxTemps;
@property (strong, nonatomic) NSMutableArray *temps;
@property (strong, nonatomic) IBOutlet LineChartView *chartView;
@property (nonatomic, strong) NSArray *options;
@end

@implementation ChartsViewController


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

#pragma mark - Chart

- (void)setChart {
    self.title = @"Line Chart 1 Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleFilled", @"label": @"Toggle Filled"},
                     @{@"key": @"toggleCircles", @"label": @"Toggle Circles"},
                     @{@"key": @"toggleCubic", @"label": @"Toggle Cubic"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"toggleStartZero", @"label": @"Toggle StartZero"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    
    // x-axis limit line
    ChartLimitLine *llXAxis = [[ChartLimitLine alloc] initWithLimit:10.0 label:@"Index 10"];
    llXAxis.lineWidth = 4.0;
    llXAxis.lineDashLengths = @[@(10.f), @(10.f), @(0.f)];
    llXAxis.labelPosition = ChartLimitLabelPositionRightBottom;
    llXAxis.valueFont = [UIFont systemFontOfSize:10.f];
    
    //[_chartView.xAxis addLimitLine:llXAxis];
    
    ChartLimitLine *ll1 = [[ChartLimitLine alloc] initWithLimit:progressMax - 10.0 label:@"Upper Limit"];
    ll1.lineWidth = 4.0;
    ll1.lineDashLengths = @[@5.f, @5.f];
    ll1.labelPosition = ChartLimitLabelPositionRightTop;
    ll1.valueFont = [UIFont systemFontOfSize:10.0];
    
    ChartLimitLine *ll2 = [[ChartLimitLine alloc] initWithLimit:-progressMax + 10.0 label:@"Lower Limit"];
    ll2.lineWidth = 4.0;
    ll2.lineDashLengths = @[@5.f, @5.f];
    ll2.labelPosition = ChartLimitLabelPositionRightBottom;
    ll2.valueFont = [UIFont systemFontOfSize:10.0];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    [leftAxis addLimitLine:ll1];
    [leftAxis addLimitLine:ll2];
    leftAxis.customAxisMax = progressMax;
    leftAxis.customAxisMin = -progressMax;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    _chartView.rightAxis.enabled = NO;
    
    [_chartView.viewPortHandler setMaximumScaleY: 2.f];
    [_chartView.viewPortHandler setMaximumScaleX: 2.f];
    
//        BalloonMarker *marker = [[BalloonMarker alloc] initWithColor:[UIColor colorWithWhite:180/255. alpha:1.0] font:[UIFont systemFontOfSize:12.0] insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    //    marker.minimumSize = CGSizeMake(80.f, 40.f);
    //    _chartView.marker = marker;
    
    _chartView.legend.form = ChartLegendFormLine;
}

- (void)setDataCount {
    
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
    if (!_maxTemps) {
        _maxTemps = [[NSMutableArray alloc] init];
    } else {
        [_maxTemps removeAllObjects];
    }
    
    if (!_minTemps) {
        _minTemps = [[NSMutableArray alloc] init];
    } else {
        [_minTemps removeAllObjects];
    }
    
    NSInteger index = 0;
    for (id <OWMWeather> object in self.currentForecast.list) {
        [_maxTemps addObject:object.main.temp_max];
        [_minTemps addObject:object.main.temp_min];
        [xVals addObject:[@(index) stringValue]];
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:[object.main.temp_max doubleValue] xIndex:index]];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:[object.main.temp_min doubleValue] xIndex:index]];
        index++;
    }

    NSLog(@"max & min: %@", yVals1, yVals2);
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals1 label:@"DataSet 1"];
    set1.lineDashLengths = @[@5.f, @2.5f];
    set1.highlightLineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.redColor];
    [set1 setCircleColor:UIColor.redColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 3.0;
    set1.drawCircleHoleEnabled = NO;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.fillAlpha = 65/255.0;
    set1.fillColor = UIColor.blackColor;
    
    LineChartDataSet *set2 = [[LineChartDataSet alloc] initWithYVals:yVals2 label:@"DataSet 2"];
    set2.lineDashLengths = @[@5.f, @2.5f];
    set2.highlightLineDashLengths = @[@5.f, @2.5f];
    [set2 setColor:UIColor.blueColor];
    [set2 setCircleColor:UIColor.blueColor];
    set2.lineWidth = 1.0;
    set2.circleRadius = 3.0;
    set2.drawCircleHoleEnabled = NO;
    set2.valueFont = [UIFont systemFontOfSize:9.f];
    set2.fillAlpha = 65/255.0;
    set2.fillColor = UIColor.blackColor;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    _chartView.data = data;
}



#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadForecast:^{
        [self setChart];
        [self setDataCount];
        [_chartView animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart];
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
