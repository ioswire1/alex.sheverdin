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

#import "SwitchTableViewCell.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *cityNameInput;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

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
                                           Place *city = [[Place alloc] initWithName:mark.name];
                                           city.countryCode = countryCode;
                                           CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                                           city.location = location;
                                           
                                           [[WeatherManager defaultManager].places addObject:city];
                                           [self.tableView reloadData];
                                       }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return [[WeatherManager defaultManager].places count];
    } else
        return 1;
    
}

- (void) switchChanged:(UISwitch *) sender {
    NSString *units = kWeatherUnitMetric;
    if (sender.isOn) {
        units = kWeatherUnitImperial;
    }
    [[NSUserDefaults standardUserDefaults] setObject:units forKey:kUnitKey];
    [OpenWeatherMap setUnits:units];
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     static NSString * const reuseCityIdentifier = @"City Cell";
     static NSString * const reuseSwitchIdentifier = @"Switch Cell";
     
     UITableViewCell *cell;
     
     if (indexPath.section == 0) {
         cell = [tableView dequeueReusableCellWithIdentifier:reuseSwitchIdentifier];
         cell.textLabel.text = @"metric (ºC) / imperial (ºF)";
         UISwitch *switcher = [(SwitchTableViewCell *)cell switchUnits];
         NSString *units = [[NSUserDefaults standardUserDefaults] stringForKey:kUnitKey];
         if ([units containsString:kWeatherUnitMetric])
             switcher.on = NO;
         else
             switcher.on = YES;;
         [switcher addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
         [cell.contentView bringSubviewToFront:switcher];
     } else {
     
         cell = [tableView dequeueReusableCellWithIdentifier:reuseCityIdentifier];
         if (indexPath.section == 1) {
             cell.textLabel.text = [WeatherManager defaultManager].places[indexPath.row].name;
             cell.accessoryType = UITableViewCellAccessoryNone;
         } else if (indexPath.section == 2) {
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
             cell.textLabel.text = @"Add new city...";
         }
     }

     return cell;
 }


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.section == 1) {
        if (self.cityDidSelect) {
            self.cityDidSelect(indexPath.row);
            self.cityDidSelect = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } 
 }


#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
