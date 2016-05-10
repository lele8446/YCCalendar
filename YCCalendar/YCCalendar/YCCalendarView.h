//
//  YCCalendarView.h
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarMonthView.h"

#define ChangeViewFrameX(view, X) (view.frame = CGRectMake(X, view.frame.origin.y, view.frame.size.width, view.frame.size.height))
#define ChangeViewFrameY(view, Y) (view.frame = CGRectMake(view.frame.origin.x, Y, view.frame.size.width, view.frame.size.height))
#define ChangeViewFrameHeight(view, height) (view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height))
#define ChangeViewFrameWidth(view, width) (view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height))

@class YCCalendarView;
@protocol YCCalendarViewDelegate <NSObject>

/**
 *  已滑动至某一日期
 *
 *  @param date
 */
- (void)YCCalendarView:(YCCalendarView *)calendarView didEndScrollToDate:(NSDate *)date;

/**
 *  选择了某一日期
 *
 *  @param date
 */
- (void)YCCalendarView:(YCCalendarView *)calendarView selectCalendarDate:(NSDate *)date;

@end


@interface YCCalendarView : UIView
/**
 *  日历样式，default CalendarMonth
 */
@property (nonatomic, assign) CalendarViewType viewType;
@property (nonatomic, weak) id<YCCalendarViewDelegate> delegate;

/**
 *  刷新数据
 */
- (void)refreshData;

/**
 *  加载初始数据
 *
 *  @param selectDay 选定日期
 */
- (void)loadingInitialDataSelectDay:(NSDate *)selectDay;

/**
 *  上一页
 */
- (void)scrollToLastPage;

/**
 *  下一页
 */
- (void)scrollToNextPage;

/**
 *  前一天
 */
- (void)scrollToLastDay;

/**
 *  后一天
 */
- (void)scrollToNextDay;

/**
 *  滑动到今天
 */
- (void)scrollToToday;

@end
