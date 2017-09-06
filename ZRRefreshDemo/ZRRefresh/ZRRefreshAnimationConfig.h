//
//  ZRRefreshAnimationConfig.h
//  ZRRefreshDemo
//
//  Created by Run on 2017/9/6.
//  Copyright © 2017年 Run. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZRAnimationFactory.h"

@interface ZRRefreshAnimationConfig : NSObject

+ (instancetype)animationConfig;
/**
 水平平移随机范围,默认为150，
 平移值为 (- randomness)  ~ (randomness - 2) 范围内的偶数
 */
@property (nonatomic) CGFloat randomness;

@property (nonatomic) CGFloat repeatCount;

@property (nonatomic) CGFloat duration;

@property (nonatomic) BOOL autoreverses;
/**
 动画类型
 */
@property (nonatomic) ZRRefreshingAnimationType animationType;

/**
 正在刷新的动画
 */
@property (nonatomic,strong,readonly) CAAnimation *refreshingAnimation;

@end
