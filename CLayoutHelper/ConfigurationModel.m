//
//  ConfigurationModel.m
//  listDemo
//
//  Created by ChiJinLian on 16/9/6.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import "ConfigurationModel.h"

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
    [self.layout addEntriesFromDictionary:info[@"layout"]];
    self.model = info[@"model"];
    NSArray *subviews = self.layout[@"subviews"];
    if (subviews && subviews.count > 0) {
        NSMutableArray *newSubviews = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < subviews.count; i ++) {
            ConfigurationModel *model = [[ConfigurationModel alloc]initConfigurationModelInfo:subviews[i]];
            [model modelFromInfo:subviews[i]];
            [newSubviews addObject:model];
        }
        [self.layout setObject:newSubviews forKey:@"subviews"];
    }
}
@end
