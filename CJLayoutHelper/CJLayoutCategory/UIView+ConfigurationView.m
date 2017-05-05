//
//  UIView+ConfigurationView.m
//  CJLayoutHelperDemo
//
//  Created by ChiJinLian on 16/11/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "UIView+ConfigurationView.h"
#import <objc/runtime.h>

@implementation UIView (ConfigurationView)
static char idDescriptionStrKey;
- (void)setIdDescription:(NSString *)idDescription{
    //OBJC_ASSOCIATION_COPY_NONATOMIC跟属性声明中的retain、assign、copy是一样
    objc_setAssociatedObject(self, &idDescriptionStrKey, idDescription, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)idDescription{
    return objc_getAssociatedObject(self, &idDescriptionStrKey);
}

- (nullable __kindof UIView *)viewWithIdDescription:(nullable NSString *)idDescription {
    return [self viewWithIdDescription:idDescription fromSuperView:self];
}

- (nullable __kindof UIView *)viewWithIdDescription:(nullable NSString *)idDescription fromSuperView:(UIView *)superView {
    UIView *view = nil;
    if (!idDescription || idDescription==nil || [idDescription isKindOfClass:[NSNull class]] || idDescription==NULL || [idDescription length]==0) {
        return view;
    }
    if ([superView.idDescription isEqualToString:idDescription]) {
        view = superView;
    }else{
        if (superView.subviews.count > 0){
            for (UIView *childView in superView.subviews) {
                UIView *theView = [self viewWithIdDescription:idDescription fromSuperView:childView];
                if (theView && nil != theView) {
                    view = theView;
                    break;
                }
            }
        }
    }
    return view;
}
@end
