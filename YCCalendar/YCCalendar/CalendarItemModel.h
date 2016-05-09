//
//  CalendarItemModel.h
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ThisMonthTextColor     ([UIColor colorWithRed:0.1845 green:0.1885 blue:0.206 alpha:1.0])
#define OtherMonthTextColor    ([UIColor colorWithRed:0.8078 green:0.8078 blue:0.8078 alpha:1.0])
#define DefaultBackColor       ([UIColor whiteColor])
#define DefaultTodaySelectTextcolor ([UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0])
#define DefaultTodatSelectBackcolor ([UIColor colorWithRed:0.083 green:0.4504 blue:0.9318 alpha:1.0])
#define DefaultTodayBorderColor ([UIColor colorWithRed:0.8078 green:0.8078 blue:0.8078 alpha:1.0])

@interface CalendarItemModel : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIColor *textcolor;
@property (nonatomic, strong) UIColor *backcolor;
@property (nonatomic, strong) UIColor *todaySelectTextcolor;
@property (nonatomic, strong) UIColor *todayselectBackcolor;
@property (nonatomic, strong) UIColor *selectBorderColor;
@property (nonatomic, strong) UIColor *todayBorderColor;
@property (nonatomic, assign) BOOL haveData;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL isThisMonth;
@property (nonatomic, assign) BOOL isToday;

/**
 *  初始化
 *
 *  @param date                 日期
 *  @param textColor            文本颜色
 *  @param backColor            背景颜色（default [UIColor whiteColor]）
 *  @param todaySelectTextcolor 选中今天文本颜色（default [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]）
 *  @param todayselectBackcolor 选中今天背景颜色（default [UIColor colorWithRed:0.083 green:0.4504 blue:0.9318 alpha:1.0]）
 *  @param selectBorderColor    选中边框颜色（default [UIColor colorWithRed:0.083 green:0.4504 blue:0.9318 alpha:1.0]）
 *  @param todayBorderColor     今天未选中时的边框颜色（default [UIColor colorWithRed:0.8078 green:0.8078 blue:0.8078 alpha:1.0]）
 *  @param haveData             当天是否有数据
 *  @param selected             是否被选中
 *  @param isThisMonth          是否为当月数据
 *  @param isToday              是否为今天
 *
 *  @return
 */
- (instancetype)initWithDate:(NSDate *)date
                   textColor:(UIColor *)textcolor
                   backColor:(UIColor *)backcolor
        todaySelectTextcolor:(UIColor *)todaySelectTextcolor
        todayselectBackcolor:(UIColor *)todayselectBackcolor
           selectBorderColor:(UIColor *)selectBorderColor
            todayBorderColor:(UIColor *)todayBorderColor
                    haveData:(BOOL)haveData
                    selected:(BOOL)selected
                 isThisMonth:(BOOL)isThisMonth
                     isToday:(BOOL)isToday;
@end
