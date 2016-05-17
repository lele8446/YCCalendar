//
//  ViewController.m
//  YCCalendar
//
//  Created by YiChe on 16/5/3.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "ViewController.h"
#import "YCCalendarView.h"
#import "CalendarDataServer.h"
#import "CalendarItemModel.h"

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()<YCCalendarViewDelegate>
@property (nonatomic, strong) YCCalendarView *calendarView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIView *topView;

@property (nonatomic, assign) CGFloat headViewHeight;
@property (nonatomic, assign) BOOL isExpaned;
@property (nonatomic, strong) NSDate *selectDate;
@end

@implementation ViewController

- (void)dealloc {
    self.calendarView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTopView];
    
    self.isExpaned = YES;
    
    self.calendarView = [[YCCalendarView alloc]initWithFrame:CGRectMake(0, 200, ScreenWidth, DefaultCalendarWeekViewHeight*6)];
    self.calendarView.calendarViewDelegate = self;
    self.calendarView.heightAdjust = YES;
    [self.calendarView YCCalendarViewLoadInitialDataWithSelectDay:[NSDate date]];
    [self.view addSubview:self.calendarView];
    
}

- (void)customTopView {
    self.topView.backgroundColor = [UIColor colorWithRed:0.9373 green:0.9373 blue:0.9373 alpha:1.0];
    for (int i = 0; i < 7; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        CGFloat width = self.topView.frame.size.width / 7;
        label.frame = CGRectMake(i * width, 0, width, CGRectGetHeight(self.topView.frame));
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = (i == 0 || i == 6)?[UIColor colorWithRed:0.9922 green:0.5255 blue:0.0353 alpha:1.0]:[UIColor colorWithRed:0.5451 green:0.5451 blue:0.5451 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = i==0?@"日":i==1?@"一":i==2?@"二":i==3?@"三":i==4?@"四":i==5?@"五":@"六";
        [self.topView addSubview:label];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextMonth:(id)sender {
    [self.calendarView YCCalendarViewScrollToNextPage];
}

- (IBAction)lastMonth:(id)sender {
    [self.calendarView YCCalendarViewScrollToLastPage];
}

- (IBAction)nextDate:(id)sender {
    [self.calendarView YCCalendarViewScrollToNextDay];
}

- (IBAction)lastDate:(id)sender {
    [self.calendarView YCCalendarViewScrollToLastDay];
}

- (IBAction)today:(id)sender {
    [self.calendarView YCCalendarViewScrollToToday];
}

- (IBAction)changeCalendarViewType {
    self.isExpaned = !self.isExpaned;
    [UIView animateWithDuration:0.3 animations:^(void){
        
    }];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"fade"];
    [animation setSubtype:kCATransitionFromTop];
    [self.calendarView.layer addAnimation:animation forKey:nil];
    
    if (self.isExpaned) {
        self.calendarView.viewType = CalendarMonth;
        ChangeViewFrameHeight(self.calendarView, 6 * DefaultCalendarWeekViewHeight);
        [self.calendarView YCCalendarViewLoadInitialDataWithSelectDay:self.selectDate];
    }else{
        self.calendarView.viewType = CalendarWeek;
        ChangeViewFrameHeight(self.calendarView, DefaultCalendarWeekViewHeight);
        [self.calendarView YCCalendarViewLoadInitialDataWithSelectDay:self.selectDate];
    }
}

#pragma mark - YCCalendarViewDelegate
- (void)YCCalendarView:(YCCalendarView *)calendarView didEndScrollToDate:(NSDate *)date selectDateRow:(NSInteger)row {
    if (calendarView == self.calendarView) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *timeString= [formatter stringFromDate:date];
        self.label.text = timeString;
        self.selectDate = date;
    }
}

- (void)YCCalendarView:(YCCalendarView *)calendarView selectCalendarDate:(NSDate *)date selectDateRow:(NSInteger)row {
    if (calendarView == self.calendarView) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *timeString= [formatter stringFromDate:date];
        self.label.text = timeString;
        self.selectDate = date;
    }
}

- (void)YCCalendarView:(YCCalendarView *)calendarView adjustFrameWithWeekNumber:(NSInteger)number {
    NSLog(@"高度变为 %@ 行",@(number));
}
@end
