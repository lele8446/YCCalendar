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
    
    self.calendarView = [[YCCalendarView alloc]initWithFrame:CGRectMake(0, 200, ScreenWidth, 240*ScreenWidth/320.0)];
    self.calendarView.delegate = self;
    [self.calendarView loadingInitialDataSelectDay:[NSDate date]];
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
        if (i == 0) {
            label.text = @"日";
        }else if (i == 1){
            label.text = @"一";
        }else if (i == 2){
            label.text = @"二";
        }else if (i == 3){
            label.text = @"三";
        }else if (i == 4){
            label.text = @"四";
        }else if (i == 5){
            label.text = @"五";
        }else if (i == 6){
            label.text = @"六";
        }
        [self.topView addSubview:label];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextMonth:(id)sender {
    [self.calendarView scrollToNextPage];
}

- (IBAction)lastMonth:(id)sender {
    [self.calendarView scrollToLastPage];
}

- (IBAction)nextDate:(id)sender {
    [self.calendarView scrollToNextDay];
}

- (IBAction)lastDate:(id)sender {
    [self.calendarView scrollToLastDay];
}

- (IBAction)today:(id)sender {
    [self.calendarView scrollToToday];
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
        ChangeViewFrameHeight(self.calendarView, 240*ScreenWidth/320.0);
        self.calendarView.viewType = CalendarMonth;
    }else{
        ChangeViewFrameHeight(self.calendarView, (240*ScreenWidth/320.0)/6);
        self.calendarView.viewType = CalendarWeek;
    }
    [self.calendarView loadingInitialDataSelectDay:self.selectDate];
}

#pragma mark - YCCalendarViewDelegate
- (void)YCCalendarView:(YCCalendarView *)calendarView didEndScrollToDate:(NSDate *)date {
    if (calendarView == self.calendarView) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *timeString= [formatter stringFromDate:date];
        self.label.text = timeString;
        self.selectDate = date;
    }
}

- (void)YCCalendarView:(YCCalendarView *)calendarView selectCalendarDate:(NSDate *)date {
    self.selectDate = date;
}
@end
