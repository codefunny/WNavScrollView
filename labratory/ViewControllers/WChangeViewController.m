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

static NSArray* dataSource(){
    static NSArray* items = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        items = @[@"测试",@"哈哈",@"2016",@"2015",@"明天更好",@"红包",@"春节",@"猴年大吉"];
    });
    
    return items;
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
    
    NSInteger count = dataSource().count;
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
    
    self.controllerView.contentSize = CGSizeMake(count * self.controllerView.bounds.size.width, self.controllerView.bounds.size.height);
}

#pragma mark - 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    WLOG(@"%d,%d,%d",scrollView.isDragging,scrollView.isTracking,scrollView.isDecelerating);
    if (!scrollView.isDragging && scrollView.isDecelerating == NO) {
        return ;
    }
    
    WLOG(@"offset:%lf",scrollView.contentOffset.x);
    CGFloat offSet = scrollView.contentOffset.x ;
    CGFloat width = kScreenWidth;
    NSInteger iPage = offSet / width;
    CGFloat offsetX = offSet - iPage * width;
    WLOG(@"offx:%ld,ratio:%lf",iPage,offsetX/width);
    
    [self.navScrollView navScrollViewDidScrollPage:(NSInteger)iPage ratio:offsetX/width];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offSet = scrollView.contentOffset.x ;
    CGFloat width = kScreenWidth;
    NSInteger iPage = offSet / width;
    [self.navScrollView scrollToNextCellAtIndex:iPage];
}

#pragma mark wnavScrollDatasource
- (NSInteger)numberOfColumesInScrollView:(WNavScrollView *)scrollView {
    return dataSource().count;
}

- (WNavScrollViewCell *)navScrollView:(WNavScrollView *)scrollView cellForRowAtIndexPath:(NSUInteger)index {
    WNavScrollViewCell *cell = [scrollView dequeueReusableCellWithIdentifier:@"scrollCell"];
    if (!cell) {
        cell = [[WNavScrollViewCell alloc] initReuseIdentifier:@"scrollCell"];
    }
    
    cell.text = dataSource()[index];
    cell.textColor = [UIColor blackColor];
    cell.selectedColor = [UIColor orangeColor];
    cell.selectedFont = [UIFont systemFontOfSize:17.];
    
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
