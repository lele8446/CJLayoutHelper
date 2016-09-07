//
//  AutoBaseTableViewCell.h
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLayoutHelper.h"
#import "ConfigurationModel.h"

typedef void(^viewTapBlock)(UIView *, id);

@interface AutoBaseTableViewCell : UITableViewCell<CLayoutHelperDelegate>
@property (nonatomic, copy) viewTapBlock tapBlock;

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(ConfigurationModel *)info;
- (void)cellInfo:(ConfigurationModel *)info;
+ (CGFloat)cellHeightWithInfo:(ConfigurationModel *)info;
@end
