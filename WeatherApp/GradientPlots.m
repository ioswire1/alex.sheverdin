//
//  GradientPlots.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/4/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "GradientPlots.h"

#define CGColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0].CGColor

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

static double const invisibleStartLengthX = 14.0;
static double const invisibleEndLengthX = 9.0;
- (CPTXYGraph *)graph {
    if (!_graph) {
        CGRect frame = [self.hostingView bounds];
        _graph = [[CPTXYGraph alloc] initWithFrame:frame];
    }
    _graph.paddingTop = 0.0f;
    _graph.paddingRight = 0.0f;
    _graph.paddingBottom = 0.0f;
    _graph.paddingLeft = 0.0f;
   
    _graph.plotAreaFrame.paddingTop = 0.0f;
    _graph.plotAreaFrame.paddingRight = 0.0f;
    _graph.plotAreaFrame.paddingBottom = 0.0f;
    _graph.plotAreaFrame.paddingLeft = 0.0f;

    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor whiteColor];
    lineStyle.lineWidth = 1.0f;
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = 11;
    textStyle.color = [CPTColor whiteColor];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    axisSet.zPosition = 1;

    axisSet.xAxis.axisLineStyle = nil;
    axisSet.xAxis.majorTickLineStyle = nil;
    axisSet.xAxis.minorTickLineStyle = nil;
    
    NSTimeInterval threeHour = 8*4* 3 * 60 * 60;
    axisSet.xAxis.majorIntervalLength = @(threeHour);
    axisSet.xAxis.labelTextStyle = textStyle;
    axisSet.xAxis.labelOffset = -2.0f;
    axisSet.xAxis.tickLabelDirection = CPTSignPositive;
    axisSet.xAxis.orthogonalPosition = @(self.minTempereature);
    
    CPTPlotRange *exclusiveRangeX = [[CPTPlotRange alloc] initWithLocation:@(self.start) length:@(100)];
    axisSet.xAxis.labelExclusionRanges = @[exclusiveRangeX];


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
//    dateFormatter.dateFormat = @"H:mm";
    dateFormatter.dateFormat = @"dd/MM";
    dateFormatter.locale = [NSLocale currentLocale];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
//    NSDate *refDate = [NSDate dateWithTimeIntervalSince1970:self.start];
//    timeFormatter.referenceDate = refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;

    axisSet.yAxis.axisLineStyle = nil;
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.labelTextStyle = textStyle;
    axisSet.yAxis.labelOffset = 2.0f;
    axisSet.yAxis.majorIntervalLength = @(20.0f);
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.minorTickLength = 3.0f;
    axisSet.yAxis.majorTickLength = 5.0f;
    axisSet.yAxis.tickDirection = CPTSignPositive;
    axisSet.yAxis.tickLabelDirection = CPTSignPositive;
    axisSet.yAxis.orthogonalPosition = @(self.start + 600);// @(0.0);
    
    CPTPlotRange *exclusiveRangeYstart = [[CPTPlotRange alloc] initWithLocation:@(self.minTempereature) length:@(invisibleStartLengthX)];
    CPTPlotRange *exclusiveRangeYend = [[CPTPlotRange alloc] initWithLocation:@(self.maxTempereature - invisibleEndLengthX) length:@(invisibleEndLengthX)];
    axisSet.yAxis.labelExclusionRanges = @[exclusiveRangeYstart, exclusiveRangeYend];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setPositivePrefix:@"+"];
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
        CPTMutableLineStyle *lineStyleNoLine = [CPTMutableLineStyle lineStyle];
        lineStyleNoLine.lineWidth = 0.0f;
        _maxPlot.dataLineStyle = nil;
        
        CPTGradient *areaGradient =[CPTGradient gradientWithBeginningColor:[CPTColor colorWithCGColor:CGColorFromRGB(0xFF050A)] endingColor:[CPTColor clearColor]];
        areaGradient.angle = - 90.0f;
        CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
        _maxPlot.areaFill = areaGradientFill;
        _maxPlot.areaBaseValue = @(self.minTempereature);
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
        _minPlot.dataLineStyle = nil;
        
        CPTGradient *areaGradient =[CPTGradient gradientWithBeginningColor:[CPTColor colorWithCGColor:CGColorFromRGB(0x03A2FB)] endingColor:[CPTColor colorWithCGColor:CGColorFromRGB(0x64BFFB)]];
        areaGradient.angle = - 90.0f;
        CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
        _minPlot.areaFill = areaGradientFill;
        _minPlot.areaBaseValue = @(self.minTempereature);
//TODO: REMOVE - it's for debugging
//        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol snowPlotSymbol];
//        plotSymbol.size = CGSizeMake(8.0, 8.0);
//        _maxPlot.plotSymbol = plotSymbol;

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
   
    if (plot == self.maxPlot)
        point = [self.dataSource valueForMaxTemperatureAtIndex:index];
    if (plot == self.minPlot)
        point = [self.dataSource valueForMinTemperatureAtIndex:index];
//    NSLog(@"en:%lu  ind:%lu  x:%.2f, y:%.2f", (unsigned long)fieldEnum, index, point.x, point.y);
    return fieldEnum == CPTScatterPlotFieldX ? @(point.x) : @(point.y);
}

@end
