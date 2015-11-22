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

@interface ForecastViewController () <GradientPlotsDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet GradientPlots *plots;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) id <OWMForecastDailyObject> forecastsDaily;

@end

@implementation ForecastViewController

#pragma mark - Get data

- (void)loadForecastDaily:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    
    [[WeatherManager defaultManager] getForecastDailyByLocation:location forDaysCount:16 success:^(OWMObject <OWMForecastDailyObject> *object) {
        
        wSelf.forecastsDaily = object;
        [wSelf.collectionView reloadData];
        
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
    if (notification.object) {
        __weak typeof(self) wSelf = self;
        [self loadForecastDaily:^{
            [wSelf setScaleMinMax];
            [wSelf.plots redrawPlots];
        }];
        
    }
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
    NSArray <__kindof OWMObject <OWMWeatherDaily> *> *forecasts = self.forecastsDaily.list;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectCell" forIndexPath:indexPath];
    
    NSDate *firstDate = [NSDate dateWithTimeIntervalSince1970:[forecasts[0].dt doubleValue]];
    UILabel *labelDayOfWeek = (UILabel *)[cell viewWithTag:300];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"e";
    int dayOfWeek = [[formatter stringFromDate:firstDate] intValue];
    labelDayOfWeek.text = [NSString stringWithFormat:@"%d", dayOfWeek];
    
    NSUInteger temp = dayOfWeek + [self.forecastsDaily.list count];
    if ((indexPath.row + 1 >= dayOfWeek) && (indexPath.row < dayOfWeek + [self.forecastsDaily.list count] - 1)) {
        long int index = indexPath.row - dayOfWeek;
        UILabel *labelDay = (UILabel *)[cell viewWithTag:100];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[forecasts[index].dt doubleValue]];
        
        formatter.dateFormat = @"E";
        NSString *dateString = [[formatter stringFromDate:date] uppercaseString];
        labelDay.text = dateString;
        UILabel *labelTemp = (UILabel *)[cell viewWithTag:101];
        int temperature = forecasts[index].temp.day.intValue;
        
        labelTemp.text = [NSString stringWithFormat:@"%d°", temperature];
        
        int weatherID = [[forecasts[index].weather[0] objectForKey:@"id"] intValue];
        UILabel *labelID = (UILabel *)[cell viewWithTag:222];
        labelID.text = [NSString stringWithFormat:@"%d", weatherID];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:200];
        imageView.image = [UIImage imageWithConditionGroup:OWMConditionGroupByConditionCode(weatherID)];
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


#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView reloadData];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    __weak typeof(self) wSelf = self;
    [self loadForecastDaily:^{
        [wSelf setScaleMinMax];
        [wSelf.plots redrawPlots];
        
    }];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kDidUpdateLocationsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
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
