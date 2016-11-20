//
//  Configuration.m
//  listDemo
//
//  Created by ChiJinLian on 16/9/2.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import "ConfigurationTool.h"
#import <objc/runtime.h>

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

CGFloat CGFloatForLayoutKey(NSDictionary *layout, NSString *key) {
    return layout[key]?[layout[key] floatValue]:0;
}

NSString * NSStringForInfoKey(NSDictionary *_Nullable info, NSString *_Nullable key, NSString *_Nullable defaultValue, BOOL lowercase) {
    id obj = [info objectForKey:key];
    if ([obj isKindOfClass:[NSString class]] &&[(NSString *)obj length]>0) {
        return lowercase?[(NSString *)obj lowercaseString]:(NSString *)obj;
    }else{
        return (!CJIsNull(defaultValue))?defaultValue:@"";
    }
}

BOOL BOOLForInfoKey(NSDictionary *_Nullable info, NSString *_Nullable key) {
    return [[info objectForKey:key] boolValue];
}

LayoutDirection ViewLayoutDirection(NSDictionary * _Nullable info) {
    LayoutDirection theDirectionLayout = horizontallyLayout;
    NSString *directionString = NSStringForInfoKey(info, kLayoutDirection, kHorizontally, YES);
    if ([directionString isEqualToString:[kHorizontally lowercaseString]]) {
        theDirectionLayout = horizontallyLayout;
    }else if ([directionString isEqualToString:[kVertical lowercaseString]]) {
        theDirectionLayout = verticalLayout;
    }
    return theDirectionLayout;
}

HorizontallyAlignmentType getHorizontallyAlignment(NSDictionary * _Nullable info) {
    HorizontallyAlignmentType horizontallyAlignment = horizontallyLeftWidth;
    NSString *horizontallyString = NSStringForInfoKey(info, kHorizontallyAlignment, kLeftWidth, YES);
    if ([horizontallyString isEqualToString:[kLeftWidth lowercaseString]]) {
        horizontallyAlignment = horizontallyLeftWidth;
    }else if ([horizontallyString isEqualToString:[kCenter lowercaseString]]) {
        horizontallyAlignment = horizontallyCenter;
    }else if ([horizontallyString isEqualToString:[kWidthRight lowercaseString]]) {
        horizontallyAlignment = horizontallyWidthRight;
    }else if ([horizontallyString isEqualToString:[kLeftRight lowercaseString]]) {
        horizontallyAlignment = horizontallyLeftRight;
    }
    return horizontallyAlignment;
}

VerticalAlignmentType getVerticalAlignment(NSDictionary * _Nullable info) {
    VerticalAlignmentType verticalAlignment = verticalTopHeight;
    NSString *verticalString = NSStringForInfoKey(info, kVerticalAlignment, kTopHeight, YES);
    if ([verticalString isEqualToString:[kTopHeight lowercaseString]]) {
        verticalAlignment = verticalTopHeight;
    }else if ([verticalString isEqualToString:[kCenter lowercaseString]]) {
        verticalAlignment = verticalCenter;
    }else if ([verticalString isEqualToString:[kHeightBottom lowercaseString]]) {
        verticalAlignment = verticalHeightBottom;
    }else if ([verticalString isEqualToString:[kTopBottom lowercaseString]]) {
        verticalAlignment = verticalTopBottom;
    }
    return verticalAlignment;
}


@implementation ConfigurationTool

+ (CGSize)calculateStringSize:(NSString *)titleString titleFont:(UIFont *)titleFont width:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeZero;
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    [attDic setObject:titleFont forKey:NSFontAttributeName];
    
    CGSize strSize = [titleString boundingRectWithSize:CGSizeMake(width, height)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:attDic
                                               context:nil].size;
    
    size = CGSizeMake(CGFloat_ceil(strSize.width), CGFloat_ceil(strSize.height));
    return size;
}

/**
 *  计算宽度／高度
 *
 *  传入的valueStr有三种情况：
 *         1、"0"     未确定，比如UILable的宽度确定，高度随文本内容动态变化的情况
 *         2、"0.5p"  按superValue的百分比取值； 0.5p = (superValue - padding)*0.5
 *         3、"44"    取具体数值44
 *
 *  @param valueStr   需要计算值的字符串
 *  @param superValue 父视图确定的值
 *  @param padding    内边距的值
 *
 *  @return
 */
+ (CGFloat)calculateValue:(NSString * _Nullable)valueStr superValue:(CGFloat)superValue padding:(CGFloat)padding {
    CGFloat value = 0;
    if (([valueStr isKindOfClass:[NSString class]])&&([valueStr hasSuffix:@"p"] || [valueStr hasSuffix:@"P"])){
        if ([valueStr hasSuffix:@"p"]) {
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@"p" withString:@""];
        }else if ([valueStr hasSuffix:@"P"]){
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@"P" withString:@""];
        }
        value = [valueStr floatValue]>1?1:[valueStr floatValue];
        value = (superValue - padding) * value;
    }else{
        value = [valueStr floatValue];
    }
    return value;
}

//根据布局方向计算当前Value值
+ (CGFloat)calculateValue:(ConfigurationModel *)info directionLayout:(LayoutDirection)directionLayout superValue:(CGFloat)superValue isWidth:(BOOL)isWidth {
    CGFloat value = 0;
    if (isWidth) {//计算宽度
        if (getHorizontallyAlignment(info.layout) == horizontallyLeftRight) {
            CGFloat leftPadding = CGFloatForLayoutKey(info.layout, kLeftPadding);
            CGFloat rightPadding = CGFloatForLayoutKey(info.layout, kRightPadding);
            value = superValue - leftPadding - rightPadding;
        }else{
            //子View是垂直方向布局
            if (directionLayout == verticalLayout) {
                CGFloat leftPadding = CGFloatForLayoutKey(info.layout, kLeftPadding);
                CGFloat rightPadding = CGFloatForLayoutKey(info.layout, kRightPadding);
                value = [self calculateValue:info.layout[kWidth] superValue:superValue padding:leftPadding+rightPadding];
            }else if (directionLayout == horizontallyLayout) {
                //子view水平方向布局时superValue已经减去了所有子view的内边距，所以这里不用再计算padding了
                value = [self calculateValue:info.layout[kWidth] superValue:superValue padding:0];
            }
        }
    }else {
        if (getVerticalAlignment(info.layout) == verticalTopBottom) {
            CGFloat topPadding = CGFloatForLayoutKey(info.layout, kTopPadding);
            CGFloat bottomPadding = CGFloatForLayoutKey(info.layout, kBottomPadding);
            value = superValue - topPadding - bottomPadding;
        }else{
            //子View是垂直方向布局
            if (directionLayout == verticalLayout) {
                //子view垂直方向布局时superValue已经减去了所有子view的内边距，所以这里不用再计算padding了
                value = [self calculateValue:info.layout[kHeight] superValue:superValue padding:0];
            }else if (directionLayout == horizontallyLayout) {
                CGFloat topPadding = CGFloatForLayoutKey(info.layout, kTopPadding);
                CGFloat bottomPadding = CGFloatForLayoutKey(info.layout, kBottomPadding);
                value = [self calculateValue:info.layout[kHeight] superValue:superValue padding:topPadding+bottomPadding];
            }
        }
    }
    return value;
}

+ (CGFloat)superViewWidthAccordingToPadding:(ConfigurationModel *_Nullable)info superWidth:(CGFloat)superWidth {
    LayoutDirection directionLayout = ViewLayoutDirection(info.layout);
    if (directionLayout == horizontallyLayout) {//子view水平布局
        return [self superViewValueWithoutPadding:info superValue:superWidth width:YES];
    }else {
        return superWidth;
    }
}

+ (CGFloat)superViewHeightAccordingToPadding:(ConfigurationModel *_Nullable)info superHeight:(CGFloat)superHeight {
    LayoutDirection directionLayout = ViewLayoutDirection(info.layout);
    if (directionLayout == verticalLayout) {//子view垂直布局
        return [self superViewValueWithoutPadding:info superValue:superHeight width:NO];
    }else {
        return superHeight;
    }
}

+ (CGFloat)superViewValueWithoutPadding:(ConfigurationModel *_Nullable)info superValue:(CGFloat)superValue width:(BOOL)width {
    CGFloat padding = 0;
    NSArray *subviews = info.layout[kSubviews];
    if (subviews || subviews.count > 0) {
        if (width) {
            for (ConfigurationModel *childModel in subviews) {
                CGFloat leftPadding = CGFloatForLayoutKey(childModel.layout, kLeftPadding);
                CGFloat rightPadding = CGFloatForLayoutKey(childModel.layout, kRightPadding);
                padding = padding + leftPadding + rightPadding;
            }
        }else{
            for (ConfigurationModel *childModel in subviews) {
                CGFloat topPadding = CGFloatForLayoutKey(childModel.layout, kTopPadding);
                CGFloat bottomPadding = CGFloatForLayoutKey(childModel.layout, kBottomPadding);
                padding = padding + topPadding + bottomPadding;
            }
        }
        return superValue - padding;
    }else{
        return superValue;
    }
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    BOOL successFlag = YES;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            NSLog(@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            successFlag = NO;
            alpha = red = blue = green = 0.0f;
            break;
    }
    if (successFlag) {
        return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    } else {
        return [UIColor blackColor];
    }
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end


@implementation UIView (ConfigurationView)

static char idDescriptionStrKey;
- (void)setIdDescription:(NSString *)idDescription{
    //OBJC_ASSOCIATION_COPY_NONATOMIC跟属性声明中的retain、assign、copy是一样
    objc_setAssociatedObject(self, &idDescriptionStrKey, idDescription, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)idDescription{
    return objc_getAssociatedObject(self, &idDescriptionStrKey);
}

- (nullable __kindof UIView *)viewWithIdDescription:(nullable NSString *)idDescription {
    return [self viewWithIdDescription:idDescription fromSuperView:self];
}

- (nullable __kindof UIView *)viewWithIdDescription:(nullable NSString *)idDescription fromSuperView:(UIView *)superView {
    UIView *view = nil;
    if (CJIsNull(idDescription) || [idDescription length]==0) {
        return view;
    }
    if ([superView.idDescription isEqualToString:idDescription]) {
        view = superView;
    }else{
        if (superView.subviews.count > 0){
            for (UIView *childView in superView.subviews) {
                UIView *theView = [self viewWithIdDescription:idDescription fromSuperView:childView];
                if (theView && nil != theView) {
                    view = theView;
                    break;
                }
            }
        }
    }
    return view;
}

@end
