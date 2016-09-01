//
//  ConfigurationLayoutHelper.m
//  listDemo
//
//  Created by YiChe on 16/9/1.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "ConfigurationLayoutHelper.h"
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

@interface ConfigurationLayoutHelper ()<UIGestureRecognizerDelegate>
/**
 *  配置文件对应的整体view的标识符
 */
@property (nonatomic, copy) NSString *viewStyleIdentifier;
/**
 *  当前绘制的view的标题（如果存在的话）
 */
@property (nonatomic, copy) NSString *titleString;
/**
 *  当前绘制的view的字体，默认取最底层superView的配置信息，如果都没有则默认为：[UIFont systemFontOfSize:14]
 */
@property (nonatomic, strong) UIFont *titleFont;
/**
 *  当前绘制的view的字体颜色，默认取最底层superView的配置信息，如果都没有则默认为：[UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *titleColor;
/**
 *  需要在上面绘制UI的View
 */
@property (nonatomic, strong) UIView *layoutContentView;

@end

@implementation ConfigurationLayoutHelper
+ (instancetype)sharedManager {
    static ConfigurationLayoutHelper *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/*
 * alloc方法初始化实例时，默认会调用allocWithZone方法。
 * 在此将allocWithZone:重写，是为了防止用户直接使用allocWithZone创建实例，使得项目中不是存在唯一的实例，违背了单例的原则
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    static ConfigurationLayoutHelper *instance;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (CGFloat)getViewHeightWithInfo:(NSDictionary *)info {
    return [self handleHorizontallyLayoutChildViewHeight:info withSuperViewHeight:0];
}

//获取水平方向view的最大高度
+ (CGFloat)handleHorizontallyLayoutChildViewHeight:(NSDictionary *)info withSuperViewHeight:(CGFloat)superViewHeight {
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

+ (void)initializeViewWithInfo:(NSDictionary *)info layoutContentView:(UIView *)layoutContentView withContentViewWidth:(CGFloat)contentViewWidth {
    [ConfigurationLayoutHelper sharedManager].layoutContentView = layoutContentView;
    [ConfigurationLayoutHelper sharedManager].viewStyleIdentifier = (info[@"viewStyleIdentifier"]&&([info[@"viewStyleIdentifier"] length]>0))?info[@"viewStyleIdentifier"]:@"viewStyleIdentifier";
    [ConfigurationLayoutHelper sharedManager].titleFont = [UIFont systemFontOfSize:(info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[info[@"titleFont"] floatValue]:14];
    [ConfigurationLayoutHelper sharedManager].titleColor = [UIColor blackColor];
    
    [self initializeViewInfo:info superView:layoutContentView withIndex:0 withSuperViewWidth:contentViewWidth layoutDirection:ViewLayoutDirection(info)];
}

+ (void)initializeViewInfo:(NSDictionary *)info
                     superView:(UIView *)superView
                     withIndex:(NSInteger)index
            withSuperViewWidth:(CGFloat)superViewWidth
               layoutDirection:(LayoutDirection)direction
{
    UIView *currentVIew = nil;
    CGFloat width = 0;
    NSString *viewClass = info[@"viewType"];//view类型
    id theViewClass = NSClassFromString(viewClass);
    if (!viewClass || viewClass.length <= 0 || !theViewClass || nil == theViewClass) {
        NSString *errorStr = [NSString stringWithFormat:@"viewType类型出错，viewType :%@",info[@"viewType"]];
        NSLog(@"errorStr = %@",errorStr);
        NSLog(@"errorInfo = %@",info);
    }else {
        CGFloat xSpacing = (info[@"xSpacing"])?[info[@"xSpacing"] floatValue]:0;
        NSString *horizontallyAlignment = info[@"horizontallyAlignment"];//水平方向
        width = [info[@"width"] floatValue];//宽度
        width = width <= 1?(superViewWidth-2*xSpacing)*width:width;
        //        NSLog(@"superView is %@, superViewWidth = %@",NSStringFromClass([superView class]),@(superViewWidth));
        
        CGFloat ySpacing = (info[@"ySpacing"])?[info[@"ySpacing"] floatValue]:0;
        NSString *verticalAlignment = info[@"verticalAlignment"];//垂直方向
        CGFloat height = [info[@"height"] floatValue];//高度
        
        [ConfigurationLayoutHelper sharedManager].titleFont = (info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[UIFont systemFontOfSize:[info[@"titleFont"] floatValue]]:[ConfigurationLayoutHelper sharedManager].titleFont;
        
        [ConfigurationLayoutHelper sharedManager].titleString = info[@"title"];
        if ([ConfigurationLayoutHelper sharedManager].titleString && [ConfigurationLayoutHelper sharedManager].titleString.length >0) {
            NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
            [attDic setObject:[ConfigurationLayoutHelper sharedManager].titleFont forKey:NSFontAttributeName];
            CGSize strSize = [[ConfigurationLayoutHelper sharedManager].titleString boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
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
        NSString *tagStr = [NSString stringWithFormat:@"%@_%@_%@_%@",[ConfigurationLayoutHelper sharedManager].viewStyleIdentifier,@(tag),@(index),viewClass];
        currentVIew = [superView viewWithTag:[tagStr hash]];
        if (nil == currentVIew) {
            currentVIew = [[NSClassFromString(viewClass) alloc]init];
            currentVIew.tag = [tagStr hash];
            [superView addSubview:currentVIew];
        }
        currentVIew.translatesAutoresizingMaskIntoConstraints = NO;
        
//        [self handleView:currentVIew withInfo:info];
        
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
                NSString *errorStr = [NSString stringWithFormat:@"获取lastView出错，superView :%@\n currentVIew :%@",superView.description,currentVIew.description];
                NSLog(@"lastView error =%@",errorStr);
            }
        }
        
        //垂直布局
        if (direction == verticalLayout) {
            [self verticalAddVerticalLayoutConstraint:currentVIew lastView:lastView superView:superView index:index verticalAlignment:verticalAlignment ySpacing:ySpacing height:height metrics:metrics];
            [self verticalAddHorizontallyLayoutConstraint:currentVIew superView:superView horizontallyAlignment:horizontallyAlignment xSpacing:xSpacing width:width metrics:metrics];
            
        }else if (direction == horizontallyLayout) {//水平布局
            [self horizontallyAddVerticalLayoutConstraint:currentVIew superView:superView verticalAlignment:verticalAlignment ySpacing:ySpacing height:height metrics:metrics];
            [self horizontallyAddHorizontallyLayoutConstraint:currentVIew lastView:lastView superView:superView index:index horizontallyAlignment:horizontallyAlignment xSpacing:xSpacing width:width metrics:metrics];
        }
        
        if ([[ConfigurationLayoutHelper sharedManager].viewStyleIdentifier isEqualToString:@"scrollView"]) {
            //当view是UIScrollView时立即刷新，以便能够在后面获取准确的contentSize
            [[ConfigurationLayoutHelper sharedManager].layoutContentView layoutIfNeeded];
        }else{
            [[ConfigurationLayoutHelper sharedManager].layoutContentView setNeedsLayout];
        }
        [[ConfigurationLayoutHelper sharedManager].layoutContentView updateConstraints];
    }
    
    NSArray *subviews = info[@"subviews"];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            /**
             *  防止当前这一层视图的配置信息出错，比如"viewType"声明错误，但其中却存在有"subviews"
             *  则跳过这一层，直接绘制在superView上面
             */
            if (!currentVIew || nil == currentVIew) {
                currentVIew = superView;
                width = superViewWidth;
            }
            [self initializeViewInfo:subviews[i] superView:currentVIew withIndex:i withSuperViewWidth:width layoutDirection:ViewLayoutDirection(info)];
            
            //当前view是UIScrollView，并且已经绘制完其中所有的subviews时，计算contentSize
            if (([currentVIew isKindOfClass:[UIScrollView class]])&&(i == subviews.count-1)) {
                UIView *childView = currentVIew.subviews[currentVIew.subviews.count-1];
                UIScrollView *scrollView = (UIScrollView *)currentVIew;
                
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
+ (void)verticalAddVerticalLayoutConstraint:(UIView *)view
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
        if (height == 0) {//不确定高度
            if (index == 0) {//第一个子view，垂直方向相对位置的view取superView
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }else{//不是第一个子view时，垂直方向相对位置的view取前一个子view
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }
        }else{
            if (index == 0) {
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
            }else{
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastView]-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
            }
        }
    }else if ([verticalAlignment isEqualToString:@"center"]){
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        
    }else if ([verticalAlignment isEqualToString:@"bottom"]){
        if (height == 0) {
            if (index == 0) {
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
            }else{
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
            }
        }else{
            if (index == 0) {
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-|" options:0 metrics:metrics views:views]];
            }else{
                [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-[lastView]" options:0 metrics:metrics views:views]];
            }
            
        }
    }
}

/**
 *  子View垂直方向布局时添加水平方向的约束
 */
+ (void)verticalAddHorizontallyLayoutConstraint:(UIView *)view
                                      superView:(UIView *)superView
                          horizontallyAlignment:(NSString*)horizontallyAlignment
                                       xSpacing:(CGFloat)xSpacing
                                          width:(CGFloat)width
                                        metrics:(NSDictionary *)metrics
{
    //垂直方向布局时水平方向相对位置的view都取superView
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    if ([horizontallyAlignment isEqualToString:@"left"]) {
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if ([horizontallyAlignment isEqualToString:@"center"]){
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if ([horizontallyAlignment isEqualToString:@"right"]){
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }
}

//子View水平方向布局时添加垂直方向的约束
+ (void)horizontallyAddVerticalLayoutConstraint:(UIView *)view
                                      superView:(UIView *)superView
                              verticalAlignment:(NSString*)verticalAlignment
                                       ySpacing:(CGFloat)ySpacing
                                         height:(CGFloat)height
                                        metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    if ([verticalAlignment isEqualToString:@"top"]) {
        if (height == 0) {
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        }else{
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
        }
    }else if ([verticalAlignment isEqualToString:@"center"]){
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        
    }else if ([verticalAlignment isEqualToString:@"bottom"]){
        if (height == 0) {
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
        }else{
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-|" options:0 metrics:metrics views:views]];
        }
    }
}

//子View水平方向布局时添加水平方向的约束
+ (void)horizontallyAddHorizontallyLayoutConstraint:(UIView *)view
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
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }else if ([horizontallyAlignment isEqualToString:@"center"]){
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if ([horizontallyAlignment isEqualToString:@"right"]){
        if (index == 0) {
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [[ConfigurationLayoutHelper sharedManager].layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }
}


+ (void)handleView:(UIView *)view withInfo:(NSDictionary *)info {
    //绑定点击控件
    if (![view isMemberOfClass:[UIView class]] && view.userInteractionEnabled == YES ) {
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
        singleTap.delegate = [ConfigurationLayoutHelper sharedManager];
        objc_setAssociatedObject(singleTap, "info", info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [view addGestureRecognizer:singleTap];
    }
    
}

+ (void)singleTapping:(UITapGestureRecognizer*)tapGesture {
//    if (self.tapBlock) {
//        NSDictionary *info = objc_getAssociatedObject(tapGesture, "info");
//        self.tapBlock(tapGesture.view,info);
//    }
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

/**
 *  根据16进制的NSString，返回一个颜色
 *
 *  @param hexString
 *
 *  @return
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    BOOL successFlag = YES;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            NSLog(@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            successFlag = NO;
            alpha = red = blue = green = 0.0f;
            break;
    }
    if (successFlag) {
        return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    } else {
        return [UIColor blackColor];
    }
}


+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


@end
