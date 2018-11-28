//
//  UIScrollView+HYEmpty.m
//  HYEmptyView
//
//  Created by 徐浩宇 on 2018/3/2.
//  Copyright © 2018年 徐浩宇. All rights reserved.
//

#import "UIScrollView+HYEmpty.h"
#import "HYEmptyView.h"
#import <objc/runtime.h>

@implementation NSObject (HYExchange)
//替换方法（方法2 取代 方法1）
+ (void)hy_exchangeInstanceMethod1:(SEL)method1 WithMethod2:(SEL)method2 {
    
    //class_getInstanceMethod(Class _Nullable cls, SEL _Nonnull name): 返回给定类的指定实例方法。
    //cls :你想要检查的类。
    //name:您想要检索的方法的选择器。
    method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2));
}
@end


@interface UIScrollView ()<UIGestureRecognizerDelegate>
/**
 空页面占位图控件
 */
@property (nonatomic, strong) HYEmptyView *emptyView;
@end
@implementation UIScrollView (HYEmpty)
@dynamic emptyDataSetSource;
static char const *const kHYEmptyKey             = "emptyDataSetView";
static char const *const kHYEmptyDataSetSource   = "emptyDataSetSourceAndDelegate";
static char const *const kHYEmptySeparatorStyle  = "emptySeparatorStyle";
#pragma mark - ⬅️⬅️⬅️⬅️ set & get ➡️➡️➡️➡️
#pragma mark -
- (void)setEmptyView:(HYEmptyView *)emptyView {
    //set
    objc_setAssociatedObject(self, kHYEmptyKey, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HYEmptyView *)emptyView {
    //get
    HYEmptyView *view = objc_getAssociatedObject(self, kHYEmptyKey);
    if (!view)  {
        view = [[HYEmptyView alloc]init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        view.hidden = YES;
        
        view.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hy_didTapContentView:)];
        view.tapGesture.delegate = self;
        [view addGestureRecognizer:view.tapGesture];

        view.clickBlock = ^{
            [self hy_didTapContentView:nil];
        };
        
        [self setEmptyView:view];
    }
    return view;
    
}

- (id<HYEmptyDataSetSourceAndDelegate>)emptyDataSetSourceAndDelegate {
    id<HYEmptyDataSetSourceAndDelegate> delegate = objc_getAssociatedObject(self, kHYEmptyDataSetSource);
    return delegate;
}

- (void)setEmptyDataSetSource:(id<HYEmptyDataSetSourceAndDelegate>)datasource {
    if (!datasource) {
        [self hiddenEmptyView];
    }
    
    objc_setAssociatedObject(self, kHYEmptyDataSetSource, datasource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - ⬅️⬅️⬅️⬅️ Privat methods ➡️➡️➡️➡️
#pragma mark -
- (void)hy_didTapContentView:(id)sender {
    if (self.emptyDataSetSourceAndDelegate && [self.emptyDataSetSourceAndDelegate respondsToSelector:@selector(refreshDataForEmptyDataSet:)]) {
        [self.emptyDataSetSourceAndDelegate refreshDataForEmptyDataSet:self];
    }
}
//计算显示的数据个数
- (NSInteger)totalDataCount {
    
    NSInteger totalCount = 0;
    // 没有响应'dataSource'，所以我们退出
    if (![self respondsToSelector:@selector(dataSource)]) {
        return totalCount;
    }
    
    // UITableView support
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                totalCount += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
        
    // UICollectionView support
    }else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                totalCount += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    return totalCount;
}

//是否显示emptyView
- (void)getDataAndSetEmptyView {
    
    //没有设置emptyView的，直接返回
    if (!self.emptyView && ![self hy_customView]) {
        return;
    }
    
    if ([self totalDataCount] == 0) {
        if ([self isKindOfClass:[UITableView class]]) {
            UITableView *tempSelf = (UITableView *)self;
            objc_setAssociatedObject(self, kHYEmptySeparatorStyle, @(tempSelf.separatorStyle),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            tempSelf.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [self showEmptyView];
        
    }else {
        if ([self isKindOfClass:[UITableView class]]) {
            UITableView *tempSelf = (UITableView *)self;
            id separatorStyle = objc_getAssociatedObject(self, kHYEmptySeparatorStyle);
            tempSelf.separatorStyle = [separatorStyle integerValue];
        }
        [self hiddenEmptyView];
        
    }
}

- (void)showEmptyView {
    //此处可扩展
    //可以设置许多自己需要的功能（比如自动显示和隐藏）
    //......................//
    HYEmptyView *view  = self.emptyView;
    self.scrollEnabled = NO;
    if (!view.superview) {
        // 如果出现HeaderView和/或FooterView，以及sectionHeaders或任何其他内容，则将视图一直发送到后面
        if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && self.subviews.count > 1) {
            [self insertSubview:view atIndex:0];
        }else {
            [self addSubview:view];
        }
    }
    
    UIView *customView = [self hy_customView];
    if (customView) {
        view.customView = customView;
    }else {
        
        NSAttributedString *titleLabelString = [self hy_titleLabelString];
        NSString *detailLabelString = [self hy_detailLabelString];
//        UIImage *buttonImage = [self hy_buttonImageForState:UIControlStateNormal];
        NSAttributedString *buttonTitle = [self hy_buttonTitleForState:UIControlStateNormal];
        UIImage *image = [self hy_image];
        
        //配置图片
        if (image) {
            view.image = image;
        }
        //配置标题
        if (titleLabelString) {
            view.title = titleLabelString;
        }
        //配置说明
        if (detailLabelString) {
            view.detailText = detailLabelString;
        }
        //配置按钮标题
        if (buttonTitle) {
            view.buttonTitle = buttonTitle;
            [view.tapGesture removeTarget:self action:@selector(hy_didTapContentView:)];
        }else {
            [view.tapGesture addTarget:self action:@selector(hy_didTapContentView:)];
        }
        //配置按钮图片
        //...
        
        [view.superview layoutSubviews];
        //让 emptyBGView 始终保持在最上层
        [self bringSubviewToFront:view];
    }
    view.hidden = NO;
    [view setupConstraints];
    
}
- (void)hiddenEmptyView {
    //此处可扩展
    //可以设置许多自己需要的功能（比如自动显示和隐藏）
    //......................//
    if (self.emptyView) {
        [self.emptyView prepareForReuse];
        [self.emptyView removeFromSuperview];
        [self setEmptyView:nil];
    }
    self.scrollEnabled = YES;
}
#pragma mark - ⬅️⬅️⬅️⬅️ Data Source Getters ➡️➡️➡️➡️
#pragma mark -
- (UIView *)hy_customView {
    if (self.emptyDataSetSourceAndDelegate && [self.emptyDataSetSourceAndDelegate respondsToSelector:@selector(customViewForEmptyDataSet:)]) {
        UIView *view = [self.emptyDataSetSourceAndDelegate customViewForEmptyDataSet:self];
        if (view) NSAssert([view isKindOfClass:[UIView class]], @"You must return a valid UIView object for -customViewForEmptyDataSet:");
        return view;
    }
    return nil;
}

- (UIImage *)hy_image {
    if (self.emptyDataSetSourceAndDelegate && [self.emptyDataSetSourceAndDelegate respondsToSelector:@selector(imageForEmptyDataSet:)]) {
        UIImage *image = [self.emptyDataSetSourceAndDelegate imageForEmptyDataSet:self];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -imageForEmptyDataSet:");
        return image;
    }
    return nil;
}

- (NSAttributedString *)hy_titleLabelString {
    if (self.emptyDataSetSourceAndDelegate && [self.emptyDataSetSourceAndDelegate respondsToSelector:@selector(titleForEmptyDataSet:)]) {
        NSAttributedString *string = [self.emptyDataSetSourceAndDelegate titleForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -titleForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (NSString *)hy_detailLabelString {
    if (self.emptyDataSetSourceAndDelegate && [self.emptyDataSetSourceAndDelegate respondsToSelector:@selector(descriptionForEmptyDataSet:)]) {
        NSString *string = [self.emptyDataSetSourceAndDelegate descriptionForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSString class]], @"You must return a valid NSString object for -descriptionForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (NSAttributedString *)hy_buttonTitleForState:(UIControlState)state {
    if (self.emptyDataSetSourceAndDelegate && [self.emptyDataSetSourceAndDelegate respondsToSelector:@selector(buttonTitleForEmptyDataSet:forState:)]) {
        NSAttributedString *string = [self.emptyDataSetSourceAndDelegate buttonTitleForEmptyDataSet:self forState:state];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -buttonTitleForEmptyDataSet:forState:");
        return string;
    }
    return nil;
}

//- (UIImage *)hy_buttonImageForState:(UIControlState)state {
//    if (self.emptyDataSetSourceAndDelegate && [self.emptyDataSetSourceAndDelegate respondsToSelector:@selector(buttonImageForEmptyDataSet:forState:)]) {
//        UIImage *image = [self.emptyDataSetSourceAndDelegate buttonImageForEmptyDataSet:self forState:state];
//        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -buttonImageForEmptyDataSet:forState:");
//        return image;
//    }
//    return nil;
//}
@end












@implementation UITableView (HYEmpty)

//重写系统的load方法
+ (void)load {
    //替换系统的reloadData方法
    [self hy_exchangeInstanceMethod1:@selector(reloadData) WithMethod2:@selector(hy_reloadData)];
    
    //Section
    //替换系统的Section刷新方法
    [self hy_exchangeInstanceMethod1:@selector(insertSections:withRowAnimation:) WithMethod2:@selector(hy_insertSections:withRowAnimation:)];
    [self hy_exchangeInstanceMethod1:@selector(deleteSections:withRowAnimation:) WithMethod2:@selector(hy_deleteSections:withRowAnimation:)];
    
    ///row
    //替换系统的row刷新方法
    [self hy_exchangeInstanceMethod1:@selector(insertRowsAtIndexPaths:withRowAnimation:) WithMethod2:@selector(hy_insertRowsAtIndexPaths:withRowAnimation:)];
    [self hy_exchangeInstanceMethod1:@selector(deleteRowsAtIndexPaths:withRowAnimation:) WithMethod2:@selector(hy_deleteRowsAtIndexPaths:withRowAnimation:)];
}
#pragma mark - ⬅️⬅️⬅️⬅️ 重写系统的reloadData刷新方法 ➡️➡️➡️➡️
#pragma mark -
- (void)hy_reloadData {
    [self hy_reloadData];
    [self getDataAndSetEmptyView];
}

#pragma mark - ⬅️⬅️⬅️⬅️ 重写系统的section刷新方法 ➡️➡️➡️➡️
#pragma mark -
- (void)hy_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self hy_insertSections:sections withRowAnimation:animation];
    [self getDataAndSetEmptyView];
}
- (void)hy_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self hy_deleteSections:sections withRowAnimation:animation];
    [self getDataAndSetEmptyView];
}
#pragma mark - ⬅️⬅️⬅️⬅️ 重写系统的row刷新方法 ➡️➡️➡️➡️
#pragma mark -
- (void)hy_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self hy_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self getDataAndSetEmptyView];
}
- (void)hy_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self hy_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self getDataAndSetEmptyView];
}
@end


@implementation UICollectionView (HYEmpty)

+ (void)load {
    //替换系统的reloadData方法
    [self hy_exchangeInstanceMethod1:@selector(reloadData) WithMethod2:@selector(hy_reloadData)];
    
    ///section
    //替换系统的Section刷新方法
    [self hy_exchangeInstanceMethod1:@selector(insertSections:) WithMethod2:@selector(hy_insertSections:)];
    [self hy_exchangeInstanceMethod1:@selector(deleteSections:) WithMethod2:@selector(hy_deleteSections:)];
    [self hy_exchangeInstanceMethod1:@selector(reloadSections:) WithMethod2:@selector(hy_reloadSections:)];
    
    ///item
    //替换系统的row刷新方法
    [self hy_exchangeInstanceMethod1:@selector(insertItemsAtIndexPaths:) WithMethod2:@selector(hy_insertItemsAtIndexPaths:)];
    [self hy_exchangeInstanceMethod1:@selector(deleteItemsAtIndexPaths:) WithMethod2:@selector(hy_deleteItemsAtIndexPaths:)];
    [self hy_exchangeInstanceMethod1:@selector(reloadItemsAtIndexPaths:) WithMethod2:@selector(hy_reloadItemsAtIndexPaths:)];
}
#pragma mark - ⬅️⬅️⬅️⬅️ 重写系统的reloadData刷新方法 ➡️➡️➡️➡️
#pragma mark -
- (void)hy_reloadData{
    [self hy_reloadData];
    [self getDataAndSetEmptyView];
}
///section
#pragma mark - ⬅️⬅️⬅️⬅️ 重写系统的section刷新方法 ➡️➡️➡️➡️
#pragma mark -
- (void)hy_insertSections:(NSIndexSet *)sections{
    [self hy_insertSections:sections];
    [self getDataAndSetEmptyView];
}
- (void)hy_deleteSections:(NSIndexSet *)sections{
    [self hy_deleteSections:sections];
    [self getDataAndSetEmptyView];
}
- (void)hy_reloadSections:(NSIndexSet *)sections{
    [self hy_reloadSections:sections];
    [self getDataAndSetEmptyView];
}

///item
#pragma mark - ⬅️⬅️⬅️⬅️ 重写系统的row刷新方法 ➡️➡️➡️➡️
#pragma mark -
- (void)hy_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    [self hy_insertItemsAtIndexPaths:indexPaths];
    [self getDataAndSetEmptyView];
}
- (void)hy_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    [self hy_deleteItemsAtIndexPaths:indexPaths];
    [self getDataAndSetEmptyView];
}
- (void)hy_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    [self hy_reloadItemsAtIndexPaths:indexPaths];
    [self getDataAndSetEmptyView];
}

@end
