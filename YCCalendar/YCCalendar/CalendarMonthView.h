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
/**
 *  更改view的frame值
 *
 *  @param weekNum 当前月有多少周
 */
typedef void(^ChangeCalendarFrameBlock)(NSInteger weekNum);

@interface CalendarMonthView : UIView<UICollectionViewDelegate , UICollectionViewDataSource>
@property (nonatomic, copy) SelectCalendarDateBlock selectDateBlock;
@property (nonatomic, copy) ChangeCalendarFrameBlock changeFrameBlock;
@property (nonatomic, assign) NSInteger selectDateRow;//选定日期是在第几行
@property (nonatomic, assign) BOOL heightAdjust;

/**
 *  刷新数据
 *
 *  @param selectDate
 *  @param viewType
 *  @param heightAdjust
 */
- (void)loadDataSelectDate:(NSDate *)selectDate withType:(CalendarViewType)viewType heightAdjust:(BOOL)heightAdjust;
@end
