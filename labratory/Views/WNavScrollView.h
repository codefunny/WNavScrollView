//
//  WNavScrollView.h
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WNavScrollViewCell.h"

#ifdef DEBUG
#define WLOG(...) NSLog(__VA_ARGS__);
#define WLOG_METHOD NSLog(@"%s", __func__);
#else
#define WLOG(...); #define LOG_METHOD;
#endif

@class WNavScrollView;
@protocol WNavScrollViewDataSource <NSObject>

- (NSInteger)numberOfColumesInScrollView:(WNavScrollView *)scrollView;
- (WNavScrollViewCell *)navScrollView:(WNavScrollView *)scrollView cellForRowAtIndexPath:(NSUInteger)index ;

@end

@protocol WNavScrollViewDelegate <NSObject>

@optional
- (void)navScrollView:(WNavScrollView *)scrollView didScrollToIndex:(NSInteger)index;
- (CGFloat)navScrollView:(WNavScrollView *)scrollView widthForColumesAtIndexPath:(NSInteger)index;

@end

@interface WNavScrollView : UIScrollView

@property (nonatomic,weak) id<WNavScrollViewDataSource> dataSource;
@property (nonatomic,weak) id<WNavScrollViewDelegate> navDelegate;

- (WNavScrollViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier ;
- (void)reloadData ;
- (void)scrollToNextCellAtIndex:(NSInteger)index ;
- (void)navScrollViewDidScrollPage:(NSInteger)iPage ratio:(CGFloat)offsetX ;

@end
