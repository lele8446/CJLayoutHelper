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

#define PlaceholderColor [UIColor colorWithRed:0.7333 green:0.7294 blue:0.7608 alpha:1.0]

@implementation AutoBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style withCellInfo:(NSDictionary *)info {
    self.cellStyle = (info[@"cellStyle"]&&([info[@"cellStyle"] length]>0))?info[@"cellStyle"]:@"cellStyle";
    self.titleFont = [UIFont systemFontOfSize:(info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[info[@"titleFont"] floatValue]:14];
    self.titleColor = [UIColor blackColor];
    self = [super initWithStyle:style reuseIdentifier:self.cellStyle];
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

+ (CGFloat)cellHeightWithInfo:(NSDictionary *)info {
    CGFloat height = 0;
    
    NSArray *subviews = info[@"subviews"];
    for (NSInteger i = 0; i < subviews.count; i++) {
        CGFloat childViewHeight = 0;
        height = height + [self handleChildViewHeight:subviews[i] withHeight:childViewHeight];
    }
//    NSLog(@"cell height = %@",@(height));
    return height;
}

//获取每一行子view的最大高度
+ (CGFloat)handleChildViewHeight:(NSDictionary *)info withHeight:(CGFloat)height {
    height = (info[@"height"]&&[info[@"height"] floatValue]>height)?[info[@"height"] floatValue]:height;
    NSArray *subviews = info[@"subviews"];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            height = [self handleChildViewHeight:subviews[i] withHeight:height];
        }
    }
//    NSLog(@"childViewHeight = %@",@(height));
    return height;
}

- (void)cellInfo:(NSDictionary *)info {

    NSArray *subviews = info[@"subviews"];
    for (NSInteger i = 0; i < subviews.count; i++) {
        self.contentView.tag = 0;
        [self initializeCellView:subviews[i] superView:self.contentView withIndex:i withSuperViewWidth:ScreenWidth];
    }

}

- (void)initializeCellView:(NSDictionary *)info superView:(UIView *)superView withIndex:(NSInteger)index withSuperViewWidth:(CGFloat)superViewWidth {
    
    NSString *viewClass = info[@"viewType"];//view类型
    
    CGFloat xSpacing = (info[@"xSpacing"])?[info[@"xSpacing"] floatValue]:0;
    NSString *horizontallyAlignment = info[@"horizontallyAlignment"];//水平方向
    CGFloat width = [info[@"width"] floatValue];//宽度
    width = width <= 1?(superViewWidth-2*xSpacing)*width:width;
//    NSLog(@"superView is %@, superViewWidth = %@",NSStringFromClass([superView class]),@(superViewWidth));
    
    CGFloat ySpacing = (info[@"ySpacing"])?[info[@"ySpacing"] floatValue]:0;
    NSString *verticalAlignment = info[@"verticalAlignment"];//垂直方向
    CGFloat height = [info[@"height"] floatValue];//高度
    
    self.titleFont = (info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[UIFont systemFontOfSize:[info[@"titleFont"] floatValue]]:self.titleFont;
    
    self.titleString = info[@"title"];
    if (self.titleString && self.titleString.length >0) {
        NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
        [attDic setObject:self.titleFont forKey:NSFontAttributeName];
        CGSize strSize = [self.titleString boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                     attributes:attDic
                                                        context:nil].size;
        if (width == 0) {
            width = strSize.width+6;
        }
        if (strSize.width+6 > width) {
            width = strSize.width+6;
        }
    }
    
    NSInteger tag = superView.tag;
    NSString *tagStr = [NSString stringWithFormat:@"%@_%@_%@",self.cellStyle,@(tag),@(index)];
    UIView *view = [superView viewWithTag:[tagStr hash]];
    if (nil == view) {
        view = [[NSClassFromString(viewClass) alloc]init];
        view.tag = [tagStr hash];
        [superView addSubview:view];
    }
    view.translatesAutoresizingMaskIntoConstraints = NO;

    [self handleView:view withInfo:info];

    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    NSDictionary *metrics = @{@"ySpacing":@(ySpacing),
                              @"height":@(height),
                              @"xSpacing":@(xSpacing),
                              @"width":@(width)};
    
    if ((superView == self.contentView && index == 0) || (superView != self.contentView)) {
        //垂直方向约束
        if ([verticalAlignment isEqualToString:@"top"]) {
            if (height == 0) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
            }
        }else if ([verticalAlignment isEqualToString:@"center"]){
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
            
        }else if ([verticalAlignment isEqualToString:@"bottom"]){
            if (height == 0) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-|" options:0 metrics:metrics views:views]];
            }
        }
    }else if (superView == self.contentView){
        UIView *lastChildView = [superView.subviews objectAtIndex:index-1];
        NSDictionary *views = NSDictionaryOfVariableBindings(view,lastChildView);
        if ([verticalAlignment isEqualToString:@"top"]) {
            if (height == 0) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastChildView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastChildView]-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
            }
        }else if ([verticalAlignment isEqualToString:@"center"]){
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
            
        }else if ([verticalAlignment isEqualToString:@"bottom"]){
            if (height == 0) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastChildView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-[lastChildView]" options:0 metrics:metrics views:views]];
            }
        }
    }
    
    UIView *lastView = nil;
    //水平方向约束
    if (index == 0 || (superView == self.contentView)) {//当是第一个子view时，相对位置的view取superView
        lastView = superView;
        if ([horizontallyAlignment isEqualToString:@"left"]) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else if ([horizontallyAlignment isEqualToString:@"center"]){
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else if ([horizontallyAlignment isEqualToString:@"right"]){
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }else{//不是第一个子view时，相对位置的view取上一个子view
        lastView = [superView.subviews objectAtIndex:index-1];
        if ([horizontallyAlignment isEqualToString:@"left"]) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else if ([horizontallyAlignment isEqualToString:@"center"]){
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else if ([horizontallyAlignment isEqualToString:@"right"]){
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }
    
    
    if ([self.cellStyle isEqualToString:@"scrollView"]) {
        //当view是UIScrollView时立即刷新，以便能够在后面获取准确的contentSize
        [self layoutIfNeeded];
    }else{
        [self setNeedsLayout];
    }
    
    NSArray *subviews = info[@"subviews"];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            [self initializeCellView:subviews[i] superView:view withIndex:i withSuperViewWidth:width];
            if (([view isKindOfClass:[UIScrollView class]])&&(i == subviews.count-1)) {
                UIView *childView = view.subviews[view.subviews.count-1];
                UIScrollView *scrollView = (UIScrollView *)view;
                
                if ((CGRectGetMaxX(childView.frame) >= CGRectGetWidth(scrollView.frame)) && (CGRectGetMaxY(childView.frame) <= CGRectGetHeight(scrollView.frame))) {
                    scrollView.contentSize = CGSizeMake(CGRectGetMaxX(childView.frame), 0);
                }
                if ((CGRectGetMaxY(childView.frame) >= CGRectGetHeight(scrollView.frame)) && (CGRectGetMaxX(childView.frame) <= CGRectGetWidth(scrollView.frame))) {
                    scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(childView.frame));
                }
            }
        }
    }
    
}

- (void)handleView:(UIView *)view withInfo:(NSDictionary *)info {
    
    if (view.userInteractionEnabled == YES && ![view isMemberOfClass:[UIView class]]) {
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
            textView.placeHoldTextFont = self.titleFont;
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
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([touch.view isKindOfClass:[UITextView class]] ||[touch.view isKindOfClass:[UITextField class]]){
        return NO;
    }
    return YES;
}
@end
