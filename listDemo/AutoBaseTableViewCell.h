//
//  AutoBaseTableViewCell.h
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJLayoutHelper.h"
#import "ConfigurationModel.h"

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

typedef void(^viewTapBlock)(UIView *, id);

@interface AutoBaseTableViewCell : UITableViewCell<CJLayoutHelperDelegate>
@property (nonatomic, copy) viewTapBlock tapBlock;

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(ConfigurationModel *)info;
- (void)cellInfo:(ConfigurationModel *)info;
+ (CGFloat)cellHeightWithInfo:(ConfigurationModel *)info;
@end
