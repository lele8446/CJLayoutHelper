//
//  Configuration.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/2.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConfigurationModel.h"

#define CJIsNull(a) (!a || (a)==nil || (a)==NULL || [a isKindOfClass:[NSNull class]])
#define PlaceholderColor [UIColor colorWithRed:0.7333 green:0.7294 blue:0.7608 alpha:1.0]

#if defined(DEBUG)||defined(_DEBUG)
#   define CJNSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define CJNSLog(fmt,...)
#endif

/**
 *  根据key获取CGFloat，默认0
 *
 *  @param layout
 *  @param key
 *
 *  @return
 */
FOUNDATION_EXPORT CGFloat CGFloatForLayoutKey(NSDictionary *_Nullable layout, NSString *_Nullable key);

/**
 *  根据key获取NSString
 *
 *  @param info
 *  @param key
 *  @param defaultValue 默认值
 *  @param lowercase    是否转换为小写
 *
 *  @return
 */
FOUNDATION_EXPORT NSString *_Nonnull NSStringForInfoKey(NSDictionary *_Nullable info, NSString *_Nullable key, NSString *_Nullable defaultValue, BOOL lowercase);

/**
 *  根据key获取BOOL，默认NO
 *
 *  @param info
 *  @param key
 *
 *  @return
 */
FOUNDATION_EXPORT BOOL BOOLForInfoKey(NSDictionary *_Nullable info, NSString *_Nullable key);

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
FOUNDATION_EXPORT LayoutDirection ViewLayoutDirection(NSDictionary * _Nullable info);

/**
 水平方向的位置
 */
typedef enum : NSUInteger {
    horizontallyLeftWidth = 0,//left＋width确定
    horizontallyCenter,       //x＋width确定
    horizontallyWidthRight,   //width＋right确定
    horizontallyLeftRight     //left＋right确定
} HorizontallyAlignmentType;

/**
 *  获取水平方向的位置（默认horizontallyLeftWidth）
 */
FOUNDATION_EXPORT HorizontallyAlignmentType getHorizontallyAlignment(NSDictionary * _Nullable info);

/**
 垂直方向的位置
 */
typedef enum : NSUInteger {
    verticalTopHeight = 0, //top＋height确定
    verticalCenter,        //y＋height确定
    verticalHeightBottom,  //height＋bottom确定
    verticalTopBottom      //top＋bottom确定
} VerticalAlignmentType;

/**
 *  获取垂直方向的位置（默认verticalTopHeight）
 */
FOUNDATION_EXPORT VerticalAlignmentType getVerticalAlignment(NSDictionary * _Nullable info);


@interface ConfigurationTool : NSObject

/**
 *  计算宽/高
 *
 *  @param info
 *  @param directionLayout 当前view的布局方向
 *  @param superValue      父view的宽/高
 *  @param isWidth         是否计算宽度，YES 宽度；NO 高度
 *
 *  @return 
 */
+ (CGFloat)calculateValue:(ConfigurationModel *_Nullable)info directionLayout:(LayoutDirection)directionLayout superValue:(CGFloat)superValue isWidth:(BOOL)isWidth;

/**
 *  计算父view宽度，子view水平方向布局时，减去了其所有子view的内边距
 *
 *  @param info
 *  @param superWidth 父view宽度(未减去其所有子view的内边距)
 *
 *  @return
 */
+ (CGFloat)superViewWidthAccordingToPadding:(ConfigurationModel *_Nullable)info superWidth:(CGFloat)superWidth;

/**
 *  计算父view高度，子view垂直方向布局时，减去了其所有子view的内边距
 *
 *  @param info
 *  @param superWidth 父view高度(未减去其所有子view的内边距)
 *
 *  @return
 */
+ (CGFloat)superViewHeightAccordingToPadding:(ConfigurationModel *_Nullable)info superHeight:(CGFloat)superHeight;

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

@end