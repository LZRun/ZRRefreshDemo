//
//  ZRRefreshHeader.m
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/1.
//  Copyright © 2017年 Run. All rights reserved.
//

#import "ZRRefreshHeader.h"

@interface  ZRRefreshHeader ()
@property (nonatomic,weak) UIScrollView *superScrollView;
/**
 动画视图
 */
@property (nonatomic,strong) CAShapeLayer *animationLayer;

@end

@implementation ZRRefreshHeader
+ (instancetype)refreshHeaderWithRefreshingHandler: (ZRRefreshHeaderRefreshingHandler)handler{
    ZRRefreshHeader *header = [[self alloc] initWithFrame:CGRectZero];
    if (header) {
        header.refreshingHandler = handler;
    }
    return header;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configHeader];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview && [newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
        [_superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }
}

- (void)dealloc{
    [_superScrollView removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)configHeader{
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - getting
- (CAShapeLayer *)animationLayer{
    if (!_animationLayer) {
        _animationLayer = [CAShapeLayer layer];
        _animationLayer.strokeColor = [UIColor redColor].CGColor;
        _animationLayer.fillColor = [UIColor clearColor].CGColor;
        _animationLayer.lineJoin = kCALineJoinRound;
        _animationLayer.lineCap = kCALineCapRound;
        _animationLayer.lineWidth = 2;
        _animationLayer.strokeEnd = 0;
    }
    return _animationLayer;
}

- (void)setText:(NSString *)text{
    if (_text != text) {
        _text = [text copy];
    }
}
@end
