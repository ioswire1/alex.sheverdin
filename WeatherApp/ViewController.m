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
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Picker.h"

static int progressMax = 50;

@interface ViewController ()
@property (strong, nonatomic) UIView *animatorView;
@property (strong, nonatomic) CircleView *circleView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) FallBehavior *behavior;
@property (strong, nonatomic) UIImage *locationImage;
@property (strong, nonatomic) UIImage *bluredImage;

@property (strong, nonatomic) id <OWMCurrentWeatherObject> currentWeather;

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
            [wSelf addBounceAnimation:1 completion:nil];
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
                [UIView animateWithDuration:0.45 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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

    double temp = [self.currentWeather.main.temp doubleValue];
    double progress = (temp + progressMax) / (2 * progressMax);

    [self.circleView addProgressAnimation:progress completion:completion];
}

- (void)loadWeather:(void (^)())completion {
    
    __weak typeof(self) wSelf = self;
    CLLocation *location = [self currentLocation];
    [[WeatherManager defaultManager] getWeatherByLocation:location success:^(OWMObject <OWMCurrentWeatherObject> *object) {
        // TODO: just for development
        NSAssert(weather, @"Weather should not be nil");
        wSelf.currentWeather = object;
        if (completion) {
            completion();
        }
        
        NSString *hundred = [[object.weather[0][@"id"] stringValue] substringWithRange:NSMakeRange(0, 1)];
        NSString *imageName = [hundred stringByAppendingString:@"00"];

        __weak typeof(wSelf) wwSelf = wSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *image = [UIImage imageNamed:imageName];
            wwSelf.locationImage = [image applyBlurWithRadius:0
                                                    tintColor:nil
                                        saturationDeltaFactor:1
                                                    maskImage:nil];
            wwSelf.bluredImage = [image applyBlurWithRadius:5
                                                  tintColor:nil
                                      saturationDeltaFactor:1
                                                  maskImage:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [wwSelf refreshBackground];
            });
        });

        
    } failure:^(NSError *error) {
        // TODO: implementation
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? 100 : 8;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    int varRand = arc4random() % 6 - 6;
    int random = (indexPath.row + varRand) - 50;
    
    UIImage *spectorImage = [UIImage imageNamed:@"color_spectrum"];
    
    float pecentage = (float)(random + 50 + 6)/ 106.f;
    CGPoint valuePosition = CGPointMake(spectorImage.size.width * pecentage, 1);
    UIColor *color = [spectorImage colorAtPosition:valuePosition];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d°", random];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%0d:00", (int)indexPath.row]];
    [attrStr addAttribute:NSKernAttributeName value:@(0.5) range:NSMakeRange(0, attrStr.length)];
    cell.textLabel.attributedText = attrStr;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.contentView.backgroundColor = [color colorWithAlphaComponent:0.25];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.view.bounds.size.height) / 10.f;
}

static bool blured;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL newValue = self.tableView.contentOffset.y > 100;
    if (blured != newValue) {
        blured = newValue;

        [[UIApplication sharedApplication] setStatusBarHidden:blured withAnimation:UIStatusBarAnimationFade];
        [self refreshBackground];
    }
    
    self.tableView.pagingEnabled = (self.tableView.contentOffset.y < self.tableView.bounds.size.height + 10);
}

- (void)refreshBackground {
    UIImage *backgroundImage = blured ? self.bluredImage : self.locationImage;
    __block UIImageView *imageView = (UIImageView *)self.tableView.backgroundView;
        [UIView transitionWithView:imageView
                          duration:0.5
                           options:(UIViewAnimationOptionShowHideTransitionViews)
                        animations:^{
                            imageView.image = backgroundImage;
                        } completion:NULL];
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
        [self addBounceAnimation:1 completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    UIImageView *backgroundView = [[UIImageView alloc] init];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = backgroundView;
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

        //if you want translucent vibrant table view separator lines
        self.tableView.separatorEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    }
    
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
