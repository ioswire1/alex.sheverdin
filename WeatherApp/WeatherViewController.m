//
//  WeatherViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/1/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "WeatherViewController.h"
#import "AppDelegate.h"
#import "GradientPlots.h"
#import "ForecastViewController.h"
#import "UIImage+OWMCondition.h"
#import "Design.h"
#import "PageWeatherController.h"
#import "SettingsViewController.h"

@interface WeatherViewController () <GradientPlotsDataSource>

@property (nonatomic, strong) IBOutlet GradientPlots *plots;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) id <OWMCurrentWeatherObject> currentWeather;
@property (strong, nonatomic) id <OWMForecastObject> currentForecast;
@property (strong, nonatomic) id <OWMForecastDailyObject> currentForecastsDaily;

@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *windLabel;
@property (strong, nonatomic) IBOutlet UILabel *humidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *pressureLabel;

@end


@implementation WeatherViewController


#pragma mark - Load weather data

- (Place *)place {
    if (!_place) {
        _place = [[Place alloc] init];
    }
    return _place;
}

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
        
//        if (!self.pageIndex) {
//            [WeatherManager defaultManager].places[0].name = self.currentWeather.name;
//            [WeatherManager defaultManager].places[0].countryCode = self.currentWeather.sys.country;
//            [WeatherManager defaultManager].places[0].location = location;
//        }
        
        self.place.name = self.currentWeather.name;
        self.place.countryCode = self.currentWeather.sys.country;
        self.place.location = location;
        

        UILabel *label = [UILabel navigationTitle:title andSubtitle:subtitle];
        [label sizeToFit];
       
        self.parentViewController.navigationItem.titleView = label;
        [self.parentViewController.navigationItem.titleView sizeToFit];
        
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
        
        wSelf.currentForecast = object;
        [wSelf setScaleMinMax];
        [wSelf.plots redrawPlots];
        
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


#pragma mark - Setters

- (void)setCurrentForecast:(id<OWMForecastObject>)currentForecast {
    
    _currentForecast = currentForecast;
}

#pragma mark - Location

- (CLLocation *)currentLocation {
    
//    if (!self.pageIndex) {
        return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
//    }
//    Place *city = [WeatherManager defaultManager].places[self.pageIndex];
    
//    return city.location;
}


#pragma mark - Notifications

- (void)appDidBecomeActive {
//TODO: to implement
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



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PageWeatherController *pvc = (PageWeatherController *)self.parentViewController;
//    self.pageIndex = [pvc.controllers indexOfObject:self];
    
//    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
//        self.view.alpha = 1.0;
//    } completion:nil];
//    if (!self.pageIndex) {
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kDidUpdateLocationsNotification object:nil];
//    }

    __weak typeof(self) wSelf = self;
    [self loadWeather:^{
        
    }];
    
    [self loadForecast:^{
//        [wSelf setScaleMinMax];
//        [wSelf.plots redrawPlots];
    }];
    
    [self loadForecastDaily:^{
        
    }];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
//        self.view.alpha = 0.0;
//    } completion:nil];
//    if (!self.pageIndex) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
//    }
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

    if ([segue.destinationViewController isKindOfClass:[ForecastViewController class]]) {
        ForecastViewController *vc = segue.destinationViewController;
//        vc.pageIndex = self.pageIndex;
        vc.place = self.place;
    }
}


@end
