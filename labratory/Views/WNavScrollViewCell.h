//
//  WNavScrollViewCell.h
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WNavScrollViewCell : UIView

@property (nonatomic,strong) NSString   *text;
@property (nonatomic,strong) UIColor    *textColor;
@property (nonatomic,strong) UIFont     *textFont;
@property (nonatomic,strong) UIColor    *selectedColor;
@property (nonatomic,strong) UIFont     *selectedFont;
@property (nonatomic,strong) UIColor    *indicateColor;
@property (nonatomic,strong) NSString   *reuseIdentifier;
@property (nonatomic,assign) BOOL       showIndicate;
@property (nonatomic,assign) BOOL       selected;

@property (nonatomic,readonly) UIView   *indicateView;

- (instancetype)initReuseIdentifier:(NSString *)reuseIdentifier ;

@end
