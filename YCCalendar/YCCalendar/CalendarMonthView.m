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
#import "CalendarDataServer.h"
#import "YCCalendarView.h"

NSString *const YCCalendarCellIdentifier = @"cell";

@interface CalendarMonthView ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, assign) CalendarViewType viewType;

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


- (void)loadDataSelectDate:(NSDate *)selectDate withType:(CalendarViewType)viewType {
    [self.dateArray removeAllObjects];
    self.viewType = viewType;
    if (viewType == CalendarMonth) {
        [self.dateArray addObjectsFromArray:[CalendarDataServer handleMonthDateTodayDate:[NSDate date] selectDate:selectDate]];
    }else if (viewType == CalendarWeek) {
        [self.dateArray addObjectsFromArray:[CalendarDataServer handleWeekDateTodayDate:[NSDate date] selectDate:selectDate]];
    }
    [_collectionView reloadData];
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
    cell.pointLabel.hidden = !calendarItem.haveData;
    cell.textLabel.layer.borderColor = [UIColor clearColor].CGColor;
    if (calendarItem.isToday) {
        if (calendarItem.selected) {
            cell.textLabel.textColor = calendarItem.todaySelectTextcolor;
            cell.textLabel.backgroundColor = calendarItem.todayselectBackcolor;
            cell.textLabel.layer.cornerRadius = TextLabelHeight(cell)/2;
            cell.textLabel.layer.borderWidth = 1;
        }else {
            cell.textLabel.textColor = calendarItem.textcolor;
            cell.textLabel.backgroundColor = calendarItem.backcolor;
            cell.textLabel.layer.cornerRadius = TextLabelHeight(cell)/2;
            cell.textLabel.layer.borderColor = calendarItem.todayBorderColor.CGColor;
            cell.textLabel.layer.borderWidth = 1;
        }
    }else{
        if (calendarItem.selected) {
            cell.textLabel.textColor = calendarItem.textcolor;
            cell.textLabel.backgroundColor = calendarItem.backcolor;
            cell.textLabel.layer.cornerRadius = TextLabelHeight(cell)/2;
            cell.textLabel.layer.borderColor = calendarItem.selectBorderColor.CGColor;
            cell.textLabel.layer.borderWidth = 1;
        }
    }
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    //TODO:点击判断
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
    if ( (self.viewType == CalendarWeek) || (calendarItem.isThisMonth && (self.viewType == CalendarMonth))) {
        calendarItem.selected  = YES;
        [newDateArray replaceObjectAtIndex:indexPath.row withObject:calendarItem];
        [self.dateArray removeAllObjects];
        [self.dateArray addObjectsFromArray:newDateArray];
        [self.collectionView reloadData];
    }
    if (self.selectDateBlock) {
        self.selectDateBlock(calendarItem.date,calendarItem.isThisMonth);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width / 7, self.dateArray.count>7?self.collectionView.frame.size.height/6:self.collectionView.frame.size.height);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
