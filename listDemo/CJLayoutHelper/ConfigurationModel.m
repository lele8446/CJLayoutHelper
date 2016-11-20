//
//  ConfigurationModel.m
//  listDemo
//
//  Created by ChiJinLian on 16/9/6.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import "ConfigurationModel.h"

NSString * const kLayout                = @"layout";
NSString * const kViewStyleIdentifier   = @"viewStyleIdentifier";
NSString * const kViewType              = @"viewType";
NSString * const kHorizontallyAlignment = @"horizontallyAlignment";
NSString * const kLeftPadding           = @"leftPadding";
NSString * const kRightPadding          = @"rightPadding";
NSString * const kWidth                 = @"width";
NSString * const kVerticalAlignment     = @"verticalAlignment";
NSString * const kTopPadding            = @"topPadding";
NSString * const kBottomPadding         = @"bottomPadding";
NSString * const kHeight                = @"height";
NSString * const kAutolayoutHeight      = @"autolayoutHeight";
NSString * const kLayoutDirection       = @"layoutDirection";
NSString * const kSubviews              = @"subviews";

NSString * const kModel                 = @"model";
NSString * const kIdDescription         = @"idDescription";

NSString * const kHorizontally          = @"horizontally";
NSString * const kVertical              = @"vertical";
NSString * const kLeftWidth             = @"leftWidth";
NSString * const kCenter                = @"center";
NSString * const kWidthRight            = @"widthRight";
NSString * const kLeftRight             = @"leftRight";
NSString * const kTopHeight             = @"topHeight";
NSString * const kHeightBottom          = @"heightBottom";
NSString * const kTopBottom             = @"topBottom";


@implementation ConfigurationModel

- (instancetype)initConfigurationModelInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        [self modelFromInfo:info];
    }
    return self;
}

- (void)modelFromInfo:(NSDictionary *)info {
    self.layout = [NSMutableDictionary dictionaryWithCapacity:4];
    [self.layout addEntriesFromDictionary:info[kLayout]];
    self.model = info[kModel];
    NSArray *subviews = self.layout[kSubviews];
    if (subviews && subviews.count > 0) {
        NSMutableArray *newSubviews = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < subviews.count; i ++) {
            ConfigurationModel *model = [[ConfigurationModel alloc]initConfigurationModelInfo:subviews[i]];
            [model modelFromInfo:subviews[i]];
            [newSubviews addObject:model];
        }
        [self.layout setObject:newSubviews forKey:kSubviews];
    }
}
@end
