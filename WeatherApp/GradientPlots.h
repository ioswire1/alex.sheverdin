//
//  GradientPlots.h
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/4/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot-CocoaTouch.h>

@interface GradientPlots : NSObject <CPTPlotDataSource>

// init the plots in the provided hosting view with the provided data
// The data array should contain array of NSValue objects each representing a CGPoint
-(id)initWithHostingView:(CPTGraphHostingView *)hostingView;

-(void)drawPlotsWithData:(NSMutableArray *)data;


@end
