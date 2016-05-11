//
//  CalendarMonthView.h
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  日历的打开样式
 */
typedef NS_ENUM(NSInteger, CalendarViewType) {
    CalendarMonth = 0,//以月为单位
    CalendarWeek,     //以周为单位
};

#define ViewAutoresizingFlexibleAll UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin

typedef void(^SelectCalendarDateBlock)(NSDate *date, BOOL isThisMonth);

@interface CalendarMonthView : UIView<UICollectionViewDelegate , UICollectionViewDataSource>
@property (nonatomic, copy) SelectCalendarDateBlock selectDateBlock;
@property (nonatomic, assign) NSInteger selectDateRow;//选定日期是在第几行

/**
 *  刷新数据
 *
 *  @param selectDate
 *  @param viewType
 */
- (void)loadDataSelectDate:(NSDate *)selectDate withType:(CalendarViewType)viewType;
@end
