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
    [self.graph addPlot:self.maxPlot];
    [self.graph addPlot:self.minPlot];
}

- (CPTXYGraph *)graph {
    if (!_graph) {
        CGRect frame = [self.hostingView bounds];
        self.graph = [[CPTXYGraph alloc] initWithFrame:frame];
        
        self.graph.plotAreaFrame.paddingTop = 20.0f;
        self.graph.plotAreaFrame.paddingRight = 20.0f;
        self.graph.plotAreaFrame.paddingBottom = 50.0f;
        self.graph.plotAreaFrame.paddingLeft = 40.0f;
        //self.graph.backgroundColor = [UIColor blueColor].CGColor;
        
        
        [self.graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
        
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
        
    //    float xmax = - MAXFLOAT;
    //    float xmin = MAXFLOAT;
    //    for (NSNumber *num in numbers) {
    //        for (int i=0; i<[self.graphData count]; i++) {
    //            float x = [self.graphData objectAtIndex:index].floatValue;
    //            if (x < xmin) xmin = x;
    //            if (x > xmax) xmax = x;
    //        }
    //        float x = num.floatValue;
    //        if (x < xmin) xmin = x;
    //        if (x > xmax) xmax = x;
    //    }
        

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

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm";
        dateFormatter.locale = [NSLocale currentLocale];
        axisSet.xAxis.labelFormatter = dateFormatter;
        
        
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
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        axisSet.xAxis.labelFormatter = formatter;

        axisSet.yAxis.labelFormatter = formatter;
        
        //axisSet.yAxis.alternatingBandFills = [NSArray arrayWithObjects:[CPTColor blueColor], [CPTColor yellowColor], [CPTColor orangeColor], [CPTColor redColor], nil];
            
    }
    return _graph;
}

#pragma mark - Properties

- (void)setStart:(CGFloat)start {
    _start = start;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(_start) length:@(_length)];
}

- (void)setLength:(CGFloat)length {
    _length = length;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(_start) length:@(_length)];
}

- (void)setMinTempereature:(CGFloat)minTempereature {
    _minTempereature = minTempereature;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(_minTempereature) length:@(_maxTempereature - _minTempereature)];
}

- (void)setMaxTempereature:(CGFloat)maxTempereature {
    _maxTempereature = maxTempereature;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(_minTempereature) length:@(_maxTempereature - _minTempereature)];
}

static NSString *const kMaxPlotIdentifier = @"MaxTempPlot";

- (CPTScatterPlot *)maxPlot {
    if (!_maxPlot) {
        _maxPlot = [[CPTScatterPlot alloc] init];
        _maxPlot.identifier = kMaxPlotIdentifier;
        _maxPlot.dataSource = self;
        //    plot1.dataLineStyle = lineStyle;
        //    plot1.plotSymbol = plotSymbol;
        _maxPlot.interpolation = CPTScatterPlotInterpolationCurved;
        
        CPTGradient *areaGradient =[CPTGradient gradientWithBeginningColor:[CPTColor redColor] endingColor:[CPTColor clearColor]];
        // test of something like color array gradient
        //    areaGradient = [areaGradient addColorStop:[CPTColor orangeColor] atPosition:0.4];
        //    areaGradient = [areaGradient addColorStop:[CPTColor yellowColor] atPosition:0.6];
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
        //    plot1.dataLineStyle = lineStyle;
        //    plot1.plotSymbol = plotSymbol;
        _minPlot.interpolation = CPTScatterPlotInterpolationCurved;
        
        CPTGradient *areaGradient =[CPTGradient gradientWithBeginningColor:[CPTColor redColor] endingColor:[CPTColor clearColor]];
        // test of something like color array gradient
        //    areaGradient = [areaGradient addColorStop:[CPTColor orangeColor] atPosition:0.4];
        //    areaGradient = [areaGradient addColorStop:[CPTColor yellowColor] atPosition:0.6];
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
    return [self.dataSource numberOfRecords];
}

// Delegate method that returns a single X or Y value for a given plots.
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    CGPoint point = CGPointZero;
    
    if (plot == self.maxPlot) point = [self.dataSource valueForMaxTemperatureAtIndex:index];
    if (plot == self.minPlot) point = [self.dataSource valueForMinTemperatureAtIndex:index];
    
    return fieldEnum == CPTScatterPlotFieldX ? @(point.x) : @(point.y);
}

@end
