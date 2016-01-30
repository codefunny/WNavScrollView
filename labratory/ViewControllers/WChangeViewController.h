//
//  WChangeViewController.h
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "WBaseViewController.h"

#ifdef DEBUG
#define WLOG(...) NSLog(__VA_ARGS__);
#define WLOG_METHOD NSLog(@"%s", __func__);
#else
#define WLOG(...); #define LOG_METHOD;
#endif

@interface WChangeViewController : WBaseViewController

@end
