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
        self.layout = info[@"layout"];
        self.model = info[@"model"];
    }
    return self;
}
@end
