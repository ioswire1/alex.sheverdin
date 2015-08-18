 //
//  ViewController.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
#import "TableViewController.h"
#import "WeatherView.h"
#import "AppDelegate.h"
#import "Forecast+API.h"
#import "Weather+API.h"

//static NSString  *urlWeather = @"http://api.openweathermap.org/data/2.5/weather?lat=50&lon=36.25&units=metric";
static NSString  *urlWeather = @"http://api.openweathermap.org/data/2.5/weather?q=kharkiv&units=metric";
//static NSString  *urlForecast = @"http://api.openweathermap.org/data/2.5/forecast?lat=50&lon=36.25&units=metric";
static NSString  *urlForecast = @"http://api.openweathermap.org/data/2.5/forecast?q=kharkiv&units=metric";


@interface ViewController ()

@property (nonatomic, strong) NSDictionary *allWeatherData;
@property (nonatomic, strong) NSArray *forecast;
@property (nonatomic, weak) TableViewController *tableViewController;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UILabel *lblLongitude;
@property (weak, nonatomic) IBOutlet UILabel *lblLatitude;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;

@property (weak, nonatomic) IBOutlet UIImageView *imageWeather;
@property (weak, nonatomic) IBOutlet WeatherView *weatherView;

@property (weak, nonatomic) IBOutlet UILabel *lblUpdateDateTime;
@end

@implementation ViewController


- (IBAction)refresh:(UIButton *)sender {
    [self downloadWeather];
    [self downloadForecast];
  
    //[self.weatherView setNeedsDisplay];
}

- (NSURL *) composeURLWithType:(ASHURLType) URLType {
    
    NSString *urlString;
    switch(URLType){
        case ASHURLTypeWeatherCityName  :
            urlString = urlWeather;
            break;
        case ASHURLTypeForecastCityName  :
            urlString = urlForecast;
            break;
        case ASHURLTypeWeatherCoords  :
            urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.2f&lon=%.2f&units=metric", self.latitude, self.longitude];
            break;
        case ASHURLTypeForecastCoords  :
            urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.2f&lon=%.2f&units=metric", self.latitude, self.longitude];
            break;
    }
    return [NSURL URLWithString:urlString];
}


- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}


- (void) downloadWeather {
     [self downloadWeatherDataFromURL:[self composeURLWithType:ASHURLTypeWeatherCoords] withBlock:^(id result) {
        if ([result isKindOfClass:[NSError class]]) {
            //
        } else if ([result isKindOfClass:[NSData class]]) {
            NSError *error;
            self.allWeatherData = [NSJSONSerialization JSONObjectWithData:result
                                                                  options:0
                                                                    error:&error];
             if (!error) {
                 [Weather weatherWithDictionary:self.allWeatherData inContext:[self managedObjectContext]];
             }
            if (![[self managedObjectContext] save:&error]) {
                NSLog(@"%@", error);
            }
            
            Weather *weather = [Weather lastWeatherInContext:[self managedObjectContext]] ;
            
            
            
            self.lblTemperature.text = [NSString stringWithFormat:@"%dº", [weather.temp intValue]];
            self.lblCity.text = weather.name;
            NSLog(@"Data = %@", weather);
           
            // get date and time of last update
            NSTimeInterval timeInterval = [weather.dt doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
            [dateformatter setLocale:[NSLocale currentLocale]];
            [dateformatter setDateFormat:@"dd.mm.yy HH:mm"];
            NSString *dateString=[dateformatter stringFromDate:date];
            NSLog(@"DateTime: %@", dateString);
            self.lblUpdateDateTime.text = [@"Get at " stringByAppendingString:dateString];
            
            
            
            //NSString *urlOfImage = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",[weather valueForKey:@"icon"]];
            
            //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlOfImage]]];
            //[self.imageWeather setImage:image];
            [self.imageWeather setImage:weather.weatherIcon];
        }
    }];
}


- (void) downloadForecast {
    
    [self downloadWeatherDataFromURL:[self composeURLWithType:ASHURLTypeForecastCityName] withBlock:^(id result) {
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
            
            self.tableViewController.forcast = self.forecast;
            [self.tableViewController refreshTable];
        }
        
    }];

}

- (void)downloadWeatherDataFromURL:(NSURL *)url withBlock:(void(^)(id result))completion {
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    __weak typeof(request) wRequest = request;
    [request setCompletionBlock:^{
        if (completion) {
            completion(wRequest.responseData);
        }
    }];
    
    [request setFailedBlock:^{
        if (completion) {
            completion(wRequest.error);
        }
    }];

    [request startAsynchronous];
}

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
    NSLog(@"didFailWithError: %@", error);
    //!!! Replace UIAlertView with UIAlertController
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray*)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    if (currentLocation != nil) {
        self.lblLongitude.text = [NSString stringWithFormat:@"%.2f", currentLocation.coordinate.longitude];
        self.lblLatitude.text = [NSString stringWithFormat:@"%.2f", currentLocation.coordinate.latitude];
        self.longitude = currentLocation.coordinate.longitude;
        self.latitude = currentLocation.coordinate.latitude;
    }
    NSLog(@"Current loсation is %@", currentLocation);
    [self downloadWeather];
    [self downloadForecast];
}


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //!!! Add check for Location Service is On
    // init locationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter=500;
    
    [self.locationManager startUpdatingLocation];
    [self downloadWeather];
    [self downloadForecast];
    // notification for entering app to foreground (instead viewWillAppear)
    //!!! where removeObserver to be done?
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}


- (void)appWillEnterForeground{ //Application will enter foreground.
//!!! what about Layer ?
//    [self.weatherView.circle removeFromSuperlayer];
//    self.weatherView.circle = nil;
    [self.weatherView setNeedsDisplay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.weatherView setNeedsDisplay];
}

@end
