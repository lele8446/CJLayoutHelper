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
/**
 布局方向
 */
typedef enum : NSUInteger {
    horizontallyLayout = 0,//水平方向
    verticalLayout//垂直方向
} LayoutDirection;

/**
 *  获取布局方向的宏（默认水平方向horizontallyLayout）
 */
#define ViewLayoutDirection(info) ({\
                                LayoutDirection theDirectionLayout = horizontallyLayout;\
                                NSString *directionString = (info[@"layoutDirection"] && [info[@"layoutDirection"] length]>0)?info[@"layoutDirection"]:@"horizontally";\
                                if ([directionString isEqualToString:@"horizontally"]) {\
                                    theDirectionLayout = horizontallyLayout;\
                                }else if ([directionString isEqualToString:@"vertical"]) {\
                                    theDirectionLayout = verticalLayout;\
                                }else{\
                                    theDirectionLayout = horizontallyLayout;\
                                }\
                                theDirectionLayout;\
                            })

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
        height = height + [self handleHorizontallyLayoutChildViewHeight:subviews[i] withSuperViewHeight:childViewHeight];
    }
//    NSLog(@"cell height = %@",@(height));
    return height;
}

//获取水平方向，每行view的最大高度
+ (CGFloat)handleHorizontallyLayoutChildViewHeight:(NSDictionary *)info withSuperViewHeight:(CGFloat)superViewHeight
{
    superViewHeight = (info[@"height"]&&[info[@"height"] floatValue]>superViewHeight)?[info[@"height"] floatValue]:superViewHeight;
    NSArray *subviews = info[@"subviews"];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            superViewHeight = [self handleHorizontallyLayoutChildViewHeight:subviews[i] withSuperViewHeight:superViewHeight];
        }
    }
//    NSLog(@"childViewHeight = %@",@(superViewHeight));
    return superViewHeight;
}

- (void)cellInfo:(NSDictionary *)info {

    NSArray *subviews = info[@"subviews"];
    for (NSInteger i = 0; i < subviews.count; i++) {
        self.contentView.tag = 0;
        [self initializeCellViewInfo:subviews[i] superView:self.contentView withIndex:i withSuperViewWidth:ScreenWidth layoutDirection:ViewLayoutDirection(info)];
    }

}

- (void)initializeCellViewInfo:(NSDictionary *)info
                     superView:(UIView *)superView
                     withIndex:(NSInteger)index
            withSuperViewWidth:(CGFloat)superViewWidth
               layoutDirection:(LayoutDirection)direction
{
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
    
    if ([view isMemberOfClass:[UIImageView class]]) {
        UIImageView *textView = (UIImageView *)view;
        textView.backgroundColor = [UIColor redColor];
    }

    NSDictionary *metrics = @{@"ySpacing":@(ySpacing),
                              @"height":@(height),
                              @"xSpacing":@(xSpacing),
                              @"width":@(width)};
    
    UIView *lastView = nil;
    if (index == 0) {
        lastView = superView;
    }else{
        @try {
            lastView = [superView.subviews objectAtIndex:index-1];
        } @catch (NSException *exception) {
            lastView = superView;
            NSString *errorStr = [NSString stringWithFormat:@"获取lastView出错，superView :%@\n currentVIew :%@",superView.description,view.description];
            [[NSException exceptionWithName:@"lastView error" reason:errorStr userInfo:nil] raise];
        }
    }
    
    //垂直布局
    if (direction == verticalLayout) {
        [self verticalAddVerticalLayoutConstraint:view lastView:lastView superView:superView index:index verticalAlignment:verticalAlignment ySpacing:ySpacing height:height metrics:metrics];
        [self verticalAddHorizontallyLayoutConstraint:view superView:superView horizontallyAlignment:horizontallyAlignment xSpacing:xSpacing width:width metrics:metrics];
        
    }else if (direction == horizontallyLayout) {//水平布局
        [self horizontallyAddVerticalLayoutConstraint:view superView:superView verticalAlignment:verticalAlignment ySpacing:ySpacing height:height metrics:metrics];
        [self horizontallyAddHorizontallyLayoutConstraint:view lastView:lastView superView:superView index:index horizontallyAlignment:horizontallyAlignment xSpacing:xSpacing width:width metrics:metrics];
    }
    
//    if ([self.cellStyle isEqualToString:@"scrollView"]) {
//        //当view是UIScrollView时立即刷新，以便能够在后面获取准确的contentSize
//        [self layoutIfNeeded];
//    }else{
//        [self setNeedsLayout];
//    }
    [self layoutIfNeeded];
    [self updateConstraints];
    
    NSArray *subviews = info[@"subviews"];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            [self initializeCellViewInfo:subviews[i] superView:view withIndex:i withSuperViewWidth:width layoutDirection:ViewLayoutDirection(info)];
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

/**
 *  子View垂直方向布局时添加垂直方向的约束
 *
 *  @param view              当前view
 *  @param lastView          当前view的前一个view
 *  @param superView
 *  @param index
 *  @param verticalAlignment 布局位置（top，center，bottom）
 *  @param ySpacing          view之间的间隔
 *  @param height            当前view高度
 *  @param metrics
 */
- (void)verticalAddVerticalLayoutConstraint:(UIView *)view
                                   lastView:(UIView *)lastView
                                  superView:(UIView *)superView
                                      index:(NSInteger)index
                          verticalAlignment:(NSString*)verticalAlignment
                                   ySpacing:(CGFloat)ySpacing
                                     height:(CGFloat)height
                                    metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view,lastView);
    if ([verticalAlignment isEqualToString:@"top"]) {
        if (height == 0) {
            if (index == 0) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }else{
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }
        }else{
            if (index == 0) {
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastView]-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
            }
        }
    }else if ([verticalAlignment isEqualToString:@"center"]){
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        
    }else if ([verticalAlignment isEqualToString:@"bottom"]){
        if (height == 0) {
            if (index == 0) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
            }else{
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
            }
        }else{
            if (index == 0) {
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-|" options:0 metrics:metrics views:views]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-[lastView]" options:0 metrics:metrics views:views]];
            }
            
        }
    }
}

/**
 *  子View垂直方向布局时添加水平方向的约束
 */
- (void)verticalAddHorizontallyLayoutConstraint:(UIView *)view
                                      superView:(UIView *)superView
                          horizontallyAlignment:(NSString*)horizontallyAlignment
                                       xSpacing:(CGFloat)xSpacing
                                          width:(CGFloat)width
                                        metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    if ([horizontallyAlignment isEqualToString:@"left"]) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if ([horizontallyAlignment isEqualToString:@"center"]){
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if ([horizontallyAlignment isEqualToString:@"right"]){
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }
}

//子View水平方向布局时添加垂直方向的约束
- (void)horizontallyAddVerticalLayoutConstraint:(UIView *)view
                                  superView:(UIView *)superView
                          verticalAlignment:(NSString*)verticalAlignment
                                   ySpacing:(CGFloat)ySpacing
                                     height:(CGFloat)height
                                    metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
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
}

//子View水平方向布局时添加水平方向的约束
- (void)horizontallyAddHorizontallyLayoutConstraint:(UIView *)view
                                           lastView:(UIView *)lastView
                                          superView:(UIView *)superView
                                              index:(NSInteger)index
                              horizontallyAlignment:(NSString*)horizontallyAlignment
                                           xSpacing:(CGFloat)xSpacing
                                              width:(CGFloat)width
                                            metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view,lastView);
    if ([horizontallyAlignment isEqualToString:@"left"]) {
        if (index == 0) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }else if ([horizontallyAlignment isEqualToString:@"center"]){
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if ([horizontallyAlignment isEqualToString:@"right"]){
        if (index == 0) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }
}


- (void)handleView:(UIView *)view withInfo:(NSDictionary *)info {
    //绑定点击控件
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
