//
//  ConfigurationModel.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/6.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigurationModel : NSObject

/**
 *  布局相关的数据
 * {
    "viewStyleIdentifier": "scrollViewType",//配置文件对应的整体view的标识符，最外层view特有字段（最外层view时必填）
    "viewType": "UIView",                   //当前view的class，对应UIKit中的类型（必填）
    "xSpacing": 0,                          //水平方向的间距，对应Leading、Trailing的值（默认0）
    "horizontallyAlignment": "left",        //水平方向的布局位置，left、center、right（默认left）
    "width": "1p",                          //宽度：0高度固定，宽度随文本内容动态变化； 0p~1p：数字加p表示取父view宽度的百分比；40表示＝40（必填）
    "ySpacing": 0,                          //垂直方向的间距，对应Top、Bottom的值（默认0）
    "verticalAlignment": "top",             //垂直方向的布局位置，top、center、bottom（默认top）
    "height": 44,                           //高度：0宽度固定，高度随文本内容动态变化； 0p~1p：数字加p表示取父view高度的百分比；44表示＝44（必填）
    "autolayoutHeight":true,                //是否自动调整高度，当子view中包含高度未确定的元素时，值为true，默认false
    "layoutDirection":"vertical",           //含有子view时，子view的布局方向，horizontally、vertical（默认horizontally水平布局）
    "subviews": []                          //子view的model数组
   }
 */
@property (nonatomic, strong) NSMutableDictionary *layout;

/**
 *  当前view对应的数据
 * {
    "backgroundColor": "#87CEEB",//背景颜色
    "title": "标题",              //当前绘制的view的标题（如果存在的话）
    "titleFont": 14,             //当前绘制的view的字体，默认取最底层superView的配置信息，如果都没有则默认为：[UIFont systemFontOfSize:14]
    "titleColor": "#000000"      //当前绘制的view的字体颜色，默认取最底层superView的配置信息，如果都没有则默认为：[UIColor blackColor]
    "idDescription": "CJUITextView_dz", //用来描述当前view的id，需要保证唯一性
    "placeholder": "请输入地址"    //默认提示
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
