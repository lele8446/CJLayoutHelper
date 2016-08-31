//
//  AutoBaseTableViewCell.h
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

typedef void(^viewTapBlock)(UIView *, id);

@interface AutoBaseTableViewCell : UITableViewCell
@property (nonatomic, copy) viewTapBlock tapBlock;

@property (nonatomic, copy) NSString *cellStyle;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(NSDictionary *)info;
- (void)cellInfo:(NSDictionary *)info;
+ (CGFloat)cellHeightWithInfo:(NSDictionary *)info;
@end
