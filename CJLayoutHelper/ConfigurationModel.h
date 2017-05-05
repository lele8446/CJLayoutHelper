//
//  ConfigurationModel.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/6.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>

// key值 相关
FOUNDATION_EXPORT NSString * const kLayout;
FOUNDATION_EXPORT NSString * const kViewStyleIdentifier;
FOUNDATION_EXPORT NSString * const kViewType;
FOUNDATION_EXPORT NSString * const kHorizontallyAlignment;
FOUNDATION_EXPORT NSString * const kLeftPadding;
FOUNDATION_EXPORT NSString * const kRightPadding;
FOUNDATION_EXPORT NSString * const kWidth;
FOUNDATION_EXPORT NSString * const kVerticalAlignment;
FOUNDATION_EXPORT NSString * const kTopPadding;
FOUNDATION_EXPORT NSString * const kBottomPadding;
FOUNDATION_EXPORT NSString * const kHeight;
FOUNDATION_EXPORT NSString * const kAutolayoutHeight;
FOUNDATION_EXPORT NSString * const kLayoutDirection;
FOUNDATION_EXPORT NSString * const kSubviews;

FOUNDATION_EXPORT NSString * const kModel;
FOUNDATION_EXPORT NSString * const kIdDescription;

// 布局方向的值 相关
FOUNDATION_EXPORT NSString * const kHorizontally;
FOUNDATION_EXPORT NSString * const kVertical;
FOUNDATION_EXPORT NSString * const kLeftWidth;
FOUNDATION_EXPORT NSString * const kCenter;
FOUNDATION_EXPORT NSString * const kWidthRight;
FOUNDATION_EXPORT NSString * const kLeftRight;
FOUNDATION_EXPORT NSString * const kTopHeight;
FOUNDATION_EXPORT NSString * const kHeightBottom;
FOUNDATION_EXPORT NSString * const kTopBottom;

/**
 *  文本内容
 */
FOUNDATION_EXPORT NSString * const kText;
/**
 *  字体颜色，默认[UIColor blackColor]
 */
FOUNDATION_EXPORT NSString * const kTextColor;
/**
 *  字体大小，默认[UIFont systemFontOfSize:14]
 */
FOUNDATION_EXPORT NSString * const kFont;
/**
 *  背景颜色
 */
FOUNDATION_EXPORT NSString * const kBackgroundColor;


@interface ConfigurationModel : NSObject

/**
 *  布局相关的数据
 * {
    "viewStyleIdentifier": "scrollViewType",//配置文件对应的整体view的标识符，最外层view特有字段（最外层view时必填）
    "viewType": "UIView",                   //当前view的class，对应UIKit中的类型（必填）
    "leftPadding": 0,                       //水平方向左边的间距，对应Leading的值（默认0）
    "rightPadding": 0,                      //水平方向右边的间距，对应Trailing的值（默认0）
    "horizontallyAlignment": "leftWidth",   //水平方向的布局位置，leftWidth、center、widthRight、leftRight(同级只有一个子view时才可设置)（默认leftWidth）
    "width": "1p",                          //宽度0表示：高度固定，宽度随文本内容动态变化； 0p~1p：数字加p表示取父view宽度的百分比；40表示＝40
    "topPadding": 0,                        //垂直方向上边的间距，对应Top的值（默认0）
    "bottomPadding": 0,                     //垂直方向下边的间距，对应Bottom的值（默认0）
    "verticalAlignment": "topHeight",       //垂直方向的布局位置，topHeight、center、heightBottom、topBottom(同级只有一个子view时才可设置)（默认topHeight）
    "height": 44,                           //高度0表示：宽度固定，高度随文本内容动态变化； 0p~1p：数字加p表示取父view高度的百分比；44表示＝44
    "autolayoutHeight":true,                //是否自动调整高度，当子view中包含高度未确定的元素时，值为true，默认false
    "layoutDirection":"vertical",           //含有子view时，子view的布局方向，horizontally、vertical（默认horizontally水平布局）
    "subviews": []                          //子view的model数组
   }
 */
@property (nonatomic, strong) NSMutableDictionary *layout;

/**
 *  当前view对应的数据
 * {
    "backgroundColor": "#87CEEB",       //背景颜色
    "text": "标题",                      //当前绘制的view的标题（如果存在的话）
    "font": 14,                         //当前绘制的view的字体，默认[UIFont systemFontOfSize:14]
    "textColor": "#000000"              //当前绘制的view的字体颜色，默认[UIColor blackColor]
    "idDescription": "CJUITextView_dz", //用来描述当前view的id，需要保证唯一性
   }
 */
@property (nonatomic, strong) NSDictionary *model;


/**
 *  初始化model
 *
 *  @param info
 *
 *  @return 
 */
- (instancetype)initConfigurationModelInfo:(NSDictionary *)info;

@end
