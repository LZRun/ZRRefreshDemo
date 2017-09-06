//
//  ZRRefreshAnimationConfig.m
//  ZRRefreshDemo
//
//  Created by Run on 2017/9/6.
//  Copyright © 2017年 Run. All rights reserved.
//

#import "ZRRefreshAnimationConfig.h"

@implementation ZRRefreshAnimationConfig
@synthesize refreshingAnimation = _refreshingAnimation;

+ (instancetype)animationConfig{
    return [[self alloc]init];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _randomness = 150;
        _repeatCount = HUGE_VALF;
        _duration = 3;
        _autoreverses = YES;
        _animationType = ZRRefreshingAnimationTypeMidToSide;
    }
    return self;
}

- (CAAnimation *)refreshingAnimation{
    //if (!_refreshingAnimation) {
    _refreshingAnimation = [ZRAnimationFactory refreshingAnimationWithAnimationType:_animationType];
    _refreshingAnimation.repeatCount = _repeatCount;
    _refreshingAnimation.duration = _duration;
    _refreshingAnimation.autoreverses = _autoreverses;
    //}
    return _refreshingAnimation;
}
@end
