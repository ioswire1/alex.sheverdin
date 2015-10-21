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
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet CircleView *circleView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) FallBehavior *fallBehavior;
@property (weak, nonatomic) IBOutlet UISlider *progressValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;
@property (strong, nonatomic) NSDictionary * lastWeather;

@property (weak, nonatomic) IBOutlet UILabel *lblFailedLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblFailedConnection;

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
    self.lastWeather = nil;
    [self.circleView addProgressAnimation:-50.0 completion:^(BOOL finished) {
        [self addLoadAnimationWithBounceCount:3];
    }];
    [self downloadWeatherWithProgress:NO];
}

#pragma mark - Location

- (CLLocation *)currentLocation {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
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
        
        UIEdgeInsets inset;
        inset.left = 20.0;
        inset.top = 10.0;
        inset.bottom = self.view.bounds.size.height / 2 - self.circleView.radius * 2;
        inset.right = 20.0;
        self.fallBehavior.collisionInset = inset;
    }
    return _fallBehavior;
}

- (void) addLoadAnimationWithBounceCount:(int) bounceCount {
    [self.fallBehavior addItem:self.circleView];
    __block int count = 0;
    __weak ViewController *wSelf = self;
    [self.fallBehavior setBounceAction:^(id<UIDynamicItem> item) {
        if (item == wSelf.circleView) {
            count ++;
            if ((count >= bounceCount) && (wSelf.lastWeather)) {
                [wSelf.fallBehavior removeItem:wSelf.circleView];
                [UIView animateWithDuration:0.45 animations:^{
                    wSelf.circleView.center = wSelf.view.center;
                } completion:^(BOOL finished) {
                 
                    if (wSelf.lastWeather) {
                        NSDictionary *main = wSelf.lastWeather[@"main"];
                        //self.temperature =  main[@"temp"];
                        [wSelf.circleView addProgressAnimation:[main[@"temp"] doubleValue] completion:nil];
                    }
//                    NSDictionary *main = dictionary[@"main"];
//                    self.temperature =  main[@"temp"];
//                    [wSelf.circleView addProgressAnimation:[wSelf.temperature doubleValue] completion:nil];
                }];
                count = 0;
            }
        }
    }];
}

#pragma mark - Getting Weather Data

- (void) downloadWeatherWithProgress:(BOOL) isProgress {
   
    OpenWeatherMap *weatherService = [OpenWeatherMap service];
    __weak ViewController *wSelf = self;
    [weatherService getWeatherForLocation:self.currentLocation.coordinate completion:^(NSDictionary * dictionary, NSError * error) {
        if (error) {
            wSelf.lblFailedConnection.hidden = NO;
        } else {
            NSDictionary *main = dictionary[@"main"];
            wSelf.lblTemperature.text = [NSString stringWithFormat:@"%@",main[@"temp"]];
            NSLog(@"temp = %@", main[@"temp"]);
            wSelf.lastWeather = dictionary;
            wSelf.lblFailedConnection.hidden = YES;
            if (isProgress) {
                [wSelf.circleView addProgressAnimation:[main[@"temp"] doubleValue] completion:nil];
            }
        }
    }];
}


#pragma mark - Notifications

- (void)appDidBecomeActive {
   //[self downloadWeatherWithProgress:YES];
    ;
}

- (void)didReceiveUpdateLocationsNotification:(NSNotification *)notification {
    if ([notification.object integerValue] == 1) {
        [self downloadWeatherWithProgress:NO];
    } else {
        [self downloadWeatherWithProgress:YES];
            }
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateLocationsNotification:) name:kDidUpdateLocationsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
