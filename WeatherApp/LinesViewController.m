//
//  LinesViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/6/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "LinesViewController.h"
#import <CorePlot-CocoaTouch.h>

@interface LinesViewController ()
@property (nonatomic, weak) IBOutlet CPTGraphHostingView *chartsView;
@property (nonatomic, strong) CPTGraph *chartsGraph;
@end

@implementation LinesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CPTGraph *)chartsGraph {
    if (!_chartsGraph) {
        CGRect frame = [self.chartsView bounds];
        _chartsGraph = [[CPTXYGraph alloc] initWithFrame:frame];
        
        _chartsGraph.plotAreaFrame.paddingTop = 20.0f;
        _chartsGraph.plotAreaFrame.paddingRight = 20.0f;
        _chartsGraph.plotAreaFrame.paddingBottom = 50.0f;
        _chartsGraph.plotAreaFrame.paddingLeft = 40.0f;
        [_chartsGraph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
        
        self.chartsView.hostedGraph = _chartsGraph;
    }
    
    return _chartsGraph;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
