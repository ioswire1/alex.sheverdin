//
//  WeatherViewController.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/1/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

//@class PlotItem;

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface WeatherViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *indexLabel;
@property (nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) UINavigationItem *pageNavigationItem;

@end
