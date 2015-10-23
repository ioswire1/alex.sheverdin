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
@property (strong, nonatomic) UIView *animatorView;
@property (strong, nonatomic) CircleView *circleView;
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
        __weak typeof(self) wSelf = self;
        [self.circleView addProgressAnimation:0.0001 completion:^(BOOL finished) {
            [wSelf addBounceAnimation:2 completion:nil];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"cell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.view.bounds.size.height - 30.f) / 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Day";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableView.contentOffset.y > 0) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

#pragma mark - Location

- (CLLocation *)currentLocation {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate currentLocation];
}

#pragma mark - Getters

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

- (CircleView *)circleView {
    if (!_circleView) {
        _circleView = [[CircleView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        _circleView.backgroundColor = [UIColor clearColor];
        
        [self.animatorView addSubview:_circleView];
        _circleView.center = self.animatorView.center;
    }
    return _circleView;
}

- (UIView *)animatorView {
    if (!_animatorView) {
        _animatorView = [[UIView alloc] init];
        _animatorView.backgroundColor = [UIColor clearColor];
    }
    return _animatorView;
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

- (void)viewWillLayoutSubviews {
    if (!self.tableView.tableHeaderView) {
        self.animatorView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        self.tableView.tableHeaderView = self.animatorView;
    }
}

- (void)viewDidLayoutSubviews {
    
    if (!_circleView) {
        [self addBounceAnimation:3 completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.tableView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.tableView.backgroundView = blurEffectView;
        
        //if you want translucent vibrant table view separator lines
        self.tableView.separatorEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    }
    // Do any additional setup after loading the view.
    
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
