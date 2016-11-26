//
//  CJLayoutHelper.m
//  listDemo
//
//  Created by ChiJinLian on 16/9/1.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import "CJLayoutHelper.h"
#import <objc/runtime.h>
#import "ConfigurationModel.h"

//根据文本内容动态调整宽度／高度时默认增加的内边距
#define AutoSizeDefaultPadding 4

/**
 *  配置文件对应的整体view的标识符
 */
static NSString *viewStyleIdentifier;

@interface CJLayoutHelper ()<UIGestureRecognizerDelegate>

@property(nonatomic, weak) id<CJLayoutHelperDelegate> delegate;

/**
 *  需要在上面绘制UI的View
 */
@property (nonatomic, strong) UIView *layoutContentView;

/**
 *  最底层superView的字体，默认为：[UIFont systemFontOfSize:14]
 */
@property (nonatomic, strong) UIFont *superViewtitleFont;

/**
 *  最底层superView的字体颜色，默认为：[UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *superViewtitleColor;

@end

@implementation CJLayoutHelper

+ (instancetype)sharedManager {
    static CJLayoutHelper *instance = nil;
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
    static CJLayoutHelper *instance;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - PublicMethod
+ (NSString *)configurationViewStyleIdentifier:(ConfigurationModel *)info {
    viewStyleIdentifier = NSStringForInfoKey(info.layout, kViewStyleIdentifier, kViewStyleIdentifier, NO);
    return viewStyleIdentifier;
}

- (CGFloat)viewHeightWithInfo:(ConfigurationModel *)info contentViewWidth:(CGFloat)contentViewWidth contentViewHeight:(CGFloat)contentViewHeight {
    //记录最底层view的字体信息
    [self settingSuperViewValue:info.model];
    [self settingDefaultValue:info.model];

    CGFloat leftPadding = CGFloatForLayoutKey(info.layout, kLeftPadding);
    CGFloat rightPadding = CGFloatForLayoutKey(info.layout, kRightPadding);
    CGFloat topPadding = CGFloatForLayoutKey(info.layout, kTopPadding);
    CGFloat bottomPadding = CGFloatForLayoutKey(info.layout, kBottomPadding);
    
    LayoutDirection directionLayout = ViewLayoutDirection(info.layout);
    /**
     *  当前view作为父view时，减去其所有子view的内边距后的宽度/高度，用于后面其子view宽度/高度的计算
     */
    CGFloat superWidth = contentViewWidth;
    CGFloat superHeight = contentViewHeight;
    if (directionLayout == horizontallyLayout) {//水平
        superWidth = contentViewWidth - leftPadding - rightPadding;
    }else if (directionLayout == verticalLayout) {//垂直
        superHeight = contentViewHeight - topPadding - bottomPadding;
    }
    
    //宽度
    CGFloat width = [ConfigurationTool calculateValue:info directionLayout:directionLayout superValue:superWidth isWidth:YES];
    
    return [self theViewHeight:info superHeight:superHeight width:width layoutDirection:directionLayout];
}

- (void)initializeViewWithInfo:(ConfigurationModel *)info layoutContentView:(UIView *)layoutContentView contentViewWidth:(CGFloat)contentViewWidth contentViewHeight:(CGFloat)contentViewHeight delegate:(id<CJLayoutHelperDelegate>)delegate {
    
    viewStyleIdentifier = NSStringForInfoKey(info.layout, kViewStyleIdentifier, kViewStyleIdentifier, NO);
    self.layoutContentView = layoutContentView;
    self.delegate = delegate;
    
    //记录最底层view的字体信息
    [self settingSuperViewValue:info.model];
    [self settingDefaultValue:info.model];
    
    //子View布局方向
    LayoutDirection directionLayout = ViewLayoutDirection(info.layout);
    
    CGFloat leftPadding = CGFloatForLayoutKey(info.layout, kLeftPadding);
    CGFloat rightPadding = CGFloatForLayoutKey(info.layout, kRightPadding);
    CGFloat topPadding = CGFloatForLayoutKey(info.layout, kTopPadding);
    CGFloat bottomPadding = CGFloatForLayoutKey(info.layout, kBottomPadding);
    
    /**
     *  当前view作为父view时，减去其所有子view的内边距后的宽度/高度，用于后面其子view宽度/高度的计算
     */
    CGFloat superWidth = contentViewWidth;
    CGFloat superHeight = contentViewHeight;
    if (directionLayout == horizontallyLayout) {//水平
        superWidth = contentViewWidth - leftPadding - rightPadding;
    }else if (directionLayout == verticalLayout) {//垂直
        superHeight = contentViewHeight - topPadding - bottomPadding;
    }
    
    //绘制UI
    [self enumerateChildViewInfo:info superView:layoutContentView withIndex:0 withSuperViewWidth:superWidth withSuperViewHeight:superHeight layoutDirection:directionLayout];
}

#pragma mark - ViewHeightMethod
//获取指定视图的高度
- (CGFloat)theViewHeight:(ConfigurationModel *)info
             superHeight:(CGFloat)superHeight
                   width:(CGFloat)width
         layoutDirection:(LayoutDirection)direction
{
    NSString *viewClassStr = info.layout[kViewType];//view类型
    id theViewClass = NSClassFromString(viewClassStr);
    
    //高度
    CGFloat height = [self currentViewHeight:info superViewHeight:superHeight width:width layoutDirection:direction];
    
    /**
     *  当前view作为父view时，根据所有子view的内边距计算宽度/高度，用于后面其子view宽度/高度的计算
     */
    CGFloat currentAccordingToPaddingWidth = [ConfigurationTool superViewWidthAccordingToPadding:info superWidth:width];
    CGFloat currentAccordingToPaddingHeight = [ConfigurationTool superViewHeightAccordingToPadding:info superHeight:height];
    
    //动态调整高度（比如UILable高度随文本动态变化时），遍历子view，取最大值
    BOOL autolayoutHeight = BOOLForInfoKey(info.layout, kAutolayoutHeight);
    if (autolayoutHeight) {
        NSArray *subviews = info.layout[kSubviews];
        if (subviews || subviews.count > 0) {
            for (NSInteger i = 0; i < subviews.count; i++) {
                ConfigurationModel *childModel = subviews[i];
                LayoutDirection childViewdirectionLayout = ViewLayoutDirection(info.layout);
                //宽度
                CGFloat childViewWidth = [ConfigurationTool calculateValue:childModel directionLayout:childViewdirectionLayout superValue:currentAccordingToPaddingWidth isWidth:YES];

                CGFloat topPadding = CGFloatForLayoutKey(childModel.layout, kTopPadding);
                CGFloat bottomPadding = CGFloatForLayoutKey(childModel.layout, kBottomPadding);
                
                CGFloat childViewHeight = [self theViewHeight:childModel superHeight:currentAccordingToPaddingHeight width:childViewWidth layoutDirection:childViewdirectionLayout];
                childViewHeight = childViewHeight + topPadding + bottomPadding;
                height = childViewHeight>height?childViewHeight:height;
            }
        }
    }
    
    UIView *currentView = [[theViewClass alloc]init];
    LayoutDirection directionLayout = ViewLayoutDirection(info.layout);
    //子View是垂直方向布局,判断子view的叠加高度
    if (directionLayout == verticalLayout) {
        CGFloat subviewsHeight = 0;
        NSArray *subviews = info.layout[kSubviews];
        //不是UIScrollView且子view是垂直方向布局时，判断当前高度与（所有子view高度的和 + 内边距） 的大小
        if ((![currentView isKindOfClass:[UIScrollView class]])&&(subviews || subviews.count > 0)) {
            
            for (NSInteger i = 0; i < subviews.count; i++) {
                ConfigurationModel *childModel = subviews[i];
                LayoutDirection childViewdirectionLayout = ViewLayoutDirection(info.layout);
                //宽度
                CGFloat childViewWidth = [ConfigurationTool calculateValue:childModel directionLayout:childViewdirectionLayout superValue:currentAccordingToPaddingWidth isWidth:YES];
                
                CGFloat topPadding = CGFloatForLayoutKey(childModel.layout, kTopPadding);
                CGFloat bottomPadding = CGFloatForLayoutKey(childModel.layout, kBottomPadding);

                CGFloat childViewHeight = [self theViewHeight:childModel superHeight:currentAccordingToPaddingHeight width:childViewWidth layoutDirection:childViewdirectionLayout];
                
                childViewHeight = childViewHeight + topPadding + bottomPadding;
                subviewsHeight = subviewsHeight + childViewHeight;
            }
            height = height>subviewsHeight?height:subviewsHeight;
        }
    }
    
    CGFloat topPadding = CGFloatForLayoutKey(info.layout, kTopPadding);
    CGFloat bottomPadding = CGFloatForLayoutKey(info.layout, kBottomPadding);
    NSLog(@"view.idDescription = %@, topPadding = %@, bottomPadding = %@, height = %@, width = %@",NSStringForInfoKey(info.model, kIdDescription, @"", NO),@(topPadding),@(bottomPadding),@(height),@(width));
    return height;
}

//当前view的高度
- (CGFloat)currentViewHeight:(ConfigurationModel *)info
             superViewHeight:(CGFloat)superViewHeight
                       width:(CGFloat)width
             layoutDirection:(LayoutDirection)direction
{
    [self settingDefaultValue:info.model];
    CGFloat currentViewHeight = [ConfigurationTool calculateValue:info directionLayout:direction superValue:superViewHeight isWidth:NO];
    if (self.titleString && self.titleString.length >0 && width != 0 && currentViewHeight == 0) {
        CGSize strSize = [ConfigurationTool calculateStringSize:self.titleString titleFont:self.titleFont width:width height:MAXFLOAT];
        currentViewHeight = strSize.height + AutoSizeDefaultPadding;
    }
    return currentViewHeight;
}



#pragma mark - drawView
//遍历绘制所有子view
- (void)enumerateChildViewInfo:(ConfigurationModel *)info
                     superView:(UIView *)superView
                     withIndex:(NSInteger)index
            withSuperViewWidth:(CGFloat)superViewWidth
           withSuperViewHeight:(CGFloat)superViewHeight
               layoutDirection:(LayoutDirection)direction
{
    __block UIView *currentView = nil;
    
    
    NSString *viewClassStr = info.layout[kViewType];//view类型
    id theViewClass = NSClassFromString(viewClassStr);
    if (!viewClassStr || viewClassStr.length <= 0 || !theViewClass || nil == theViewClass) {
        NSString *errorStr = [NSString stringWithFormat:@"viewType类型出错，viewType :%@",info.layout[kViewType]];
        CJNSLog(@"errorStr = %@",errorStr);
        CJNSLog(@"errorInfo = %@",info);
        /**
         *  防止当前这一层视图的配置信息出错，比如"viewType"声明错误，但其中却存在有"subviews"
         *  则跳过这一层，直接绘制在superView上面
         */
        currentView = superView;
        [self contentSizeOfScrollView:info currentView:currentView width:superViewWidth height:superViewHeight];
    }else {
        [self settingDefaultValue:info.model];
        
        CGFloat leftPadding = CGFloatForLayoutKey(info.layout, kLeftPadding);
        CGFloat rightPadding = CGFloatForLayoutKey(info.layout, kRightPadding);
        //宽度
        CGFloat width = [ConfigurationTool calculateValue:info directionLayout:direction superValue:superViewWidth isWidth:YES];
        
        CGFloat topPadding = CGFloatForLayoutKey(info.layout, kTopPadding);
        CGFloat bottomPadding = CGFloatForLayoutKey(info.layout, kBottomPadding);
        //高度
        CGFloat height = [self theViewHeight:info superHeight:superViewHeight width:width layoutDirection:direction];
        
        if (self.titleString && self.titleString.length >0 && height != 0 && width == 0) {
            CGSize strSize = [ConfigurationTool calculateStringSize:self.titleString titleFont:self.titleFont width:MAXFLOAT height:height];
            width = strSize.width + AutoSizeDefaultPadding;
        }
        
        NSInteger tag = superView.tag;
        NSString *tagStr = [NSString stringWithFormat:@"%@_%@_%@_%@",viewStyleIdentifier,@(tag),@(index),viewClassStr];
        currentView = [superView viewWithTag:[tagStr hash]];
        if (nil == currentView) {
            currentView = [[NSClassFromString(viewClassStr) alloc]init];
            currentView.tag = [tagStr hash];
            [superView addSubview:currentView];
        }
        currentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *metrics = @{@"leftPadding":@(leftPadding),
                                  @"rightPadding":@(rightPadding),
                                  @"width":@(width),
                                  @"topPadding":@(topPadding),
                                  @"bottomPadding":@(bottomPadding),
                                  @"height":@(height)};
        
        UIView *lastView = nil;
        if (index == 0) {
            lastView = superView;
        }else{
            @try {
                lastView = [superView.subviews objectAtIndex:index-1];
            } @catch (NSException *exception) {
                lastView = superView;
                NSString *errorStr = [NSString stringWithFormat:@"获取lastView出错，superView :%@\n currentVIew :%@",NSStringFromClass([superView class]),NSStringFromClass([currentView class])];
                CJNSLog(@"lastView error =%@",errorStr);
            }
        }
        
        //水平方向的位置
        HorizontallyAlignmentType horizontallyAlignment = getHorizontallyAlignment(info.layout);
        //垂直方向的位置
        VerticalAlignmentType verticalAlignment = getVerticalAlignment(info.layout);
        //垂直布局
        if (direction == verticalLayout) {
            //垂直方向的约束
            [self verticalAddVerticalLayoutConstraint:currentView lastView:lastView superView:superView index:index verticalAlignment:verticalAlignment topPadding:topPadding bottomPadding:bottomPadding height:height metrics:metrics];
            //水平方向的约束
            [self verticalAddHorizontallyLayoutConstraint:currentView superView:superView horizontallyAlignment:horizontallyAlignment leftPadding:leftPadding rightPadding:rightPadding width:width metrics:metrics];
            
        }else if (direction == horizontallyLayout) {//水平布局
            //垂直方向的约束
            [self horizontallyAddVerticalLayoutConstraint:currentView superView:superView verticalAlignment:verticalAlignment topPadding:topPadding bottomPadding:bottomPadding height:height metrics:metrics];
            //水平方向的约束
            [self horizontallyAddHorizontallyLayoutConstraint:currentView lastView:lastView superView:superView index:index horizontallyAlignment:horizontallyAlignment leftPadding:leftPadding rightPadding:rightPadding width:width metrics:metrics];
        }
        if ([currentView isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)currentView;
            label.preferredMaxLayoutWidth = width;
        }
        
        [self.layoutContentView updateConstraints];
        //当view是UIScrollView时立即刷新，以便能够在后面获取准确的contentSize
        if (([currentView isKindOfClass:[UIScrollView class]]) || ([currentView.superview isKindOfClass:[UIScrollView class]])) {
            [self.layoutContentView layoutIfNeeded];
        }else{
            [self.layoutContentView setNeedsLayout];
        }
        
        [self handleView:currentView withModelInfo:info];
        [self contentSizeOfScrollView:info currentView:currentView width:width height:height];
    }
    
}

//判断是否为UIScrollView，并获取contentSize
- (void)contentSizeOfScrollView:(ConfigurationModel *)info
                    currentView:(UIView *)currentView
                          width:(CGFloat)width
                         height:(CGFloat)height
{
    NSArray *subviews = info.layout[kSubviews];
    if (subviews || subviews.count > 0) {
        for (NSInteger i = 0; i < subviews.count; i++) {
            ConfigurationModel *childModel = subviews[i];
            
            /**
             *  当前view作为父view时，减去其所有子view的内边距后的宽度/高度，用于后面其子view宽度/高度的计算
             */
            CGFloat superWithoutPaddingWidth = [ConfigurationTool superViewWidthAccordingToPadding:info superWidth:width];
            CGFloat superWithoutPaddingHeight = [ConfigurationTool superViewHeightAccordingToPadding:info superHeight:height];
           
            [self enumerateChildViewInfo:childModel
                               superView:currentView
                               withIndex:i
                      withSuperViewWidth:superWithoutPaddingWidth
                     withSuperViewHeight:superWithoutPaddingHeight
                         layoutDirection:ViewLayoutDirection(info.layout)];
            
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

#pragma mark - autolayout
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
                          verticalAlignment:(VerticalAlignmentType)verticalAlignment
                                 topPadding:(CGFloat)topPadding
                              bottomPadding:(CGFloat)bottomPadding
                                     height:(CGFloat)height
                                    metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view,lastView);
    if (verticalAlignment == verticalTopHeight) {//top＋height
        if (index == 0) {//第一个子view，垂直方向相对位置的view取superView
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:topPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }else{//不是第一个子view时，垂直方向相对位置的view取前一个子view
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1 constant:topPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }
    }else if (verticalAlignment == verticalCenter) {//center
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
    }else if (verticalAlignment == verticalHeightBottom) {//height＋bottom
        if (index == 0) {
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }else{
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTop multiplier:1 constant:-bottomPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
        }
    }else if (verticalAlignment == verticalTopBottom) {//top＋bottom
        if (index == 0) {
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:topPadding]];
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomPadding]];
        }else{
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTop multiplier:1 constant:topPadding]];
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomPadding]];
        }
    }
}

/**
 *  子View垂直方向布局时添加水平方向的约束
 */
- (void)verticalAddHorizontallyLayoutConstraint:(UIView *)view
                                      superView:(UIView *)superView
                          horizontallyAlignment:(HorizontallyAlignmentType)horizontallyAlignment
                                    leftPadding:(CGFloat)leftPadding
                                   rightPadding:(CGFloat)rightPadding
                                          width:(CGFloat)width
                                        metrics:(NSDictionary *)metrics
{
    //垂直方向布局时水平方向相对位置的view都取superView
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    if (horizontallyAlignment == horizontallyLeftWidth) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:leftPadding]];
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if (horizontallyAlignment == horizontallyCenter) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if (horizontallyAlignment == horizontallyWidthRight) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-rightPadding]];
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if (horizontallyAlignment == horizontallyLeftRight) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:leftPadding]];
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-rightPadding]];
    }

}

//子View水平方向布局时添加垂直方向的约束
- (void)horizontallyAddVerticalLayoutConstraint:(UIView *)view
                                      superView:(UIView *)superView
                              verticalAlignment:(VerticalAlignmentType)verticalAlignment
                                     topPadding:(CGFloat)topPadding
                                  bottomPadding:(CGFloat)bottomPadding
                                         height:(CGFloat)height
                                        metrics:(NSDictionary *)metrics
{
    //水平方向布局时垂直方向相对位置的view都取superView
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    if (verticalAlignment == verticalTopHeight) {
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topPadding)-[view(==height)]" options:0 metrics:metrics views:views]];
    }else if (verticalAlignment == verticalCenter) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
    }else if (verticalAlignment == verticalHeightBottom) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomPadding]];
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:metrics views:views]];
    }else if (verticalAlignment == verticalTopBottom) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:topPadding]];
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomPadding]];
    }
}

//子View水平方向布局时添加水平方向的约束
- (void)horizontallyAddHorizontallyLayoutConstraint:(UIView *)view
                                           lastView:(UIView *)lastView
                                          superView:(UIView *)superView
                                              index:(NSInteger)index
                              horizontallyAlignment:(HorizontallyAlignmentType)horizontallyAlignment
                                        leftPadding:(CGFloat)leftPadding
                                       rightPadding:(CGFloat)rightPadding
                                              width:(CGFloat)width
                                            metrics:(NSDictionary *)metrics
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view,lastView);
    if (horizontallyAlignment == horizontallyLeftWidth) {
        if (index == 0) {
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:leftPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1 constant:leftPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }else if (horizontallyAlignment == horizontallyCenter) {
        [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
    }else if (horizontallyAlignment == horizontallyWidthRight) {
        if (index == 0) {
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-rightPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }else{
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeLeading multiplier:1 constant:-rightPadding]];
            [self.layoutContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==width)]" options:0 metrics:metrics views:views]];
        }
    }else if (horizontallyAlignment == horizontallyLeftRight) {
        if (index == 0) {
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:leftPadding]];
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-rightPadding]];
        }else{
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeLeading multiplier:1 constant:leftPadding]];
            [self.layoutContentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-rightPadding]];
        }
    }
}

#pragma mark - ConfigurationLayoutHelperDelegate
- (void)handleView:(UIView *)view withModelInfo:(ConfigurationModel *)info {
    //设置idDescription的值
    NSString *idDescription = NSStringForInfoKey(info.model, kIdDescription, @"", NO);
    view.idDescription = idDescription;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(configureView: withModelInfo:)]) {
        [self.delegate configureView:view withModelInfo:info.model];
    }
    
    //通用属性设置
    UIColor *backColor = (info.model[@"backgroundColor"]&&([info.model[@"backgroundColor"] length]>0))?[ConfigurationTool colorWithHexString:info.model[@"backgroundColor"]]:[UIColor whiteColor];
    view.backgroundColor = backColor;
}

#pragma mark - ModelInfo
//设置最底层view的信息
- (void)settingSuperViewValue:(NSDictionary *)model {
    //记录最底层view的字体信息
    CGFloat fontSize = (model[@"titleFont"] && [model[@"titleFont"] floatValue]>0)?[model[@"titleFont"] floatValue]:14;
    self.superViewtitleFont = [UIFont systemFontOfSize:fontSize];
    if (model[@"titleColor"]&&([model[@"titleColor"] length]>0)) {
        self.superViewtitleColor = [ConfigurationTool colorWithHexString:model[@"titleColor"]];
    }else{
        self.superViewtitleColor = [UIColor blackColor];
    }
}

//设置model信息
- (void)settingDefaultValue:(NSDictionary *)model {
    self.titleString = model[@"title"]&&[model[@"title"] length]>0?model[@"title"]:@"";
    if (model[@"titleFont"]&&([model[@"titleFont"] floatValue]>0)) {
        self.titleFont = [UIFont systemFontOfSize:[model[@"titleFont"] floatValue]];
    }else{//不存在，取最底层的值
        self.titleFont = self.superViewtitleFont;
    }
    
    if (model[@"titleColor"]&&([model[@"titleColor"] length]>0)) {
        self.titleColor = [ConfigurationTool colorWithHexString:model[@"titleColor"]];
    }else{
        self.titleColor = self.superViewtitleColor;
    }
}

@end
