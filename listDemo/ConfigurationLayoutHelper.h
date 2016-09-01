//
//  ConfigurationLayoutHelper.h
//  listDemo
//
//  Created by YiChe on 16/9/1.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ConfigurationLayoutHelper : NSObject

+ (instancetype)sharedManager;

+ (CGFloat)getViewHeightWithInfo:(NSDictionary *)info;

+ (void)initializeViewWithInfo:(NSDictionary *)info layoutContentView:(UIView *)layoutContentView withContentViewWidth:(CGFloat)contentViewWidth;




@end
