//
//  UIView+GKExtension.h
//  CancerAssistantV2
//
//  Created by GKY on 2017/5/22.
//  Copyright © 2017年 Run. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (GKExtension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat top;

- (UIImage *)screenshot;
- (UIImage *)screenshotWithRect:(CGRect)rect;

/**
 切割圆角
 
 @param radius 半径
 */
- (void)inciseCircularBeadWithRadius: (CGFloat)radius;

@end
