//
//  WChangeViewController.m
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "WChangeViewController.h"
#import "ViewController.h"
#import "WNavScrollView.h"

static const NSInteger kTestCount = 8;
#define  kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface WChangeViewController () <WNavScrollViewDataSource,WNavScrollViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) WNavScrollView *navScrollView;
@property (nonatomic,strong) UIScrollView   *controllerView;

@end

@implementation WChangeViewController

+ (void)load {
    WChangeViewController *controller = [[WChangeViewController alloc] init];
    [ViewController registerWithTitle:@"change" handler:^UIViewController *{
        return controller;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view addSubview:self.navScrollView];
    [self.navScrollView reloadData];
    [self.view addSubview:self.controllerView];
    [self addContentView];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.view addGestureRecognizer:pan];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithTitle:@"refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = rightBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
//    [self exchangeView];
//    [self exchangeSubView];
    UIView* view = self.view;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // 获取手势的触摸点坐标
        CGPoint location = [recognizer locationInView:view];
        // 判断,用户从右半边滑动的时候,推出下一个VC(根据实际需要是推进还是推出)
        if (location.x > CGRectGetMidX(view.bounds) && self.navigationController.viewControllers.count == 1){
//            self.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
            //
//            [self presentViewController:_nextVC animated:YES completion:nil];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // 获取手势在视图上偏移的坐标
        CGPoint translation = [recognizer translationInView:view];
        // 根据手指拖动的距离计算一个百分比，切换的动画效果也随着这个百分比来走
        CGFloat distance = fabs(translation.x / CGRectGetWidth(view.bounds));
        // 交互控制器控制动画的进度
//        [self.interactionController updateInteractiveTransition:distance];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [recognizer translationInView:view];
        // 根据手指拖动的距离计算一个百分比，切换的动画效果也随着这个百分比来走
        CGFloat distance = fabs(translation.x / CGRectGetWidth(view.bounds));
        // 移动超过一半就强制完成
        if (distance > 0.5) {
//            [self.interactionController finishInteractiveTransition];
        } else {
//            [self.interactionController cancelInteractiveTransition];
        }
        // 结束后一定要置为nil
//        self.interactionController = nil;
    }
}

- (void)exchangeView {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.view.backgroundColor = [UIColor blueColor];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)exchangeSubView {
    __weak typeof(self) weakSelf = self;
    UIView *snapView = [self.view snapshotViewAfterScreenUpdates:YES];
    [UIView transitionFromView:snapView toView:weakSelf.view duration:1. options:UIViewAnimationOptionCurveLinear completion:^(BOOL finished) {
        weakSelf.view.backgroundColor = [UIColor redColor];
    }];
}

- (void)addContentView {
    
    NSInteger count = kTestCount;
    for (NSInteger i = 0; i < count; i++) {
        UIView *view = [[UIView alloc] init];
        if (i % 2) {
            view.backgroundColor = [UIColor greenColor];
        } else {
            view.backgroundColor = [UIColor cyanColor];
        }
        view.frame = CGRectMake(i * kScreenWidth, 0, kScreenWidth, self.controllerView.bounds.size.height);
        [self.controllerView addSubview:view];
    }
    
    self.controllerView.contentSize = CGSizeMake(8 * self.controllerView.bounds.size.width, self.controllerView.bounds.size.height);
}

#pragma mark - 
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offSet = scrollView.contentOffset.x ;
    CGFloat width = kScreenWidth;
    NSInteger iPage = offSet / width;
    [self.navScrollView scrollToNextCellAtIndex:iPage];
}

#pragma mark wnavScrollDatasource
- (NSInteger)numberOfColumesInScrollView:(WNavScrollView *)scrollView {
    return kTestCount;
}

- (WNavScrollViewCell *)navScrollView:(WNavScrollView *)scrollView cellForRowAtIndexPath:(NSUInteger)index {
    WNavScrollViewCell *cell = [scrollView dequeueReusableCellWithIdentifier:@"scrollCell"];
    if (!cell) {
        CGRect rect = CGRectMake(0, 0, 80, scrollView.bounds.size.height);
        cell = [[WNavScrollViewCell alloc] initWithFrame:rect];
    }
    
    cell.text = @"测试一下";
    
    return cell;
}

- (void)navScrollView:(WNavScrollView *)scrollView didScrollToIndex:(NSInteger)index {
    CGFloat offset = index * kScreenWidth;
    [self.controllerView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark - getter
- (WNavScrollView *)navScrollView {
    if (!_navScrollView) {
        CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        _navScrollView = [[WNavScrollView alloc] initWithFrame:rect];
        _navScrollView.dataSource = self;
        _navScrollView.navDelegate = self;
        _navScrollView.scrollEnabled = YES;
    }
    
    return _navScrollView;
}

- (UIScrollView *)controllerView {
    if (!_controllerView) {
        CGRect rect = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44);
        _controllerView = [[UIScrollView alloc] initWithFrame:rect];
        _controllerView.scrollEnabled = YES;
        _controllerView.pagingEnabled = YES;
        _controllerView.delegate = self;
    }
    
    return _controllerView;
}

@end
