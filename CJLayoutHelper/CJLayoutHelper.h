//
//  CJLayoutHelper.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/1.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConfigurationTool.h"
#import "ConfigurationModel.h"
#import "UIView+ConfigurationView.h"
#import "UIColor+ConfigurationColor.h"

@protocol CJLayoutHelperDelegate <NSObject>

//配置回调
- (void)configureView:(UIView *)view withModelInfo:(NSDictionary *)info;

@end

@interface CJLayoutHelper : NSObject


+ (instancetype)sharedManager;

/**
 *  配置绘制的View的标识符（对应viewStyleIdentifier字段）
 *
 *  @param info
 *
 *  @return 
 */
+ (NSString *)configurationViewStyleIdentifier:(ConfigurationModel *)info;

/**
 *  获取所要绘制view的整体高度
 *
 *  @param info
 *  @param contentViewWidth  绘制UI的父视图的宽度（比如：ScreenWidth）
 *  @param contentViewHeight 绘制UI的父视图的高度（比如：ScreenHeight）
 *
 *  @return
 */
- (CGFloat)viewHeightWithInfo:(ConfigurationModel *)info
             contentViewWidth:(CGFloat)contentViewWidth
            contentViewHeight:(CGFloat)contentViewHeight;

/**
 *  根据配置文件初始化view
 *
 *  @param info
 *  @param layoutContentView 绘制UI的父视图（在哪个view上绘制）
 *  @param contentViewWidth  绘制UI的父视图的宽度（比如：ScreenWidth）
 *  @param contentViewHeight 绘制UI的父视图的高度（比如：ScreenHeight）
 *  @param delegate          代理
 */
- (void)initializeViewWithInfo:(ConfigurationModel *)info
             layoutContentView:(UIView *)layoutContentView
              contentViewWidth:(CGFloat)contentViewWidth
             contentViewHeight:(CGFloat)contentViewHeight
                      delegate:(id<CJLayoutHelperDelegate>)delegate;




@end
