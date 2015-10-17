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

@end

@implementation ViewController


#pragma mark - debugging methods

- (IBAction)progressChanged:(UISlider *)sender {
}

- (IBAction)animIntro:(UIButton *)sender {
    static int count = 0;

    [self.fallBehavior addItem:self.circleView];
    //TODO: make counting of bounces
    __weak ViewController *wSelf = self;
    self.fallBehavior.action = ^{
        //        NSLog(@"posX = %f posY = %f", wSelf.circleView.center.x, wSelf.circleView.center.y );
        count++;
    };
}

- (IBAction)addProgress:(UIButton *)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.fallBehavior removeItem:self.circleView];
        self.circleView.center = self.view.center;//CGPointMake(30.0,30.0);
    } completion:^(BOOL finished) {
        [self.circleView addProgressAnimation:self.progressValue.value completion:nil];
    }];
}

- (IBAction)animLoading:(UIButton *)sender {
    static int count = 0;
    [self.circleView addProgressAnimation:-50.0 completion:^(BOOL finished) {
        [self.fallBehavior addItem:self.circleView];
    }];
    __weak ViewController *wSelf = self;
        self.fallBehavior.action = ^{
//            NSLog(@"posX = %f posY = %f", wSelf.circleView.center.x, wSelf.circleView.center.y );
            count++;
        };
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


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.fallBehavior addItem:self.circleView];
    
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
