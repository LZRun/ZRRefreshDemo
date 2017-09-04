//
//  ZRRefreshHeader.h
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/1.
//  Copyright © 2017年 Run. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 正在刷新的回调
 */
typedef void(^ZRRefreshHeaderRefreshingHandler)(void);
@interface ZRRefreshHeader : UIView

/**
 刷新显示文字
 */
@property (nonatomic,copy) NSString *text;

@property (nonatomic,copy) ZRRefreshHeaderRefreshingHandler refreshingHandler;

+ (instancetype)refreshHeaderWithRefreshingHandler: (ZRRefreshHeaderRefreshingHandler)handler;
@end
