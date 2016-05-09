//
//  CalendarItemModel.m
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "CalendarItemModel.h"

@implementation CalendarItemModel

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
                     isToday:(BOOL)isToday
{
    self = [super init];
    if (self) {
        self.date = date;
        self.textcolor = textcolor;
        self.backcolor = backcolor?backcolor:DefaultBackColor;
        self.todaySelectTextcolor = todaySelectTextcolor?todaySelectTextcolor:DefaultTodaySelectTextcolor;
        self.todayselectBackcolor = todayselectBackcolor?todayselectBackcolor:DefaultTodatSelectBackcolor;
        self.selectBorderColor = selectBorderColor?selectBorderColor:DefaultTodatSelectBackcolor;
        self.todayBorderColor = todayBorderColor?todayBorderColor:DefaultTodayBorderColor;
        self.haveData = haveData;
        self.selected = selected;
        self.isThisMonth = isThisMonth;
        self.isToday = isToday;
    }
    return self;
}
@end
