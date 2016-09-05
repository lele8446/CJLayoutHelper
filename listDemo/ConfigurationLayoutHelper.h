//
//  ConfigurationLayoutHelper.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/1.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ConfigurationLayoutHelperDelegate <NSObject>

- (void)configureView:(UIView *)view withInfo:(NSDictionary *)info;

@end

@interface ConfigurationLayoutHelper : NSObject

@property(nonatomic, weak) id<ConfigurationLayoutHelperDelegate> myDelegate;

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
 */
+ (void)initializeViewWithInfo:(NSDictionary *)info layoutContentView:(UIView *)layoutContentView withContentViewWidth:(CGFloat)contentViewWidth withContentViewHeight:(CGFloat)contentViewHeight;




@end
