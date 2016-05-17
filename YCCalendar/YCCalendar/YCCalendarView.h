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


/**
 *  单周视图的高度，default 40
 *
 *  @return
 */
#define DefaultCalendarWeekViewHeight 40

@class YCCalendarView;
@protocol YCCalendarViewDelegate <NSObject>

/**
 *  已滑动至某一日期
 *
 *  @param calendarView
 *  @param date         选中日期
 *  @param row          选中日期在第几行
 */
- (void)YCCalendarView:(YCCalendarView *)calendarView didEndScrollToDate:(NSDate *)date selectDateRow:(NSInteger)row;

/**
 *  选择了某一日期
 *
 *  @param calendarView
 *  @param date         选中日期
 *  @param row          选中日期在第几行
 */
- (void)YCCalendarView:(YCCalendarView *)calendarView selectCalendarDate:(NSDate *)date selectDateRow:(NSInteger)row;

@optional

- (void)YCCalendarView:(YCCalendarView *)calendarView adjustFrameWithWeekNumber:(NSInteger)number;

@end


@interface YCCalendarView : UIScrollView
@property (nonatomic, weak) id<YCCalendarViewDelegate> calendarViewDelegate;

/**
 *  日历样式，default CalendarMonth
 */
@property (nonatomic, assign) CalendarViewType viewType;

/**
 *  是否根据不同月份数据自动调整高度，值为NO时需设定frame值高度 = 6 * DefaultCalendarWeekViewHeight,
 *  default NO
 */
@property (nonatomic, assign) BOOL heightAdjust;

/**
 *  加载初始数据
 *  @param selectDay 选定日期
 */
- (void)YCCalendarViewLoadInitialDataWithSelectDay:(NSDate *)selectDay;

/**
 *  上一页
 */
- (void)YCCalendarViewScrollToLastPage;

/**
 *  下一页
 */
- (void)YCCalendarViewScrollToNextPage;

/**
 *  前一天
 */
- (void)YCCalendarViewScrollToLastDay;

/**
 *  后一天
 */
- (void)YCCalendarViewScrollToNextDay;

/**
 *  滑动到今天
 */
- (void)YCCalendarViewScrollToToday;

@end
