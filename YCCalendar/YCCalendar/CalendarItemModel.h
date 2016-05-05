//
//  CalendarItemModel.h
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CalendarItemModel : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIColor *textcolor;
@property (nonatomic, strong) UIColor *selectTextcolor;
@property (nonatomic, strong) UIColor *backcolor;
@property (nonatomic, strong) UIColor *selectBackcolor;
@property (nonatomic, assign) BOOL haveData;
@property (nonatomic, assign) BOOL selected;

/**
 *  初始化
 *
 *  @param date            日期
 *  @param textcolor       文本颜色
 *  @param backcolor       背景颜色（default [UIColor whiteColor]）
 *  @param selectTextcolor 选中文本颜色（default [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]）
 *  @param selectBackcolor 选中背景颜色（default [UIColor colorWithRed:0.083 green:0.4504 blue:0.9318 alpha:1.0]）
 *  @param haveData        当天是否有任务
 *  @param selected        是否被选中
 *
 *  @return
 */
- (instancetype)initWithDate:(NSDate *)date
                   textColor:(UIColor *)textcolor
                   backColor:(UIColor *)backcolor
             selectTextColor:(UIColor *)selectTextcolor
             selectBackColor:(UIColor *)selectBackcolor
                    haveData:(BOOL)haveData
                    selected:(BOOL)selected;
@end
