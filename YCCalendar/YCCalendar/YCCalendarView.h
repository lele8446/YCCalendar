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
@property (nonatomic, assign) BOOL isExpand;//是否展开
@property (nonatomic, weak) id<YCCalendarViewDelegate> delegate;

/**
 *  刷新数据
 */
- (void)refreshData;

/**
 *  加载初始数据
 *
 *  @param date      初始化起始日期，一般与selectDay相同
 *  @param selectDay 选定日期
 */
- (void)loadingInitialData:(NSDate *)date selectDay:(NSDate *)selectDay;

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

/**
 *  向上收起
 */
- (void)YCCalendarViewNarrowCompletion:(void(^)(void))completion;

/**
 *  向下展开
 */
- (void)YCCalendarViewExpandCompletion:(void(^)(void))completion;
@end
