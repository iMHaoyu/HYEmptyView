//
//  HYEmptyView.m
//  HYEmptyView
//
//  Created by 徐浩宇 on 2018/3/2.
//  Copyright © 2018年 徐浩宇. All rights reserved.
//

#import "HYEmptyView.h"
#import "UIView+HYCategory.h"

@interface UIView (DZNConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute;

@end

static CGFloat const kHYDefaultDetailFontSize = 13.f;
static CGFloat const kHYDefaultViewSpec       = 6.f;
#define kHYSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define kHYSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface HYEmptyView ()

/** 2018-11-27 修改 */
@property (nonatomic, readonly) UIView      *contentView;
@property (nonatomic, readonly) UILabel     *titleLabel;
@property (nonatomic, readonly) UILabel     *detailLabel;
@property (nonatomic, readonly) UIButton    *button;
@property (nonatomic, readonly) UIImageView *imageView;

@end
@implementation HYEmptyView
@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel, detailLabel = _detailLabel, imageView = _imageView, button = _button;

- (void)prepareForReuse {
    //subviews 全部调用removeFromSuperview 刷新试图及其约束。很重要
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _imageView = nil;
}

/** 2018-11-27 changed by xuhaoyu */
#pragma mark - ⬅️⬅️⬅️⬅️ Getter & Setter ➡️➡️➡️➡️
#pragma mark -
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.userInteractionEnabled = YES;
        _contentView.alpha = 0;
    }
    return _contentView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = NO;
        _imageView.accessibilityIdentifier = @"empty set background image";
        
        [_contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.accessibilityIdentifier = @"empty set title";
        
        [_contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.backgroundColor = [UIColor clearColor];
        
        _detailLabel.font = [UIFont systemFontOfSize:kHYDefaultDetailFontSize];
        _detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.numberOfLines = 0;
        _detailLabel.accessibilityIdentifier = @"empty set detail label";
        
        [_contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        _button.backgroundColor = [UIColor clearColor];
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _button.accessibilityIdentifier = @"empty set button";
        
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:_button];
    }
    return _button;
}

- (void)setCustomView:(UIView *)customView {
    
    if (!customView) {
        return;
    }
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    
    _customView = customView;
//    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:customView];
    [self.contentView bringSubviewToFront:customView];
    self.contentView.backgroundColor = [UIColor greenColor];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)setTitle:(NSAttributedString *)title {
    _title = title;
    if (title.length)
        self.titleLabel.attributedText = title;
    else
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = detailText;
    if (detailText.length)
        self.detailLabel.text = detailText;
    else
        self.detailLabel.text = @"";
}

- (void)setButtonTitle:(NSAttributedString *)buttonTitle {
    
    _buttonTitle = buttonTitle;
    if (buttonTitle.length)
        [self.button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    else
        [self.button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"" attributes:nil] forState:UIControlStateNormal];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)didMoveToSuperview {
    
    CGRect superviewBounds = self.superview.bounds;
    self.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(superviewBounds), CGRectGetHeight(superviewBounds));
    
    void(^fadeInBlock)(void) = ^{self.contentView.alpha = 1.0;};
    
//    if (YES) {
        [UIView animateWithDuration:0.25
                         animations:fadeInBlock
                         completion:NULL];
//    }else {
//        fadeInBlock();
//    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)didTapButton:(id)sender {
    
    if (self.clickBlock) {
        self.clickBlock();
    }

}

- (void)setupConstraints {
    // 首先，配置内容视图约束
    // 内容视图必须始终以其父视图为中心
    NSLayoutConstraint *centerXConstraint = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterX];
    NSLayoutConstraint *centerYConstraint = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterY];
    
    [self addConstraint:centerXConstraint];
    [self addConstraint:centerYConstraint];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];

    // 如果存在自定义试图，设置自定义视图的约束
    if (self.customView) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|" options:0 metrics:nil views:@{@"customView":_customView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|" options:0 metrics:nil views:@{@"customView":_customView}]];
    }else {
        CGFloat width = CGRectGetWidth(self.frame) ? : CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat padding = roundf(width/16.0);
        
        NSMutableArray *subviewStrings = [NSMutableArray array];
        NSMutableDictionary *views = [NSMutableDictionary dictionary];
        NSDictionary *metrics = @{@"padding": @(padding)};
        
        // 指定图像视图的水平约束
        if (_imageView.superview) {
            
            [subviewStrings addObject:@"imageView"];
            views[[subviewStrings lastObject]] = _imageView;
            
            [self.contentView addConstraint:[self.contentView equallyRelatedConstraintWithView:_imageView attribute:NSLayoutAttributeCenterX]];
        }
        
        // 分配标题标签的水平约束
        if (self.title.length) {
            
            [subviewStrings addObject:@"titleLabel"];
            views[[subviewStrings lastObject]] = _titleLabel;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[titleLabel(>=0)]-(padding@750)-|"
                                                                                     options:0 metrics:metrics views:views]];
            
        //从它的父视图中移除
        }else {
            [_titleLabel removeFromSuperview];
            _titleLabel = nil;
        }
        
        // 指定详情标签的水平约束
        if (self.detailText.length) {
            
            [subviewStrings addObject:@"detailLabel"];
            views[[subviewStrings lastObject]] = _detailLabel;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[detailLabel(>=0)]-(padding@750)-|"
                                                                                     options:0 metrics:metrics views:views]];
        
        //从它的父视图中移除
        }else {
            [_detailLabel removeFromSuperview];
            _detailLabel = nil;
        }
        
        // 指定按钮的水平约束
        if (self.buttonTitle.length) {
            
            [subviewStrings addObject:@"button"];
            views[[subviewStrings lastObject]] = _button;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[button(>=0)]-(padding@750)-|"
                                                                                     options:0 metrics:metrics views:views]];
            
        //从它的父视图中移除
        }else {
            [_button removeFromSuperview];
            _button = nil;
        }
        
        NSMutableString *verticalFormat = [NSMutableString new];
        //为垂直约束构建动态字符串格式，在每个元素之间添加空白。默认是kHYDefaultViewSpec。
        for (int i = 0; i < subviewStrings.count; i++) {
            
            NSString *string = subviewStrings[i];
            [verticalFormat appendFormat:@"[%@]", string];
            
            if (i < subviewStrings.count-1) {
                [verticalFormat appendFormat:@"-(%.f@750)-", kHYDefaultViewSpec];
            }
        }
        
        // 将垂直约束分配给内容视图
        if (verticalFormat.length > 0) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|%@|", verticalFormat]
                                                                                     options:0 metrics:metrics views:views]];
        }
    }
}

@end


@implementation UIView (DZNConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

@end
