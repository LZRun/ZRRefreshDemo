//
//  UIBezierPath+ZRCovertString.m
//  ZRRefreshDemo
//
//  Created by GKY on 2017/9/4.
//  Copyright © 2017年 Run. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "UIBezierPath+ZRCovertString.h"

@implementation UIBezierPath (ZRCovertString)

- (UIBezierPath *)pathWithCovertedString: (NSString *)string attrinbutes: (NSDictionary *)attributes{
    NSAssert(string && attributes, @"字符串或");
    NSAttributedString *attritutedString = [[NSAttributedString alloc]initWithString:string attributes:attributes];
    //创建总路径
    CGMutablePathRef pathRef = CGPathCreateMutable();
    //解析字形
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attritutedString); //行
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    for (CFIndex index = 0; index < CFArrayGetCount(runs); index ++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, index);
        CTFontRef font = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        for (CFIndex glyphIndex = 0; glyphIndex < CTRunGetGlyphCount(run); glyphIndex ++) {
            CFRange range = CFRangeMake(glyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, range, &glyph);
            CTRunGetPositions(run, range, &position);
            {
                CGPathRef glyphPath = CTFontCreatePathForGlyph(font, glyph, NULL);
                CGAffineTransform transform = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(pathRef, &transform, glyphPath);
                CGPathRelease(glyphPath);
            }
        }
    }
    
    //转换为bezierPath
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:pathRef]];
    //释放C对象
    CGPathRelease(pathRef);
    CFRelease(line);
    
    return bezierPath;
}
@end
