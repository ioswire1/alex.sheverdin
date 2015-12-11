//
//  ForecastViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/13/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "ForecastViewController.h"
#import "UIImage+OWMCondition.h"
#import "AppDelegate.h"
#import "GradientPlots.h"
#import "Design.h"


#define UIColorFromRGB(rgbValue) (id)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0].CGColor


@interface ForecastViewController () <GradientPlotsDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet GradientPlots *plots;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *weekdayLabels;

@property (strong, nonatomic) id <OWMForecastDailyObject> currentForecastsDaily;

@end

@implementation ForecastViewController



#pragma mark - Get data

- (void)loadForecastDaily:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    
    [[WeatherManager defaultManager] getForecastDailyByLocation:location forDaysCount:16 success:^(OWMObject <OWMForecastDailyObject> *object) {
        
        wSelf.currentForecastsDaily = object;
        [wSelf.collectionView reloadData];
        
        if (completion) {
            completion();
        }
        NSString *title = [NSString stringWithFormat:@"%@, %@\n", self.currentForecastsDaily.city.name, self.currentForecastsDaily.city.country];
        NSArray <__kindof OWMObject <OWMWeatherDaily> *> *forecasts = self.currentForecastsDaily.list;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[forecasts[0].dt doubleValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"MMMM";
        NSString *subtitle = [formatter stringFromDate:date];
        self.navigationItem.titleView = [UILabel navigationTitle:title andSubtitle:subtitle];
        [self.navigationItem.titleView sizeToFit];
        
    } failure:^(NSError *error) {
        // TODO: implementation
    }];
}


#pragma mark - Location

- (CLLocation *)currentLocation {
    
//    if (!self.pageIndex) {
//        return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
//    }
//    Place *city = [WeatherManager defaultManager].places[self.pageIndex];
//
    CLLocation *loc = self.place.location;
    return self.place.location;
    
    
}


#pragma mark - Datasource for plots

- (NSUInteger)numberOfRecords {
    NSArray * weatherArray = [[WeatherManager defaultManager] forecastDailyArray];
    if (weatherArray) {
        return [weatherArray count];
    }
    return 0;
}

- (CGPoint)valueForMaxTemperatureAtIndex:(NSUInteger)index {
    
    NSArray * weatherArray = [[WeatherManager defaultManager] forecastDailyArray];
    id <OWMWeatherDaily> object = weatherArray[index];
    CGFloat X = object.dt.floatValue;
    CGFloat Y = object.temp.day.floatValue;
    return CGPointMake(X, Y);
}

- (CGPoint)valueForMinTemperatureAtIndex:(NSUInteger)index {
    
    NSArray * weatherArray = [[WeatherManager defaultManager] forecastDailyArray];
    id <OWMWeatherDaily> object = weatherArray[index];
    CGFloat X = object.dt.floatValue;
    CGFloat Y = object.temp.night.floatValue;
    return CGPointMake(X, Y);
}


#pragma mark - Delegate


#pragma mark - Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  28;//[self.forecastsDaily.list count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray <__kindof OWMObject <OWMWeatherDaily> *> *forecasts = self.currentForecastsDaily.list;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectCell" forIndexPath:indexPath];
    
    NSDate *firstDate = [NSDate dateWithTimeIntervalSince1970:[forecasts[0].dt doubleValue]];
    UILabel *labelDayOfWeek = (UILabel *)[cell viewWithTag:300];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = @"e";
    int dayOfWeek = [[formatter stringFromDate:firstDate] intValue];
    //    labelDayOfWeek.text = [NSString stringWithFormat:@"%d", dayOfWeek];
    UILabel *labelDay = (UILabel *)[cell viewWithTag:100];
    UILabel *labelTemp = (UILabel *)[cell viewWithTag:101];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:200];
    
    if ((indexPath.row + 1 >= dayOfWeek) && (indexPath.row < dayOfWeek + [self.currentForecastsDaily.list count] - 1)) {
        long int index = indexPath.row + 1 - dayOfWeek;

        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[forecasts[index].dt doubleValue]];
        
        formatter.dateFormat = @"dd";
        NSString *dateString = [[formatter stringFromDate:date] uppercaseString];
        labelDay.text = dateString;
        formatter.dateFormat = @"E";
        
        int temperature = forecasts[index].temp.day.intValue;
        
        labelTemp.text = [NSString stringWithFormat:@"%d°", temperature];
        
        int weatherID = [[forecasts[index].weather[0] objectForKey:@"id"] intValue];

        imageView.image = [UIImage imageWithConditionGroup:OWMConditionGroupByConditionCode(weatherID)];
        
    } else {
        
        labelDay.text = @"";
        labelTemp.text = @"";
        labelDayOfWeek.text = @"";
        imageView.image = nil;
    }
    
    return cell;
}

#pragma mark - Plots

- (void)setScaleMinMax {
    
    float xmax, xmin, ymin1, ymax1, ymin2, ymax2;
    xmax = ymax1 = ymax2 = - MAXFLOAT;
    xmin = ymin1 = ymin2 = MAXFLOAT;
    
    NSArray * weatherArray = [[WeatherManager defaultManager] forecastDailyArray];
    
    if (weatherArray) {
        for (id <OWMWeatherDaily> object in weatherArray) {
            
            CGFloat x = object.dt.floatValue;
            if (x < xmin) xmin = x;
            if (x > xmax) xmax = x;
            
            CGFloat y1 = object.temp.day.floatValue;
            if (y1 < ymin1) ymin1 = y1;
            if (y1 > ymax1) ymax1 = y1;
            
            CGFloat y2 = object.temp.night.floatValue;
            if (y2 < ymin2) ymin2 = y2;
            if (y2 > ymax2) ymax2 = y2;
        }
        
        _plots.start = xmin;
        _plots.length = xmax - xmin;
        
        _plots.minTempereature = - 55.0;//ymin2 - (ymax1 - ymin2) * axisTopBottomPadding;
        _plots.maxTempereature = 50.0;//ymax1 + (ymax1 - ymin2) * axisTopBottomPadding;
    }
    
}


#pragma mark – UICollectionViewDelegateFlowLayout


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
// return CGSizeMake(40.0,70.0);
//}
//
//
//- (UIEdgeInsets)collectionView:
//(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(2, 2, 2, 2);
//}

#pragma mark - Notifications

- (void)appDidBecomeActive {
    //TODO: to implement
}

- (void)locationDidChange:(NSNotification *)notification {
    if (notification.object) {
        __weak typeof(self) wSelf = self;
        [self loadForecastDaily:^{
                        [wSelf setScaleMinMax];
                        [wSelf.plots redrawPlots];
        }];
        
    }
}


#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.collectionView reloadData];

    __weak typeof(self) wSelf = self;
    [self loadForecastDaily:^{
        [wSelf setScaleMinMax];
        [wSelf.plots redrawPlots];
    }];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    NSArray<NSString *> *shortWeekdaySymbols = dateFormatter.shortWeekdaySymbols;
    
    if ([[NSCalendar currentCalendar] firstWeekday] == 2) {
        NSMutableArray *mutableArray = [shortWeekdaySymbols mutableCopy];
        NSObject* obj = [mutableArray firstObject];
        [mutableArray addObject:obj]; 
        [mutableArray removeObjectAtIndex:0];
        shortWeekdaySymbols = [mutableArray copy];
    }
    for (int i = 0;  i < [self.weekdayLabels count]; i++) {
        UILabel *label = self.weekdayLabels[i];
        label.text = [shortWeekdaySymbols[i] uppercaseString];
    }
//    if (!self.pageIndex) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kDidUpdateLocationsNotification object:nil];
//    }
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    if (!self.pageIndex) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//    }
    

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
