//
//  SettingsViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 12/3/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

@import CoreLocation;
#import "SettingsViewController.h"
#import "WeatherManager.h"
#import "OpenWeatherMap.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *cityNameInput;
@property (strong, nonatomic) IBOutlet UISwitch *unitSwitch;


@end

@implementation SettingsViewController

- (IBAction)tapSearch:(UIButton *)sender {
    CLGeocoder* gc = [[CLGeocoder alloc] init];
    UIAlertController *alertController = [UIAlertController
                              alertControllerWithTitle:@"Is it right city found?"
                              message:@""
                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    [gc geocodeAddressString:self.cityNameInput.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0)
        {
            CLPlacemark* mark = (CLPlacemark*)[placemarks objectAtIndex:0];
            double lat = mark.location.coordinate.latitude;
            double lng = mark.location.coordinate.longitude;
            NSString *countryCode = mark.ISOcountryCode;
            alertController.message = [NSString stringWithFormat:@"%@, %@", mark.name, mark.country];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action) {
                                               
                                           }];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           City *city = [[City alloc] initWithName:mark.name];
                                           city.countryCode = countryCode;
                                           CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                                           city.location = location;
                                           
                                           [[WeatherManager defaultManager].cities addObject:city];                                           
                                       }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}
- (IBAction)unitSwitchChanged:(UISwitch *)sender {
    NSString *units = kWeatherUnitMetric;
    if (sender.isOn) {
        units = kWeatherUnitImperial;
    }
    [[NSUserDefaults standardUserDefaults] setObject:units forKey:kUnitKey];
    [OpenWeatherMap setUnits:units];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *units = [[NSUserDefaults standardUserDefaults] stringForKey:kUnitKey];
    if ([units containsString:kWeatherUnitMetric])
        self.unitSwitch.on = NO;
    else
        self.unitSwitch.on = YES;
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
