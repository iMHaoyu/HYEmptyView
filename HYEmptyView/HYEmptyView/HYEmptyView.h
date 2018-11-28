//
//  HYEmptyView.h
//  HYEmptyView
//
//  Created by 徐浩宇 on 2018/3/2.
//  Copyright © 2018年 徐浩宇. All rights reserved.
//

#import <UIKit/UIKit.h>

//事件回调
typedef void (^HYActionTapBlock)(void);
@interface HYEmptyView : UIView

@property (nonatomic, copy) HYActionTapBlock clickBlock;

/** 2018-11-27 修改 */
@property (nonatomic, strong) UIImage            *image;
@property (nonatomic, copy)   NSAttributedString *title;
@property (nonatomic, copy)   NSString           *detailText;
@property (nonatomic, copy)   NSAttributedString *buttonTitle;

@property (nonatomic, strong) UIView                 *customView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

- (void)setupConstraints;
/** 移除子视图，准备重用 */
- (void)prepareForReuse;
@end
