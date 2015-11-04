//
//  ChartsViewController.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/1/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

//@class PlotItem;

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>



@interface ChartsViewController : UIViewController

//@property (nonatomic, strong) PlotItem *detailItem;
@property (nonatomic, copy) NSString *currentThemeName;

@property (nonatomic, strong) IBOutlet UIView *hostingView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeBarButton;

-(void)themeSelectedWithName:(NSString *)themeName;

@end
