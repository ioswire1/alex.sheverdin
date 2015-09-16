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
#import "Forecast+API.h"
#import "Weather+API.h"
#import "WeatherService.h"
#import "CircleView.h"


@interface ViewController ()

//!!! to delete?
@property (nonatomic, strong) NSDictionary *allWeatherData;
@property (nonatomic, strong) NSArray *forecast;

@property (nonatomic, weak) TableViewController *tableViewController;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (weak, nonatomic) IBOutlet CircleView *circleView;
@property (weak, nonatomic) IBOutlet UIImageView *imageWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;

@property (weak, nonatomic) IBOutlet UILabel *lblTempMinMax;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidity;
@property (weak, nonatomic) IBOutlet UILabel *lblUpdateDateTime;

//!!! for testing
@property (weak, nonatomic) IBOutlet UILabel *lblLongitude;
@property (weak, nonatomic) IBOutlet UILabel *lblLatitude;

@end

@implementation ViewController


#pragma mark -

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}


#pragma mark - Showing & refreshing UI

- (IBAction)refresh:(UIButton *)sender {
    
    //!!! Replace UIAlertView with UIAlertController

    if (nil == self.currentLocation) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Failed to Get Your Location!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    } else {
        [self downloadWeather];
        [self downloadForecast];
    }

}

- (void) showLastWeather {
    
    Weather *weather = [Weather lastWeatherInContext:[self managedObjectContext]] ;
    [self showWeather:weather];
}

- (void) showLastForecast {
    
    //updating tableView in container controller
    self.tableViewController.forcast = self.forecast;
    [self.tableViewController refreshTable];
}

- (void) showWeather: (Weather*) weather {
    
    if (weather) {
        self.lblTemperature.text = [NSString stringWithFormat:@"%dº", [weather.temp intValue]];
        self.lblTempMinMax.text = [NSString stringWithFormat:@"%dº/%dº", [weather.temp_min intValue], [weather.temp_max intValue]];
        self.lblHumidity.text = [NSString stringWithFormat:@"%d%%", [weather.humidity intValue]];
        
        self.circleView.temperature = [weather.temp floatValue];
        self.lblCity.text = weather.name;
        NSLog(@"hi from showLastWeather!");
        NSLog(@"Data = %@", weather);
        
        // get date and time of last update
        NSTimeInterval timeInterval = [weather.dt doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setLocale:[NSLocale currentLocale]];
        [dateformatter setDateFormat:@"dd.MM.yy HH:mm"];
        NSString *dateString=[dateformatter stringFromDate:date];
        NSLog(@"DateTime: %@", dateString);
        self.lblUpdateDateTime.text = [@"Get at " stringByAppendingString:dateString];
        [self.imageWeather setImage:weather.weatherIcon];
        
    } else {
        
        NSLog(@"No Data!!!");
    }
    
}


// this section needs refactoring
#pragma mark - Getting Weather & Forecast data


- (void) downloadWeather {
    
    WeatherService *weatherService = [WeatherService sharedService];
    [weatherService getWeatherForLocation:self.currentLocation completion:^(id result) {
    
        if ([result isKindOfClass:[NSError class]]) {
            //
        } else
            if ([result isKindOfClass:[NSData class]]) {
                NSError *error;
                self.allWeatherData = [NSJSONSerialization JSONObjectWithData:result
                                                                      options:0
                                                                        error:&error];
                if (!error) {
                    Weather *weather = [Weather weatherWithDictionary:self.allWeatherData inContext:[self managedObjectContext]];
                    [self showWeather:weather];
                }
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"%@", error);
                }
                NSLog(@"Completed!");
            }
    }];
    
//    [weatherService downloadWeatherData:ASHURLTypeWeatherCoords withCompletionBlock:^(id result) {
//        if ([result isKindOfClass:[NSError class]]) {
//            //
//        } else
//        if ([result isKindOfClass:[NSData class]]) {
//            NSError *error;
//            self.allWeatherData = [NSJSONSerialization JSONObjectWithData:result
//                                                                  options:0
//                                                                    error:&error];
//            if (!error) {
//                 Weather *weather = [Weather weatherWithDictionary:self.allWeatherData inContext:[self managedObjectContext]];
//                [self showWeather:weather];
//            }
//            if (![[self managedObjectContext] save:&error]) {
//                NSLog(@"%@", error);
//            }
//            NSLog(@"Completed!");
//        }
//    }];
}


- (void) downloadForecast {
    WeatherService *weatherService = [WeatherService sharedService];
    [weatherService getForecastForLocation:self.currentLocation completion:^(id result) {
        if ([result isKindOfClass:[NSError class]]) {
            //
        } else if ([result isKindOfClass:[NSData class]]) {
            NSError *error;
            self.allWeatherData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];

           if (!error) {
               
                self.forecast = [self.allWeatherData valueForKey:@"list"];

                for (NSDictionary *dictionary in self.forecast) {
                    [Forecast forecastWithDictionary:dictionary inContext:[self managedObjectContext]];
                }
                
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"%@", error);
                }
            }
            
            [self showLastForecast];
            
            //updating tableView in container controller
//            self.tableViewController.forcast = self.forecast;
//            [self.tableViewController refreshTable];
        }
        
    }];

}



#pragma mark - Transfer data to Forecast's TableViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ToTable"]) {
        if ([segue.destinationViewController isKindOfClass:[TableViewController class]]) {
            self.tableViewController = (TableViewController *)segue.destinationViewController;
            self.tableViewController.forcast = self.forecast;
        }
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Qwerty didFailWithError: %@", error);
    //!!! Replace UIAlertView with UIAlertController
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray*)locations {
    
    self.currentLocation = [locations lastObject];
    
    if (self.currentLocation != nil) {
        self.lblLongitude.text = [NSString stringWithFormat:@"%.2f", self.currentLocation.coordinate.longitude];
        self.lblLatitude.text = [NSString stringWithFormat:@"%.2f", self.currentLocation.coordinate.latitude];
    }

    [self downloadWeather];
    [self downloadForecast];
}


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // init locationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter=500;
    
    //CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus]; //check authorizationStatus
    
    // Check for iOS 8 and request user Authorization
    if ([self.locationManager respondsToSelector:
         @selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
  
    [self showLastWeather];
    //[self showLastForecast];

    // notification for entering app to foreground (instead viewWillAppear)
    //!!! where removeObserver to be done?
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appWillEnterForeground)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
}


- (void)appWillEnterForeground{ //Application will enter foreground.
//!!! what about Layer ?
//    [self.weatherView.circle removeFromSuperlayer];
//    self.weatherView.circle = nil;
//    [self.circleView setNeedsDisplay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.circleView setNeedsDisplay];
}

@end
