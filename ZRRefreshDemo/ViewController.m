//
//  ViewController.m
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/1.
//  Copyright © 2017年 Run. All rights reserved.
//

#import "ViewController.h"
#import "ZRRefreshHeader.h"
#import "UIView+GKExtension.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZRRefreshHeader *header = [[ZRRefreshHeader alloc]initWithFrame:CGRectMake(0, 50, self.view.width, 200)];
    [self.view addSubview:header];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
