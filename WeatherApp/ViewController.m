//
//  ViewController.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 10/16/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "ViewController.h"
#import "CircleView.h"
#import "FallBehavior.h"
#import "OpenWeatherMap.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet CircleView *circleView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) FallBehavior *fallBehavior;
@property (weak, nonatomic) IBOutlet UISlider *progressValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;
@property (strong, nonatomic) NSNumber *temperature;

@end

@implementation ViewController


#pragma mark - debugging methods

- (IBAction)addProgress:(UIButton *)sender {
    __weak ViewController *wSelf = self;
    [UIView animateWithDuration:0.85 animations:^{
        [wSelf.fallBehavior removeItem:wSelf.circleView];
        wSelf.circleView.center = wSelf.view.center;
    } completion:^(BOOL finished) {
        [wSelf.circleView addProgressAnimation:wSelf.progressValue.value completion:nil];
    }];
}

- (IBAction)addLoading:(UIButton *)sender {
    [self.circleView addProgressAnimation:-50.0 completion:^(BOOL finished) {
        [self addLoadAnimationWithBounceCount:3];
    }];
    [self downloadWeather];
}


#pragma mark - Fall Animation

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    return _animator;
}

- (FallBehavior *)fallBehavior {
    if (!_fallBehavior) {
        _fallBehavior = [[FallBehavior alloc] init];
        [self.animator addBehavior:_fallBehavior];
    }
    return _fallBehavior;
}

- (void) addLoadAnimationWithBounceCount:(int) bounceCount {
    [self.fallBehavior addItem:self.circleView];
    __weak ViewController *wSelf = self;
    self.fallBehavior.action = ^{
        static int count = 0;
        static CGFloat xPrev = 0, xPrevDelta = 0;
        CGFloat xCurrentDelta = wSelf.circleView.center.y - xPrev;
        //NSLog(@"curY = %.1f prevY = %.1f xCurrentDelta = %.1f xPrevDelta = %.1f", wSelf.circleView.center.y, xPrev, xCurrentDelta, xPrevDelta );
        if ((xCurrentDelta < 0) && (xPrevDelta >= 0)) {
            count++;
            //NSLog(@"Direction changed!");
        }
        if (count >= bounceCount) {
            
            [UIView animateWithDuration:0.45 animations:^{
                [wSelf.fallBehavior removeItem:wSelf.circleView];
                wSelf.circleView.center = wSelf.view.center;//CGPointMake(30.0,30.0);
            } completion:^(BOOL finished) {
//                [wSelf.circleView addProgressAnimation:wSelf.progressValue.value completion:nil];
                [wSelf.circleView addProgressAnimation:[wSelf.temperature doubleValue] completion:nil];
            }];
            count = 0;
            xPrev = xPrevDelta = 0.0;
        } else {
            xPrev = wSelf.circleView.center.y;
            xPrevDelta = xCurrentDelta;
        }
    };
}

#pragma mark - Getting Weather Data

- (void) downloadWeather {
//    if ((0 == [self currentLocation].coordinate.latitude) && (0 == [self currentLocation].coordinate.longitude)) {
//        self.lblFailedLocation.hidden = NO;
//        return;
//    } else {
//        self.lblFailedLocation.hidden = YES;
//    }
    
    OpenWeatherMap *weatherService = [OpenWeatherMap service];
    
    [weatherService getWeatherForCityName:@"kharkov" completion:^(NSDictionary * dictionary, NSError * error) {
        NSDictionary *main = dictionary[@"main"];
        self.temperature =  main[@"temp"];
        self.lblTemperature.text = [NSString stringWithFormat:@"%@",self.temperature];
        NSLog(@"temp = %@", self.temperature);
//    [weatherService getWeatherForLocation:self.currentLocation.coordinate completion:^(NSDictionary * dictionary, NSError * error) {

//        if (error) {
//            self.lblFailedConnection.hidden = NO;
//        } else {
//            Weather *weather = [Weather weatherWithDictionary:dictionary inContext:[self managedObjectContext]];
//            self.lblFailedConnection.hidden = YES;
//            [self showWeather:weather];
//            if (![[self managedObjectContext] save:&error]) {
//                //NSLog(@"%@", error);
//            }
//        }
    }];
}


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self downloadWeather];
    [self addLoadAnimationWithBounceCount:5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
