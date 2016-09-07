//
//  Configuration.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/2.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CJIsNull(a) (!a || (a)==nil || (a)==NULL || [a isKindOfClass:[NSNull class]])
#define PlaceholderColor [UIColor colorWithRed:0.7333 green:0.7294 blue:0.7608 alpha:1.0]

#if defined(DEBUG)||defined(_DEBUG)
#   define CJNSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define CJNSLog(fmt,...)
#endif

/**
 布局方向
 */
typedef enum : NSUInteger {
    horizontallyLayout = 0,//水平方向布局
    verticalLayout//垂直方向布局
} LayoutDirection;

/**
 *  获取子View的布局方向（默认水平方向 horizontallyLayout）
 */
static inline LayoutDirection ViewLayoutDirection(NSDictionary * _Nullable info) {
    LayoutDirection theDirectionLayout = horizontallyLayout;
    NSString *directionString = (info[@"layoutDirection"] && [info[@"layoutDirection"] length]>0)?info[@"layoutDirection"]:@"horizontally";
    if ([directionString isEqualToString:@"horizontally"]) {
        theDirectionLayout = horizontallyLayout;
    }else if ([directionString isEqualToString:@"vertical"]) {
        theDirectionLayout = verticalLayout;
    }else{
        theDirectionLayout = horizontallyLayout;
    }
    return theDirectionLayout;
}

/**
 水平方向的位置
 */
typedef enum : NSUInteger {
    horizontallyLeft = 0,//靠左
    horizontallyCenter,  //居中
    horizontallyRight    //靠右
} HorizontallyAlignmentType;

/**
 *  获取水平方向的位置（默认horizontallyLeft）
 */
static inline HorizontallyAlignmentType getHorizontallyAlignment(NSDictionary * _Nullable info) {
    HorizontallyAlignmentType horizontallyAlignment = horizontallyLeft;
    NSString *horizontallyString = (info[@"horizontallyAlignment"] && [info[@"horizontallyAlignment"] length]>0)?info[@"horizontallyAlignment"]:@"left";
    if ([horizontallyString isEqualToString:@"left"]) {
        horizontallyAlignment = horizontallyLeft;
    }else if ([horizontallyString isEqualToString:@"center"]) {
        horizontallyAlignment = horizontallyCenter;
    }else if ([horizontallyString isEqualToString:@"right"]) {
        horizontallyAlignment = horizontallyRight;
    }
    return horizontallyAlignment;
}

/**
 垂直方向的位置
 */
typedef enum : NSUInteger {
    verticalTop = 0, //居上
    verticalCenter,  //居中
    verticalBottom   //居下
} VerticalAlignmentType;

/**
 *  获取垂直方向的位置（默认verticalTop）
 */
static inline VerticalAlignmentType getVerticalAlignment(NSDictionary * _Nullable info) {
    VerticalAlignmentType verticalAlignment = verticalTop;
    NSString *verticalString = (info[@"verticalAlignment"] && [info[@"verticalAlignment"] length]>0)?info[@"verticalAlignment"]:@"top";
    if ([verticalString isEqualToString:@"top"]) {
        verticalAlignment = verticalTop;
    }else if ([verticalString isEqualToString:@"center"]) {
        verticalAlignment = verticalCenter;
    }else if ([verticalString isEqualToString:@"bottom"]) {
        verticalAlignment = verticalBottom;
    }
    return verticalAlignment;
}

@interface ConfigurationTool : NSObject

/**
 *  计算宽度／高度
 *
 *  传入的valueStr有三种情况：
 *         1、"0"     未确定，比如UILable的宽度确定，高度随文本内容动态变化的情况
 *         2、"0.5p"  按superValue的百分比取值； 0.5p = (superValue - 2 * padding)*0.5
 *         3、"44"    取具体数值44
 *
 *  @param valueStr   需要计算值的字符串
 *  @param superValue 父视图确定的值
 *  @param padding    内边距
 *
 *  @return
 */
+ (CGFloat)calculateValue:(NSString * _Nullable)valueStr superValue:(CGFloat)superValue padding:(CGFloat)padding;

/**
 *  计算NSString的Rect值
 *
 *  @param titleString
 *  @param titleFont
 *  @param width
 *  @param height
 *
 *  @return 
 */
+ (CGSize)calculateStringSize:(NSString *_Nullable)titleString
                    titleFont:(UIFont *_Nullable)titleFont
                        width:(CGFloat)width
                       height:(CGFloat)height;

/**
 *  根据16进制的NSString，返回一个颜色
 *  默认返回[UIColor blackColor]
 *
 *  @param hexString
 *
 *  @return
 */
+ (UIColor *_Nullable)colorWithHexString:(NSString *_Nullable)hexString;

// 根据key获取NSString
+ (NSString *_Nullable)stringFromInfo:(NSDictionary *_Nullable)info key:(NSString *_Nullable)key defaultValue:(NSString *_Nullable)defaultValue;
@end


@interface UIView (ConfigurationView)
/**
 *  自定义属性，用来描述view的id
 */
@property (nonatomic, copy) NSString *_Nullable idDescription;

/**
 *  根据idDescription获取view，
 *  可以是view本身，也可为nil
 *
 *  @param idDescription view的id声明
 *
 *  @return
 */
- (nullable __kindof UIView *)viewWithIdDescription:(nullable NSString *)idDescription;
@end
