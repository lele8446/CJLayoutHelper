//
//  ConfigurationLayoutHelper.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/1.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConfigurationTool.h"

@protocol ConfigurationLayoutHelperDelegate <NSObject>

//配置回调方法
- (void)configureView:(UIView *)view withInfo:(NSDictionary *)info;

@end

@interface ConfigurationLayoutHelper : NSObject

@property(nonatomic, weak) id<ConfigurationLayoutHelperDelegate> myDelegate;
/**
 *  当前绘制的view的标题（如果存在的话）
 */
@property (nonatomic, copy) NSString *titleString;

/**
 *  当前绘制的view的字体，默认取最底层superView的配置信息，如果都没有则默认为：[UIFont systemFontOfSize:14]
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 *  当前绘制的view的字体颜色，默认取最底层superView的配置信息，如果都没有则默认为：[UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *titleColor;


/**
 *  单例
 *
 *  @return 
 */
+ (instancetype)sharedManager;

/**
 *  配置绘制的View的标识符（对应viewStyleIdentifier字段）
 *
 *  @param info
 *
 *  @return 
 */
+ (NSString *)configurationViewStyleIdentifier:(NSDictionary *)info;

/**
 *  获取所要绘制view的整体高度
 *
 *  @param info
 *  @param contentViewWidth  最底层view的宽度（比如：ScreenWidth）
 *  @param contentViewHeight 最底层view的高度（比如：ScreenHeight）
 *
 *  @return
 */
+ (CGFloat)viewHeightWithInfo:(NSDictionary *)info withContentViewWidth:(CGFloat)contentViewWidth withContentViewHeight:(CGFloat)contentViewHeight;

/**
 *  根据配置文件初始化view
 *
 *  @param info
 *  @param layoutContentView 在哪个view上绘制（最底层view）
 *  @param contentViewWidth  最底层view的宽度（比如：ScreenWidth）
 *  @param contentViewHeight 最底层view的高度（比如：ScreenHeight）
 *  @param delegate          代理
 */
+ (void)initializeViewWithInfo:(NSDictionary *)info layoutContentView:(UIView *)layoutContentView withContentViewWidth:(CGFloat)contentViewWidth withContentViewHeight:(CGFloat)contentViewHeight withDelegate:(id<ConfigurationLayoutHelperDelegate>)delegate;




@end
