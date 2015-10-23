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

static int progressMax = 50;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *animatorView;
@property (weak, nonatomic) IBOutlet CircleView *circleView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) FallBehavior *fallBehavior;

@property (strong, nonatomic) NSDictionary * lastWeather;
@property (strong, nonatomic) NSDictionary * previousWeather;

//test properties
@property (weak, nonatomic) IBOutlet UISlider *progressValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTemperature;
@property (weak, nonatomic) IBOutlet UILabel *lblFailedLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblFailedConnection;

- (void)loadWeather:(void (^)(NSDictionary *))completion;
- (void)addProgressAnimation:(void (^)(BOOL finished))completion;
- (void)addBounceAnimation:(NSUInteger)repeatCount completion:(void (^)(BOOL finished))completion;

@end

@implementation ViewController

- (IBAction)addLoading:(UIButton *)sender {
    if (!self.fallBehavior.isActive) {
        self.lastWeather = nil;
        [self.circleView addProgressAnimation:0.0001 completion:^(BOOL finished) {
            [self addBounceAnimation:2 completion:nil];
        }];
    }
}

- (void)addBounceAnimation:(NSUInteger)repeatCount completion:(void (^)(BOOL finished))completion {
    [self.fallBehavior addItem:self.circleView];
    
    __weak typeof(self) wSelf = self;
    __block NSUInteger bounceCount = 0;
    [self.fallBehavior setBounceAction:^(id<UIDynamicItem> item) {
        if (item == wSelf.circleView) {
            
            bounceCount++;

            if (bounceCount == 1) {
                [wSelf loadWeather:nil];
            }
            
            if (bounceCount >= repeatCount && wSelf.lastWeather) {
                [wSelf.fallBehavior removeItem:wSelf.circleView];
                [UIView animateWithDuration:0.25 animations:^{
                    wSelf.circleView.center = wSelf.animatorView.center;
                } completion:^(BOOL finished) {
                    [wSelf addProgressAnimation:completion];
                }];
            }
        }
    }];
}

- (void)addProgressAnimation:(void (^)(BOOL finished))completion {
    if ([self.fallBehavior.items containsObject:self.circleView]) {
        [self.fallBehavior removeItem:self.circleView];
    }
    NSDictionary *main = self.lastWeather[@"main"];
    double temp = [main[@"temp"] doubleValue];
//    temp = self.progressValue.value;
    double progress = (temp + progressMax) / (2 * progressMax);
    self.lblTemperature.text = [NSString stringWithFormat:@"%.f", temp];
    [self.circleView addProgressAnimation:progress completion:completion];
}

- (void)loadWeather:(void (^)(NSDictionary *))completion {
    
    __weak typeof(self) wSelf = self;
    [[OpenWeatherMap service] getWeatherForLocation:[self currentLocation].coordinate completion:^(NSDictionary *dictionary, NSError *error) {
        if (error) {
            // notify user about this error
        }
        
        if (!dictionary) {
//            dictionary = previousWeather;
        }
        
        wSelf.lastWeather = dictionary;
        if (completion) completion(dictionary);
    }];
}

#pragma mark - Location

- (CLLocation *)currentLocation {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
}

#pragma mark - Fall Animation

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.animatorView];
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

#pragma mark - Notifications

- (void)appDidBecomeActive {

}

- (void)locationDidChange:(NSNotification *)notification {
    if (!self.fallBehavior.isActive) {
        if (notification.object) {
            __weak typeof(self) wSelf = self;
            [self loadWeather:^(NSDictionary *weather) {
                [wSelf addProgressAnimation:nil];
            }];
        }
    }
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kDidUpdateLocationsNotification object:nil];
    
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
    [self addBounceAnimation:3 completion:nil];
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
