//
//  CalendarDataServer.m
//  YCCalendar
//
//  Created by YiChe on 16/5/6.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "CalendarDataServer.h"
#import "CalendarItemModel.h"

@implementation CalendarDataServer

+ (NSInteger)day:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}

+ (NSInteger)month:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

+ (NSInteger)year:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

+ (NSInteger)firstMonthdayInWeek:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //设置星期日为一周开始的第一天
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

+ (NSInteger)lastMonthdayInWeek:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //设置星期日为一周开始的第一天
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:[self totaldaysInMonth:date]];
    NSDate *lastDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger lastWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:lastDayOfMonthDate];
    return lastWeekday - 1;
}

+ (NSInteger)dayInWeek:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //设置星期日为一周开始的第一天
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:[self day:date]];
    NSDate *dayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger weekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:dayOfMonthDate];
    return weekday - 1;
}

+ (NSInteger)totaldaysInMonth:(NSDate *)date {
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

+ (NSDate *)lastMonth:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

+ (NSDate*)nextMonth:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

+ (NSDate *)lastWeek:(NSDate *)date {
    NSInteger weekday = [self dayInWeek:date];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] - (weekday+1)*24*3600)];
    return newDate;
}

+ (NSDate*)nextWeek:(NSDate *)date {
    NSInteger weekday = [self dayInWeek:date];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + (7-weekday)*24*3600)];
    return newDate;
}

+ (NSArray *)handleMonthDate:(NSDate *)date todayDate:(NSDate *)todayDate selectDate:(NSDate *)selectDate {
    NSMutableArray *dateArray = [NSMutableArray array];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    //处理上一月数据
    NSInteger firstWeekday = [self firstMonthdayInWeek:date];
    if (firstWeekday != 0) {//当前月的第一天不是星期日
        NSDate *lastMonthDate = [self lastMonth:date];
        NSInteger lastMonthDays = [self totaldaysInMonth:lastMonthDate];
        NSInteger lastMonthStartDays = lastMonthDays - (firstWeekday-1);
        
        [format setDateFormat:@"yyyy"];
        //上一月年份
        NSString *lastMonthYearStr = [format stringFromDate:lastMonthDate];
        //上一月
        [format setDateFormat:@"MM"];
        NSString *lastMonthStr = [format stringFromDate:lastMonthDate];
        
        for (NSInteger i = lastMonthStartDays; i <= lastMonthDays; i++) {
            NSString *lastMonthDateStr = [NSString stringWithFormat:@"%@-%@-%ld",lastMonthYearStr,lastMonthStr,(long)i];
            [format setDateFormat:@"yyyy-MM-dd"];
            NSDate *newdate=[format dateFromString:lastMonthDateStr];
            CalendarItemModel *calendarItem =
            [[CalendarItemModel alloc] initWithDate:newdate
                                          textColor:OtherMonthTextColor
                                          backColor:nil
                               todaySelectTextcolor:nil
                               todayselectBackcolor:nil
                                  selectBorderColor:nil
                                   todayBorderColor:nil
                                           haveData:NO
                                           selected:NO
                                        isThisMonth:NO
                                            isToday:NO];
            [dateArray addObject:calendarItem];
        }
    }
    
    //当前月数据
    NSInteger curMonthDays = [self totaldaysInMonth:date];
    [format setDateFormat:@"yyyy"];
    NSString *curMonthYearStr = [format stringFromDate:date];
    [format setDateFormat:@"MM"];
    NSString *curMonthStr = [format stringFromDate:date];
    for (NSInteger i = 1; i <= curMonthDays; i++) {
        NSString *curMonthDateStr = [NSString stringWithFormat:@"%@-%@-%ld",curMonthYearStr,curMonthStr,(long)i];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSDate *newdate=[format dateFromString:curMonthDateStr];
        BOOL selected = NO;
        BOOL isToday = NO;
        
        //不是今天所在的月份
        if ([self month:date] != [self month:todayDate]) {
            if ([[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:newdate]]) {
                selected = YES;
            }
        }else{
            if ([[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:todayDate]] &&
                [[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:newdate]]) {
                selected = YES;
                isToday = YES;
            }else if ([[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:newdate]]){
                selected = YES;
            }
        }
        
        CalendarItemModel *calendarItem =
        [[CalendarItemModel alloc] initWithDate:newdate
                                      textColor:ThisMonthTextColor
                                      backColor:nil
                           todaySelectTextcolor:nil
                           todayselectBackcolor:nil
                              selectBorderColor:nil
                               todayBorderColor:nil
                                       haveData:NO
                                       selected:selected
                                    isThisMonth:YES
                                        isToday:isToday];
        [dateArray addObject:calendarItem];
    }
    
    //处理下一月数据
    if (dateArray.count < 42) {//当前月的最后一天不是最后一个星期六
        NSDate *nextMonthDate = [self nextMonth:date];
        [format setDateFormat:@"yyyy"];
        NSString *nextMonthYearStr = [format stringFromDate:nextMonthDate];
        [format setDateFormat:@"MM"];
        NSString *nextMonthStr = [format stringFromDate:nextMonthDate];
        
        NSInteger nextMonthEndDays = 42 - dateArray.count;
        for (NSInteger i = 1; i <= nextMonthEndDays; i++) {
            NSString *nextMonthDateStr = [NSString stringWithFormat:@"%@-%@-%ld",nextMonthYearStr,nextMonthStr,(long)i];
            [format setDateFormat:@"yyyy-MM-dd"];
            NSDate *newdate=[format dateFromString:nextMonthDateStr];
            CalendarItemModel *calendarItem =
            [[CalendarItemModel alloc] initWithDate:newdate
                                          textColor:OtherMonthTextColor
                                          backColor:nil
                               todaySelectTextcolor:nil
                               todayselectBackcolor:nil
                                  selectBorderColor:nil
                                   todayBorderColor:nil
                                           haveData:NO
                                           selected:NO
                                        isThisMonth:NO
                                            isToday:NO];
            [dateArray addObject:calendarItem];
        }
    }
    return dateArray;
}

+ (NSArray *)handleWeekDate:(NSDate *)date todayDate:(NSDate *)todayDate selectDate:(NSDate *)selectDate {
    NSMutableArray *dateArray = [NSMutableArray array];
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    
    NSInteger dayInWeek = [self dayInWeek:date];
    //当天是星期日
    if (dayInWeek == 0) {
        for (NSInteger i = 0; i < 7; i++) {
            NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + i*24*3600)];
            CalendarItemModel *calendarItem =
            [[CalendarItemModel alloc] initWithDate:newDate textColor:ThisMonthTextColor backColor:nil todaySelectTextcolor:nil todayselectBackcolor:nil selectBorderColor:nil todayBorderColor:nil haveData:NO selected:NO isThisMonth:NO isToday:NO];
            [dateArray addObject:calendarItem];
        }
    }
    //当天是星期六
    else if (dayInWeek == 0) {
        for (NSInteger i = 7; i > 0; i--) {
            NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] - i*24*3600)];
            CalendarItemModel *calendarItem =
            [[CalendarItemModel alloc] initWithDate:newDate textColor:ThisMonthTextColor backColor:nil todaySelectTextcolor:nil todayselectBackcolor:nil selectBorderColor:nil todayBorderColor:nil haveData:NO selected:NO isThisMonth:NO isToday:NO];
            [dateArray addObject:calendarItem];
        }
    }else{
        //当天之前
        for (NSInteger i = dayInWeek; i > 0; i--) {
            NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] - i*24*3600)];
            CalendarItemModel *calendarItem =
            [[CalendarItemModel alloc] initWithDate:newDate textColor:ThisMonthTextColor backColor:nil todaySelectTextcolor:nil todayselectBackcolor:nil selectBorderColor:nil todayBorderColor:nil haveData:NO selected:NO isThisMonth:NO isToday:NO];
            [dateArray addObject:calendarItem];
        }
        //当天之后（包含当天）
        for (NSInteger i = 0; i < 7 - dayInWeek; i++) {
            NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + i*24*3600)];
            CalendarItemModel *calendarItem =
            [[CalendarItemModel alloc] initWithDate:newDate textColor:ThisMonthTextColor backColor:nil todaySelectTextcolor:nil todayselectBackcolor:nil selectBorderColor:nil todayBorderColor:nil haveData:NO selected:NO isThisMonth:NO isToday:NO];
            [dateArray addObject:calendarItem];
        }
    }
    
    __block BOOL haveToday = NO;
    [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        CalendarItemModel *item = (CalendarItemModel *)obj;
        if ([[format stringFromDate:item.date] isEqualToString:[format stringFromDate:todayDate]]) {
            haveToday = YES;
        }
    }];
    
    NSMutableArray *newDateArray = [NSMutableArray array];
    [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        CalendarItemModel *item = (CalendarItemModel *)obj;
        item.isThisMonth = ([self month:date] == [self month:item.date])?YES:NO;
        
        //不是今天所在的星期
        if (!haveToday) {
            if ([[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:item.date]]) {
                item.selected = YES;
            }
        }else{
            if ([[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:todayDate]] &&
                [[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:item.date]]) {
                item.selected = YES;
                item.isToday = YES;
            }else if ([[format stringFromDate:selectDate] isEqualToString:[format stringFromDate:item.date]]){
                item.selected = YES;
            }
        }
        [newDateArray addObject:item];
    }];
    return newDateArray;
}
@end
