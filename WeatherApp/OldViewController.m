 //
//  OldViewController.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "OldViewController.h"
#import "TableViewController.h"
#import "AppDelegate.h"
#import "Weather+API.h"
#import "OpenWeatherMap.h"
#import "CircleView.h"
#import "FallBehavior.h"

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>


@interface OldViewController ()

@property (weak, nonatomic) IBOutlet CircleView *circleView;
@property (weak, nonatomic) IBOutlet UIImageView *imageWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lblTempMinMax;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidity;
@property (weak, nonatomic) IBOutlet UILabel *lblUpdateDateTime;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) FallBehavior *fallBehavior;

@property (weak, nonatomic) IBOutlet UILabel *lblFailedLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblFailedConnection;

@end

@implementation OldViewController

#pragma mark - debugging methods



- (IBAction)animIntro:(UIButton *)sender {
    
    [self.fallBehavior addItem:self.circleView];
}

- (IBAction)stopIntro:(UIButton *)sender {
    [self.fallBehavior removeItem:self.circleView];
}

#pragma mark - access to appDelegate methods

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

- (CLLocation *)currentLocation {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
}


#pragma mark - Fall Animation

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    return _animator;
}

- (FallBehavior *)fallBehavior {
    if (!_fallBehavior) {
        _fallBehavior = [[FallBehavior alloc] init];
        [self.animator addBehavior:_fallBehavior];
    }
    return _fallBehavior;
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
    //self.lblTemperature.hidden = NO;
    self.lblTemperature.text = [NSString stringWithFormat:@"%dº", [weather.temp intValue]];
    self.lblTempMinMax.text = [NSString stringWithFormat:@"%dº/%dº", [weather.temp_min intValue], [weather.temp_max intValue]];
    self.lblHumidity.text = [NSString stringWithFormat:@"%d%%", [weather.humidity intValue]];
    self.circleView.progress = [weather.temp floatValue];
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


#pragma mark - posting to social networks

- (IBAction)postToTwitter:(UIButton *)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:[NSString stringWithFormat:@"It's a test screenshot post from my iOS Weather App!"]];
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
        [self.view.layer.presentationLayer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [controller addImage:img];
        
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
        [controller setInitialText:[NSString stringWithFormat:@"It's a test screenshot post from my iOS Weather App"]];
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
        [self.view.layer.presentationLayer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [controller addImage:img];
        
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateLocationsNotification:) name:kDidUpdateLocationsNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(appDidBecomeActive)
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
//    [self showLastWeather];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
