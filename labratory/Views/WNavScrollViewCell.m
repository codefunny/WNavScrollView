//
//  WNavScrollViewCell.m
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "WNavScrollViewCell.h"

static const CGFloat kIndicateHeight = 5.f;

@interface WNavScrollViewCell ()

@property (nonatomic,strong) UILabel    *textLabel;
@property (nonatomic,strong) UIView     *indicateView;

@end

@implementation WNavScrollViewCell

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
    [self addSubview:self.textLabel];
    [self addSubview:self.indicateView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect viewRect = self.bounds;
    self.textLabel.frame = viewRect ;
    self.indicateView.frame = CGRectMake(0, viewRect.size.height - kIndicateHeight, viewRect.size.width, kIndicateHeight);
}

#pragma mark - getter/setter

- (void)setText:(NSString *)text {
    _text = text;
    self.textLabel.text = text;
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textLabel.textColor = _textColor;
    [self setNeedsLayout];
}

- (void)setIndicateColor:(UIColor *)indicateColor {
    _indicateColor = indicateColor;
    self.indicateView.backgroundColor = _indicateColor;
    [self setNeedsLayout];
}

- (void)setShowIndicate:(BOOL)showIndicate {
    self.indicateView.hidden = !showIndicate;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:16];
    }
    
    return _textLabel;
}

- (UIView *)indicateView {
    if (!_indicateView) {
        _indicateView = [[UIView alloc] init];
        _indicateView.backgroundColor = [UIColor orangeColor];
        _indicateView.hidden = YES;
    }
    
    return _indicateView;
}

@end
