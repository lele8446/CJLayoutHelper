//
//  UIColor+ConfigurationColor.h
//  CJLayoutHelperDemo
//
//  Created by ChiJinLian on 16/11/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ConfigurationColor)
/**
 *  根据16进制的NSString，返回一个颜色，比如#000000
 *  默认返回[UIColor blackColor]
 *
 *  @param hexString
 *
 *  @return
 */
+ (UIColor *_Nullable)colorWithHexString:(NSString *_Nullable)hexString;

@end
