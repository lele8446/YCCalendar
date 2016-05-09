//
//  CalendarMonthView.h
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ViewAutoresizingFlexibleAll UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin

typedef void(^SelectCalendarDateBlock)(NSDate *date, BOOL isThisMonth);

@interface CalendarMonthView : UIView<UICollectionViewDelegate , UICollectionViewDataSource>
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *selectDate;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, copy) SelectCalendarDateBlock selectDateBlock;

/**
 *  刷新数据
 *
 *  @param date 
 */
- (void)loadData:(NSDate *)date selectDate:(NSDate *)selectDate isExpand:(BOOL)isExpand;
@end
