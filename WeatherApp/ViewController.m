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
#import "WeatherManager.h"
#import "AppDelegate.h"

static int progressMax = 50;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *animatorView;
@property (weak, nonatomic) IBOutlet CircleView *circleView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) FallBehavior *behavior;

@property (strong, nonatomic) Weather *currentWeather;

- (void)loadWeather:(void (^)())completion;
- (void)addProgressAnimation:(void (^)(BOOL finished))completion;
- (void)addBounceAnimation:(NSUInteger)repeatCount completion:(void (^)(BOOL finished))completion;

@end

@implementation ViewController

- (IBAction)addLoading:(UIButton *)sender {
    if (!self.behavior.isActive) {
        self.currentWeather = nil;
        [self.circleView addProgressAnimation:0.0001 completion:^(BOOL finished) {
            [self addBounceAnimation:2 completion:nil];
        }];
    }
}

- (void)addBounceAnimation:(NSUInteger)repeatCount completion:(void (^)(BOOL finished))completion {
    [self.behavior addItem:self.circleView];
    
    __weak typeof(self) wSelf = self;
    __block NSUInteger bounceCount = 0;
    [self.behavior setBounceAction:^(id<UIDynamicItem> item) {
        if (item == wSelf.circleView) {
            
            bounceCount++;

            if (bounceCount == 1) {
                [wSelf loadWeather:nil];
            }
            
            if (bounceCount >= repeatCount && wSelf.currentWeather) {
                [wSelf.behavior removeItem:wSelf.circleView];
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
    if ([self.behavior.items containsObject:self.circleView]) {
        [self.behavior removeItem:self.circleView];
    }

    double temp = [self.currentWeather.temp doubleValue];
    double progress = (temp + progressMax) / (2 * progressMax);

    [self.circleView addProgressAnimation:progress completion:completion];
}

- (void)loadWeather:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    [[WeatherManager defaultManager] getWeatherByLocation:[self currentLocation] success:^(Weather *weather) {
        // TODO: just for development
        NSAssert(weather, @"Weather should not be nil");
        wSelf.currentWeather = weather;
        if (completion) {
            completion();
        }
    } failure:^(NSError *error) {
        // TODO: implementation
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
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

- (FallBehavior *)behavior {
    if (!_behavior) {
        _behavior = [[FallBehavior alloc] init];
        [self.animator addBehavior:_behavior];
    }
    return _behavior;
}

#pragma mark - Notifications

- (void)appDidBecomeActive {

}

- (void)locationDidChange:(NSNotification *)notification {
    if (!self.behavior.isActive) {
        if (notification.object) {
            __weak typeof(self) wSelf = self;
            [self loadWeather:^{
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
