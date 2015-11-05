//
//  GradientPlots.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/4/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "GradientPlots.h"

@interface GradientPlots ()

@property (nonatomic, retain) NSMutableArray *graphData;

@end

@implementation GradientPlots


-(id)initWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data {
    
    self = [super init];
    if ( self != nil ) {
        self.hostingView = hostingView;
        self.graphData = data;
        self.graph = nil;
    }
    return self;
}

-(void)initialisePlots {

    if ( (self.hostingView == nil) || (self.graphData == nil) ) {
        NSLog(@"Cannot initialise plots without hosting view or data.");
        return;
    }
    if ( self.graph != nil ) {
        NSLog(@"Graph object already exists"); //no need?
        return;
    }
    CGRect frame = [self.hostingView bounds];
    self.graph = [[CPTXYGraph alloc] initWithFrame:frame];
    
    self.graph.plotAreaFrame.paddingTop = 20.0f;
    self.graph.plotAreaFrame.paddingRight = 20.0f;
    self.graph.plotAreaFrame.paddingBottom = 50.0f;
    self.graph.plotAreaFrame.paddingLeft = 40.0f;
    //self.graph.backgroundColor = [UIColor blueColor].CGColor;
    
    self.hostingView.hostedGraph = self.graph;
    

    //[self.graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    //TODO: Create more line (text) styles for different plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor whiteColor];
    lineStyle.lineWidth = 2.0f;
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = 14;
    textStyle.color = [CPTColor whiteColor];
    
//    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol snowPlotSymbol];
//    plotSymbol.lineStyle = lineStyle;
//    plotSymbol.size = CGSizeMake(8.0, 8.0);
    
    NSUInteger xScaleMax = ([self.graphData count] - 1) * 3;
    float xAxisMin = 0;
    float xAxisMax = (float) xScaleMax;
    //TODO: implement scale from real min/max
    float yAxisMin = -20;
    float yAxisMax = 20;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(xAxisMin) length:@(xAxisMax - xAxisMin)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(yAxisMin) length:@(yAxisMax - yAxisMin)];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    
    axisSet.xAxis.title = @"Time, h";
    axisSet.xAxis.titleTextStyle = textStyle;
    axisSet.xAxis.titleOffset = 30.0f;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.labelTextStyle = textStyle;
    axisSet.xAxis.labelOffset = 3.0f;
    axisSet.xAxis.majorIntervalLength = @(3.0f);
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.orthogonalPosition = @(-20.0);
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh:mm";
//    dateFormatter.locale = [NSLocale currentLocale];
//    axisSet.xAxis.labelFormatter = dateFormatter;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    axisSet.xAxis.labelFormatter = formatter;
    
    axisSet.yAxis.title = @"Temperature, Cº";
    axisSet.yAxis.titleTextStyle = textStyle;
    axisSet.yAxis.titleOffset = 23.0f;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.labelTextStyle = textStyle;
    axisSet.yAxis.labelOffset = 3.0f;
    axisSet.yAxis.majorIntervalLength = @(5.0f);
    axisSet.yAxis.minorTicksPerInterval = 5;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelFormatter = formatter;
    
    //axisSet.yAxis.alternatingBandFills = [NSArray arrayWithObjects:[CPTColor blueColor], [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor redColor], nil];
    
    CPTScatterPlot *plot1 = [[CPTScatterPlot alloc] init];
    plot1.identifier = @"plot1";
    plot1.dataSource = self;
//    plot1.dataLineStyle = lineStyle;
//    plot1.plotSymbol = plotSymbol;
    plot1.interpolation = CPTScatterPlotInterpolationCurved;
    
    CPTGradient *areaGradient =[CPTGradient gradientWithBeginningColor:[CPTColor redColor] endingColor:[CPTColor clearColor]];
    // test of something like color array gradient
//    areaGradient = [areaGradient addColorStop:[CPTColor orangeColor] atPosition:0.4];
//    areaGradient = [areaGradient addColorStop:[CPTColor yellowColor] atPosition:0.6];
    areaGradient.angle =-90.0f;
    CPTFill *areaGradientFill =[CPTFill fillWithGradient:areaGradient];
    plot1.areaFill = areaGradientFill;
    plot1.areaBaseValue = @(-20.0);
    
    CPTScatterPlot *plot2 = [[CPTScatterPlot alloc] init];
    plot2.identifier = @"plot2";
    plot2.dataSource = self;
//    plot2.dataLineStyle = lineStyle;
//    plot2.plotSymbol = plotSymbol;
    plot2.interpolation = CPTScatterPlotInterpolationCurved;
    
    CPTGradient *areaGradient2 =[CPTGradient gradientWithBeginningColor:[CPTColor blueColor] endingColor:[CPTColor clearColor]];
    areaGradient2.angle =-90.0f;
    CPTFill *areaGradientFill2 =[CPTFill fillWithGradient:areaGradient2];
    plot2.areaFill = areaGradientFill2;
    plot2.areaBaseValue = @(-20.0);
  
    [self.graph addPlot:plot1];
    [self.graph addPlot:plot2];
}

// Delegate method that returns the number of points on the plot
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ( [plot.identifier isEqual:@"plot1"] || [plot.identifier isEqual:@"plot2"]) {
        return [self.graphData count];
    }
    return 0;
}

// Delegate method that returns a single X or Y value for a given plots.
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    int plotIndex = 0;
    if ([plot.identifier isEqual:@"plot1"]) {
        plotIndex = 0;
    } else if ([plot.identifier isEqual:@"plot2"]){
        plotIndex = 1;
    } else
        return [NSNumber numberWithFloat:0];
        
    NSArray *array = [self.graphData objectAtIndex:index];
    CGPoint point = [array[plotIndex] CGPointValue];
    
    // FieldEnum determines if we return an X or Y value.
    if ( fieldEnum == CPTScatterPlotFieldX )     {
        return [NSNumber numberWithFloat:point.x * 3.0];
    }
    else { // Y-Axis
        return [NSNumber numberWithFloat:point.y];
    }
}

@end
