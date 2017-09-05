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
 刷新显示文字
 */
@property (nonatomic,copy) NSString *text;

/**
 正在刷新回调
 */
@property (nonatomic,copy) ZRRefreshHeaderRefreshingHandler refreshingHandler;


/**
 控件的当前状态
 */
@property (nonatomic,readonly) ZRRefreshState refreshState;

/**
 水平平移随机范围,默认为150，
 平移值为 (- randomness)  ~ (randomness - 2) 范围内的偶数
 */
@property (nonatomic) CGFloat randomness;
/**
 最大下拉距离,下拉超过这个值且停止拖拽后开始刷新,
 默认 100.f
 */
@property (nonatomic,assign) CGFloat maxDropHeight;

+ (instancetype)refreshHeaderWithRefreshingHandler: (ZRRefreshHeaderRefreshingHandler)handler;

- (void)endRefreshing;
@end
