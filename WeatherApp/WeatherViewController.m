//
//  WeatherViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/1/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "WeatherViewController.h"
#import "WeatherManager.h"
#import "AppDelegate.h"
#import "GradientPlots.h"
#import "ForecastViewController.h"
#import "UIImage+OWMCondition.h"
#import "Design.h"
#import "PageForecastController.h"
#import "NavigationController.h"

#define UIColorFromRGB(rgbValue) (id)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0].CGColor


@interface WeatherViewController () <GradientPlotsDataSource>

@property (nonatomic, strong) IBOutlet GradientPlots *plots;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;


@property (strong, nonatomic) id <OWMCurrentWeatherObject> currentWeather;
@property (strong, nonatomic) id <OWMForecastObject> currentForecast;
@property (strong, nonatomic) id <OWMForecastDailyObject> currentForecastsDaily;

@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *windLabel;
@property (strong, nonatomic) IBOutlet UILabel *humidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *pressureLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end


@implementation WeatherViewController


#pragma mark - Load weather data

- (void)loadWeather:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    [[WeatherManager defaultManager] getWeatherByLocation:location success:^(OWMObject <OWMCurrentWeatherObject> *object) {
        
        wSelf.currentWeather = object;
        if (completion) {
            completion();
        }
        
        NSString *title = [NSString stringWithFormat:@"%@, %@\n", self.currentWeather.name, self.currentWeather.sys.country];
        NSString *subtitle = [[self.currentWeather.weather[0] objectForKey:@"description"] lowercaseString];
        
        UIView *view = self.navigationItem.titleView;
        UILabel *label = [UILabel navigationTitle:title andSubtitle:subtitle];
        [label sizeToFit];
        
        UINavigationItem *navigationItem = self.navigationItem;
        navigationItem = self.pageNavigationItem;
        UILabel *tempLabel = (UILabel *)navigationItem.titleView;
        
        self.navigationItem.titleView = label;
        self.pageNavigationItem.titleView = label;

//        self.navigationItem.titleView = [UILabel navigationTitle:title andSubtitle:subtitle];

        [self.navigationItem.titleView sizeToFit];
        [self.pageNavigationItem.titleView sizeToFit];
        
        NSString *tempString = [NSString stringWithFormat:@"%dº",[self.currentWeather.main.temp intValue]];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:tempString];
        NSRange range = NSMakeRange([attrString length] - 1, 1);
       
        UIFont *font = self.temperatureLabel.font;
        
        UIFontDescriptor *fontDescriptor = [UIFontDescriptor
                                            fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute: font.fontName,
                                                                               UIFontDescriptorTraitsAttribute: @{UIFontWeightTrait:@(0.25)}}];
        
        UIFont *boldFont = [UIFont fontWithDescriptor:fontDescriptor size:font.pointSize * 0.45];
        NSNumber *offsetAmount = @(font.capHeight - boldFont.capHeight - 2);
        
        [attrString addAttribute:NSFontAttributeName value:boldFont range:range];
        [attrString addAttribute:NSBaselineOffsetAttributeName value:offsetAmount range:range];
     
        self.temperatureLabel.attributedText = attrString;
          self.windLabel.text = [NSString stringWithFormat:@"%.2f",[self.currentWeather.wind.speed floatValue]];
        self.humidityLabel.text = [NSString stringWithFormat:@"%d",[self.currentWeather.main.humidity intValue]];
        self.pressureLabel.text = [NSString stringWithFormat:@"%d",[self.currentWeather.main.pressure intValue]];
        
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

- (void)loadForecastDaily:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    
    [[WeatherManager defaultManager] getForecastDailyByLocation:location forDaysCount:16 success:^(OWMObject <OWMForecastDailyObject> *object) {

        wSelf.currentForecastsDaily = object;
        [wSelf.collectionView reloadData];
        
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

    NSArray * weatherArray = [[WeatherManager defaultManager] forecastArrayOneDayFromInterval:[NSDate date].timeIntervalSince1970];

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

#pragma mark - Navigation Controller Helpers


- (NSArray *)cities {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NavigationController *nvc = (NavigationController *)window.rootViewController;
    return nvc.cities;
}

- (NSUInteger)pageIndex {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NavigationController *nvc = (NavigationController *)window.rootViewController;
    return nvc.pageIndex;
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
        [self loadForecastDaily:^{
            
        }];

    }
}


#pragma mark - Datasource for plots

- (NSUInteger)numberOfRecords {
    NSArray * weatherArray = [[WeatherManager defaultManager] forecastArrayOneDayFromLastUpdate];
    if (weatherArray) {
        return [weatherArray count];
    }
    return 0;
}

- (CGPoint)valueForMaxTemperatureAtIndex:(NSUInteger)index {

    NSArray * weatherArray = [[WeatherManager defaultManager] forecastArrayOneDayFromLastUpdate];
    id <OWMWeather> object = weatherArray[index];
    CGFloat X = object.dt.floatValue;
    CGFloat Y = object.main.temp_max.floatValue;
    return CGPointMake(X, Y);
}

- (CGPoint)valueForMinTemperatureAtIndex:(NSUInteger)index {

    NSArray * weatherArray = [[WeatherManager defaultManager] forecastArrayOneDayFromLastUpdate];
    id <OWMWeather> object = weatherArray[index];
    CGFloat X = object.dt.floatValue;
    CGFloat Y = object.main.temp_min.floatValue;
    return CGPointMake(X, Y);
}


#pragma mark - Delegate for Collection View



#pragma mark - Datasource for Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  7;//[self.forecastsDaily.list count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray <__kindof OWMObject <OWMWeatherDaily> *> *forecasts = self.currentForecastsDaily.list;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectCell" forIndexPath:indexPath];
    UILabel *labelDay = (UILabel *)[cell viewWithTag:100];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[forecasts[indexPath.row].dt doubleValue]];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E";
    NSString *dateString = [[formatter stringFromDate:date] uppercaseString];
    labelDay.text = dateString;
    UILabel *labelTemp = (UILabel *)[cell viewWithTag:101];
    int temperature = forecasts[indexPath.row].temp.day.intValue;
    labelTemp.text = [NSString stringWithFormat:@"%d°", temperature];
    
    int weatherID = [[forecasts[indexPath.row].weather[0] objectForKey:@"id"] intValue];
    UILabel *labelID = (UILabel *)[cell viewWithTag:222];
    labelID.text = [NSString stringWithFormat:@"%d", weatherID];

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:200];
    imageView.image = [UIImage imageWithConditionGroup:OWMConditionGroupByConditionCode(weatherID)];
    
    return cell;
}


#pragma mark - Lifecycle



- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.indexLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.pageIndex];

    [self.view.layer insertSublayer:[self getGradientLayer] atIndex:0];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.indexLabel.text = [[self cities] objectAtIndex:self.pageIndex];
    self.pageControl.currentPage = self.pageIndex;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kDidUpdateLocationsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    __weak typeof(self) wSelf = self;
    [self loadWeather:^{
        
    }];
    
    [self loadForecast:^{
        [wSelf setScaleMinMax];
        [wSelf.plots redrawPlots];
    }];
    
    [self loadForecastDaily:^{
        
    }];
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
    
//    Class class = [PageForecastController class];
//    class = [segue.destinationViewController class];
//    if ([segue.destinationViewController isKindOfClass:[PageForecastController class]]) {
//        PageForecastController *vc = (PageForecastController *)segue.destinationViewController;
//        //            vc.forecasts = [[WeatherManager defaultManager] forecastForOneDayFromNow];
//
//    NSUInteger index = self.pageIndex;
//    [vc setViewControllers:@[[vc viewControllerAtIndex:index]] direction: UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
//    }];
//    }
}


@end
