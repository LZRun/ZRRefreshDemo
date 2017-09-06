//
//  ZRRefreshHeader.h
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/1.
//  Copyright © 2017年 Run. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 刷新控件状态
 */
typedef NS_ENUM(NSUInteger, ZRRefreshState) {
    ZRRefreshStateIdle = 0, //闲置状态
    ZRRefreshStateRefreshing,//正在刷新状态
};
/**
 正在刷新的回调
 */
typedef void(^ZRRefreshHeaderRefreshingHandler)(void);
@interface ZRRefreshHeader : UIView

/**
 正在刷新回调
 */
@property (nonatomic,copy) ZRRefreshHeaderRefreshingHandler refreshingHandler;
/**
 刷新显示文字 默认Loading
 */
@property (nonatomic,copy) NSString *text;
/**
 刷新显示文字颜色,默认 [UIColor redColor]
 */
@property (nonatomic,strong) UIColor *textColor;
/**
 刷新显示文字字体 [UIFont systemFontOfSize:50]
 */
@property (nonatomic,strong) UIFont *textFont;

/**
 控件的当前状态
 */
@property (nonatomic,readonly) ZRRefreshState refreshState;
/**
 最大下拉距离,下拉超过这个值且停止拖拽后开始刷新,
 默认 80.f
 */
@property (nonatomic,assign) CGFloat maxDropHeight;

/**
 水平平移随机范围,默认为150，
 平移值为 (- randomness)  ~ (randomness - 2) 范围内的偶数
 */
@property (nonatomic) CGFloat randomness;

+ (instancetype)refreshHeaderWithRefreshingHandler: (ZRRefreshHeaderRefreshingHandler)handler;

- (void)endRefreshing;
@end
