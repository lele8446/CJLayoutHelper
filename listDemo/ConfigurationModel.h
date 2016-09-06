//
//  ConfigurationModel.h
//  listDemo
//
//  Created by ChiJinLian on 16/9/6.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigurationModel : NSObject

@property (nonatomic, strong) NSDictionary *layout;
@property (nonatomic, strong) NSDictionary *model;

- (instancetype)initConfigurationModelInfo:(NSDictionary *)info;

@end
