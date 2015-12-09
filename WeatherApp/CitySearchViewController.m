//
//  CitySearchViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 12/5/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

@import CoreLocation;
#import "CitySearchViewController.h"
#import "WeatherManager.h"

@interface CitySearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *cityNameInput;
@property (strong, nonatomic) NSMutableArray *cities;

@end

@implementation CitySearchViewController

- (NSMutableArray *)cities {
    if (!_cities) {
        _cities = [[NSMutableArray alloc] init];
    }
    return _cities;
}

- (IBAction)cityInputTextChanged:(UITextField *)sender {
    CLGeocoder* gc = [[CLGeocoder alloc] init];
    [gc geocodeAddressString:self.cityNameInput.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            self.cities = [placemarks mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.view.backgroundColor = [UIColor clearColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
 
    CLPlacemark *mark = self.cities[indexPath.row];
    Place *city = [[Place alloc] initWithName:mark.name];
    city.countryCode = mark.ISOcountryCode;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:mark.location.coordinate.latitude longitude:mark.location.coordinate.longitude];
    city.location = location;
    
    [[WeatherManager defaultManager].places addObject:city];
    [self.tableView reloadData];
    NSLog(@"%@", [NSString stringWithFormat:@"%@, %@, %f, %f", mark.name, mark.country, mark.location.coordinate.latitude, mark.location.coordinate.longitude]);
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [self.cities count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityFoundCell" forIndexPath:indexPath];
    CLPlacemark* mark = (CLPlacemark *)self.cities[indexPath.row];
    cell.textLabel.text = mark.name;
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %f, %f", mark.name, mark.country, mark.location.coordinate.latitude, mark.location.coordinate.longitude];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
