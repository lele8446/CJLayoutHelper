//
//  UIView+ConfigurationView.h
//  CJLayoutHelperDemo
//
//  Created by ChiJinLian on 16/11/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

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
