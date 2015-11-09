//
//  GradientPlots.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/4/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "GradientPlots.h"

@interface GradientPlots ()

@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) CPTScatterPlot *maxPlot;
@property (nonatomic, strong) CPTScatterPlot *minPlot;

@end

@implementation GradientPlots

- (instancetype)initWithHostingView:(CPTGraphHostingView *)hostingView {

    self = [super init];
    if ( self != nil ) {
        self.hostingView = hostingView;
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.hostingView.hostedGraph = self.graph;
    _maxPlot = nil;
    _minPlot = nil;
    [self.graph addPlot:self.maxPlot];
    [self.graph addPlot:self.minPlot];

    for (CPTPlot *plot in self.graph.allPlots)     {
        [plot reloadData];
    }
}

- (void)redrawPlots {
    [self setup];
}

- (CPTXYGraph *)graph {
    if (!_graph) {
        CGRect frame = [self.hostingView bounds];
        _graph = [[CPTXYGraph alloc] initWithFrame:frame];
    }
    _graph.plotAreaFrame.paddingTop = 0.0f;
    _graph.plotAreaFrame.paddingRight = 0.0f;
    _graph.plotAreaFrame.paddingBottom = 0.0f;
    _graph.plotAreaFrame.paddingLeft = 0.0f;

    //TODO: Create more line (text) styles for different plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor whiteColor];
    lineStyle.lineWidth = 2.0f;
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = 14;
    textStyle.color = [CPTColor whiteColor];


    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    axisSet.zPosition = 1;

    CPTMutableLineStyle *lineStyleNoLine = [CPTMutableLineStyle lineStyle];
    lineStyleNoLine.lineWidth = 0.0f;

    axisSet.xAxis.axisLineStyle = lineStyleNoLine;
    axisSet.xAxis.majorTickLineStyle = lineStyleNoLine;
    axisSet.xAxis.minorTickLineStyle = lineStyleNoLine;
    axisSet.xAxis.labelTextStyle = textStyle;
    axisSet.xAxis.labelOffset = 0.0f;
    axisSet.xAxis.tickLabelDirection = CPTSignPositive;
    axisSet.xAxis.orthogonalPosition = @(self.minTempereature);// @(0.0);
    
//    CPTPlotRange *exclusiveRangeX = [[CPTPlotRange alloc] initWithLocationDecimal:[@(0.0) decimalValue] lengthDecimal:[@(0.1) decimalValue]];
//    axisSet.xAxis.labelExclusionRanges = @[exclusiveRangeX];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh:mm";
//    dateFormatter.locale = [NSLocale currentLocale];
//    axisSet.xAxis.labelFormatter = dateFormatter;
    
    axisSet.yAxis.axisLineStyle = lineStyleNoLine;
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.labelTextStyle = textStyle;
    axisSet.yAxis.labelOffset = 2.0f;
    axisSet.yAxis.majorIntervalLength = @(5.0f);
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.tickDirection = CPTSignPositive;
    axisSet.yAxis.tickLabelDirection = CPTSignPositive;
//    CPTPlotRange *exclusiveRangeY = [[CPTPlotRange alloc] initWithLocationDecimal:[@(-20.0) decimalValue] lengthDecimal:[@(1.0) decimalValue]];
//    axisSet.yAxis.labelExclusionRanges = @[exclusiveRangeY];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    axisSet.xAxis.labelFormatter = formatter;
    axisSet.yAxis.labelFormatter = formatter;
    
    return _graph;
}

#pragma mark - Properties

- (void)setStart:(CGFloat)start {
    _start = start;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(_start) length:@(_length)];
}

- (void)setLength:(CGFloat)length {
    _length = length;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(_start) length:@(_length)];
}

- (void)setMinTempereature:(CGFloat)minTempereature {
    _minTempereature = minTempereature;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(_minTempereature) length:@(_maxTempereature - _minTempereature)];
}

- (void)setMaxTempereature:(CGFloat)maxTempereature {
    _maxTempereature = maxTempereature;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(_minTempereature) length:@(_maxTempereature - _minTempereature)];
}

static NSString *const kMaxPlotIdentifier = @"MaxTempPlot";

- (CPTScatterPlot *)maxPlot {
    if (!_maxPlot) {
        _maxPlot = [[CPTScatterPlot alloc] init];
        _maxPlot.identifier = kMaxPlotIdentifier;
        _maxPlot.dataSource = self;
        _maxPlot.interpolation = CPTScatterPlotInterpolationCurved;
        
        CPTGradient *areaGradient =[CPTGradient gradientWithBeginningColor:[CPTColor redColor] endingColor:[CPTColor clearColor]];
        areaGradient.angle =-90.0f;
        CPTFill *areaGradientFill =[CPTFill fillWithGradient:areaGradient];
        _maxPlot.areaFill = areaGradientFill;
        _maxPlot.areaBaseValue = @(-20.0);
    }
    return _maxPlot;
}

static NSString *const kMinPlotIdentifier = @"MinTempPlot";

- (CPTScatterPlot *)minPlot {
    if (!_minPlot) {
        _minPlot = [[CPTScatterPlot alloc] init];
        _minPlot.identifier = kMinPlotIdentifier;
        _minPlot.dataSource = self;
        _minPlot.interpolation = CPTScatterPlotInterpolationCurved;
        
        CPTGradient *areaGradient =[CPTGradient gradientWithBeginningColor:[CPTColor blueColor] endingColor:[CPTColor clearColor]];
        areaGradient.angle =-90.0f;
        CPTFill *areaGradientFill =[CPTFill fillWithGradient:areaGradient];
        _minPlot.areaFill = areaGradientFill;
        _minPlot.areaBaseValue = @(-20.0);
    }
    return _minPlot;
}

#pragma mark - CPTPlotDataSource

// Delegate method that returns the number of points on the plot
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSUInteger count = [self.dataSource numberOfRecords];
    return count;
}

// Delegate method that returns a single X or Y value for a given plots.
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    CGPoint point = CGPointZero;
    
    if ([plot.identifier isEqual:kMaxPlotIdentifier]) {
        point = [self.dataSource valueForMaxTemperatureAtIndex:index];
    } else if ([plot.identifier isEqual:kMinPlotIdentifier]){
        point = [self.dataSource valueForMinTemperatureAtIndex:index];
    }
  
    
//    if (plot == self.maxPlot)
//        point = [self.dataSource valueForMaxTemperatureAtIndex:index];
//    if (plot == self.minPlot)
//        point = [self.dataSource valueForMinTemperatureAtIndex:index];
    NSLog(@"en:%lu  ind:%lu  x:%.2f, y:%.2f", (unsigned long)fieldEnum, index, point.x, point.y);
    return fieldEnum == CPTScatterPlotFieldX ? @(point.x) : @(point.y);
}

@end
