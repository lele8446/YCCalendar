//
//  CalendarMonthView.h
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ViewAutoresizingFlexibleAll UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin

typedef void(^SelectCalendarDateBlock)(NSDate *date);

@interface CalendarMonthView : UIView<UICollectionViewDelegate , UICollectionViewDataSource>
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *today;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, copy) SelectCalendarDateBlock selectDateBlock;

/**
 *  上一月日期
 *
 *  @param date
 *
 *  @return
 */
- (NSDate *)lastMonth:(NSDate *)date;

/**
 *  下个月日期
 *
 *  @param date
 *
 *  @return 
 */
- (NSDate*)nextMonth:(NSDate *)date;

/**
 *  刷新数据
 *
 *  @param date 
 */
- (void)loadData:(NSDate *)date;
@end
