//
//  SettingsViewController.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 12/3/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CityDidSelect)(NSUInteger);

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) CityDidSelect cityDidSelect;

@end
