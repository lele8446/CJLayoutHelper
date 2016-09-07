//
//  AutoBaseTableViewCell.m
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "AutoBaseTableViewCell.h"
#import "CJUITextView.h"
#import <objc/runtime.h>



#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define PlaceholderColor [UIColor colorWithRed:0.7333 green:0.7294 blue:0.7608 alpha:1.0]

@implementation AutoBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(ConfigurationModel *)info {
    self = [super initWithStyle:style reuseIdentifier:[CLayoutHelper configurationViewStyleIdentifier:info]];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    [CLayoutHelper initializeViewWithInfo:info layoutContentView:self.contentView contentViewWidth:ScreenWidth contentViewHeight:ScreenHeight delegate:self];
}

+ (CGFloat)cellHeightWithInfo:(ConfigurationModel *)info {
    return [CLayoutHelper viewHeightWithInfo:info contentViewWidth:ScreenWidth contentViewHeight:ScreenHeight];
}

#pragma mark - ConfigurationLayoutHelperDelegate
- (void)configureView:(UIView *)view withModelInfo:(NSDictionary *)info {
//    //绑定点击控件
//    if (![view isMemberOfClass:[UIView class]] && view.userInteractionEnabled == YES ) {
//        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
//        singleTap.delegate = self;
//        objc_setAssociatedObject(singleTap, "info", info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        [view addGestureRecognizer:singleTap];
//    }
    
    UIFont *titleFont = [CLayoutHelper sharedManager].titleFont;
    NSString *title = [CLayoutHelper sharedManager].titleString;
    UIColor *titleColor = [CLayoutHelper sharedManager].titleColor;
    if ([view isMemberOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.numberOfLines = 0;
        label.text = title;
        label.font = titleFont;
        label.textColor = titleColor;
    }
    if ([view isMemberOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        
        if (title && title.length >0) {
            button.titleLabel.font = titleFont;
            [button setTitleColor:titleColor forState:UIControlStateNormal];
            [button setTitleColor:titleColor forState:UIControlStateHighlighted];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateHighlighted];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        
        NSString *placeholder = info[@"placeholder"]?info[@"placeholder"]:@"";
        if (placeholder && placeholder.length > 0) {
            button.titleLabel.font = titleFont;
            [button setTitleColor:PlaceholderColor forState:UIControlStateNormal];
            [button setTitleColor:PlaceholderColor forState:UIControlStateHighlighted];
            [button setTitle:placeholder forState:UIControlStateNormal];
            [button setTitle:placeholder forState:UIControlStateHighlighted];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    if ([view isMemberOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)view;
        textField.font = titleFont;
        textField.textColor = titleColor;
        NSString *placeholder = info[@"placeholder"]?info[@"placeholder"]:@"";
        if (placeholder && placeholder.length > 0) {
            textField.placeholder = placeholder;
        }
    }
    if ([view isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
    }
    if ([view isMemberOfClass:[CJUITextView class]]) {
        CJUITextView *textView = (CJUITextView *)view;
        textView.font = titleFont;
        textView.textColor = titleColor;
        textView.placeHoldTextColor = PlaceholderColor;
        NSString *placeholder = info[@"placeholder"]?info[@"placeholder"]:@"";
        if (placeholder && placeholder.length > 0) {
            textView.placeHoldString = placeholder;
        }
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
        if ([view.idDescription rangeOfString:@"datePicker_button_2"].location != NSNotFound) {
            UIButton *button2 = (UIButton *)view;
            [button2 addTarget:self action:@selector(datePickerButton2Click:) forControlEvents:UIControlEventTouchUpInside];
            [button2 setImage:[UIImage imageNamed:@"icon_weixuanze_nor"] forState:UIControlStateNormal];
            [button2 setImage:[UIImage imageNamed:@"icon_xuanze_nor"] forState:UIControlStateSelected];
        }
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

//- (void)singleTapping:(UITapGestureRecognizer*)tapGesture {
//    if (self.tapBlock) {
//        NSDictionary *info = objc_getAssociatedObject(tapGesture, "info");
//        self.tapBlock(tapGesture.view,info);
//    }
//}
//
//#pragma mark--UIGestureRecognizerDelegate
////允许多个手势同时执行
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if([touch.view isKindOfClass:[UITextView class]] ||[touch.view isKindOfClass:[UITextField class]]){
//        return NO;
//    }
//    return YES;
//}

@end
