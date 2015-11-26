//
//  GradientPlots.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/4/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot-CocoaTouch.h>

@protocol GradientPlotsDataSource <NSObject>

- (NSUInteger)numberOfRecords;
- (CGPoint)valueForMaxTemperatureAtIndex:(NSUInteger)index;
- (CGPoint)valueForMinTemperatureAtIndex:(NSUInteger)index;

@end

@interface GradientPlots : NSObject <CPTPlotDataSource>

@property (nonatomic) CGFloat start; // timestamp
@property (nonatomic) CGFloat length; // timestamp difference

@property (nonatomic) CGFloat minTempereature;
@property (nonatomic) CGFloat maxTempereature;

@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostingView;
@property (weak, nonatomic) IBOutlet id <GradientPlotsDataSource> dataSource;

// init the plots in the provided hosting view with the provided data
// The data array should contain array of NSValue objects each representing a CGPoint
- (instancetype)initWithHostingView:(CPTGraphHostingView *)hostingView;
- (void) redrawPlots;

@end
