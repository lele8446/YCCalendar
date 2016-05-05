//
//  CalendarMonthView.m
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "CalendarMonthView.h"
#import "CollectionViewCell.h"
#import "CalendarItemModel.h"

NSString *const YCCalendarCellIdentifier = @"cell";

@interface CalendarMonthView ()
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation CalendarMonthView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        self.collectionView.autoresizingMask = ViewAutoresizingFlexibleAll;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.scrollsToTop = NO;
        self.collectionView.bounces = NO;
        //注册
        [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:YCCalendarCellIdentifier];
        [self addSubview:self.collectionView];
        
        self.dateArray = [NSMutableArray array];
    }
    return self;
}


- (void)loadData:(NSDate *)date {
    self.date = date;
    [self handleDateArray:date];
    [_collectionView reloadData];
}

- (void)handleDateArray:(NSDate *)date {
    [self.dateArray removeAllObjects];
    
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    
    //处理上一月数据
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    if (firstWeekday != 0) {//当前月的第一天不是星期日
        NSDate *lastMonthDate = [self lastMonth:self.date];
        NSInteger lastMonthDays = [self totaldaysInMonth:lastMonthDate];
        NSInteger lastMonthStartDays = lastMonthDays - firstWeekday;
        
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
            [[CalendarItemModel alloc]initWithDate:newdate
                                         textColor:[UIColor colorWithRed:0.8078 green:0.8078 blue:0.8078 alpha:1.0]
                                         backColor:nil
                                   selectTextColor:nil
                                   selectBackColor:nil
                                          haveData:NO
                                          selected:NO];
            [self.dateArray addObject:calendarItem];
        }
    }
    
    //当前月数据
    NSInteger curMonthDays = [self totaldaysInMonth:self.date];
    [format setDateFormat:@"yyyy"];
    NSString *curMonthYearStr = [format stringFromDate:self.date];
    [format setDateFormat:@"MM"];
    NSString *curMonthStr = [format stringFromDate:self.date];
    for (NSInteger i = 1; i <= curMonthDays; i++) {
        NSString *curMonthDateStr = [NSString stringWithFormat:@"%@-%@-%ld",curMonthYearStr,curMonthStr,(long)i];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSDate *newdate=[format dateFromString:curMonthDateStr];
        CalendarItemModel *calendarItem =
        [[CalendarItemModel alloc]initWithDate:newdate
                                     textColor:[UIColor colorWithRed:0.1845 green:0.1885 blue:0.206 alpha:1.0]
                                     backColor:nil
                               selectTextColor:nil
                               selectBackColor:nil
                                      haveData:NO
                                      selected:NO];
        if ([[format stringFromDate:newdate] isEqualToString:[format stringFromDate:self.today]]) {
            calendarItem.selected = YES;
            calendarItem.haveData = YES;
        }
        [self.dateArray addObject:calendarItem];
    }
    
    //处理下一月数据
    if (self.dateArray.count < 42) {//当前月的最后一天不是最后一个星期六
        NSDate *nextMonthDate = [self nextMonth:self.date];
        [format setDateFormat:@"yyyy"];
        NSString *nextMonthYearStr = [format stringFromDate:nextMonthDate];
        [format setDateFormat:@"MM"];
        NSString *nextMonthStr = [format stringFromDate:nextMonthDate];
        
        NSInteger nextMonthEndDays = 42 - self.dateArray.count;
        for (NSInteger i = 1; i <= nextMonthEndDays; i++) {
            NSString *nextMonthDateStr = [NSString stringWithFormat:@"%@-%@-%ld",nextMonthYearStr,nextMonthStr,(long)i];
            [format setDateFormat:@"yyyy-MM-dd"];
            NSDate *newdate=[format dateFromString:nextMonthDateStr];
            CalendarItemModel *calendarItem =
            [[CalendarItemModel alloc]initWithDate:newdate
                                         textColor:[UIColor colorWithRed:0.8078 green:0.8078 blue:0.8078 alpha:1.0]
                                         backColor:nil
                                   selectTextColor:nil
                                   selectBackColor:nil
                                          haveData:NO
                                          selected:NO];
            [self.dateArray addObject:calendarItem];
        }
    }
    
}

#pragma -mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dateArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YCCalendarCellIdentifier forIndexPath:indexPath];
    CalendarItemModel *calendarItem = (CalendarItemModel *)self.dateArray[indexPath.row];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd"];
    NSString *timeString= [formatter stringFromDate:calendarItem.date];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)[timeString integerValue]];
    cell.textLabel.textColor = calendarItem.textcolor;
    cell.textLabel.backgroundColor = calendarItem.backcolor;
    cell.textLabel.layer.cornerRadius = TextLabelHeight(cell)/2;
    cell.pointLabel.hidden = !calendarItem.haveData;
    if (calendarItem.selected) {
        cell.textLabel.textColor = calendarItem.selectTextcolor;
        cell.textLabel.backgroundColor = calendarItem.selectBackcolor;
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
//    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
//    
//    NSInteger day = 0;
//    NSInteger i = indexPath.row;
//    
//    if (i >= firstWeekday && i <= firstWeekday + daysInThisMonth - 1) {
//        day = i - firstWeekday + 1;
//        
//        //this month
//        if ([_today isEqualToDate:_date]) {
//            if (day <= [self day:_date]) {
//                return YES;
//            }
//        } else if ([_today compare:_date] == NSOrderedDescending) {
//            return YES;
//        }
//    }
//    return NO;
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *newDateArray = [NSMutableArray array];
    [self.dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        CalendarItemModel *item = (CalendarItemModel *)obj;
        item.selected = NO;
        [newDateArray addObject:item];
    }];
    
    CalendarItemModel *calendarItem = (CalendarItemModel *)self.dateArray[indexPath.row];
    calendarItem.selected  = YES;
    [newDateArray replaceObjectAtIndex:indexPath.row withObject:calendarItem];
    [self.dateArray removeAllObjects];
    [self.dateArray addObjectsFromArray:newDateArray];
    [self.collectionView reloadData];
    
    if (self.selectDateBlock) {
        self.selectDateBlock(calendarItem.date);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width / 7, self.collectionView.frame.size.height / 6);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - date

- (NSInteger)day:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}

- (NSInteger)month:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

/**
 *  当月第一天是星期几
 *
 *  @param date
 *
 *  @return 0.Sun. 1.Mon. 2.Thes. 3.Wed. 4.Thur. 5.Fri. 6.Sat.
 */
- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //设置星期日为一周开始的第一天
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

/**
 *  当月最后一天是星期几
 *
 *  @param date
 *
 *  @return 0.Sun. 1.Mon. 2.Thes. 3.Wed. 4.Thur. 5.Fri. 6.Sat.
 */
- (NSInteger)lastWeekdayInThisMonth:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //设置星期日为一周开始的第一天
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:[self totaldaysInMonth:date]];
    NSDate *lastDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger lastWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:lastDayOfMonthDate];
    return lastWeekday - 1;
}

- (NSInteger)totaldaysInMonth:(NSDate *)date {
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

- (NSDate *)lastMonth:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

@end
