//
//  TLMaskView.m
//  TLKit
//
//  Created by libokun on 2021/1/1.
//

#import "TLMaskView.h"
#import "UIColor+TLKit.h"
#import <Masonry/Masonry.h>

@interface TLMaskView ()

@property (nonatomic, strong) UIWindow *displayWindow;
@property (nonatomic, strong) UIVisualEffectView *effectview;

@end

@implementation TLMaskView
@synthesize isShowing = _isShowing;

- (instancetype)initWithStyle:(TLMaskViewStyle)style
{
    if (self = [self initWithFrame:CGRectZero]) {
        self.style = style;
    }
    return self;;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _animationDuration = 0.15;
        _animated = YES;
        [self setBackgroundColor:[UIColor colorShadow]];
        [self setDisableTapEvent:NO];
    }
    return self;
}

- (void)setStyle:(TLMaskViewStyle)style
{
    if (_style == style) {
        return;
    }
    _style = style;
    [self setBackgroundColor:[UIColor clearColor]];
    if (style == TLMaskViewStyleTranslucent) {
        [self setBackgroundColor:[UIColor colorShadow]];
    }
    else if (style == TLMaskViewStyleBlur) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        if (@available(iOS 12.0, *)) {
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            }
        }
        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        [effectview setUserInteractionEnabled:NO];
        _effectview = effectview;
        [self insertSubview:self.effectview atIndex:0];
        [self.effectview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
        }];
    }
}

- (void)setDisableTapEvent:(BOOL)disableTapEvent
{
    _disableTapEvent = disableTapEvent;
    [self removeTarget:self action:@selector(tapEventAction) forControlEvents:UIControlEventTouchUpInside];
    if (!disableTapEvent) {
        [self addTarget:self action:@selector(tapEventAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)tapEventAction
{
    if (self.tapAction) {
        self.tapAction(self);
        return;
    }
    [self dismissWithAnimated:self.animated];
}

#pragma mark - # 显示与隐藏
- (void)show
{
    [self showWithAnimated:self.animated];
}

- (void)showWithAnimated:(BOOL)animated
{
    [self showInView:nil animated:animated];
}

- (void)showInView:(__kindof UIView *)view
{
    [self showInView:view animated:self.animated];
}

- (void)showInView:(__kindof UIView *)view animated:(BOOL)animated
{
    if (self.isShowing) {
        return;
    }
    self.animated = animated;
    self.isShowing = YES;
    
    // 处理父视图
    UIView *targetView = view;
    if (!targetView) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIViewController *vc = [[UIViewController alloc] init];
        [vc.view setBackgroundColor:[UIColor clearColor]];
        [window setRootViewController:vc];
        [window setBackgroundColor:[UIColor clearColor]];
        [window makeKeyAndVisible];
        targetView = self.displayWindow = window;
    }
    [self removeFromSuperview];
    [targetView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self layoutIfNeeded];
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:self.animationDuration animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)dismiss
{
    [self dismissWithAnimated:self.animated];
}

- (void)dismissWithAnimated:(BOOL)animated
{
    if (!self.isShowing) {
        return;
    }
    void (^dismissedAction)(void) = ^{
        self.displayWindow.rootViewController = nil;
        [self.displayWindow resignKeyWindow];
        self.displayWindow = nil;
        [self removeFromSuperview];
        self.isShowing = NO;
    };
    if (animated) {
        [UIView animateWithDuration:self.animationDuration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            dismissedAction();
        }];
    }
    else {
        dismissedAction();
    }
}

#pragma mark - # Getter
- (void)setIsShowing:(BOOL)isShowing
{
    _isShowing = isShowing;
}

@end
