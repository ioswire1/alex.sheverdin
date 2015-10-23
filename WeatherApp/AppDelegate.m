//
//  AppDelegate.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
    
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
    self.locationManager.distanceFilter=500;
    [self.locationManager startUpdatingLocation];
    return YES;
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
