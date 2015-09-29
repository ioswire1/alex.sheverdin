 //
//  ViewController.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"
#import "AppDelegate.h"
#import "Weather+API.h"
#import "OpenWeatherMap.h"
#import "CircleView.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet CircleView *circleView;
@property (weak, nonatomic) IBOutlet UIImageView *imageWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lblTempMinMax;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidity;
@property (weak, nonatomic) IBOutlet UILabel *lblUpdateDateTime;

@property (weak, nonatomic) IBOutlet UILabel *lblFailedLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblFailedConnection;

@end

@implementation ViewController


#pragma mark - access to appDelegate methods

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

- (CLLocation *)currentLocation {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
}

#pragma mark - Showing & refreshing UI

- (IBAction)refresh:(UIButton *)sender {
    if ((0 == [self currentLocation].coordinate.latitude) && (0 == [self currentLocation].coordinate.longitude)) {
        self.lblFailedLocation.hidden = NO;
    } else {
        self.lblFailedLocation.hidden = YES;
        [self downloadWeather];
    }
}

- (void) showLastWeather {
    Weather *weather = [Weather lastWeatherInContext:[self managedObjectContext]];
    if (weather) [self showWeather:weather];
}

- (void) showWeather: (Weather*) weather {
    self.lblTemperature.text = [NSString stringWithFormat:@"%dº", [weather.temp intValue]];
    self.lblTempMinMax.text = [NSString stringWithFormat:@"%dº/%dº", [weather.temp_min intValue], [weather.temp_max intValue]];
    self.lblHumidity.text = [NSString stringWithFormat:@"%d%%", [weather.humidity intValue]];
    self.circleView.temperature = [weather.temp floatValue];
    self.lblCity.text = weather.name;

    NSTimeInterval timeInterval = [weather.dt doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"dd.MM.yy HH:mm"];
    NSString *dateString=[dateformatter stringFromDate:date];
    self.lblUpdateDateTime.text = [@"Get at " stringByAppendingString:dateString];
    [self.imageWeather setImage:weather.weatherIcon];
}

#pragma mark - Getting Weather Data

- (void) downloadWeather {
    OpenWeatherMap *weatherService = [OpenWeatherMap service];
    [weatherService getWeatherForLocation:self.currentLocation completion:^(BOOL success, NSDictionary * dictionary, NSError * error) {
        
        if (!success) {
            self.lblFailedConnection.hidden = NO;
        } else {
            Weather *weather = [Weather weatherWithDictionary:dictionary inContext:[self managedObjectContext]];
            self.lblFailedConnection.hidden = YES;
            [self showWeather:weather];
            if (![[self managedObjectContext] save:&error]) {
                //NSLog(@"%@", error);
            }
        }
    }];
}


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kDidUpdateLocationsNotification object:nil];
}

- (void)didReceiveNotification:(NSNotification *)notification {
        [self downloadWeather];
}

- (void)appWillEnterForeground{
    //Application will enter foreground.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showLastWeather];
}

@end
