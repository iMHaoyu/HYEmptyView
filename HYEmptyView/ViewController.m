//
//  ViewController.m
//  HYEmptyView
//
//  Created by 徐浩宇 on 2018/3/2.
//  Copyright © 2018年 徐浩宇. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+HYEmpty.h"
#import "HYEmptyView.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, HYEmptyDataSetSourceAndDelegate>

@property (nonatomic,weak)  UITableView *mainTableView;
@property (copy, nonatomic) NSArray     *dataArray;
@end

@implementation ViewController

- (UITableView *)mainTableView {
    
    if (!_mainTableView) {
        UITableView *temp   = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 500)];
        temp.delegate       = self;
        temp.dataSource     = self;
        temp.emptyDataSetSource = self;
        [self.view addSubview:temp];
        _mainTableView      = temp;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mainTableView];
    self.dataArray = @[];
    [self.mainTableView reloadData];

    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.dataArray.count) {
        self.dataArray = @[];
        [self.mainTableView reloadData];
    }else {
        self.dataArray = @[@"1",@"2",@"3",@"4",@"5"];
        [self.mainTableView reloadData];
    }
}


//- (nullable UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
//    //    HYEmptyView *temp =  [HYEmptyView hy_getEmptyViewWithFrame:self.mainTableView.bounds AndSuperView:self.mainTableView];
//    //    temp.clickBlock = ^{
//    //        [self updateData];
//    //    };
//    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
//    tempView.backgroundColor = [UIColor redColor];
//    return tempView;
//}

/** 非Custom下的 图片 */
- (nullable UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"ic_empty"];
}

/** 非Custom下的 标题名称 - 默认使用固定的字体样式。如果需要不同的字体样式，请返回带属性的字符串 */
- (nullable NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"没有数据了哦";
    return [[NSAttributedString alloc] initWithString:text attributes:nil];
}

/** 非Custom下的 描述文字 - 默认使用固定的字体样式。如果需要不同的字体样式，请返回带属性的字符串 */
- (nullable NSString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    return @"点击尝试再次刷新一下...";
}

///** 非Custom下的 按钮的标题 */
//- (nullable NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
//    NSString *text = @"刷新";
//    return [[NSAttributedString alloc] initWithString:text attributes:nil];
//}

- (void)refreshDataForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.dataArray.count) {
        self.dataArray = @[];
        [self.mainTableView reloadData];
    }else {
        self.dataArray = @[@"1",@"2",@"3",@"4",@"5"];
        [self.mainTableView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
