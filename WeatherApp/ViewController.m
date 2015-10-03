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

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>


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
        [self downloadWeather];
}

- (void) showLastWeather {
    Weather *weather = [Weather lastWeatherInContext:[self managedObjectContext]];
    if (weather)
        [self showWeather:weather];
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
    if ((0 == [self currentLocation].coordinate.latitude) && (0 == [self currentLocation].coordinate.longitude)) {
        self.lblFailedLocation.hidden = NO;
        return;
    } else {
        self.lblFailedLocation.hidden = YES;
    }
    
    OpenWeatherMap *weatherService = [OpenWeatherMap service];
    [weatherService getWeatherForLocation:self.currentLocation.coordinate completion:^(NSDictionary * dictionary, NSError * error) {
        
        if (error) {
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


#pragma mark - posting to Facebook and Twitter

- (IBAction)postToTwitter:(UIButton *)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:[NSString stringWithFormat:@"Hello Twitter! :) It's just a test! I'll post from my first iOS app :) The temperature at %@ is %@. Hurrah!!!", self.lblCity.text, self.lblTemperature.text]];
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        //TODO: Why UIAlertController is better than UIAlertView?
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"You can't send this right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)postToFacebook:(UIButton *)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:[NSString stringWithFormat:@"Hello Facebook!:) It's just a test! I'll post from my first iOS app :) The temperature at %@ is %@. Hurrah!!!", self.lblCity.text, self.lblTemperature.text]];
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"You can't send this right now, make sure your device has an internet connection and you have at least one Facebook account setup in Settings"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveUpdateLocationsNotification:(NSNotification *)notification {
    self.lblFailedLocation.hidden = YES;
    [self downloadWeather];
}

- (void)appDidBecomeActive {
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
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateLocationsNotification:) name:kDidUpdateLocationsNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(appDidBecomeActive)
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [self showLastWeather];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
