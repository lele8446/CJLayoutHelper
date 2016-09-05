//
//  ConfigurationLayoutHelper.m
//  listDemo
//
//  Created by ChiJinLian on 16/9/1.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import "ConfigurationLayoutHelper.h"
#import "ConfigurationTool.h"
#import "CJUITextView.h"
#import <objc/runtime.h>

#define Manager [ConfigurationLayoutHelper sharedManager]
//根据文本内容动态调整宽度／高度时默认增加的内边距
#define AutoSizeDefaultPadding 4

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
 *  需要在上面绘制UI的View
 */
@property (nonatomic, strong) UIView *layoutContentView;

@end

@implementation ConfigurationLayoutHelper

- (void)dealloc {
    Manager.myDelegate = nil;
}

#pragma mark - 单例
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

#pragma mark - 共有方法
+ (NSString *)configurationViewStyleIdentifier:(NSDictionary *)info {
    Manager.viewStyleIdentifier = (info[@"viewStyleIdentifier"]&&([info[@"viewStyleIdentifier"] length]>0))?info[@"viewStyleIdentifier"]:@"viewStyleIdentifier";
    return Manager.viewStyleIdentifier;
}

+ (CGFloat)viewHeightWithInfo:(NSDictionary *)info withContentViewWidth:(CGFloat)contentViewWidth withContentViewHeight:(CGFloat)contentViewHeight {
    Manager.titleFont = (info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[UIFont systemFontOfSize:[info[@"titleFont"] floatValue]]:Manager.titleFont;
    Manager.titleString = info[@"title"];
    CGFloat xSpacing = (info[@"xSpacing"])?[info[@"xSpacing"] floatValue]:0;
    //宽度
    CGFloat width = [ConfigurationTool calculateValue:info[@"width"] superValue:contentViewWidth padding:xSpacing];
    CGFloat ySpacing = (info[@"ySpacing"])?[info[@"ySpacing"] floatValue]:0;
    NSString *viewClassStr = info[@"viewType"];//view类型
    id theViewClass = NSClassFromString(viewClassStr);
    return [self theViewHeight:info superViewHeight:contentViewHeight ySpacing:ySpacing width:width theViewClass:theViewClass];
}

+ (void)initializeViewWithInfo:(NSDictionary *)info layoutContentView:(UIView *)layoutContentView withContentViewWidth:(CGFloat)contentViewWidth withContentViewHeight:(CGFloat)contentViewHeight {
    Manager.layoutContentView = layoutContentView;
    Manager.viewStyleIdentifier = (info[@"viewStyleIdentifier"]&&([info[@"viewStyleIdentifier"] length]>0))?info[@"viewStyleIdentifier"]:@"viewStyleIdentifier";
    Manager.titleFont = [UIFont systemFontOfSize:(info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[info[@"titleFont"] floatValue]:14];
    
    //子View布局方向
    LayoutDirection directionLayout = ViewLayoutDirection(info);
    //绘制UI
    [self enumerateChildViewInfo:info superView:layoutContentView withIndex:0 withSuperViewWidth:contentViewWidth withSuperViewHeight:contentViewHeight layoutDirection:directionLayout];
}

#pragma mark - 获取高度相关
//获取指定视图的高度
+ (CGFloat)theViewHeight:(NSDictionary *)info superViewHeight:(CGFloat)superViewHeight ySpacing:(CGFloat)ySpacing width:(CGFloat)width theViewClass:(id)theViewClass {
    //高度
    CGFloat height = [self currentViewHeight:info superViewHeight:superViewHeight ySpacing:ySpacing width:width];
    UIView *currentView = [[theViewClass alloc]init];
    LayoutDirection directionLayout = ViewLayoutDirection(info);
    //子View是垂直方向布局,判断子view的叠加高度
    if (directionLayout == verticalLayout) {
        CGFloat subviewsHeight = 0;
        NSArray *subviews = info[@"subviews"];
        //不是UIScrollView且子view是垂直方向布局时，高度＝所有子view高度的和
        if ((![currentView isKindOfClass:[UIScrollView class]])&&(subviews || subviews.count > 0)) {
            for (NSInteger i = 0; i < subviews.count; i++) {
                
                CGFloat childViewXSpacing = (subviews[i][@"xSpacing"])?[subviews[i][@"xSpacing"] floatValue]:0;
                CGFloat childViewWidth = [ConfigurationTool calculateValue:subviews[i][@"width"] superValue:width padding:childViewXSpacing];
                CGFloat childViewYSpacing = (subviews[i][@"ySpacing"])?[subviews[i][@"ySpacing"] floatValue]:0;
                
                BOOL autolayoutHeight = subviews[i][@"autolayoutHeight"]?[info[@"autolayoutHeight"] boolValue]:NO;
                if (autolayoutHeight) {
                    subviewsHeight = subviewsHeight + [self compareViewHeightWithInfo:subviews[i] width:childViewWidth superViewHeight:height ySpacing:childViewYSpacing];
                }else{
                    subviewsHeight = subviewsHeight + [self currentViewHeight:subviews[i] superViewHeight:height ySpacing:childViewYSpacing width:childViewWidth];
                }
            }
            height = height>subviewsHeight?height:subviewsHeight;
        }
    }
    
    //动态调整高度（比如UILable高度随文本动态变化时），遍历子view，取最大值
    BOOL autolayoutHeight = info[@"autolayoutHeight"]?[info[@"autolayoutHeight"] boolValue]:NO;
    if (autolayoutHeight) {
        NSArray *subviews = info[@"subviews"];
        if (subviews || subviews.count > 0) {
            for (NSInteger i = 0; i < subviews.count; i++) {
                CGFloat childViewXSpacing = (subviews[i][@"xSpacing"])?[subviews[i][@"xSpacing"] floatValue]:0;
                //宽度
                CGFloat childViewWidth = [ConfigurationTool calculateValue:subviews[i][@"width"] superValue:width padding:childViewXSpacing];
                CGFloat childViewYSpacing = (subviews[i][@"ySpacing"])?[subviews[i][@"ySpacing"] floatValue]:0;
                CGFloat childViewHeight = [self compareViewHeightWithInfo:subviews[i] width:childViewWidth superViewHeight:height ySpacing:childViewYSpacing];
                height = childViewHeight>height?childViewHeight:height;
            }
        }
    }
    return height;
}

/*
 *  当前view的最大高度
 *  水平方向布局：获取所有view中的最大高度
 *  垂直方向布局：判断所有子view的叠加高度
 */
+ (CGFloat)compareViewHeightWithInfo:(NSDictionary *)info
                               width:(CGFloat)width
                     superViewHeight:(CGFloat)superViewHeight
                            ySpacing:(CGFloat)ySpacing
{
    NSString *viewClassStr = info[@"viewType"];//view类型
    id theViewClass = NSClassFromString(viewClassStr);
    if (!viewClassStr || viewClassStr.length <= 0 || !theViewClass || nil == theViewClass) {
        return 0;
    }
    
    CGFloat currentViewHeight = [self currentViewHeight:info superViewHeight:superViewHeight ySpacing:ySpacing width:width];
    UIView *currentView = [[theViewClass alloc]init];
    LayoutDirection directionLayout = ViewLayoutDirection(info);
    //子View是垂直方向布局
    if (directionLayout == verticalLayout) {
        CGFloat subviewsHeight = 0;
        NSArray *subviews = info[@"subviews"];
        //不是UIScrollView且子view是垂直方向布局时，高度＝所有子view高度的和
        if ((![currentView isKindOfClass:[UIScrollView class]])&&(subviews || subviews.count > 0)) {
            for (NSInteger i = 0; i < subviews.count; i++) {
                
                CGFloat childViewXSpacing = (subviews[i][@"xSpacing"])?[subviews[i][@"xSpacing"] floatValue]:0;
                CGFloat childViewWidth = [ConfigurationTool calculateValue:subviews[i][@"width"] superValue:width padding:childViewXSpacing];
                CGFloat childViewYSpacing = (subviews[i][@"ySpacing"])?[subviews[i][@"ySpacing"] floatValue]:0;
                
                subviewsHeight = subviewsHeight + [self currentViewHeight:subviews[i] superViewHeight:currentViewHeight ySpacing:childViewYSpacing width:childViewWidth];
            }
            currentViewHeight = currentViewHeight>subviewsHeight?currentViewHeight:subviewsHeight;
        }
    }
    
    superViewHeight = currentViewHeight>superViewHeight?currentViewHeight:superViewHeight;
    
    NSArray *subviews = info[@"subviews"];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            CGFloat childViewXSpacing = (subviews[i][@"xSpacing"])?[subviews[i][@"xSpacing"] floatValue]:0;
            //宽度
            CGFloat childViewWidth = [ConfigurationTool calculateValue:subviews[i][@"width"] superValue:width padding:childViewXSpacing];
            CGFloat childViewYSpacing = (subviews[i][@"ySpacing"])?[subviews[i][@"ySpacing"] floatValue]:0;
            CGFloat childViewHeight = [self compareViewHeightWithInfo:subviews[i] width:childViewWidth superViewHeight:currentViewHeight ySpacing:childViewYSpacing];
            superViewHeight = childViewHeight>superViewHeight?childViewHeight:superViewHeight;
        }
    }
    return superViewHeight;
}

//当前view的高度
+ (CGFloat)currentViewHeight:(NSDictionary *)info
             superViewHeight:(CGFloat)superViewHeight
                    ySpacing:(CGFloat)ySpacing
                       width:(CGFloat)width
{
    Manager.titleFont = (info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[UIFont systemFontOfSize:[info[@"titleFont"] floatValue]]:Manager.titleFont;
    Manager.titleString = info[@"title"];
    CGFloat currentViewHeight = [ConfigurationTool calculateValue:info[@"height"] superValue:superViewHeight padding:ySpacing];
    if (Manager.titleString && Manager.titleString.length >0 && width != 0 && currentViewHeight == 0) {
        CGSize strSize = [ConfigurationTool calculateStringSize:Manager.titleString titleFont:Manager.titleFont width:width height:MAXFLOAT];
        currentViewHeight = strSize.height + AutoSizeDefaultPadding;
    }
    return currentViewHeight;
}

+ (void)sizeOfViewWithInfo:(NSDictionary *)info
            superViewWidth:(CGFloat)superViewWidth
           superViewHeight:(CGFloat)superViewHeight
                   success:(void (^)(CGFloat xSpacing, CGFloat ySpacing, CGFloat width, CGFloat height))success
                   failure:(void (^)(void))failure
{
    CGFloat width = 0;
    CGFloat height = 0;
    NSString *viewClassStr = info[@"viewType"];//view类型
    id theViewClass = NSClassFromString(viewClassStr);
    if (!viewClassStr || viewClassStr.length <= 0 || !theViewClass || nil == theViewClass) {
        NSString *errorStr = [NSString stringWithFormat:@"viewType类型出错，viewType :%@",info[@"viewType"]];
        CJNSLog(@"errorStr = %@",errorStr);
        CJNSLog(@"errorInfo = %@",info);
        if (failure) {
            failure();
        }
    }else {
        Manager.titleFont = (info[@"titleFont"]&&([info[@"titleFont"] floatValue]>0))?[UIFont systemFontOfSize:[info[@"titleFont"] floatValue]]:Manager.titleFont;
        Manager.titleString = info[@"title"];
        CGFloat xSpacing = (info[@"xSpacing"])?[info[@"xSpacing"] floatValue]:0;
        //宽度
        width = [ConfigurationTool calculateValue:info[@"width"] superValue:superViewWidth padding:xSpacing];
        
        CGFloat ySpacing = (info[@"ySpacing"])?[info[@"ySpacing"] floatValue]:0;
        //高度
        height = [self theViewHeight:info superViewHeight:superViewHeight ySpacing:ySpacing width:width theViewClass:theViewClass];
        
        if (Manager.titleString && Manager.titleString.length >0 && height != 0 && width == 0) {
            CGSize strSize = [ConfigurationTool calculateStringSize:Manager.titleString titleFont:Manager.titleFont width:MAXFLOAT height:height];
            width = strSize.width + AutoSizeDefaultPadding;
        }
        if (success) {
            success(xSpacing,ySpacing,width,height);
        }
    }
}

#pragma mark - draw视图
//遍历绘制所有子view
+ (void)enumerateChildViewInfo:(NSDictionary *)info
                     superView:(UIView *)superView
                     withIndex:(NSInteger)index
            withSuperViewWidth:(CGFloat)superViewWidth
           withSuperViewHeight:(CGFloat)superViewHeight
               layoutDirection:(LayoutDirection)direction
{
    __block UIView *currentView = nil;
    
    [self sizeOfViewWithInfo:info
              superViewWidth:superViewWidth
             superViewHeight:superViewHeight
                     success:^(CGFloat xSpacing, CGFloat ySpacing, CGFloat width, CGFloat height){
                         
                         NSString *viewClassStr = info[@"viewType"];//view类型
                         NSInteger tag = superView.tag;
                         NSString *tagStr = [NSString stringWithFormat:@"%@_%@_%@_%@",Manager.viewStyleIdentifier,@(tag),@(index),viewClassStr];
                         
                         currentView = [superView viewWithTag:[tagStr hash]];
                         if (nil == currentView) {
                             currentView = [[NSClassFromString(viewClassStr) alloc]init];
                             currentView.tag = [tagStr hash];
                             [superView addSubview:currentView];
                         }
                         currentView.translatesAutoresizingMaskIntoConstraints = NO;
                         
                         [self handleView:currentView withInfo:info];
                         
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
                                 NSString *errorStr = [NSString stringWithFormat:@"获取lastView出错，superView :%@\n currentVIew :%@",superView.description,currentView.description];
                                 CJNSLog(@"lastView error =%@",errorStr);
                             }
                         }
                         
                         //水平方向的位置
                         HorizontallyAlignmentType horizontallyAlignment = getHorizontallyAlignment(info);
                         //垂直方向的位置
                         VerticalAlignmentType verticalAlignment = getVerticalAlignment(info);
                         //垂直布局
                         if (direction == verticalLayout) {
                             //垂直方向的约束
                             [self verticalAddVerticalLayoutConstraint:currentView lastView:lastView superView:superView index:index verticalAlignment:verticalAlignment ySpacing:ySpacing height:height metrics:metrics];
                             //水平方向的约束
                             [self verticalAddHorizontallyLayoutConstraint:currentView superView:superView horizontallyAlignment:horizontallyAlignment xSpacing:xSpacing width:width metrics:metrics];
                             
                         }else if (direction == horizontallyLayout) {//水平布局
                             //垂直方向的约束
                             [self horizontallyAddVerticalLayoutConstraint:currentView superView:superView verticalAlignment:verticalAlignment ySpacing:ySpacing height:height metrics:metrics];
                             //水平方向的约束
                             [self horizontallyAddHorizontallyLayoutConstraint:currentView lastView:lastView superView:superView index:index horizontallyAlignment:horizontallyAlignment xSpacing:xSpacing width:width metrics:metrics];
                         }
                         
                         [Manager.layoutContentView updateConstraints];
                         //当view是UIScrollView时立即刷新，以便能够在后面获取准确的contentSize
                         if (([currentView isKindOfClass:[UIScrollView class]]) || ([currentView.superview isKindOfClass:[UIScrollView class]])) {
                             [Manager.layoutContentView layoutIfNeeded];
                         }else{
                             [Manager.layoutContentView setNeedsLayout];
                         }
                         [self contentSizeOfScrollView:info currentView:currentView width:width height:height];
                         
                     }failure:^(void){
                         /**
                          *  防止当前这一层视图的配置信息出错，比如"viewType"声明错误，但其中却存在有"subviews"
                          *  则跳过这一层，直接绘制在superView上面
                          */
                         currentView = superView;
                         [self contentSizeOfScrollView:info currentView:currentView width:superViewWidth height:superViewHeight];
                     }];
}

//判断是否为UIScrollView，并获取contentSize
+ (void)contentSizeOfScrollView:(NSDictionary *)info
                    currentView:(UIView *)currentView
                          width:(CGFloat)width
                         height:(CGFloat)height
{
    NSArray *subviews = info[@"subviews"];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            [self enumerateChildViewInfo:subviews[i] superView:currentView withIndex:i withSuperViewWidth:width withSuperViewHeight:height layoutDirection:ViewLayoutDirection(info)];
            
            //当前view是UIScrollView，并且已经绘制完其中所有的subviews，计算contentSize
            if (([currentView isKindOfClass:[UIScrollView class]])&&(i == subviews.count-1)) {
                UIView *childView = currentView.subviews[currentView.subviews.count-1];
                UIScrollView *scrollView = (UIScrollView *)currentView;
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

#pragma mark - autolayout约束
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
                          verticalAlignment:(VerticalAlignmentType)verticalAlignment
                                   ySpacing:(CGFloat)ySpacing
                                     height:(CGFloat)height
                                    metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view,lastView);
    if (verticalAlignment == verticalTop) {
        if (index == 0) {//第一个子view，垂直方向相对位置的view取superView
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }else{//不是第一个子view时，垂直方向相对位置的view取前一个子view
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }
    }else if (verticalAlignment == verticalCenter) {
        [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
    }else if (verticalAlignment == verticalBottom) {
        if (index == 0) {
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:ySpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }else{
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTop multiplier:1 constant:ySpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }
    }
}

/**
 *  子View垂直方向布局时添加水平方向的约束
 */
+ (void)verticalAddHorizontallyLayoutConstraint:(UIView *)view
                                      superView:(UIView *)superView
                          horizontallyAlignment:(HorizontallyAlignmentType)horizontallyAlignment
                                       xSpacing:(CGFloat)xSpacing
                                          width:(CGFloat)width
                                        metrics:(NSDictionary *)metrics
{
    //垂直方向布局时水平方向相对位置的view都取superView
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    if (horizontallyAlignment == horizontallyLeft) {
        [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if (horizontallyAlignment == horizontallyCenter) {
        [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if (horizontallyAlignment == horizontallyRight) {
        [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }

}

//子View水平方向布局时添加垂直方向的约束
+ (void)horizontallyAddVerticalLayoutConstraint:(UIView *)view
                                      superView:(UIView *)superView
                              verticalAlignment:(VerticalAlignmentType)verticalAlignment
                                       ySpacing:(CGFloat)ySpacing
                                         height:(CGFloat)height
                                        metrics:(NSDictionary *)metrics
{
    //水平方向布局时垂直方向相对位置的view都取superView
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    if (verticalAlignment == verticalTop) {
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(ySpacing)-[view(==height)]" options:0 metrics:metrics views:views]];
    }else if (verticalAlignment == verticalCenter) {
        [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        
    }else if (verticalAlignment == verticalBottom) {
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]-(ySpacing)-|" options:0 metrics:metrics views:views]];
    }
}

//子View水平方向布局时添加水平方向的约束
+ (void)horizontallyAddHorizontallyLayoutConstraint:(UIView *)view
                                           lastView:(UIView *)lastView
                                          superView:(UIView *)superView
                                              index:(NSInteger)index
                              horizontallyAlignment:(HorizontallyAlignmentType)horizontallyAlignment
                                           xSpacing:(CGFloat)xSpacing
                                              width:(CGFloat)width
                                            metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view,lastView);
    if (horizontallyAlignment == horizontallyLeft) {
        if (index == 0) {
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }else if (horizontallyAlignment == horizontallyCenter) {
        [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if (horizontallyAlignment == horizontallyRight) {
        if (index == 0) {
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:xSpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [Manager.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeLeading multiplier:1 constant:xSpacing]];
            [Manager.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }
}

+ (void)handleView:(UIView *)view withInfo:(NSDictionary *)info {
    if (Manager.myDelegate && [Manager.myDelegate respondsToSelector:@selector(configureView: withInfo:)]) {
        [Manager.myDelegate configureView:view withInfo:info];
    }
    //绑定点击控件
    if (![view isMemberOfClass:[UIView class]] && view.userInteractionEnabled == YES ) {
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
        singleTap.delegate = Manager;
        objc_setAssociatedObject(singleTap, "info", info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [view addGestureRecognizer:singleTap];
    }
    UIColor *backColor = (info[@"backgroundColor"]&&([info[@"backgroundColor"] length]>0))?[ConfigurationTool colorWithHexString:info[@"backgroundColor"]]:[UIColor whiteColor];
    view.backgroundColor = backColor;
    
    
}

+ (void)singleTapping:(UITapGestureRecognizer*)tapGesture {
    //    if (self.tapBlock) {
    NSDictionary *info = objc_getAssociatedObject(tapGesture, "info");
    UIView *view = tapGesture.view;
    NSLog(@"view = %@",NSStringFromClass([view class]));
    NSLog(@"info = %@",info);
    if ([view isMemberOfClass:[UIButton class]]) {
        if (info[@"selectImage"] && [info[@"selectImage"] length]>0) {
            UIButton *button = (UIButton *)view;
            button.selected = !button.selected;
        }
    }
    if ([view isMemberOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)view;
        NSLog(@"%@",tableView);
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
