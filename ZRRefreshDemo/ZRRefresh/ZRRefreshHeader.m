//
//  ZRRefreshHeader.m
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/1.
//  Copyright © 2017年 Run. All rights reserved.
//

#import "ZRRefreshHeader.h"
#import "UIBezierPath+ZRCovertString.h"

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
 便宜量
 */
@property (nonatomic,assign) CGFloat contentInsetTop;

@end

@implementation ZRRefreshHeader
+ (instancetype)refreshHeaderWithRefreshingHandler: (ZRRefreshHeaderRefreshingHandler)handler{
    ZRRefreshHeader *header = [[self alloc] initWithFrame:CGRectMake(0,-100, [UIScreen mainScreen].bounds.size.width, 100)];
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
        self.contentInsetTop = _superScrollView.contentInset.top;
        [_superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

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

- (void)dealloc{
    [_superScrollView removeObserver:self forKeyPath:@"contentOffset"];
}
#pragma mark - config
- (void)configHeader{
    self.backgroundColor = [UIColor clearColor];
    self.layer.geometryFlipped = YES;
    [self.layer addSublayer:self.animationLayer];
    
    self.randomness = 150;
    self.maxDropHeight = 80;
    _refreshState = ZRRefreshStateIdle;
    self.text = @"Loading";
}
- (void)reloadPath{
    UIBezierPath *path = [UIBezierPath bezierPathWithCovertedString:_text attrinbutes:@{NSFontAttributeName : [UIFont systemFontOfSize:50]}];
    CGRect stringBounds = path.bounds;
    CGFloat paddingX = (self.bounds.size.width - stringBounds.size.width) / 2;
    CGFloat padingY = (self.bounds.size.height - stringBounds.size.height) / 2;
    
    _animationLayer.frame = CGRectMake(paddingX, padingY, stringBounds.size.width, stringBounds.size.height);
    _animationLayer.path = path.CGPath;
    
    NSMutableArray *allPoints = [path pointsInPath];
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
                startPoint.x += paddingX;
                startPoint.y += padingY;
                CGPoint endPoint = [pathPoints[idx + 1] CGPointValue];
                endPoint.x += paddingX;
                endPoint.y += padingY;
                
                CAShapeLayer *dropLayer = [self dropAnimationLayerWithStartPoint:startPoint endPoint:endPoint];
                [self.layer addSublayer:dropLayer];
                [_dropLayers addObject:dropLayer];
            }
        }];
    }
}

- (void)executeDropAnimationWithProgresss: (CGFloat)progress{
    NSLog(@"progress == %f",progress);
    for (CALayer *dropLayer in _dropLayers) {
        dropLayer.timeOffset = progress;
    }
}

- (void)executeRefreshAnimaiton{
    [_animationLayer addAnimation:self.refreshingAnimation forKey:nil];
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

#pragma mark - getting
- (CAShapeLayer *)animationLayer{
    if (!_animationLayer) {
        _animationLayer = [CAShapeLayer layer];
        _animationLayer.bounds = self.bounds;
        _animationLayer.position = self.center;
        _animationLayer.strokeColor = [UIColor redColor].CGColor;
        _animationLayer.fillColor = [UIColor clearColor].CGColor;
        _animationLayer.lineJoin = kCALineJoinRound;
        _animationLayer.lineCap = kCALineCapRound;
        _animationLayer.lineWidth = 2;
        _animationLayer.strokeEnd = 0;
    }
    return _animationLayer;
}

- (CAShapeLayer *)dropAnimationLayerWithStartPoint:(CGPoint)startPoint endPoint: (CGPoint)endPoint {
    CAShapeLayer *dropLayer = [CAShapeLayer layer];
    dropLayer.frame = self.bounds;
    //dropLayer.bounds = self.bounds;
    //dropLayer.position = self.center;
    dropLayer.strokeColor = [UIColor redColor].CGColor;
    dropLayer.fillColor = [UIColor clearColor].CGColor;
    dropLayer.lineJoin = kCALineJoinRound;
    dropLayer.lineCap = kCALineCapRound;
    dropLayer.lineWidth = 2.f;
    dropLayer.speed = 0;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    dropLayer.path = path.CGPath;
    
    //animation
    int translationX = arc4random_uniform(_randomness) * 2 - _randomness;
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    positionAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(translationX,self.frame.size.height/2, 0)];
    positionAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];


    CABasicAnimation *rotationAnimaiton = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimaiton.fromValue = @(M_PI_4);
    rotationAnimaiton.toValue = @0;
    
    CABasicAnimation *scaleAniamtion = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAniamtion.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];
    scaleAniamtion.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = @0.3;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionAnimation/*,rotationAnimaiton*/,scaleAniamtion,opacityAnimation];
    group.duration = 1;
    [dropLayer addAnimation:group forKey:nil];
    return dropLayer;
}

- (CAAnimation *)refreshingAnimation{
    CABasicAnimation *animaiton = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animaiton.toValue = @1;
    animaiton.duration = 3;
    animaiton.repeatCount = HUGE_VALF;
    return animaiton;
}

#pragma mark - setting
- (void)setText:(NSString *)text{
    if (_text != text) {
        _text = [text copy];
        [self reloadPath];
    }
}
@end
