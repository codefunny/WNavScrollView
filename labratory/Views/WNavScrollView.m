//
//  WNavScrollView.m
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "WNavScrollView.h"

static const CGFloat defaultColumeWidth = 80.f;

@interface WNavScrollView () {
    BOOL _needsReload;
    NSMutableSet *_reusableCells;
    NSMutableDictionary *_cachedCells;
    NSMutableArray      *_cellFrames;
    NSInteger   _currentIndex;
    
    struct{
        unsigned didScrollToIndex:1;
        unsigned widthForColumesAtIndexPath:1;
    }_delegateHas;
    
    struct{
        unsigned numberOfColumesInScrollView:1;
        unsigned cellForRowAtIndexPath:1;
    }_dataSourceHas;
}

@property (nonatomic,strong) NSMutableArray     *reuse;

@property (nonatomic,strong) UIView   *indicateView;

@end

@implementation WNavScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp {
    _reusableCells = [[NSMutableSet alloc] init];
    _cachedCells = [[NSMutableDictionary alloc] init];
    _currentIndex = 0;
    _needsReload = NO;

    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
}

- (void)dealloc {
    
}

- (void)setDataSource:(id<WNavScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceHas.numberOfColumesInScrollView = [dataSource respondsToSelector:@selector(numberOfColumesInScrollView:)];
    _dataSourceHas.cellForRowAtIndexPath = [dataSource respondsToSelector:@selector(navScrollView:cellForRowAtIndexPath:)];
    
    [self _setNeedsReload];
}

- (void)setNavDelegate:(id<WNavScrollViewDelegate>)navDelegate {
    _navDelegate = navDelegate;
    
    _delegateHas.didScrollToIndex = [navDelegate respondsToSelector:@selector(navScrollView:didScrollToIndex:)];
    _delegateHas.widthForColumesAtIndexPath = [navDelegate respondsToSelector:@selector(navScrollView:widthForColumesAtIndexPath:)];
}

- (WNavScrollViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    for (WNavScrollViewCell *cell in _reusableCells) {
        if ([cell.reuseIdentifier isEqualToString:identifier]) {
            WNavScrollViewCell *strongCell = cell;
            [_reusableCells removeObject:cell];
            
            return strongCell;
        }
    }
    
    return nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    const CGPoint location = [touch locationInView:self];
    
    NSInteger _highlightedRow = [self indexPathForRowAtPoint:location];
    [self scrollToNextCellAtIndex:_highlightedRow];
    _delegateHas.didScrollToIndex ? [self.navDelegate navScrollView:self didScrollToIndex:_highlightedRow] : nil;
}

- (NSInteger)indexPathForRowAtPoint:(CGPoint)point {
    NSArray *paths = [self indexPathsForRowsInRect:CGRectMake(point.x,point.y,1,1)];
    NSNumber *number = ([paths count] > 0)? [paths objectAtIndex:0] : @(0);
    return [number integerValue];
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    const NSInteger columesCount = [self numberOfColumes];
    CGFloat offset = 0;
    
    for (NSInteger i=0; i<columesCount; i++) {
        const CGFloat width = [_cellFrames[i] CGRectValue].size.width;
        CGRect simpleRowRect = CGRectMake(offset, rect.origin.y, width, rect.size.height);
        
        if (CGRectIntersectsRect(rect,simpleRowRect)) {
            [results addObject:@(i)];
        } else if (simpleRowRect.origin.x > rect.origin.x+rect.size.width) {
            break;
        }
        
        offset += width;
    }
    
    return results;
}

- (void)navScrollViewDidScrollPage:(NSInteger)iPage ratio:(CGFloat)offsetX {
    WNavScrollViewCell *cell = [self cellForColumeAtIndex:_currentIndex];
    CGFloat offSet = 0;
    
    if (offsetX == 0) {
        return ;
    }
    
    if (iPage == _currentIndex) {
         offSet = (offsetX * cell.bounds.size.width);
    } else {
         offSet = (offsetX * cell.bounds.size.width) - cell.bounds.size.width;
    }
    WLOG(@"cell:%@,setX:%lf,ipage:%ld,idex:%ld",NSStringFromCGRect(cell.bounds),offSet,iPage,_currentIndex);
    
    CGRect frame = cell.indicateView.frame;
    frame.origin.x = offSet;
    cell.indicateView.frame = frame;
}

- (void)scrollToNextCellAtIndex:(NSInteger)index {
    if (_currentIndex == index) {
        return;
    }
    
    __block WNavScrollViewCell *fromCell = [self cellForColumeAtIndex:_currentIndex];
    __block WNavScrollViewCell *toCell = [self cellForColumeAtIndex:index];
    if (fromCell.indicateView.frame.origin.x != 0) {
        fromCell.showIndicate = NO;
        fromCell.selected = NO;
        CGRect rect = fromCell.indicateView.frame;
        rect.origin.x = 0;
        fromCell.indicateView.frame = rect;
        toCell.showIndicate = YES;
        toCell.selected = YES;
        _currentIndex = index;
        [self _scrollRectToVisible:toCell.frame animated:YES];
        
        return ;
    }
    
    WLOG(@"tag:%ld,%ld",fromCell.tag,toCell.tag);
    CGFloat transX = CGRectGetMaxX(toCell.frame) - CGRectGetMaxX(fromCell.frame);
    CGPoint center = fromCell.indicateView.center;
    CGPoint orginCenter = center;
    center.x += (transX);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        fromCell.indicateView.center = center ;
    } completion:^(BOOL finished) {
        fromCell.showIndicate = NO;
        fromCell.selected = NO;
        fromCell.indicateView.center = orginCenter;
        toCell.showIndicate = YES;
        toCell.selected = YES;
        _currentIndex = index;
        [weakSelf _scrollRectToVisible:toCell.frame animated:YES];
        
    }];
}

- (WNavScrollViewCell *)cellForColumeAtIndex:(NSInteger)index {
    const NSInteger columesCount = [_cachedCells count];
    if (index < columesCount) {
        return _cachedCells[@(index)];
    }
    
    return [_cachedCells objectForKey:@(index)];
}

- (void)_scrollRectToVisible:(CGRect)aRect animated:(BOOL)animated {
    if (!CGRectIsNull(aRect) && aRect.size.width > 0) {
        CGRect  rect = self.bounds;
        CGFloat pointX = CGRectGetMidX(aRect);
        CGFloat subValue = pointX - rect.size.width/2.;
        CGFloat offsetToRight = self.contentSize.width - pointX;
        WLOG(@"%lf,offset:%f",pointX,self.contentOffset.x);
        if (subValue > 0) {
            if (offsetToRight > rect.size.width/2. ) {
                [self setContentOffset:CGPointMake(subValue, 0) animated:animated];
            } else {
                CGFloat externOffset = self.contentSize.width - rect.size.width;
                if (externOffset > self.contentOffset.x) {
                    [self setContentOffset:CGPointMake(externOffset, 0) animated:animated];
                }
            }
        } else {
            if (self.contentOffset.x > 0) {
                [self setContentOffset:CGPointZero animated:animated];
            }
        }
    }
}

- (void)_layoutScrollView {
    NSInteger columesCount = [self numberOfColumes];
    if (columesCount <= 0) {
        return;
    }
    
    const CGSize  boundsSize = self.bounds.size;
    const CGFloat contentOffset = self.contentOffset.x;
    const CGRect  visibleBounds = CGRectMake(contentOffset,0,boundsSize.width,boundsSize.height);
    NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
    
    for (NSInteger i = 0; i <  columesCount; i++) {
        CGRect  cellRect = [_cellFrames[i] CGRectValue];
        WNavScrollViewCell *cell = _cachedCells[@(i)];
        if (CGRectIntersectsRect(cellRect,visibleBounds)) {
            if (cell == nil) {
                WNavScrollViewCell *cell = [self.dataSource navScrollView:self cellForRowAtIndexPath:i];
                CGRect rect = cellRect;
                rect.size.height = self.bounds.size.height;
                cell.frame = rect;
                [_cachedCells setObject:cell forKey:@(i)];
                if (i == _currentIndex) {
                    cell.showIndicate = YES ;
                    cell.selected = YES;
                } else {
                    cell.showIndicate = NO ;
                    cell.selected = NO;
                }
                cell.tag = 100 + i;
                [self addSubview:cell];
            }
        } else {
            if (cell) {
                [cell removeFromSuperview];
                [_cachedCells removeObjectForKey:@(i)];
            }
        }
    }
    
    for (WNavScrollViewCell *cell in [availableCells allValues]) {
        if (cell.reuseIdentifier && !CGRectIntersectsRect(cell.frame, visibleBounds)) {
            [_reusableCells addObject:cell];
        }
    }
}

- (void)_contentSize {
    NSInteger columesCount = [self numberOfColumes];
    if (columesCount <= 0) {
        return;
    }
    
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    
    [_cellFrames removeAllObjects];
    CGFloat totalWidth = 0;

    for (NSInteger row=0; row<columesCount; row++) {
        const CGFloat columWidth = _delegateHas.widthForColumesAtIndexPath? [self.navDelegate navScrollView:self widthForColumesAtIndexPath:row] : defaultColumeWidth;
        
        CGRect cellRect = CGRectMake(totalWidth, 0, columWidth, 1);
        [_cellFrames addObject:[NSValue valueWithCGRect:cellRect]];
        totalWidth += columWidth;
    }
    
    self.contentSize = CGSizeMake(totalWidth, self.bounds.size.height);
}

- (void)_reloadDataIfNeeded {
    if (_needsReload) {
        [self reloadData];
    }
}

- (void)_setNeedsReload {
    _needsReload = YES;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [self _reloadDataIfNeeded];
    [self _layoutScrollView];
    [super layoutSubviews];
}

- (void)reloadData {
    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells removeAllObjects];
    [_cachedCells removeAllObjects];
    
    [self _contentSize];
    _needsReload = NO;
}

#pragma mark -
- (NSInteger)numberOfColumes {
    return [self.dataSource numberOfColumesInScrollView:self];
}

- (BOOL)isInScreen:(CGRect)frame {
    WLOG(@"%@",NSStringFromCGRect(self.bounds));
    return (CGRectGetMaxX(frame) > self.contentOffset.x) &&
    (CGRectGetMinX(frame) < self.contentOffset.x + self.bounds.size.width);
}

@end
