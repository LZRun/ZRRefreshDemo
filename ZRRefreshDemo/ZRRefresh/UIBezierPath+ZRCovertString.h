//
//  UIBezierPath+ZRCovertString.h
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/4.
//  Copyright © 2017年 Run. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (ZRCovertString)

+ (UIBezierPath *)bezierPathWithCovertedString: (NSString *)string attrinbutes: (NSDictionary *)attributes;
@end
