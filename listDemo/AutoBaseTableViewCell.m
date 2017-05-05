//
//  AutoBaseTableViewCell.m
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "AutoBaseTableViewCell.h"
#import <objc/runtime.h>

#define PlaceholderColor [UIColor colorWithRed:0.7333 green:0.7294 blue:0.7608 alpha:1.0]

@interface AutoBaseTableViewCell ()
@property (nonatomic, strong) CJLayoutHelper *layoutHelper;
@end

@implementation AutoBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(ConfigurationModel *)info {
    self = [super initWithStyle:style reuseIdentifier:[CJLayoutHelper configurationViewStyleIdentifier:info]];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.layoutHelper = [[CJLayoutHelper alloc]init];
        [self cellInfo:info];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellInfo:(ConfigurationModel *)info {
    [self.layoutHelper initializeViewWithInfo:info layoutContentView:self.contentView contentViewWidth:ScreenWidth contentViewHeight:ScreenHeight delegate:self];
}

+ (CGFloat)cellHeightWithInfo:(ConfigurationModel *)info {
    return [[CJLayoutHelper sharedManager] viewHeightWithInfo:info contentViewWidth:ScreenWidth contentViewHeight:ScreenHeight];
}

#pragma mark - ConfigurationLayoutHelperDelegate
- (void)configureView:(UIView *)view withModelInfo:(NSDictionary *)info {
    
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        if ([btn.idDescription isEqualToString:@"datePicker_button_2"]) {
            [btn addTarget:self action:@selector(datePickerButton2Click:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage imageNamed:@"icon_weixuanze_nor"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"icon_xuanze_nor"] forState:UIControlStateSelected];
        }
    }
    if ([view isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)view;
        textField.placeholder = info[@"placeholder"];
    }
    if ([view isKindOfClass:[UILabel class]] && [view.idDescription isEqualToString:@"label_Text"]) {
        UILabel *label = (UILabel *)view;
        label.numberOfLines = 0;
    }
    
    [self configurationViewWithIdDescription:info view:view];
}

- (void)configurationViewWithIdDescription:(NSDictionary *)info view:(UIView *)view {
    if ([view isKindOfClass:[UIButton class]]) {
        if ([view.idDescription rangeOfString:@"UIScrollView_button"].location != NSNotFound) {
            UIButton *button = (UIButton *)view;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([view.idDescription rangeOfString:@"datePicker_button_1"].location != NSNotFound) {
            UIButton *button1 = (UIButton *)view;
            objc_setAssociatedObject(button1, "placeholder", info[@"placeholder"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [button1 addTarget:self action:@selector(datePickerButton1Click:) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([view.idDescription rangeOfString:@"Button二"].location != NSNotFound) {
            UIButton *button2 = (UIButton *)view;
            objc_setAssociatedObject(button2, "placeholder", info[@"title"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [button2 addTarget:self action:@selector(datePickerButton1Click:) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([view.idDescription rangeOfString:@"datePicker_button_2"].location != NSNotFound) {
            UIButton *button2 = (UIButton *)view;
            [button2 addTarget:self action:@selector(datePickerButton2Click:) forControlEvents:UIControlEventTouchUpInside];
            [button2 setImage:[UIImage imageNamed:@"icon_weixuanze_nor"] forState:UIControlStateNormal];
            [button2 setImage:[UIImage imageNamed:@"icon_xuanze_nor"] forState:UIControlStateSelected];
        }
    }
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.numberOfLines = 0;
    }
}

- (void)buttonClick:(UIButton *)sender {
    if (self.tapBlock) {
        self.tapBlock(sender,sender.idDescription);
    }
}

- (void)datePickerButton1Click:(UIButton *)sender {
    if (self.tapBlock) {
        NSString *placeholder = objc_getAssociatedObject(sender, "placeholder");
        self.tapBlock(sender,placeholder);
    }
}

- (void)datePickerButton2Click:(UIButton *)sender {
    sender.selected = !sender.selected;
}

@end
