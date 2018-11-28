//
//  UIScrollView+HYEmpty.h
//  HYEmptyView
//
//  Created by 徐浩宇 on 2018/3/2.
//  Copyright © 2018年 徐浩宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYEmptyView.h"

@protocol HYEmptyDataSetSourceAndDelegate;
@interface UIScrollView (HYEmpty)

@property (nonatomic, weak, nullable) id<HYEmptyDataSetSourceAndDelegate> emptyDataSetSource;

@end

@protocol HYEmptyDataSetSourceAndDelegate <NSObject>
@optional
/** 刷新方法 */
- (void)refreshDataForEmptyDataSet:(UIScrollView *)scrollView;

/** 请求数据源显示自定义视图，而不是默认视图 */
- (nullable UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView;


/***************************************************************/
/********************** 以下只针对 非Custom **********************/
/***************************************************************/
/** 非Custom下的 图片 */
- (nullable UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView;

/** 非Custom下的 标题名称 - 默认使用固定的字体样式。如果需要不同的字体样式，请返回带属性的字符串 */
- (nullable NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView;

/** 非Custom下的 描述文字 - 默认使用固定的字体样式。如果需要不同的字体样式，请返回带属性的字符串 */
- (nullable NSString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView;

/** 非Custom下的 按钮的标题 */
- (nullable NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

/** 非Custom下的 按钮的图片 */
//- (nullable UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;
@end
