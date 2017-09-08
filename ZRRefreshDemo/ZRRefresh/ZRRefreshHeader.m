//
//  ZRRefreshHeader.m
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/1.
//  Copyright © 2017年 Run. All rights reserved.
//

#import "ZRRefreshHeader.h"
#import "UIBezierPath+ZRCovertString.h"

static CGFloat const kRefreshHeaderHeight = 80;
@interface  ZRRefreshHeader ()
@property (nonatomic,weak) UIScrollView *superScrollView;
/**
 刷新动画视图
 */
@property (nonatomic,strong) CAShapeLayer *animationLayer;
/**
 下拉刷新layers
 */
@property (nonatomic,strong) NSMutableArray<CAShapeLayer *> *dropLayers;
/**
 偏移量
 */
@property (nonatomic,assign) CGFloat contentInsetTop;
/**
 文字路径
 */
@property (nonatomic,strong) UIBezierPath *textPath;

@end

@implementation ZRRefreshHeader

@synthesize animationConfig = _animationConfig;

+ (instancetype)refreshHeaderWithRefreshingHandler: (ZRRefreshHeaderRefreshingHandler)handler{
    return  [self refreshHeaderWithAnimationConfig:nil refreshingHandler:handler];
}
+ (instancetype)refreshHeaderWithAnimationConfig: (ZRRefreshAnimationConfig *)animationConfig refreshingHandler: (ZRRefreshHeaderRefreshingHandler)handler{
    ZRRefreshHeader *header = [[self alloc] initWithFrame:CGRectZero];
    if (header) {
        //不调用set方法
        header -> _animationConfig = animationConfig;
        [header setUpAnimaitonConfigViewHeightHandler];
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
    [super willMoveToSuperview:newSuperview];
    //移除父视图KVO
    [self removeObserver];
    if (newSuperview && [newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
        self.frame = CGRectMake(0, - kRefreshHeaderHeight, _superScrollView.frame.size.width, kRefreshHeaderHeight);
        _superScrollView.alwaysBounceVertical = YES;
        self.contentInsetTop = _superScrollView.contentInset.top;
        [self addObserver];
        
        //绘制文字
        [self reloadPath];
    }
}

- (void)layoutSubviews{
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    self.frame = frame;
    
    [self placeLayer];
    [super layoutSubviews];
}
- (void)dealloc{
    [self removeObserver];
}
#pragma mark - config
- (void)configHeader{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.layer.geometryFlipped = YES;
    
    self.maxDropHeight = 80;
    _refreshState = ZRRefreshStateIdle;
    _text = @"Loading";
    _textFont = [UIFont systemFontOfSize:50];
    _textColor = [UIColor redColor];
    _refresingLineColor = [UIColor blackColor];
    
    [self.layer addSublayer:self.animationLayer];
}

- (void)reloadPath{
    self.textPath = [UIBezierPath bezierPathWithCovertedString:_text attrinbutes:@{NSFontAttributeName : _textFont}];
    _animationLayer.path = _textPath.CGPath;
    
    NSMutableArray *allPoints = [_textPath pointsInPath];
    if (self.dropLayers) {
        [self.dropLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.dropLayers removeAllObjects];
    }else{
       self.dropLayers = [NSMutableArray array];
    }
    for (NSArray *pathPoints in allPoints) {
        //忽略少于2个点的路径数组
        if (pathPoints.count < 2) {
            continue;
        }
        //以0开始，到倒数第二个截止添加线条
        NSInteger lastCout = pathPoints.count - 1;
        [pathPoints enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < lastCout) {
                CGPoint startPoint = obj.CGPointValue;
                CGPoint endPoint = [pathPoints[idx + 1] CGPointValue];
                //分割所有线条
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:startPoint];
                [path addLineToPoint:endPoint];

                CAShapeLayer *dropLayer = [self dropAnimationLayerWithPath:path];
                [self.layer addSublayer:dropLayer];
                [_dropLayers addObject:dropLayer];
            }
        }];
    }
    [self placeLayer];
    
    [_animationLayer removeFromSuperlayer];
    [self.layer addSublayer:_animationLayer];
}
//对layar布局
- (void)placeLayer{
    if (!_textPath) {
        return;
    }
    CGRect stringBounds = _textPath.bounds;
    CGFloat paddingX = (self.bounds.size.width - stringBounds.size.width) / 2;
    CGFloat padingY =  (self.bounds.size.height - stringBounds.size.height) / 2;
    
    CGRect layerFrame = CGRectMake(paddingX, padingY, stringBounds.size.width, stringBounds.size.height);
    _animationLayer.frame = layerFrame;
    [_dropLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = layerFrame;
    }];
}
//配置AnimaitonConfig回调函数
- (void)setUpAnimaitonConfigViewHeightHandler{
    __weak ZRRefreshHeader *weakSelf = self;
    _animationConfig.viewHeightHandler = ^CGFloat (void){
        return weakSelf.frame.size.height;
    };
}
#pragma mark - animaiton
- (void)executeDropAnimationWithProgresss: (CGFloat)progress{
    //NSLog(@"progress == %f",progress);
    NSInteger count = _dropLayers.count - 1;
    [_dropLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //控制动画完成速率，保证动画逐步完成
        CGFloat timeOffset = progress * (count * 2 - idx) / count;
        timeOffset = MIN(timeOffset, 1);
        obj.timeOffset = timeOffset;
    }];
}

- (void)executeRefreshAnimaiton{
    [_animationLayer addAnimation:self.animationConfig.refreshingAnimation forKey:nil];
    if (_refreshingHandler) {
        _refreshingHandler();
    }
}
#pragma mark - public
- (void)endRefreshing{
    _refreshState = ZRRefreshStateIdle;
    [_animationLayer removeAllAnimations];
    UIEdgeInsets edgeInsets = _superScrollView.contentInset;
    edgeInsets.top = _contentInsetTop;
    [UIView animateWithDuration:0.3 animations:^{
        _superScrollView.contentInset =  edgeInsets;
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }
    CGFloat contentOffsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
    NSLog(@"contentOffset = %f",contentOffsetY);
    
    CGFloat realContentOffSet = contentOffsetY - _contentInsetTop;
    if (realContentOffSet <= 0 && _refreshState != ZRRefreshStateRefreshing) {
        CGFloat dropRate = - realContentOffSet / _maxDropHeight;
        dropRate = MIN(dropRate, 1);
        [self executeDropAnimationWithProgresss:dropRate];
        
        if (!_superScrollView.dragging && dropRate == 1){
            _refreshState = ZRRefreshStateRefreshing;
            UIEdgeInsets edgeInsets = _superScrollView.contentInset;
            edgeInsets.top += _maxDropHeight;
            _superScrollView.contentInset =  edgeInsets;
            [self executeRefreshAnimaiton];
        }
    }
}
- (void)addObserver{
    [_superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver{
    [_superScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - getLayer
- (CAShapeLayer *)animationLayer{
    if (!_animationLayer) {
        _animationLayer = [CAShapeLayer layer];
        _animationLayer.bounds = self.bounds;
        _animationLayer.position = self.center;
        _animationLayer.strokeColor = _refresingLineColor.CGColor;
        _animationLayer.fillColor = [UIColor clearColor].CGColor;
        _animationLayer.lineJoin = kCALineJoinRound;
        _animationLayer.lineCap = kCALineCapRound;
        _animationLayer.lineWidth = 2;
        _animationLayer.strokeEnd = 0;
        _animationLayer.strokeStart = 0;
    }
    return _animationLayer;
}
- (CAShapeLayer *)dropAnimationLayerWithPath: (UIBezierPath *)path {
    CAShapeLayer *dropLayer = [CAShapeLayer layer];
    //dropLayer.frame = self.bounds;
    //dropLayer.bounds = self.bounds;
    //dropLayer.position = self.center;
    dropLayer.strokeColor = _textColor.CGColor;
    dropLayer.fillColor = [UIColor clearColor].CGColor;
    dropLayer.lineJoin = kCALineJoinRound;
    dropLayer.lineCap = kCALineCapRound;
    dropLayer.lineWidth = 2.f;
    dropLayer.speed = 0;
    dropLayer.path = path.CGPath;
    
    [dropLayer addAnimation:self.animationConfig.pullingAnimation forKey:nil];
    return dropLayer;
}

#pragma mark - setting,getting
- (void)setText:(NSString *)text{
    if (_text != text) {
        _text = [text copy];
        [self reloadPath];
    }
}
- (void)setTextFont:(UIFont *)textFont{
    if (_textFont != textFont) {
        _textFont = textFont;
        [self reloadPath];
    }
}

- (void)setTextColor:(UIColor *)textColor{
    if (_textColor != textColor) {
        _textColor = textColor;
        [_dropLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.strokeColor = textColor.CGColor;
        }];
    }
}
- (void)setRefresingLineColor:(UIColor *)refresingLineColor{
    if (_refresingLineColor != refresingLineColor) {
        _refresingLineColor = refresingLineColor;
        _animationLayer.strokeColor = refresingLineColor.CGColor;
    }
}

- (ZRRefreshAnimationConfig *)animationConfig{
    if (!_animationConfig) {
        _animationConfig = [[ZRRefreshAnimationConfig alloc]init];
        [self setUpAnimaitonConfigViewHeightHandler];
    }
    return _animationConfig;
}

- (void)setAnimationConfig:(ZRRefreshAnimationConfig *)animationConfig{
    if (_animationConfig != animationConfig) {
        _animationConfig = animationConfig;
        [self setUpAnimaitonConfigViewHeightHandler];
        [self reloadPath];
    }
}
@end
