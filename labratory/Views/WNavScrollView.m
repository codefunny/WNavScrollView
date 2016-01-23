//
//  WNavScrollView.m
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "WNavScrollView.h"

static const CGFloat defaultRowHeight = 80.f;

@interface WNavScrollView () {
    BOOL _needsReload;
    NSMutableSet *_reusableCells;
    NSMutableDictionary *_cachedCells;
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

    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
//    self.pagingEnabled = YES;
    
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
        const CGFloat width = _delegateHas.widthForColumesAtIndexPath ? [self.navDelegate navScrollView:self widthForColumesAtIndexPath:i] : defaultRowHeight;
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

- (void)scrollToNextCellAtIndex:(NSInteger)index {
    if (_currentIndex == index) {
        return;
    }
    
    WNavScrollViewCell *fromCell = [self cellForColumeAtIndex:_currentIndex];
    WNavScrollViewCell *toCell = [self cellForColumeAtIndex:index];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        fromCell.showIndicate = NO;
        toCell.showIndicate = YES;
    } completion:^(BOOL finished) {
        _currentIndex = index;
        if (![weakSelf isInScreen:toCell.frame]) {
            [weakSelf _scrollRectToVisible:toCell.frame animated:YES];
        }
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
        aRect.size.width += aRect.size.width/2;
        [self scrollRectToVisible:aRect animated:animated];
    }
}

- (void)_layoutScrollView {
    NSInteger columesCount = [self numberOfColumes];
    if (columesCount <= 0) {
        return;
    }
    
    const CGSize  boundsSize = self.bounds.size;
    const CGFloat contentOffset = self.contentOffset.y;
    const CGRect  visibleBounds = CGRectMake(0,contentOffset,boundsSize.width,boundsSize.height);
    NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
    [_cachedCells removeAllObjects];
    
    for (NSInteger i = 0; i <  columesCount; i++) {
        WNavScrollViewCell *cell = [self.dataSource navScrollView:self cellForRowAtIndexPath:i];
        CGRect rect = cell.bounds;
        rect.origin.x = i * rect.size.width;
        cell.frame = rect;
        [_cachedCells setObject:cell forKey:@(i)];
        if (i == _currentIndex) {
            cell.showIndicate = YES ;
        } else {
            cell.showIndicate = NO ;
        }
        [self addSubview:cell];
    }
    
    for (WNavScrollViewCell *cell in [availableCells allValues]) {
        if (cell.reuseIdentifier) {
            [_reusableCells addObject:cell];
        } else {
            [cell removeFromSuperview];
        }
    }
    
    NSArray* allCachedCells = [_cachedCells allValues];
    for (WNavScrollViewCell *cell in _reusableCells) {
        if (CGRectIntersectsRect(cell.frame,visibleBounds) && ![allCachedCells containsObject: cell]) {
            [cell removeFromSuperview];
        }
    }
}

- (void)_contentSize {
    NSInteger columesCount = [self numberOfColumes];
    if (columesCount <= 0) {
        return;
    }
    
    CGFloat totalWidth = 0;

    for (NSInteger row=0; row<columesCount; row++) {
        const CGFloat columWidth = _delegateHas.widthForColumesAtIndexPath? [self.navDelegate navScrollView:self widthForColumesAtIndexPath:row] : defaultRowHeight;
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
    [self _contentSize];
    _needsReload = NO;
}

#pragma mark -
- (NSInteger)numberOfColumes {
    return [self.dataSource numberOfColumesInScrollView:self];
}

- (BOOL)isInScreen:(CGRect)frame {
    return (CGRectGetMinX(frame) > self.contentOffset.x) &&
    (CGRectGetMaxX(frame) < self.contentOffset.x + self.bounds.size.width);
}

@end
