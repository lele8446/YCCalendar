//
//  YCCalendarView.h
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCCalendarViewDelegate <NSObject>

/**
 *  已滑动至某一日期
 *
 *  @param date
 */
- (void)YCCalendarViewdidEndScrollToDate:(NSDate *)date;

/**
 *  选择了某一日期
 *
 *  @param date
 */
- (void)YCCalendarViewSelectCalendarDate:(NSDate *)date;

@end

@interface YCCalendarView : UIView

@property (nonatomic, weak) id<YCCalendarViewDelegate> delegate;
@property (nonatomic, copy) NSString *currentMonth;//当前月份id

/**
 *  刷新数据
 */
- (void)refreshData;

/**
 *  加载初始数据
 *
 *  @param date  本月日期
 *  @param today 当前日期
 */
- (void)loadingInitialData:(NSDate *)date today:(NSDate *)today;

/**
 *  上一月
 */
- (void)scrollToLastMonth;

/**
 *  下一月
 */
- (void)scrollToNextMonth;

/**
 *  滑动到今天
 */
- (void)scrollToToday;

@end
