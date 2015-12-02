//
//  AppDelegate.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenWeatherMap.h"

#define UIColorFromRGB(rgbValue) (id)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0].CGColor

static NSString *const kOpenWeatherApiKey = @"317eb1575c16aa97869f70407660d3e6";

@interface AppDelegate ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [OpenWeatherMap setApiKey:kOpenWeatherApiKey];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.window setBackgroundColor:[UIColor blackColor]];
    
    // Override point for customization after application launch.
    // init locationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus]; //check authorizationStatus
    
    // Check for iOS 8 and request user Authorization
    if ([self.locationManager respondsToSelector:
         @selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDidUpdateLocationsNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateBackground];
    }];
    return YES;
}

- (void)setWindow:(UIWindow *)window {
    _window = window;
    [self updateBackground];
}

- (void)updateBackground {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.window.bounds;
    //OWMWeatherSysObject *sys = (OWMWeatherSysObject *)self.currentWeather.sys;
    DayTime daytime = DayTimeDay;//[sys dayTime];
    switch (daytime) {
        case DayTimeMorning:
            
            gradient.colors = @[UIColorFromRGB(0x3a4f6e), UIColorFromRGB(0x55e75), UIColorFromRGB(0xd3808a), UIColorFromRGB(0xf4aca0), UIColorFromRGB(0xf8f3c9)];
            gradient.locations = @[@(0.0), @(0.3), @(0.66), @(0.8), @(1.0)];
            break;
        case DayTimeDay:
            
            gradient.colors = @[UIColorFromRGB(0x6dcff6), UIColorFromRGB(0x0daaed), UIColorFromRGB(0x0771c7), UIColorFromRGB(0x012d78)];
            gradient.locations = @[@(0.0), @(0.35), @(0.6), @(1.0)];
            break;
        case DayTimeEvening:
            
            gradient.colors = @[UIColorFromRGB(0xb47c4b), UIColorFromRGB(0xac6049), UIColorFromRGB(0x432a51), UIColorFromRGB(0x110724), UIColorFromRGB(0x150c1f)];
            gradient.locations = @[@(0.0), @(0.11), @(0.36), @(0.7), @(1.0)];
            break;
        case DayTimeNigth:
            
            gradient.colors = @[UIColorFromRGB(0x387d7e), UIColorFromRGB(0x154e59), UIColorFromRGB(0x05111d), UIColorFromRGB(0x02020c)];
            gradient.locations = @[@(0.0), @(0.14), @(0.55), @(1.0)];
            break;
        default:
            break;
    }
    
    [self.window.layer insertSublayer:gradient atIndex:0];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.halkyon.WeatherApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location didFailWithError: %@", error);
    if ([error code] == kCLErrorLocationUnknown)
        return;
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"Getting Location Error", nil)
                                message:[error localizedDescription]
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    if ([error code] == kCLErrorDenied) {
        alert.message = NSLocalizedString(@"Turn Location Service ON!", nil);
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
    }
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
    //self.lblFailedLocation.hidden = NO;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray*)locations {
    if (_currentLocation != locations.lastObject) {
        _currentLocation = locations.lastObject;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdateLocationsNotification object:_currentLocation];

}

@end
