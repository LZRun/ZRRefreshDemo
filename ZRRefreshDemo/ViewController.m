//
//  ViewController.m
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/1.
//  Copyright © 2017年 Run. All rights reserved.
//

#import "ViewController.h"
#import "UIView+GKExtension.h"
#import "UIScrollView+ZRRefresh.h"

static NSString *cellID = @"cellID";
@interface ViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    __weak typeof (self) weakSelf = self;
    _tableView.zr_header = [ZRRefreshHeader refreshHeaderWithRefreshingHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView.zr_header endRefreshing];
        });
    }];
    
    UITextField *textFiled = [[UITextField alloc]initWithFrame:CGRectMake(0, 0,200, 44)];
    textFiled.borderStyle = UITextBorderStyleRoundedRect;
    textFiled.delegate = self;
    textFiled.placeholder = @"输入文字,再下拉视图，可更换效果";
    textFiled.returnKeyType = UIReturnKeyDone;
    self.navigationItem.titleView = textFiled;
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    if (textField.text.length > 0) {
        _tableView.zr_header.text = textField.text;
    }
    return YES;
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.backgroundColor = [UIColor orangeColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"index:%ld",indexPath.row];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
