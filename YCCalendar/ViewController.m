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

@interface ViewController ()<YCCalendarViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) YCCalendarView *calendarView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIView *topView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) CGFloat headViewHeight;
@property (nonatomic, assign) BOOL headViewExpand;
@end

@implementation ViewController

- (void)dealloc {
    self.calendarView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTopView];
    
    self.headViewHeight = (240*ScreenWidth/320.0)/6 + 4;
    self.headViewExpand = NO;
    
    self.calendarView = [[YCCalendarView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 240*ScreenWidth/320.0)];
    self.calendarView.delegate = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *selectDateStr = @"2016-04-08";
    NSDate *selectDate = [formatter dateFromString:selectDateStr];
    NSDate *date = [formatter dateFromString:@"2016-04-03"];
    
    [self.calendarView loadingInitialData:date selectDay:selectDate];
    [self.calendarView YCCalendarViewNarrowCompletion:^(void){
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    
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
    [self.calendarView scrollToNextMonth];
}

- (IBAction)lastMonth:(id)sender {
    [self.calendarView scrollToLastMonth];
}

- (IBAction)today:(id)sender {
    [self.calendarView scrollToToday];
}

#pragma mark - YCCalendarViewDelegate
- (void)YCCalendarViewdidEndScrollToDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM"];
    NSString *timeString= [formatter stringFromDate:date];
    self.label.text = timeString;
}


- (void)YCCalendarViewSelectCalendarDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *timeString= [formatter stringFromDate:date];
    
//    NSInteger weekDay = [CalendarDataServer dayInWeek:date];
//    NSLog(@"%@ 是星期 %@",timeString,@(weekDay));
//
//    NSDate *nextDate = [CalendarDataServer nextWeek:date];
//    NSString *nextDateStr = [formatter stringFromDate:nextDate];
//    
//    NSDate *lastDate = [CalendarDataServer lastWeek:date];
//    NSString *lastDateStr = [formatter stringFromDate:lastDate];
//    NSLog(@"下星期第一天 %@",nextDateStr);
//    NSLog(@"上星期最后一天 %@",lastDateStr);
//    
//    NSArray *ary = [CalendarDataServer handleWeekDate:date selectDate:[NSDate date]];
//    for (CalendarItemModel *item in ary) {
//        NSString *dateStr = [formatter stringFromDate:item.date];
//        NSLog(@"日期 %@",dateStr);
//    }
    
//    NSLog(@"==============");
//    NSString *DateStr = [formatter stringFromDate:date];
//    NSLog(@"选择的是 %@",DateStr);
//    
//    NSDate *lastDate = [CalendarDataServer lastMonth:date];
//    NSString *lastDateStr = [formatter stringFromDate:lastDate];
//    NSLog(@"上个月最后一天是 %@",lastDateStr);
//    NSDate *lastWeekDate = [CalendarDataServer lastWeek:date];
//    NSString *lastWeekStr = [formatter stringFromDate:lastWeekDate];
//    NSLog(@"上周第一天是 %@",lastWeekStr);
//    
//    NSDate *nextDate = [CalendarDataServer nextMonth:date];
//    NSString *nextDateStr = [formatter stringFromDate:nextDate];
//    NSLog(@"下个月第一天是 %@",nextDateStr);
//    NSDate *nextWeekDate = [CalendarDataServer nextWeek:date];
//    NSString *nextWeekStr = [formatter stringFromDate:nextWeekDate];
//    NSLog(@"下周第一天是 %@",nextWeekStr);
    
    NSLog(@"这是第 %@ 周",@([CalendarDataServer weekOfYear:date]));

    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择日期" message:timeString preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    [alert addAction:cancel];
//    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section
{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(__unused NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.row)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.headViewHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section; {
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(self.calendarView.frame) +4)];
    headView.backgroundColor = [UIColor colorWithRed:0.9373 green:0.9373 blue:0.9373 alpha:1.0];
    [headView addSubview:self.calendarView];
    return headView;
}

static CGFloat kOldOffset = 0;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView.contentOffset.y == 0)
//        if (self.tableView.contentOffset.y <= kOldOffset)
    {//展开
        self.headViewHeight = 240*ScreenWidth/320.0 + 4;
        self.headViewExpand = YES;
        [self.calendarView YCCalendarViewExpandCompletion:^(void){
            [self.tableView reloadData];
        }];
        
    }
    //收起
    if (scrollView.contentOffset.y > kOldOffset && self.headViewExpand) {
        self.headViewHeight = (240*ScreenWidth/320.0)/6 + 4;
        self.headViewExpand = NO;
        [self.calendarView YCCalendarViewNarrowCompletion:^(void){
            [self.tableView reloadData];
        }];
    }
    kOldOffset = scrollView.contentOffset.y;
}
@end
