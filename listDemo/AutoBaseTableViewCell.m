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

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(NSDictionary *)info {
    self = [super initWithStyle:style reuseIdentifier:[ConfigurationLayoutHelper configurationViewStyleIdentifier:info]];
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

- (void)cellInfo:(NSDictionary *)info {
    [ConfigurationLayoutHelper initializeViewWithInfo:info layoutContentView:self.contentView withContentViewWidth:ScreenWidth withContentViewHeight:ScreenHeight];
    [ConfigurationLayoutHelper sharedManager].myDelegate = self;
}

+ (CGFloat)cellHeightWithInfo:(NSDictionary *)info {
    return [ConfigurationLayoutHelper viewHeightWithInfo:info withContentViewWidth:ScreenWidth withContentViewHeight:ScreenHeight];
}

- (void)configureView:(UIView *)view withInfo:(NSDictionary *)info {
    //绑定点击控件
    if (![view isMemberOfClass:[UIView class]] && view.userInteractionEnabled == YES ) {
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
        singleTap.delegate = self;
        objc_setAssociatedObject(singleTap, "info", info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [view addGestureRecognizer:singleTap];
    }
    
    UIColor *backColor = (info[@"backColor"]&&([info[@"backColor"] length]>0))?[UIColor colorWithRed:0.8074 green:0.8213 blue:0.8391 alpha:1.0]:[UIColor whiteColor];
    view.backgroundColor = backColor;
    
    if ([view isMemberOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.text = self.titleString;
        label.font = self.titleFont;
        label.textColor = self.titleColor;
    }
    if ([view isMemberOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        
        NSString *image = info[@"image"];
        if (image && image.length > 0) {
            [button setImage:[UIImage imageNamed:@"icon_weixuanze_nor"] forState:UIControlStateNormal];
        }
        NSString *selectImage = info[@"selectImage"];
        if (selectImage && selectImage.length > 0) {
            [button setImage:[UIImage imageNamed:@"icon_xuanze_nor"] forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageNamed:@"icon_xuanze_nor"] forState:UIControlStateSelected];
        }
        
        button.titleLabel.font = self.titleFont;
        [button setTitleColor:self.titleColor forState:UIControlStateNormal];
        [button setTitleColor:self.titleColor forState:UIControlStateHighlighted];
        if (self.titleString && self.titleString.length >0) {
            [button setTitle:self.titleString forState:UIControlStateNormal];
            [button setTitle:self.titleString forState:UIControlStateHighlighted];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        
        NSString *placeholder = info[@"placeholder"]?info[@"placeholder"]:@"";
        if (placeholder && placeholder.length > 0) {
            [button setTitleColor:PlaceholderColor forState:UIControlStateNormal];
            [button setTitleColor:PlaceholderColor forState:UIControlStateHighlighted];
            [button setTitle:placeholder forState:UIControlStateNormal];
            [button setTitle:placeholder forState:UIControlStateHighlighted];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        
        
    }
    if ([view isMemberOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)view;
        textField.font = self.titleFont;
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
        textView.placeHoldTextColor = PlaceholderColor;
        NSString *placeholder = info[@"placeholder"]?info[@"placeholder"]:@"";
        if (placeholder && placeholder.length > 0) {
            textView.placeHoldString = placeholder;
            textView.font = self.titleFont;
        }
    }
    if ([view isMemberOfClass:[UIImageView class]]) {
        UIImageView *textView = (UIImageView *)view;
        textView.backgroundColor = [UIColor redColor];
    }

}

- (void)singleTapping:(UITapGestureRecognizer*)tapGesture {
    if (self.tapBlock) {
        NSDictionary *info = objc_getAssociatedObject(tapGesture, "info");
        self.tapBlock(tapGesture.view,info);
    }
}

#pragma mark--UIGestureRecognizerDelegate
//允许多个手势同时执行
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([touch.view isKindOfClass:[UITextView class]] ||[touch.view isKindOfClass:[UITextField class]]){
        return NO;
    }
    return YES;
}

@end
