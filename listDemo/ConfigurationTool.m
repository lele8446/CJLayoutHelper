//
//  Configuration.m
//  listDemo
//
//  Created by ChiJinLian on 16/9/2.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import "ConfigurationTool.h"

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}


@implementation ConfigurationTool

+ (CGSize)calculateStringSize:(NSString *)titleString titleFont:(UIFont *)titleFont width:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeZero;
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    [attDic setObject:titleFont forKey:NSFontAttributeName];
    
    CGSize strSize = [titleString boundingRectWithSize:CGSizeMake(width, height)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:attDic
                                               context:nil].size;
    
    size = CGSizeMake(CGFloat_ceil(strSize.width), CGFloat_ceil(strSize.height));
    return size;
}

+ (CGFloat)calculateValue:(id)valueStr superValue:(CGFloat)superValue padding:(CGFloat)padding {
    CGFloat value = 0;
    if (([valueStr isKindOfClass:[NSString class]])&&([valueStr hasSuffix:@"p"] || [valueStr hasSuffix:@"P"])){
        if ([valueStr hasSuffix:@"p"]) {
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@"p" withString:@""];
        }else if ([valueStr hasSuffix:@"P"]){
            valueStr = [valueStr stringByReplacingOccurrencesOfString:@"P" withString:@""];
        }
        value = [valueStr floatValue]>1?1:[valueStr floatValue];
        value = (superValue - 2*padding)*value;
    }else{
        value = [valueStr floatValue];
    }
    return value;
}

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
