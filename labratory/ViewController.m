//
//  ViewController.m
//  labratory
//
//  Created by wenchao on 16/1/23.
//  Copyright © 2016年 wenchao. All rights reserved.
//

#import "ViewController.h"

static NSMutableDictionary  *titleHandlers;
static NSMutableArray       *titles;
static NSString*const kCellIdentifier = @"cell";

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView    *tableView;

@end

@implementation ViewController

+ (void)registerWithTitle:(NSString *)title handler:(UIViewController *(^)())handler {
    if (!titleHandlers) {
        titleHandlers = [NSMutableDictionary dictionary];
        titles = [NSMutableArray array];
    }
    
    [titles addObject:title];
    [titleHandlers setObject:handler forKey:title];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleHandlers.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *title = [titles objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *controller = ((ViewControllerHandler)titleHandlers[titles[indexPath.row]])();
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark getter/setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
    }
    
    return _tableView;
}

@end
