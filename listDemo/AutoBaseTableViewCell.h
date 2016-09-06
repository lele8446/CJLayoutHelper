//
//  AutoBaseTableViewCell.h
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigurationLayoutHelper.h"


typedef void(^viewTapBlock)(UIView *, id);

@interface AutoBaseTableViewCell : UITableViewCell<ConfigurationLayoutHelperDelegate>
@property (nonatomic, copy) viewTapBlock tapBlock;

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(NSDictionary *)info;
- (void)cellInfo:(NSDictionary *)info;
+ (CGFloat)cellHeightWithInfo:(NSDictionary *)info;
@end
