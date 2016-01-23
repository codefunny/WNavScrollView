//
//  WControllerFactory.m
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "WControllerFactory.h"
#import <UIKit/UIKit.h>

@interface WControllerFactory()

@property (nonatomic,strong) UIStoryboard  *storyBoard;

@end

@implementation WControllerFactory

+ (instancetype)instance {
    static WControllerFactory   *factory = nil;
    static dispatch_once_t      onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[WControllerFactory alloc] init];
    });
    
    return factory;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    
    return self;
}

@end
