//
//  ViewController.h
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIViewController *(^ViewControllerHandler)();
@interface ViewController : UIViewController

+ (void)registerWithTitle:(NSString *)title handler:(ViewControllerHandler)handler ;

@end

