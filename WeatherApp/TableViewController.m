//
//  TableViewController.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "TableViewController.h"
#import "NSManagedObject+ActiveRecord.h"
#import "Forecast+API.h"

@interface TableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResults;


@end

@implementation TableViewController


- (void)refreshTable {
    
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.fetchedResults = [Forecast fetchAllSortedBy:@"dt_txt" ascending:YES withPredicate:nil groupBy:nil];
    self.fetchedResults.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller

   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configurateCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

- (void)configurateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Forecast *forecast = [self.fetchedResults objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%dºC", [forecast.temp intValue]];
    NSRange range = NSMakeRange(0, 16);
    cell.detailTextLabel.text = [forecast.dt_txt substringWithRange: range];
    
}



#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResults sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id  sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *cellIdentifier = @"Cell Forecast";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                               reuseIdentifier:@"Cell Forecast"];

    [self configurateCell:cell atIndexPath:indexPath];
    return cell;
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return [self.forcast count];
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
//                           reuseIdentifier:@"Cell Forecast"];
//    
//    // Set the text on the cell with the description of the item
//    // that is at the nth index of items, where n = row this cell
//    // will appear in on the tableview
//    
//    NSDictionary *dict = self.forcast[indexPath.row];
//    NSDictionary *main = [dict valueForKey:@"main"];
//    NSString *temp = [NSString stringWithFormat:@"%dº", [[main valueForKey:@"temp"] intValue]];
//    NSArray *weatherTmp = [dict valueForKey:@"weather"];
//    NSDictionary *weather = [weatherTmp firstObject];
//    NSString *clouds = [weather valueForKey:@"description"];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@   -   %@", temp, clouds];
//    NSRange range = NSMakeRange(0, 16);
//    cell.detailTextLabel.text = [[dict valueForKey:@"dt_txt"] substringWithRange: range];
//  
//    return cell;
//}


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
