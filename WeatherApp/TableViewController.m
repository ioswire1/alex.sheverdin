//
//  TableViewController.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "OpenWeatherMap.h"

@interface TableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResults;

@end


@implementation TableViewController

- (CLLocation *)currentLocation {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
}

- (IBAction)refreshForecast:(UIRefreshControl *)sender {
    [self downloadForecast];
}

- (void) downloadForecast {
    OpenWeatherMap *weatherService = [OpenWeatherMap service];
    [weatherService getForecastForLocation:self.currentLocation completion:^(BOOL success, NSDictionary * dictionary, NSError * error) {
        [self.refreshControl endRefreshing];
        
        if (!success) {
            UILabel *faultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
            faultLabel.text = @"Can't get forecast data!";
            faultLabel.textAlignment = NSTextAlignmentCenter;
            [faultLabel sizeToFit];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;;
            self.tableView.backgroundView = faultLabel;
            self.forecast = nil;
            [self.tableView reloadData];
        } else {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;;
            self.tableView.backgroundView = nil;
            self.forecast = dictionary[@"list"];
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kDidUpdateLocationsNotification object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveNotification:(NSNotification *)notification {
    [self downloadForecast];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self downloadForecast];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.forecast count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                       reuseIdentifier:@"Cell Forecast"];
    NSDictionary *dict = self.forecast[indexPath.row];

    NSDictionary *main = [dict valueForKey:@"main"];
    NSString *temp = [NSString stringWithFormat:@"%dº", [[main valueForKey:@"temp"] intValue]];
    NSArray *weatherTmp = [dict valueForKey:@"weather"];
    NSDictionary *weather = [weatherTmp firstObject];
    NSString *clouds = [weather valueForKey:@"description"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@   -   %@", temp, clouds];
    NSRange range = NSMakeRange(0, 16);
    cell.detailTextLabel.text = [[dict valueForKey:@"dt_txt"] substringWithRange: range];
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
