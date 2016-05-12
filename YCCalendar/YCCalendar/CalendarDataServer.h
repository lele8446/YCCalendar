//
//  CalendarDataServer.h
//  YCCalendar
//
//  Created by YiChe on 16/5/6.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarDataServer : NSObject

/**
 *  该天是当月的第几天
 *
 *  @param date
 *
 *  @return
 */
+ (NSInteger)day:(NSDate *)date;

/**
 *  该天所在周是一年中的第几周
 *
 *  @param date
 *
 *  @return
 */
+ (NSInteger)weekOfYear:(NSDate *)date;

/**
 *  该天对应的月份
 *
 *  @param date
 *
 *  @return
 */
+ (NSInteger)month:(NSDate *)date;

/**
 *  该天对应的年份
 *
 *  @param date
 *
 *  @return
 */
+ (NSInteger)year:(NSDate *)date;

/**
 *  当月第一天是星期几
 *
 *  @param date
 *
 *  @return 0.Sun. 1.Mon. 2.Thes. 3.Wed. 4.Thur. 5.Fri. 6.Sat.
 */
+ (NSInteger)firstMonthdayInWeek:(NSDate *)date;

/**
 *  当月最后一天是星期几
 *
 *  @param date
 *
 *  @return 0.Sun. 1.Mon. 2.Thes. 3.Wed. 4.Thur. 5.Fri. 6.Sat.
 */
+ (NSInteger)lastMonthdayInWeek:(NSDate *)date;

/**
 *  该天是星期几
 *
 *  @param date
 *
 *  @return 0.Sun. 1.Mon. 2.Thes. 3.Wed. 4.Thur. 5.Fri. 6.Sat.
 */
+ (NSInteger)dayInWeek:(NSDate *)date;

/**
 *  当月总共有多少天
 *
 *  @param date
 *
 *  @return
 */
+ (NSInteger)totaldaysInMonth:(NSDate *)date;

/**
 *  上一月最后一天日期
 *
 *  @param date
 *
 *  @return
 */
+ (NSDate *)lastMonth:(NSDate *)date;

/**
 *  下一月第一天日期
 *
 *  @param date
 *
 *  @return
 */
+ (NSDate*)nextMonth:(NSDate *)date;

/**
 *  上一周周日日期
 *
 *  @param date
 *
 *  @return
 */
+ (NSDate *)lastWeek:(NSDate *)date;

/**
 *  下一周周日日期
 *
 *  @param date
 *
 *  @return
 */
+ (NSDate*)nextWeek:(NSDate *)date;

/**
 *  根据指定日期，返回当月数据
 *
 *  @param date
 *  @param todayDate
 *  @param selectDate
 *
 *  @return
 */
+ (NSArray *)handleMonthDateTodayDate:(NSDate *)todayDate selectDate:(NSDate *)selectDate;

/**
 *  根据指定日期，返回本周数据
 *
 *  @param date
 *  @param todayDate
 *  @param selectDate
 *
 *  @return
 */
+ (NSArray *)handleWeekDateTodayDate:(NSDate *)todayDate selectDate:(NSDate *)selectDate;

@end
