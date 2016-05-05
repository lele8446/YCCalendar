//
//  ViewController.m
//  YCCalendar
//
//  Created by YiChe on 16/5/3.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "ViewController.h"
#import "YCCalendarView.h"

@interface ViewController ()<YCCalendarViewDelegate>
@property (nonatomic, weak) IBOutlet YCCalendarView *calendarView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@end

@implementation ViewController

- (void)dealloc {
    self.calendarView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _calendarView.delegate = self;
    [_calendarView loadingInitialData:[NSDate date] today:[NSDate date]];
    // Do any additional setup after loading the view, typically from a nib.
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
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM"];
    NSString *timeString= [formatter stringFromDate:date];
    self.label.text = timeString;
}


- (void)YCCalendarViewSelectCalendarDate:(NSDate *)date {
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *timeString= [formatter stringFromDate:date];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择日期" message:timeString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
