//
//  WNavScrollViewCell.m
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "WNavScrollViewCell.h"

static const CGFloat kIndicateHeight = 2.f;

@interface WNavScrollViewCell ()

@property (nonatomic,strong) UILabel    *textLabel;
@property (nonatomic,strong) UIView     *indicateView;

@end

@implementation WNavScrollViewCell

- (instancetype)initReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        [self setUp];
    }
    
    return self;

}

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
    _textColor = [UIColor blackColor];
    _textFont = [UIFont systemFontOfSize:15.];
    _selectedFont = [UIFont systemFontOfSize:18.];
    _selectedColor = [UIColor orangeColor];
    [self addSubview:self.textLabel];
    [self addSubview:self.indicateView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect viewRect = self.bounds;
    self.textLabel.frame = viewRect ;
    self.indicateView.frame = CGRectMake(0, viewRect.size.height - kIndicateHeight, viewRect.size.width, kIndicateHeight);
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.textLabel.textColor = self.selectedColor;
        self.textLabel.font = self.selectedFont;
    } else {
        self.textLabel.textColor = _textColor;
        self.textLabel.font = _textFont;
    }
    
    [self setNeedsDisplay];
}

#pragma mark - getter/setter

- (void)setText:(NSString *)text {
    _text = text;
    self.textLabel.text = text;
    [self setNeedsDisplay];
}

- (void)setIndicateColor:(UIColor *)indicateColor {
    _indicateColor = indicateColor;
    self.indicateView.backgroundColor = _indicateColor;
    [self setNeedsDisplay];
}

- (void)setShowIndicate:(BOOL)showIndicate {
    self.indicateView.hidden = !showIndicate;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = _textColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = _textFont;
    }
    
    return _textLabel;
}

- (UIView *)indicateView {
    if (!_indicateView) {
        CGRect viewRect = self.bounds;
        _indicateView = [[UIView alloc] init];
        _indicateView.frame = CGRectMake(0, viewRect.size.height - kIndicateHeight, viewRect.size.width, kIndicateHeight);
        _indicateView.backgroundColor = [UIColor orangeColor];
        _indicateView.hidden = YES;
    }
    
    return _indicateView;
}

@end
